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

pub fn send_event(
    event_type: msg::EventType,
    data: msg::event::Data,
) -> Result<(), Box<dyn Error>> {
    let mut ev = msg::Event::new();
    ev.event_id = event_type.into();

    let data = Some(data);
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

pub fn add_event_to_global(event: msg::EventType) {
    let mut ev = msg::Event::new();
    ev.event_id = event.into();

    let ev_vec = ev.write_to_bytes().expect("Failed to write event to byte");

    unsafe {
        behaviour::EVENTS.lock().unwrap().push_back(ev_vec);
    }
}
