import 'dart:async';
import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:charmev/common/services/db/constant.dart';

const String transactionTable = DbConstant.transactionTable;
const String idColumn = DbConstant.id;
const String dataColumn = DbConstant.data;
const String dateColumn = DbConstant.date;
const String progressColumn = DbConstant.progress;
const String transactionTypeColumn = DbConstant.transactionType;
const String signatoryColumn = DbConstant.signatory;

class CEVDBService {
  CEVDBService._();
  static final CEVDBService db = CEVDBService._();

  static late Database _database;
  static bool _isOpen = false;

  Future<Database> get database async {
    if (_isOpen) {
      return _database;
    }

    // if _database is null we initialize it
    _database = await initDB();
    _isOpen = true;
    return _database;
  }

  Future<Database> initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String dbPath = path.join(documentsDirectory.path, "CharmevDB.db");
    Database odb = await openDatabase(dbPath, version: 1, onOpen: (db) {},
        onCreate: (Database db, int version) async {
      Batch batch = db.batch();
      _createTableTransactionsV1(batch);
      batch.commit();
    }, onDowngrade: onDatabaseDowngradeDelete);
    return odb;
  }

  /// create transactions table first version
  _createTableTransactionsV1(Batch batch) {
    batch.execute("DROP TABLE IF EXISTS $transactionTable");
    batch.execute('''CREATE TABLE $transactionTable ( 
      $idColumn TEXT, $progressColumn REAL, $transactionTypeColumn TEXT, $signatoryColumn TEXT, $dataColumn TEXT, $dateColumn INTEGER)''');
  }
}
