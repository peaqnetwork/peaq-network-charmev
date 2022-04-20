use android_logger::Config;
use anyhow::{Ok, Result};
use log::{trace, Level};

use crate::request;

//
// NOTE: Please look at https://github.com/fzyzcjy/flutter_rust_bridge/blob/master/frb_example/simple/rust/src/api.rs
// to see more types that this code generator can generate.
//

pub fn init_logger() -> Result<()> {
    android_logger::init_once(Config::default().with_min_level(Level::Trace));
    trace!("\n\n INIT LOGGER ON RUST");
    Ok(())
}

// Connect and subscribe to a p2p peer connection
pub fn connect_p2p(url: String) -> Result<()> {
    trace!("\n\n P2P URL ON RUST {}", url);
    request::connect_p2p(url).unwrap();
    Ok(())
}

// unsubscribe and disconnect from a p2p peer connection
pub fn disconnect_p2p(peer_id: String) -> Result<()> {
    trace!("\n\n P2P PEEER ID ON RUST {}", peer_id);
    request::disconnect_p2p(peer_id).unwrap();
    Ok(())
}

// Send Identity Challenge event to provider peer
pub fn send_identity_challenge_event() -> Result<Vec<u8>> {
    let res = request::send_identity_challenge_event().unwrap();
    Ok(res)
}

// Send Stop charge event to provider peer
pub fn send_stop_charge_event() -> Result<Vec<u8>> {
    let res = request::send_stop_charge_event().unwrap();
    Ok(res)
}

// Send Service Requested event to provider peer
pub fn send_service_requested_event(
    provider: String,
    consumer: String,
    token_deposited: String,
) -> Result<Vec<u8>> {
    let res = request::send_service_requested_event(provider, consumer, token_deposited).unwrap();
    Ok(res)
}

pub fn generate_account(ws_url: String, secret_phrase: String) -> Result<Vec<u8>> {
    let res = request::generate_account(ws_url, secret_phrase).unwrap();
    Ok(res)
}

// Creates a multi signature wallet address
pub fn create_multisig_address(signatories: Vec<String>, threshold: u16) -> Result<Vec<u8>> {
    let res = request::create_multisig_wallet(signatories, threshold).unwrap();
    Ok(res)
}

// approve a multi signature transaction
pub fn approve_multisig(
    ws_url: String,
    threshold: u16,
    other_signatories: Vec<String>,
    timepoint_height: u32,
    timepoint_index: u32,
    call_hash: String,
    seed: String,
) -> Result<Vec<u8>> {
    let res = request::approve_multisig(
        ws_url,
        threshold,
        other_signatories,
        timepoint_height,
        timepoint_index,
        call_hash,
        seed,
    )
    .unwrap();
    Ok(res)
}

// Transfer fund to a wallet address
pub fn transfer_fund(
    ws_url: String,
    address: String,
    amount: String,
    seed: String,
) -> Result<Vec<u8>> {
    let res = request::transfer_fund(ws_url, address, amount, seed).unwrap();
    Ok(res)
}

// get peer provider event
pub fn get_event() -> Result<Vec<u8>> {
    let res = request::get_event().unwrap();
    Ok(res)
}

// verify provider did doc signature hash
pub fn verify_peer_did_document(provider_pk: String, signature: Vec<u8>) -> Result<Vec<u8>> {
    let res = request::verify_peer_did_document(provider_pk, signature).unwrap();
    Ok(res)
}

// verify provider did doc signature hash
pub fn verify_peer_identity(
    provider_pk: String,
    plain_data: String,
    signature: Vec<u8>,
) -> Result<Vec<u8>> {
    let res = request::verify_peer_challenge_data(provider_pk, plain_data, signature).unwrap();
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
