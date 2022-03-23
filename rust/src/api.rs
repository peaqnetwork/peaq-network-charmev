use anyhow::{Ok, Result};

use crate::request;

//
// NOTE: Please look at https://github.com/fzyzcjy/flutter_rust_bridge/blob/master/frb_example/simple/rust/src/api.rs
// to see more types that this code generator can generate.
//

pub fn connect_p2p(url: String) -> Result<()> {
    println!("\n\n WS URL ON RUST {}", url);
    request::connect_p2p(url).unwrap();
    Ok(())
}
