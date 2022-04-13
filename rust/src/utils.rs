use codec::Compact;
use codec::{Decode, Encode};
// use keyring::sr25519;
use keyring::ed25519;
use keyring::sr25519;
use log::trace;
use sp_core::blake2_256;
use sp_runtime::traits::Verify;
pub use sp_runtime::{
    generic::SignedBlock as SignedBlockG, traits::IdentifyAccount, AccountId32 as AccountId,
    MultiSignature, MultiSigner,
};
use std::str::FromStr;

use peaq_p2p_proto_message::did_document_format as doc;

pub fn generate_random_data() -> String {
    let data = rand::random::<[u8; 32]>();

    let hex_string = hex::encode(data);
    // trace!("\nRANDOM CHALLENG DATA:: {:?}\n", &hex_string);
    hex_string
}

pub fn parse_signatories(address: &str) -> AccountId {
    let to = sr25519::sr25519::Public::from_str(&address).unwrap();
    let to = AccountId::decode(&mut &to.0[..]).unwrap_or_default();
    to
}

pub fn create_multisig_account(signatories: Vec<String>, threshold: u16) -> String {
    // Get the len of the signatories into u8
    let sig_len = &signatories.len().to_le_bytes();
    let sig_len: u8 = sig_len[0];

    let mut who: Vec<Vec<u8>> = signatories
        .iter()
        .map(|si| {
            let to = sr25519::sr25519::Public::from_str(&si).unwrap();
            to.0[..].to_vec()
        })
        .collect();

    let _ = &who.sort();
    let prefix = b"modlpy/utilisuba";
    let threshold = threshold.to_le_bytes();
    // compact encoded length of signatories
    let len = Compact(sig_len).encode();

    let concat_data = [&prefix[..], &len[..], &who.concat(), &threshold[..]].concat();

    let entropy = blake2_256(&concat_data);
    trace!("entropy:: {:?}", &entropy);

    let multi = AccountId::decode(&mut &entropy[..]).unwrap_or_default();

    trace!("MULTI:: {}", &multi);

    multi.to_string()
}

pub fn verify_peer_did_signature(provider_pk: String, signature: doc::Signature) -> bool {
    let vt: doc::VerificationType = signature.field_type.enum_value().unwrap();
    let mut verify = false;

    let peaq_issuer_pk = "74caa527ea78bd3ea6f3c190c25bd92ff306a9ac308eb27a5b2768776a753102";

    match vt {
        doc::VerificationType::Sr25519VerificationKey2020 => {
            let pk = sr25519::sr25519::Public::from_str(provider_pk.as_str()).unwrap();
            let pk_hex = sp_core::hexdisplay::HexDisplay::from(&pk.0).to_string();
            // trace!("\n pk_hex:: {}\n", &pk_hex);
            verify = sr25519_verify(&peaq_issuer_pk, &pk_hex.as_str(), signature.hash);
        }
        doc::VerificationType::Ed25519VerificationKey2020 => {
            let pk = ed25519::ed25519::Public::from_str(provider_pk.as_str()).unwrap();
            let pk_hex = sp_core::hexdisplay::HexDisplay::from(&pk.0).to_string();
            verify = ed25519_verify(&peaq_issuer_pk, &pk_hex.as_str(), signature.hash);
        }
    };

    verify
}

pub fn verify_identity_challenge(
    provider_pk: String,
    plain_data: String,
    signature: doc::Signature,
) -> bool {
    let vt: doc::VerificationType = signature.field_type.enum_value().unwrap();
    let mut verify = false;
    match vt {
        doc::VerificationType::Sr25519VerificationKey2020 => {
            // trace!("\n pk_hex:: {}\n", &plain_data);
            verify = sr25519_verify(&provider_pk.as_str(), &plain_data.as_str(), signature.hash);
        }
        doc::VerificationType::Ed25519VerificationKey2020 => {
            // trace!("\n pk_hex:: {}\n", &plain_data);
            verify = ed25519_verify(&provider_pk, &plain_data.as_str(), signature.hash);
        }
    };

    return verify;
}

fn ed25519_verify(public_key: &str, plain_data: &str, signature: String) -> bool {
    let pk_vec = hex::decode(public_key).expect("Unable to decode public key data");
    let pk_data: [u8; 32] = pk_vec[..].try_into().unwrap();
    let pk = ed25519::ed25519::Public::from_raw(pk_data);
    // trace!("\n ed25519_verify pk:: {:?}\n", &pk);
    // trace!("\n ed25519_verify signature:: {:?}\n", &signature);

    let hd = hex::decode(signature).unwrap();
    let hda: [u8; 64] = hd[..].try_into().unwrap();
    let sig = ed25519::ed25519::Signature::from_raw(hda);
    let data = hex::decode(plain_data).expect("Unable to decode hex data");

    let verify = sig.verify(&*data, &pk);
    // trace!("\n ed25519_verify verify:: {:?}\n", &verify);

    verify
}

fn sr25519_verify(public_key: &str, plain_data: &str, signature: String) -> bool {
    let pk_vec = hex::decode(public_key).expect("Unable to decode public key data");
    let pk_data: [u8; 32] = pk_vec[..].try_into().unwrap();
    let pk = sr25519::sr25519::Public::from_raw(pk_data);

    // trace!("\n sr25519_verify pk:: {:?}\n", &pk);
    // trace!("\n sr25519_verify signature:: {:?}\n", &signature);

    let hd = hex::decode(signature).unwrap();
    let hda: [u8; 64] = hd[..].try_into().unwrap();
    let sig = sr25519::sr25519::Signature::from_raw(hda);

    let data = hex::decode(plain_data).expect("Unable to decode hex data");
    let verify = sig.verify(&*data, &pk);

    // trace!("\n sr25519_verify verify:: {:?}\n", &verify);

    verify
}
