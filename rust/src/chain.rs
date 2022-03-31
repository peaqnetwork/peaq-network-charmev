use codec::{Decode, Encode};
use peaq_p2p_proto_message::did_document_format as doc;
use protobuf::Message;
use sp_core::sr25519;
use std::{error::Error, str::FromStr};
use substrate_api_client::{self as subclient, rpc as subclient_rpc};

use scale_info::TypeInfo;
use serde::Serialize;
use sp_core::RuntimeDebug;

type BlockNumber = u32;
type Moment = u64;

/// Attributes of a DID.
#[derive(
    Serialize,
    PartialEq,
    Eq,
    PartialOrd,
    Ord,
    Clone,
    Encode,
    Decode,
    Default,
    RuntimeDebug,
    TypeInfo,
)]
pub struct Attribute<BlockNumber, Moment> {
    pub name: Vec<u8>,
    pub value: Vec<u8>,
    pub validity: BlockNumber,
    pub created: Moment,
}

// fetch did document from the chain storage
pub fn get_did_document(
    ws_url: String,
    public_key: String,
    storage_name: String,
) -> Result<doc::Document, Box<dyn Error>> {
    let ws_client = subclient_rpc::WsRpcClient::new(&ws_url);
    let api = subclient::Api::<sr25519::Pair, _>::new(ws_client).unwrap();

    // generate public key from string slice
    let pk = sr25519::Public::from_str(&public_key).unwrap();
    let storage_pallet = "PeaqDid".to_string();
    let storage_store = "AttributeStore".to_string();

    let key = generate_storage_key(&pk, storage_pallet, storage_store, storage_name).unwrap();

    // make a request to the chain to fetch document
    // and serialize it to Attribute struct
    let result: Attribute<BlockNumber, Moment> = api
        .get_storage_by_key_hash(key, None)
        .unwrap()
        .or_else(|| Some(Attribute::default()))
        .unwrap();

    let document_byte = hex::decode(&result.value).unwrap();

    let new_doc = doc::Document::parse_from_bytes(&document_byte.as_slice()).unwrap();

    Ok(new_doc)
}

// generate storage key needed to query the chain storage
fn generate_storage_key(
    public_key: &sr25519::Public,
    storage_pallet: String,
    storage_store: String,
    storage_name: String,
) -> Result<subclient::StorageKey, Box<dyn Error>> {
    let attr_key = get_hashed_key_for_attr(&public_key, storage_name.as_bytes());
    // encode the key using blake2b
    // hash the attr_key to bytes using blake2b concat method
    let attr_byte_hash = sp_core::blake2_128(&attr_key)
        .iter()
        .chain(attr_key.iter())
        .cloned()
        .collect::<Vec<_>>();

    // hash the hashed_key_bytes to hex
    let attr_byte_hash_hex = hex::encode(&attr_byte_hash);

    // hash the pallet name
    let pallet_hash = sp_core::twox_128(storage_pallet.as_bytes()).to_vec();
    let pallet_hash_hex = hex::encode(&pallet_hash);

    // hash the storage store name
    let storage_store_hash = sp_core::twox_128(storage_store.as_bytes()).to_vec();
    let storage_store_hash_hex = hex::encode(&storage_store_hash);

    // concatenate pallet_hash_hex storage_store_hash_hex attr_byte_hash_hex
    // to form the raw storage key
    let storage_key_string = format!(
        "{}{}{}",
        pallet_hash_hex, storage_store_hash_hex, attr_byte_hash_hex
    );

    let raw_key = hex::decode(storage_key_string).unwrap();

    Ok(subclient::StorageKey(raw_key))
}

// using the public key and the name attribute to create storage key hash
fn get_hashed_key_for_attr(did_account: &sr25519::Public, name: &[u8]) -> [u8; 32] {
    let mut bytes_in_name: Vec<u8> = name.to_vec();
    let mut bytes_to_hash: Vec<u8> = did_account.encode().as_slice().to_vec();
    bytes_to_hash.append(&mut bytes_in_name);
    sp_core::blake2_256(&bytes_to_hash[..])
}
