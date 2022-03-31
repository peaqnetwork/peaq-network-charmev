// use log::trace;
use peaq_p2p_proto_message::p2p_message_format as msg;
use protobuf::Message;
use std::error::Error;

use crate::p2p::behaviour;

// get a first event from the global EVENTS store
pub fn get_event_from_global() -> Option<Vec<u8>> {
    let mut event: Option<Vec<u8>> = None;

    unsafe {
        if let Some(ev) = behaviour::EVENTS.get_mut().unwrap().front() {
            event = Some(ev.to_vec());
            // remove the element from the slice
            behaviour::EVENTS.get_mut().unwrap().pop_front();
        };
    }

    event
}

pub fn send_identity_challenge_event(plain_data: String) -> Result<(), Box<dyn Error>> {
    let mut ev = msg::Event::new();
    ev.event_id = msg::EventType::IDENTITY_CHALLENGE.into();
    let mut challenge_data = msg::IdentityChallengeData::new();
    challenge_data.plain_data = plain_data;
    let data = Some(msg::event::Data::identity_challenge_data(challenge_data));
    ev.data = data;

    let v = ev.write_to_bytes().expect("Failed to write event");
    // trace!("send_identity_challenge_event ev:: {:?}", &ev);
    // trace!("send_identity_challenge_event ev-v:: {:?}", &v);
    // trace!(
    //     "send_identity_challenge_event ev-parse:: {:?}",
    //     msg::Event::parse_from_bytes(&v)
    // );

    let topic;
    let swarm;

    unsafe {
        swarm = behaviour::EVENT_BEHAVIOUR.get_mut().unwrap();
        topic = behaviour::EVENT_TOPIC.get_mut().unwrap().clone();
    }
    // trace!("send_identity_challenge_event topic:: {:?}", &topic);

    if let Some(top) = topic {
        swarm.behaviour_mut().gossip.publish(top, &*v).unwrap();
    }

    Ok(())
}
