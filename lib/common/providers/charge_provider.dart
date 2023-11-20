import 'dart:math';

import 'package:charmev/common/models/detail.dart';
import 'package:charmev/common/models/enum.dart';
import 'package:charmev/common/models/station.dart';
import 'package:charmev/common/models/transaction.dart';
import 'package:charmev/common/services/db/transactions.dart';
import 'package:charmev/common/widgets/route.dart';
import 'package:charmev/config/env.dart';
import 'package:charmev/config/navigator.dart';
import 'package:charmev/screens/home.dart';
import 'package:charmev/theme.dart';
import 'package:charmev/common/providers/application_provider.dart';
import 'package:provider/provider.dart' as provider;
import 'package:flutter/widgets.dart';
import 'package:scan/scan.dart';
import 'package:peaq_network_ev_charging_message_format/did_document_format.pb.dart';
import 'package:peaq_network_ev_charging_message_format/did_document_format.pbenum.dart';
import 'package:peaq_network_ev_charging_message_format/p2p_message_format.pb.dart'
    as msg;

class CEVChargeProvider with ChangeNotifier {
  CEVChargeProvider({required this.db});

  final CEVTransactionDB db;

  late CEVApplicationProvider appProvider;

  static CEVChargeProvider of(BuildContext context) {
    return provider.Provider.of<CEVChargeProvider>(context);
  }

  ScanController qrController = ScanController();

  LoadingStatus _status = LoadingStatus.idle;
  LoadingStatus _chargingStatus = LoadingStatus.idle;
  String _statusMessage = '';
  String _providerDid = "";
  int _repeatedSessionCount = 0;
  int _approvalCount = 0;
  int _pendingTransactionCount = 0;
  bool _isFetchAllFromDBRunning = false;
  double _chargeProgress = 0;
  CEVStation _station = CEVStation();
  List<Detail> _transactions = [];
  msg.TransactionValue _refundInfo = msg.TransactionValue();
  msg.TransactionValue _spentInfo = msg.TransactionValue();
  List<Detail> _details = [];
  BigInt _atto = BigInt.parse("1000000000000000000");

  num token = (10 * pow(10, 19));

  String get providerDid => _providerDid;
  CEVStation? get station => _station;
  List<Detail> get details => _details;
  LoadingStatus get status => _status;
  LoadingStatus get chargingStatus => _chargingStatus;
  List<Detail> get transactions => _transactions;
  msg.TransactionValue get refundInfo => _refundInfo;
  msg.TransactionValue get spentInfo => _spentInfo;
  int get repeatedSessionCount => _repeatedSessionCount;
  double get chargeProgress => _chargeProgress;
  String get statusMessage => _statusMessage;
  bool get isFetchAllFromDBRunning => _isFetchAllFromDBRunning;

  set chargeProgress(double progress) {
    _chargeProgress = progress;
    notifyListeners();
  }

  set chargingStatus(LoadingStatus cstatus) {
    _chargingStatus = cstatus;
    notifyListeners();
  }

  set refundInfo(msg.TransactionValue info) {
    _refundInfo = info;
    notifyListeners();
  }

  set spentInfo(msg.TransactionValue info) {
    _spentInfo = info;
    notifyListeners();
  }

  set providerDid(String did) {
    _providerDid = did;
    notifyListeners();
  }

  setStatus(LoadingStatus status, {String message = ""}) {
    _status = status;
    _statusMessage = message;
    notifyListeners();
  }

  reset() {
    _status = LoadingStatus.idle;
    _statusMessage = "";
    notifyListeners();
  }

  /// Process all pending transactions in local db
  Future<void> processPendingTransactionsFromDB() async {
    try {
      _isFetchAllFromDBRunning = true;
      notifyListeners();

      // Spent transactions (Station pending payment) are top priority
      // so we process them first
      List<CEVTransactionDbModel> pendingSpentTransactions =
          await _getPendingTransactionsFromDB(TransactonType.spent);

      if (pendingSpentTransactions.isNotEmpty) {
        _pendingTransactionCount = pendingSpentTransactions.length;
        await _processPendingTransaction(pendingSpentTransactions);
      }

      _isFetchAllFromDBRunning = false;
      notifyListeners();

      CEVNavigator.pushReplacementRoute(CEVFadeRoute(
        builder: (context) => const HomeScreen(),
        duration: const Duration(milliseconds: 600),
      ));

      List<CEVTransactionDbModel> pendingRefundTransactions =
          await _getPendingTransactionsFromDB(TransactonType.refund);

      if (pendingRefundTransactions.isNotEmpty) {
        _processPendingTransaction(pendingRefundTransactions);
      }
    } catch (e) {}
  }

