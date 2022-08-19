.DEFAULT_GOAL := help
PROJECTNAME=peaq_codec_api
RUST_INPUT=src/api.rs
DART_OUTPUT=../lib/common/services/fr_bridge/bridge_generated.dart
PROJECT_NDK_PATH=${HOME}/ndk

.PHONY: help
help: makefile
	@echo
	@echo " Available actions in "$(PROJECTNAME)":"
	@echo
	@sed -n 's/^##//p' $< | column -t -s ':' |  sed -e 's/^/ /'
	@echo

## install: dependencies installation.
install:
	rustup target add aarch64-linux-android armv7-linux-androideabi i686-linux-android x86_64-linux-android
	@if [ $$(uname) == "Darwin" ] ; then cargo install cargo-lipo ; fi
	cargo install cbindgen

## create custom NDk toolchains
## [ARCH]-linux-android-ar was missing in NDK 23.1+
## This was used to create them for each target arch
ndk-copy-ar: 
	cp ${ANDROID_NDK_HOME}/toolchains/llvm/prebuilt/darwin-x86_64/bin/llvm-ar ${ANDROID_NDK_HOME}/toolchains/llvm/prebuilt/darwin-x86_64/bin/aarch64-linux-android-ar
	cp ${ANDROID_NDK_HOME}/toolchains/llvm/prebuilt/darwin-x86_64/bin/llvm-ar ${ANDROID_NDK_HOME}/toolchains/llvm/prebuilt/darwin-x86_64/bin/arm-linux-androideabi-ar
	cp ${ANDROID_NDK_HOME}/toolchains/llvm/prebuilt/darwin-x86_64/bin/llvm-ar ${ANDROID_NDK_HOME}/toolchains/llvm/prebuilt/darwin-x86_64/bin/x86_64-linux-android-ar

## android: for android binaries compilation.
android: ndk-home check-llvm ndk-copy-ar clean bridge
	cargo +nightly ndk --platform 28 -t arm64-v8a -o ../android/app/src/main/jniLibs build -Zbuild-std --release; \
	cargo +nightly ndk --platform 28 -t armeabi-v7a -o ../android/app/src/main/jniLibs build -Zbuild-std --release; \
	cargo +nightly ndk --platform 28 -t x86_64 -o ../android/app/src/main/jniLibs build -Zbuild-std --release;

## android-arch64: for android arch64 binary
## saves time for dev - instead of building three binaries
android-arch64: ndk-home ndk-copy-ar clean bridge
	cargo +nightly ndk --platform 28 -t arm64-v8a -o ../android/app/src/main/jniLibs build -Zbuild-std --release;

## bridge:
bridge:
	flutter_rust_bridge_codegen --rust-input ${RUST_INPUT} --dart-output ${DART_OUTPUT} --llvm-path ${LLVM_PATH}

## ndk-home: check for NDK env settings
ndk-home:
	@if [ ! -d "${ANDROID_NDK_HOME}" ] ; then \
		echo "Error: Please, set the ANDROID_NDK_HOME env variable to point to your NDK folder" ; \
		exit 1 ; \
	fi

check-llvm:
	@if [ ! -d "${LLVM_PATH}" ] ; then \
		echo "Error: Please, set the LLVM_PATH env variable to point to your LLVM folder" ; \
		exit 1 ; \
	fi

## clean: clear compiled binaries
clean:
	cargo clean

## test:
test:
	cargo test