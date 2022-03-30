use peaq_p2p_proto_message::p2p_message_format as msg;
use protobuf::Message;
use std::error::Error;

use crate::p2p::behaviour;

pub fn send_identity_challenge_event(plain_data: String) -> Result<(), Box<dyn Error>> {
    let mut ev = msg::Event::new();
    ev.event_id = msg::EventType::IDENTITY_CHALLENGE.into();
    let mut challenge_data = msg::IdentityChallengeData::new();
    challenge_data.plain_data = plain_data;
    let data = Some(msg::event::Data::identity_challenge_data(challenge_data));
    ev.data = data;

    let v = ev.write_to_bytes().expect("Failed to write event");
    println!("ev:: {:?}", &ev);
    println!("ev-v:: {:?}", &v);
    println!("ev-parse:: {:?}", msg::Event::parse_from_bytes(&v));

    let topic;
    let swarm;

    unsafe {
        swarm = behaviour::EVENT_BEHAVIOUR.get_mut().unwrap();
        topic = behaviour::EVENT_TOPIC.clone();
    }

    if let Some(top) = topic {
        swarm.behaviour_mut().gossip.publish(top, &*v).unwrap();
    }

    Ok(())
}
