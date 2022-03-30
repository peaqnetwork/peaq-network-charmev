use anyhow::{Ok, Result};

use crate::request;

//
// NOTE: Please look at https://github.com/fzyzcjy/flutter_rust_bridge/blob/master/frb_example/simple/rust/src/api.rs
// to see more types that this code generator can generate.
//

// Connect and subscribe to a p2p peer connection
pub fn connect_p2p(url: String) -> Result<()> {
    println!("\n\n P2P URL ON RUST {}", url);
    request::connect_p2p(url).unwrap();
    Ok(())
}

// Send Identity Challenge event to provider peer
pub fn send_identity_challenge_event() -> Result<Vec<u8>> {
    let res = request::send_identity_challenge_event().unwrap();
    Ok(res)
}

// get peer provider event
pub fn get_event() -> Result<Vec<u8>> {
    let res = request::get_event().unwrap();
    Ok(res)
}

// Fetch DiD Document from chain
pub fn fetch_did_document(
    ws_url: String,
    public_key: String,
    storage_name: String,
) -> Result<Vec<u8>> {
    let res = request::fetch_did_document(ws_url, public_key, storage_name).unwrap();
    Ok(res)
}
