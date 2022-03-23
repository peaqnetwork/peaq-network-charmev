use futures::StreamExt;
use libp2p::{
    core::{
        muxing::StreamMuxerBox,
        upgrade::{self, SelectUpgrade},
    },
    identify::{Identify, IdentifyConfig, IdentifyEvent},
    identity, mplex, noise,
    swarm::{NetworkBehaviourEventProcess, SwarmBuilder, SwarmEvent},
    tcp::TokioTcpConfig,
    yamux, Multiaddr, NetworkBehaviour, PeerId, Transport,
};
use std::error::Error;
use tokio::io::{self, AsyncBufReadExt};

#[tokio::main]
pub async fn connect(peer_url: String) -> Result<(), Box<dyn Error>> {
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

    let mut swarm = {
        let behaviour = EventBehaviour {
            identify: Identify::new(IdentifyConfig::new(
                "/ipfs/id/1.0.0".into(),
                local_key.clone().public(),
            )),
        };

        SwarmBuilder::new(transport, behaviour, local_peer_id)
            .executor(Box::new(|fut| {
                tokio::spawn(fut);
            }))
            .build()
    };

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
#[derive(NetworkBehaviour)]
#[behaviour(event_process = true)]
struct EventBehaviour {
    identify: Identify,
}

impl NetworkBehaviourEventProcess<IdentifyEvent> for EventBehaviour {
    // Called when `identify` produces an event.
    fn inject_event(&mut self, event: IdentifyEvent) {
        println!("identify: {:?}", event);
    }
}
