# Peaq Network CharmEV
A decentralized app (DApp) that enable Providers to render a decentralized EV charging service to Consumers.

The Consumer (app user) connects to the provider peer via peer-to-peer connection to order the charge service.

## Requirements
* [Install](https://docs.flutter.dev/get-started/install) `flutter`
* [Download and Install](https://developer.android.com/studio#downloads) `android studio`
* Download and install `android emulator` via android studio
* Install `ffi`

  `dart pub global activate ffigen`
* [Install](https://pub.dev/packages/ffigen#installing-llvm) `LLVM`

## Run

To run app on emulator `flutter run`

## Build

If changes are made to models, run `./build.sh`

To build apk run `flutter build apk --release`

see flutter [documentation](https://docs.flutter.dev/deployment/android#sidenav-6) for more build commands and deployments.

### Note:
iOS intergration coming soon

## License

[Apache 2.0](https://choosealicense.com/licenses/apache-2.0/)