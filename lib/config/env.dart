class Env {
  Env._();

  static const String importString = 'Import';
  static const String startCharging = 'Start Charging Session';
  static const String stopCharging = 'Stop Charging Session';
  static const String scanProviderDID = "Scan Provider DID";
  static const String scanQRCode = "Scan QR Code";
  static const String authorizePayment = "Authorize Payment";
  static const String logout = "Logout";
  static const String account = "Account";
  static const String editAccount = "Edit Account";
  static const String pk = "pk";
  static const String sk = "sk";
  static const String address = "address";
  static const String did = "did";
  static const String accountPrefKey = "_account_";
  static const String nodePrefKey = "_nodes_";
  static const String appName = "CharmEv";
  static const String eventExplorer = "Event Explorer";
  static const String fetchingData = "Fetching Provider DID Details...";
  static const String invalidProviderDid = "Invalid Provider DID";
  static const String providerDidNotFound = "Provider DID Details not Found";
  static const String storageKeyGenError = "Storage key creation failed";
  static const String requestingService = "Requesting service from station...";
  static const String serviceRequestFailed =
      "Service request failed. Please try again...";
  static const String serviceRequested =
      "Service requested. Waiting for station response...";
  static const String stoppingCharge = "Stopping charging session...";
  static const String creatingTransaction = "Creating transactions...";
  static const String approvingTransaction = "Approving transactions...";
  static const String creatingMultisigWallet = "Creating Multisig wallet...";
  static const String creatingMultisigWalletFailed =
      "Multisig wallet creation failed";
  static const String fundingMultisigWallet = "Funding Multisig wallet...";
  static const String fundingMultisigWalletFailed =
      "Multisig wallet funding failed";
  static const String serviceDeliveredEvent = "ServiceDelivered";
  // static const String peaqTestnet = "wss://fn1.test.peaq.network";
  static const String peaqTestnet = "wss://af6f-197-210-45-228.ngrok.io";
  // static const String scaleCodecBaseURL = "https://codec.test.peaq.network";
  static const String scaleCodecBaseURL =
      "https://7f60-197-210-45-228.ngrok.io";
  static const String eventURL = "/events";
  static const String storageURL = "/storage";
  static const String multisigURL = "/multisig";
  static const String transferURL = "/transfer";
  static const String transactionURL = "/transaction";
}
