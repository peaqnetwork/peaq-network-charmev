use codec::{Decode, Encode};
use keyring::sr25519::sr25519;
use log::trace;
use peaq_p2p_proto_message::did_document_format as doc;
use protobuf::Message;
use sp_runtime::{AccountId32 as AccountId, MultiAddress};
use std::{error::Error, str::FromStr};
use subclient::Pair;
use substrate_api_client::{self as subclient, rpc as subclient_rpc};

use scale_info::TypeInfo;
use serde::{Deserialize, Serialize};
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

pub struct ApproveMultisigParams {
    pub ws_url: String,
    pub threshold: u16,
    pub max_weight: u64,
    pub other_signatories: Vec<AccountId>,
    pub timepoint: Timepoint<BlockNumber>,
    pub call_hash: String,
    pub seed: String,
}

pub enum ChainError {
    Error(String),
    None,
}

#[derive(Serialize, Deserialize, Debug)]
pub struct Account {
    pub address: String,
    pub sk: String,
    pub balance: String,
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
    let pub_key = pair.public().to_string();

    let mut account = Account {
        address: pub_key,
        sk: hex::encode(seed),
        balance: "0".to_string(),
    };

    let client = subclient_rpc::WsRpcClient::new(&ws_url);
    let api_res = subclient::Api::new(client).map(|api| api.set_signer(pair.clone()));

    match api_res {
        Ok(api) => {
            let id = AccountId::decode(&mut &pair.public().0[..]).unwrap_or_default();

            let account_info = api.get_account_data(&id);
            match account_info {
                Ok(info) => {
                    if let Some(acc) = info {
                        account.balance = acc.free.to_string();
                    }
                }
                _ => (),
            }
        }
        _ => (),
    }

    Some(AccountResult::Success(account))
}

pub fn approve_multisig(params: ApproveMultisigParams) -> Option<ChainError> {
    // initialize api and set the signer (sender) that is used to sign the extrinsics
    let from = sr25519::Pair::from_string(&params.seed, None).unwrap();
    let client = subclient_rpc::WsRpcClient::new(&params.ws_url);
    let api = subclient::Api::new(client)
        .map(|api| api.set_signer(from.clone()))
        .unwrap();

    let call_hash = params.call_hash.strip_prefix("0x").unwrap();
    let call_hash_data = hex::decode(call_hash).unwrap();
    let call_hash: [u8; 32] = call_hash_data[..].try_into().unwrap();

    let threshold = params.threshold;
    let other_signatories = params.other_signatories;
    let maybe_timepoint = Some(params.timepoint);
    let max_weight: u64 = 1000000000;
    // trace!("\n Composed Call: {:?}\n", multi_param);

    // compose the extrinsic with all the element
    #[allow(clippy::redundant_clone)]
    let xt: subclient::UncheckedExtrinsicV4<_> = subclient::compose_extrinsic!(
        api,
        "MultiSig",
        "approve_as_multi",
        threshold,
        other_signatories,
        maybe_timepoint,
        call_hash,
        max_weight
    );

    // trace!("\n Composed Extrinsic: {:?}\n", xt);

    let xt_hash = xt.hex_encode(); //.strip_prefix("0x").unwrap().to_string();

    // trace!("\n Composed Extrinsic: {:?}\n", &xt_hash,);

    // send and watch extrinsic until InBlock
    let res = api.send_extrinsic(xt_hash.clone(), subclient::XtStatus::Finalized);

    match res {
        Ok(hash) => {
            if let Some(tx_hash) = hash {
                trace!("Multisig Transaction got included. Hash: {:?}", tx_hash);
                return Some(ChainError::None);
            }
            return Some(ChainError::Error("Transaction Approval Failed".to_string()));
        }
        Err(e) => {
            trace!("Multisig Transaction failed: Err: {:?}", e.to_string());

            return Some(ChainError::Error("Transaction Approval Failed".to_string()));
        }
    }
}

pub fn transfer(
    ws_url: String,
    address: String,
    amount: subclient::Balance,
    seed: String,
) -> Option<ChainError> {
    // initialize api and set the signer (sender) that is used to sign the extrinsics
    let from = sr25519::Pair::from_string(&seed, None).unwrap();
    let client = subclient_rpc::WsRpcClient::new(&ws_url);
    let api = subclient::Api::new(client)
        .map(|api| api.set_signer(from.clone()))
        .unwrap();

    let to = sr25519::Public::from_str(&address.as_str()).unwrap();
    let to = AccountId::decode(&mut &to.0[..]).unwrap_or_default();
    let from_account = AccountId::decode(&mut &from.public().0[..]).unwrap_or_default();

    let mut former_balance: subclient::Balance = 0;

    if let Some(account) = api.get_account_data(&to).unwrap() {
        former_balance = account.free;
    }

    match api.get_account_data(&from_account).unwrap() {
        Some(account) => {
            if account.free < amount {
                return Some(ChainError::Error("Insufficient Funds".to_string()));
            }
        }
        None => {
            return Some(ChainError::Error(
                "Can't fetch account data from chain".to_string(),
            ));
        }
    }
    // generate extrinsic
    let xt = api.balance_transfer(MultiAddress::Id(to.clone()), amount);

    // send and watch extrinsic until finalized
    api.send_extrinsic(xt.hex_encode(), subclient::XtStatus::InBlock)
        .unwrap();

    // verify that Account's free Balance increased
    let account = api.get_account_data(&to).unwrap().unwrap();

    if account.free < former_balance {
        return Some(ChainError::Error("Transfer failed".to_string()));
    }

    return Some(ChainError::None);
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
