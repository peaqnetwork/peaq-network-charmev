import 'package:charmev/common/services/db/database.dart';
import 'package:charmev/common/services/db/transactions.dart';
import 'package:flutter/material.dart';
import 'package:charmev/common/providers/service_provider.dart';
import 'package:charmev/common/utils/pref_storage.dart';

// / Builds the [CEVServiceProvider] and holds services in its state.
class CEVServiceContainer extends StatefulWidget {
  const CEVServiceContainer({required this.child, Key? key}) : super(key: key);

  final Widget child;

  @override
  CEVServiceContainerState createState() => CEVServiceContainerState();
}

class CEVServiceContainerState extends State<CEVServiceContainer> {
  late CEVSharedPref cevSharedPref;
  late CEVDBService dbService;
  late CEVTransactionDB transactionDB;

  Key key = UniqueKey();

  void restartApp() {
    setState(() {
      key = UniqueKey();
    });
  }

  @override
  void initState() {
    super.initState();

    cevSharedPref = CEVSharedPref();
    dbService = CEVDBService.db;

    transactionDB = CEVTransactionDB(dbService.database);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: key,
      child: CEVServiceProvider(
        data: this,
        child: widget.child,
      ),
    );
  }
}
