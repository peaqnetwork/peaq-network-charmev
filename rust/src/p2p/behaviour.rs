use futures::StreamExt;
use libp2p::{
    core::{
        muxing::StreamMuxerBox,
        upgrade::{self, SelectUpgrade},
    },
    gossipsub::{
        Gossipsub, GossipsubConfigBuilder, GossipsubEvent, IdentTopic as Topic,
        MessageAuthenticity, ValidationMode,
    },
    identity, mplex, noise,
    swarm::{NetworkBehaviourEventProcess, Swarm, SwarmBuilder, SwarmEvent},
    tcp::TokioTcpConfig,
    yamux, Multiaddr, NetworkBehaviour, PeerId, Transport,
};
use peaq_p2p_proto_message::p2p_message_format as msg;
use protobuf::Message;
use std::{collections::VecDeque, error::Error, time::Duration};

use once_cell::sync::Lazy;
use std::sync::Mutex;

// static mut EVENT_BEHAVIOUR: Option<&Gossipsub> = None;
// Static GLOBAL variable of TOPIC so other event publishing function can use it
// outside of this scope
pub(crate) static mut EVENT_TOPIC: Lazy<Mutex<Option<Topic>>> = Lazy::new(|| Mutex::new(None));

// Static GLOBAL variable of Events that holds all the events received from peer provider
// for the frontend side to fetch from
// Stores event received from peer
// Frontend make a request to fetch from these events
pub(crate) static mut EVENTS: Lazy<Mutex<VecDeque<Vec<u8>>>> =
    Lazy::new(|| Mutex::new(VecDeque::new()));

// Static GLOBAL variable of SWARM so other event publishing function can use it
// outside of this scope
pub(crate) static mut EVENT_BEHAVIOUR: Lazy<Mutex<Swarm<EventBehaviour>>> = Lazy::new(|| {
    let gossipsub_config = GossipsubConfigBuilder::default()
        .heartbeat_interval(Duration::from_secs(10)) // This is set to aid debugging by not cluttering the log space
        .validation_mode(ValidationMode::Strict) // This sets the kind of message validation. The default is Strict (enforce message signing)
        // .message_id_fn(message_id_fn) // content-address messages. No two messages of the
        // same content will be propagated.
        .build()
        .expect("Valid config");
    let local_key = identity::Keypair::generate_ed25519();
    let topic = Topic::new("charmev");

    // save topic to global variable
    unsafe {
        *EVENT_TOPIC.lock().unwrap() = Some(topic.clone());
    }

    let mut gossipsub = Gossipsub::new(
        MessageAuthenticity::Signed(local_key.clone()),
        gossipsub_config,
    )
    .expect("Correct configuration");

    // Create a random PeerId
    let local_key = identity::Keypair::generate_ed25519();
    let local_peer_id = PeerId::from(local_key.public());
    println!("Local peer id: {:?}", local_peer_id);

    // Create a keypair for authenticated encryption of the transport.
    let noise_keys = noise::Keypair::<noise::X25519Spec>::new()
        .into_authentic(&local_key)
        .expect("Signing libp2p-noise static DH keypair failed.");

    // Create a tokio-based TCP transport use noise for authenticated
    // encryption and Mplex for multiplexing of substreams on a TCP stream.
    let m_plex = mplex::MplexConfig::new();
    let noisee = noise::NoiseConfig::xx(noise_keys).into_authenticated();

    // Set up an encrypted TCP Transport over the Mplex and Yamux protocols
    // let transport = libp2p::development_transport(local_key.clone()).await?;
    let transport = TokioTcpConfig::new()
        .nodelay(true)
        .upgrade(upgrade::Version::V1)
        .authenticate(noisee)
        .multiplex(SelectUpgrade::new(yamux::YamuxConfig::default(), m_plex))
        .map(|(peer, muxer), _| (peer, StreamMuxerBox::new(muxer)))
        .boxed();

    let swarm = {
        // subscribes to our topic
        gossipsub.subscribe(&topic).unwrap();

        // build a gossipsub network behaviour
        // let mut gossipsub: Gossipsub =
        let behaviour = EventBehaviour { gossip: gossipsub };
        // subscribes to the topic

        SwarmBuilder::new(transport, behaviour, local_peer_id)
            .executor(Box::new(|fut| {
                tokio::spawn(fut);
            }))
            .build()
    };
    Mutex::new(swarm)
});

#[tokio::main]
pub async fn connect(peer_url: String) -> Result<(), Box<dyn Error>> {
    let swarm;
    unsafe {
        swarm = EVENT_BEHAVIOUR.get_mut().unwrap();
    }
    // Listen on all interfaces and whatever port the OS assigns
    swarm
        .listen_on("/ip4/0.0.0.0/tcp/0".parse().unwrap())
        .unwrap();

    // Dial another peer address if supplied
    if let Some(to_dial) = Some(peer_url) {
        let address: Multiaddr = to_dial.parse().expect("User to provide valid address.");
        match swarm.dial(address.clone()) {
            Ok(_) => println!("Dialed {:?}", address),
            Err(e) => println!("Dial {:?} failed: {:?}", address, e),
        };
    }

    // Read full lines from stdin
    loop {
        tokio::select! {

                // listening to swarm events
                event = swarm.select_next_some() => match event {
                    SwarmEvent::NewListenAddr { address, .. } => {
                        println!("Listening on {:?}", address);
                    }
                    _ => {}
                }

        }
    }
}

// We create a custom network behaviour.
// The derive generates a delegating `NetworkBehaviour` impl which in turn
// requires the implementations of `NetworkBehaviourEventProcess` for
// the events of each behaviour.
#[derive(NetworkBehaviour, Debug)]
#[behaviour(event_process = true)]
pub(crate) struct EventBehaviour {
    pub gossip: Gossipsub,
}

impl NetworkBehaviourEventProcess<GossipsubEvent> for EventBehaviour {
    // Called when `gossip` produces an event.
    fn inject_event(&mut self, event: GossipsubEvent) {
        println!("MSG: {:?}", event);
        match event {
            GossipsubEvent::Subscribed { peer_id, topic } => {
                println!("Subscribed:: peer: {} topic/channel: {}", peer_id, topic)
            }
            GossipsubEvent::Message {
                propagation_source: peer_id,
                message_id: id,
                message,
            } => {
                let ev = msg::Event::parse_from_bytes(&message.data).unwrap();

                println!("\nev-parse:: {:?}\n", &ev);
                println!(
                    "Got message: {} with id: {} from peer: {:?}",
                    String::from_utf8_lossy(&message.data),
                    id,
                    peer_id
                );
                // Add the event slice to the global EVENT variable
                unsafe {
                    EVENTS.lock().unwrap().push_back(message.data);
                }
            }
            _ => (),
        }
    }
}
