use codec::{Decode, Encode};
use keyring::sr25519::sr25519;
use peaq_p2p_proto_message::did_document_format as doc;
use protobuf::Message;
use serde_json::json;
use sp_runtime::AccountId32 as AccountId;
use std::{error::Error, str::FromStr};
use subclient::{Pair, RpcClient};
use substrate_api_client::{self as subclient, rpc as subclient_rpc};

use scale_info::TypeInfo;
use serde::{Deserialize, Serialize};
use sp_core::RuntimeDebug;

use crate::utils;

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
pub struct Timepoint<BlockNumber> {
    pub(crate) height: BlockNumber,
    pub(crate) index: u32,
}

#[derive(Serialize, Deserialize, Debug)]
pub struct Account {
    pub seed: String,
    pub did: String,
    pub pub_key: String,
    pub address: String,
    pub balance: f64,
    pub token_symbol: String,
    pub token_decimals: String,
}

#[derive(Serialize, Deserialize, Debug)]
struct NodeProps {
    tokenDecimals: u128,
    tokenSymbol: String,
}

pub enum AccountResult {
    Error(String),
    Success(Account),
}

pub fn generate_account(ws_url: &str, secret_phrase: &str) -> Option<AccountResult> {
    let split_words: Vec<String> = secret_phrase
        .split(" ")
        .into_iter()
        .map(|w| w.to_string())
        .collect();

    if split_words.len() != 12 {
        return Some(AccountResult::Error(
            "Invalid secret phrase: must be 12 words".to_string(),
        ));
    }

    let (pair, seed) = sr25519::Pair::from_phrase(&secret_phrase, None).unwrap();
    let address = pair.public().to_string();
    let pub_key = hex::encode(pair.public().0);

    let mut account = Account {
        did: format!("did:peaq:{}", address),
        pub_key,
        address,
        seed: hex::encode(seed),
        balance: 0.0,
        token_decimals: "18".to_string(),
        token_symbol: "PEAQ".to_string(),
    };

    let client = subclient_rpc::WsRpcClient::new(&ws_url);
    let api_res = subclient::Api::new(client.clone()).map(|api| api.set_signer(pair.clone()));

    // fetch system properties
    let req = json!({
        "method": "system_properties",
        "params": [],
        "jsonrpc": "2.0",
        "id": "4",
    });

    let res = client.clone().get_request(req).unwrap();
    let props: NodeProps = serde_json::from_str(&res.as_str()).unwrap();

    account.token_decimals = props.tokenDecimals.to_string();
    account.token_symbol = props.tokenSymbol.to_string();

    match api_res {
        Ok(api) => {
            let id = AccountId::decode(&mut &pair.public().0[..]).unwrap();
            account.balance = get_balance(api.clone(), id, props.tokenDecimals)
        }
        _ => (),
    }

    Some(AccountResult::Success(account))
}

pub fn get_account_balance(ws_url: String, token_decimals: u128, seed: String) -> f64 {
    // initialize api and set the signer (sender) that is used to sign the extrinsics
    let pair: sr25519::Pair = utils::generate_pair(&seed.as_str());

    let client = subclient_rpc::WsRpcClient::new(&ws_url);
    let api = subclient::Api::new(client)
        .map(|api| api.set_signer(pair.clone()))
        .unwrap();

    let id = AccountId::decode(&mut &pair.public().0[..]).unwrap();
    get_balance(api.clone(), id, token_decimals)
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

fn get_balance<TPair>(
    api: subclient::Api<TPair, subclient_rpc::WsRpcClient>,
    account_id: AccountId,
    token_decimals: u128,
) -> f64
where
    TPair: Pair,
{
    let mut balance = 0.0;
    let account_info = api.get_account_data(&account_id);
    match account_info {
        Ok(info) => {
            if let Some(acc) = info {
                let pow = u128::pow(10, token_decimals.try_into().unwrap());
                if acc.free > 0 {
                    let bal = acc.free as f64 / pow as f64;
                    balance = (bal * 10000.0).floor() / 10000.0; // used 1000 for 4 decimal place 10^4
                }
            }
        }
        _ => (),
    }

    balance
}
