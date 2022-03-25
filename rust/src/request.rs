use anyhow::*;
use log::{trace, Level};

use android_logger::Config;
use protobuf::Message;
use serde::{Deserialize, Serialize};

use crate::{behaviour, chain};

#[derive(Serialize, Deserialize, Debug)]
pub struct ResponseData {
    error: bool,
    message: String,
    data: Vec<u8>,
}

pub fn connect_p2p(url: String) -> Result<()> {
    android_logger::init_once(Config::default().with_min_level(Level::Trace));
    trace!("\n\n connect_p2p RUST hitts:: WS URL = {}", url);

    behaviour::connect(url).expect("p2p connection failed");

    Ok(())
}

pub fn fetch_did_document(
    ws_url: String,
    public_key: String,
    storage_name: String,
) -> Result<Vec<u8>> {
    android_logger::init_once(Config::default().with_min_level(Level::Trace));
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