  _processPendingTransaction(List<CEVTransactionDbModel> transactions) async {
    for (var i = 0; i < transactions.length; i++) {
      var tx = transactions[i];
      var txval = msg.TransactionValue.fromJson(tx.data);

      var otherSignatories = [tx.signatory];
      _chargeProgress = tx.progress;

      if (tx.transactionType == TransactonType.spent) {
        // use to count the number of processed approval
        _approvalCount += 1;
        _spentInfo = txval;
        await _approveSpentTransaction(otherSignatories);
      }

      if (tx.transactionType == TransactonType.refund) {
        _refundInfo = txval;
        _approveRefundTransaction(otherSignatories);
      }
    }
    _approvalCount = 0;
    _chargeProgress = 0;
    _chargingStatus = LoadingStatus.idle;
    _status = LoadingStatus.idle;
    notifyListeners();
  }

  // generate provider account details
  generateDetails({bool notify = false}) {
    List<Detail> newDetails = [];

    if (_station != null) {
      newDetails.addAll([
        Detail("Identity", _station.did ?? ""),
        Detail("Plug Type", _station.plugType ?? ""),
        Detail("Status", _station.status ?? "", color: CEVTheme.successColor),
        Detail("Power", _station.power ?? ""),
      ]);
    }

    _details = newDetails;
    if (notify) {
      notifyListeners();
    }
  }

  generateTransactions({bool notify = false}) {
    List<Detail> newtx = [];

    var tokenDecimals = appProvider.accountProvider.account.tokenDecimals;
    var tokenSymbol = appProvider.accountProvider.account.tokenSymbol;
    _atto = BigInt.from(pow(10, num.parse(tokenDecimals.toString())));

    if (_refundInfo.tokenNum.isNotEmpty && _spentInfo.tokenNum.isNotEmpty) {
      var refundRawToken = _refundInfo.tokenNum;
      var spentRawToken = _spentInfo.tokenNum;
      var refundToken = (BigInt.parse(refundRawToken) / _atto);

      var refundTokenString = refundToken.toStringAsFixed(4);
      var spentToken = (BigInt.parse(spentRawToken) / _atto);

      var spentTokenString = spentToken.toStringAsFixed(4);
      var total = (refundToken + spentToken).toStringAsFixed(4);
      newtx.addAll([
        Detail("Pay Station", "$spentTokenString $tokenSymbol"),
        Detail("Refund", "$refundTokenString $tokenSymbol"),
        Detail("Total", "$total $tokenSymbol"),
      ]);
    }

    _transactions = newtx;
    if (notify) {
      notifyListeners();
    }
  }

  /// fetch provider Did  document from chain state storage
  fetchProviderDidDocument(String did) async {
    _repeatedSessionCount = 0;
    reset();
    if (_providerDid == _station.did) {
      generateDetails(notify: true);
      return;
    }

    String separator = ":";

    if (!did.contains(separator)) {
      setStatus(LoadingStatus.error, message: Env.invalidProviderDid);
    }

    setStatus(LoadingStatus.loading, message: Env.fetchingData);

    var address = did.split(":")[2];

    var doc = await appProvider.peerProvider.fetchDidDocument(address);

    if (doc.id.isEmpty) {
      setStatus(LoadingStatus.error, message: Env.providerDidNotFound);
      notifyListeners();
    }

    _station.did = _providerDid;
    _station.address = address;

    for (var i = 0; i < doc.services.length; i++) {
      var service = doc.services[i];
      // Get the station metadata
      if (service.type == ServiceType.metadata) {
        var metadata = service.metadata;
        _station.plugType = metadata.plugType;
        _station.status = metadata.status.toString();
        _station.power = metadata.power;
        break;
      }
    }

    setStatus(LoadingStatus.idle, message: "");

    generateDetails(notify: true);
  }

  generateAndFundMultisigWallet() async {
    setStatus(LoadingStatus.idle);
    String consumer = appProvider.accountProvider.account.address!;
    // String provider = _station.address!;

    String provider = _providerDid.split(":")[2];

    // setStatus(LoadingStatus.loading, message: Env.creatingMultisigWallet);

    bool walletCreated =
        await appProvider.peerProvider.creatMultisigAddress(provider, consumer);

    String multisigAddress = appProvider.peerProvider.multisigAddress;

    if (!walletCreated || multisigAddress.isEmpty) {
      setStatus(LoadingStatus.error, message: Env.creatingMultisigWalletFailed);
      return;
    }

    var seed = appProvider.accountProvider.account.seed!;

    // setStatus(LoadingStatus.loading, message: Env.fundingMultisigWallet);

    var resp = await appProvider.peerProvider
        .transferFund(multisigAddress, "$token", seed);

    if (resp.error!) {
      setStatus(LoadingStatus.error, message: resp.message!);
      return;
    }
  }

