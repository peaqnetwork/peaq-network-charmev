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

class DBService {
  DBService._();
  static final DBService db = DBService._();

  static late Database _database;

  Future<Database> get database async {
    if (_database != null) return _database;

    // if _database is null we initialize it
    _database = await initDB();
    return _database;
  }

  initDB() async {
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

  /// create conpetition table first version
  _createTableTransactionsV1(Batch batch) {
    batch.execute("DROP TABLE IF EXISTS $transactionTable");
    batch.execute('''CREATE TABLE $transactionTable ( 
      $idColumn TEXT, $dataColumn TEXT, $dateColumn INTEGER)''');
  }
}
