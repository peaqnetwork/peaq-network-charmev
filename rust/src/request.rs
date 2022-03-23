use anyhow::*;
use log::{trace, Level};

use android_logger::Config;

use crate::behaviour;

pub fn connect_p2p(url: String) -> Result<()> {
    android_logger::init_once(Config::default().with_min_level(Level::Trace));
    trace!("\n\n connect_p2p RUST hitts:: WS URL = {}", url);

    behaviour::connect(url).expect("p2p connection failed");

    Ok(())
}