  startCharge(String token) async {
    setStatus(LoadingStatus.idle);

    setStatus(LoadingStatus.loading, message: Env.requestingService);

    String consumer = appProvider.accountProvider.account.address!;
    String provider = _station.address!;

    var res = await appProvider.peerProvider
        .sendServiceRequestedEvent(provider, consumer, token);

    if (!res) {
      setStatus(LoadingStatus.loading, message: Env.serviceRequestFailed);
      return;
    }

    setStatus(LoadingStatus.loading, message: Env.serviceRequested);
  }

  stopCharge() async {
    setStatus(LoadingStatus.loading, message: Env.stoppingCharge);

    bool chargeStopEventSent =
        await appProvider.peerProvider.sendStopChargeEvent();

    if (!chargeStopEventSent) {
      setStatus(LoadingStatus.error, message: Env.stoppingChargeFailed);
      return;
    }

    _chargingStatus = LoadingStatus.waiting;

    setStatus(LoadingStatus.loading, message: Env.stoppingChargeSent);
  }

  approveTransactions() async {
    if (_refundInfo.tokenNum.isEmpty || _spentInfo.tokenNum.isEmpty) {
      setStatus(LoadingStatus.error, message: "Empty transactions");
      return;
    }

    var otherSignatories = [_station.address!];

    bool approved = await _approveSpentTransaction(otherSignatories);

    if (!approved) {
      setStatus(LoadingStatus.error,
          message: Env.approvingSpentTransactionFailed);
      return;
    }

    _approveRefundTransaction(otherSignatories);

    // increased the number of times this session has been repeated
    _repeatedSessionCount += 1;
    _chargeProgress = 0;
    _chargingStatus = LoadingStatus.success;
    notifyListeners();

    setStatus(LoadingStatus.idle, message: Env.transactionCompleted);

    appProvider.peerProvider.disconnectP2P();
  }

  Future<bool> _approveSpentTransaction(List<String> otherSignatories) async {
    // setStatus(LoadingStatus.loading);

    var spentTimePoint = _spentInfo.timePoint;

    var seed = appProvider.accountProvider.account.seed ?? "";

    String loadingMsg = Env.approvingSpentTransaction;

    if (_approvalCount > 0 && _pendingTransactionCount > 0) {
      loadingMsg = "$loadingMsg \n\n $_approvalCount/$_pendingTransactionCount";
    }

    setStatus(LoadingStatus.loading, message: loadingMsg);

    // await Future.delayed(const Duration(seconds: 3));

    bool approveSpent = await appProvider.peerProvider
        .approveMultisigTransaction(
            threshold: 2,
            otherSignatories: otherSignatories,
            timepointHeight: spentTimePoint.height.toInt(),
            timepointIndex: spentTimePoint.index.toInt(),
            callHash: _spentInfo.callHash,
            seed: seed);

    if (approveSpent) {
      db.deleteTransaction(_spentInfo.txHash);
    }

    return approveSpent;
  }

  _approveRefundTransaction(List<String> otherSignatories) async {
    var refundTimePoint = _refundInfo.timePoint;
    var seed = appProvider.accountProvider.account.seed ?? "";

    bool approveRefund = await appProvider.peerProvider
        .approveMultisigTransaction(
            threshold: 2,
            otherSignatories: otherSignatories,
            timepointHeight: refundTimePoint.height.toInt(),
            timepointIndex: refundTimePoint.index.toInt(),
            callHash: _refundInfo.callHash,
            seed: seed);

    if (!approveRefund) {
      // setStatus(LoadingStatus.error,
      //     message: Env.approvingRefundTransactionFailed);
      return;
    }

    db.deleteTransaction(_refundInfo.txHash);
  }

  Future<List<CEVTransactionDbModel>> _getPendingTransactionsFromDB(
      TransactonType type) async {
    final List<CEVTransactionDbModel> transactionDbModels =
        await db.getTransactions(type);
    return transactionDbModels;
  }

  Future<bool> hasPendingTransaction() async {
    return db.hasSpentTransaction();
  }
}
