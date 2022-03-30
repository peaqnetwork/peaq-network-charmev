use anyhow::*;
use log::trace;

use core::result::Result::Ok as CoreOk;
use peaq_p2p_proto_message::did_document_format as doc;
use protobuf::Message;
use serde::{Deserialize, Serialize};

use crate::{
    chain,
    p2p::{behaviour, event},
    utils,
};

#[derive(Serialize, Deserialize, Debug)]
pub struct ResponseData {
    error: bool,
    message: String,
    data: Vec<u8>,
}

pub fn connect_p2p(url: String) -> Result<()> {
    trace!("\n\n connect_p2p RUST hitts:: p2p URL = {}", url);

    behaviour::connect(url).expect("p2p connection failed");

    Ok(())
}

// get events from the the global variable
pub fn get_event() -> Result<Vec<u8>> {
    trace!("\n\n RUST - get_event  hitts");

    let mut res = ResponseData {
        error: true,
        message: "Event Not Found".to_string(),
        data: vec![],
    };

    if let Some(ev) = event::get_event_from_global() {
        res.error = false;
        res.message = "Event Found".to_string();
        res.data = ev;
    };

    let res_data = serde_json::to_vec(&res).expect("Failed to write result data to byte");
    Ok(res_data)
}

pub fn send_identity_challenge_event() -> Result<Vec<u8>> {
    trace!("\n\n RUST - send_identity_challenge_event hitts");

    let random_data = utils::generate_random_data();

    let ev_res = event::send_identity_challenge_event(random_data.clone());

    let mut res = ResponseData {
        error: false,
        message: "Event Sent".to_string(),
        data: vec![],
    };

    match ev_res {
        CoreOk(()) => {
            // return the random data if event is sent succesfully
            res.data = random_data.as_bytes().to_vec();
            let res_data = serde_json::to_vec(&res).expect("Failed to write result data to byte");
            Ok(res_data)
        }
        Err(_) => {
            // return the random data if event is sent succesfully
            res.error = true;
            res.message = "Error Occurred While sending event".to_string();
            let res_data = serde_json::to_vec(&res).expect("Failed to write result data to byte");
            Ok(res_data)
        }
    }
}

// Verify that the signed hash on the signature == provider_pk
pub fn verify_peer_did_document(provider_pk: String, signature: Vec<u8>) -> Result<Vec<u8>> {
    let mut res = ResponseData {
        error: true,
        message: "Verification Failed".to_string(),
        data: vec![],
    };

    let sig =
        doc::Signature::parse_from_bytes(&signature).expect("Failed to parse did doc signature");

    trace!("\n verify_peer_did_document signature {} \n", &sig);
    let verify = utils::verify_peer_did_signature(provider_pk, sig);

    if verify {
        res.error = false;
        res.message = "success".to_string();
    }

    let res_data = serde_json::to_vec(&res).expect("Failed to write result data to byte");
    Ok(res_data)
}

// Verify that the signed hash of the identity reponse == GENERRATED RANDOM_DATA
pub fn verify_peer_challenge_data(
    provider_pk: String,
    plain_data: String,
    challenge_data: Vec<u8>,
) -> Result<Vec<u8>> {
    let mut res = ResponseData {
        error: true,
        message: "Verification Failed".to_string(),
        data: vec![],
    };

    let sig = doc::Signature::parse_from_bytes(&challenge_data)
        .expect("Failed to parse  identity challenge data");
   
    // trace!("\n verify_peer_challenge_data signature {:?} \n", &sig);
    let verify = utils::verify_identity_challenge(provider_pk, plain_data, sig);

    if verify {
        res.error = false;
        res.message = "success".to_string();
    }

    let res_data = serde_json::to_vec(&res).expect("Failed to write result data to byte");
    Ok(res_data)
}

pub fn fetch_did_document(
    ws_url: String,
    public_key: String,
    storage_name: String,
) -> Result<Vec<u8>> {
    trace!("\n\n fetch_did_document RUST hitts:: WS URL = {}", ws_url);

    let doc = chain::get_did_document(ws_url, public_key, storage_name)
        .expect("fetching did document failed");

    trace!("\n New Doc:: {:?}\n", doc);

    let doc_byte = doc
        .write_to_bytes()
        .expect("Failed to write document to byte");

    let res = ResponseData {
        error: false,
        message: "".to_string(),
        data: doc_byte,
    };

    let res_data = serde_json::to_vec(&res).expect("Failed to write result data to byte");

    Ok(res_data)
}
