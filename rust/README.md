
# Peaq Network CharmEV Rust API Library

#### Introduction
This library handles the core api features of:
* interacting with the node
* connecting to provider peer
* managing and sending p2p events to the app business logic
* generating consumer keys during onboarding
* fetching and parsing DID Document.

This library is currently compiled into android `.so` library files and imported into flutter using the `ffi` library.

#### Requirements
* Install `cargo-ndk`

  `cargo install cargo-ndk`

* Install `flutter-rust-bridge-codegen` ([installation instructions](http://cjycode.com/flutter_rust_bridge/tutorial_with_flutter.html) also check [troubleshoot](http://cjycode.com/flutter_rust_bridge/troubleshooting.html))
  
  `cargo install -f flutter_rust_bridge_codegen`
* Install `cbindgen`
  
  `cargo install cbindgen`

* [Download](https://developer.android.com/studio#downloads) `android SDK` 
* Export `ANDROID_SDK_HOME` path 
  
  `export ANDROID_SDK_HOME=/[PATH]/Android/sdk`


* [Download](https://developer.android.com/ndk/downloads/) `android NDK > v23` 
* Export `ANDROID_NDK_HOME` path 
  
  `export ANDROID_NDK_HOME=/[PATH]/Android/sdk/ndk/23.1.7779620`

* Export `OPENSSL_DIR` path 
  
  `export OPENSSL_DIR=/usr/local/homebrew/opt/openssl@1.1/`
* Export `OPENSSL_INCLUDE_DIR` path
  
  `OPENSSL_INCLUDE_DIR=/usr/local/homebrew/opt/openssl@1.1/include/`

#### Build Library
A `MakeFile` has been added to simpilify the process. If all requirements above have been completed, use the following `make` command to build the library:

`make install` 

installs some of the required `rust target` missing depenedecies.

`make ndk-copy-ar` 

Create custom NDk toolchains. [ARCH]-linux-android-ar was missing in NDK 23.1+ . This command create them for each target arch.

`make bridge`

Runs the `flutter-rust-code-gen` command: It generates the equivalent flutter/dart api code use to interact with the compiled library.

`make ndk-home`

Checks if the `ANDROID_NDK_HOME` path has been exported.

`make clean`

Runs `cargo clean` command.

`make test`

Runs `cargo test` command.

`make android`

Runs the `ndk-home` `ndk-copy-ar` `clean` `bridge` and compiled the library into android `arm64-v8a`, `armeabi-v7a` and `x86_64` archs.

`make android-arch64`

Runs the `ndk-home` `ndk-copy-ar` `clean` `bridge` and compiled the library into android `arm64-v8a` arch.
This is used for testing purpose to save dev time; instead of compiling all three archs.

Each compiled `.os` library files are saved in their respective arch dir inside the JNI Libs dir `/android/app/src/main/jniLibs`. The flutter code import the library from these dirs.


### Note:
iOS intergration coming soon

## License

[Apache 2.0](https://choosealicense.com/licenses/apache-2.0/)
