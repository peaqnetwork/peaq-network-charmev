import 'dart:async';

import 'package:charmev/common/models/transaction.dart';
import 'package:sqflite/sqflite.dart';
import 'constant.dart';

const String transactionTable = DbConstant.transactionTable;
const String dateColumn = DbConstant.date;
const String dataColumn = DbConstant.data;
const String idColumn = DbConstant.id;

class CEVTransactionDB {
  CEVTransactionDB(this.database);

  final Future<Database> database;

  static const limit = 20;

  Future<List<CEVTransactionDbModel>> getTransactions(int page) async {
    Database db = await database;
    int perPage = limit;
    int offset = (perPage * page) - perPage;
    var res = await db.query(transactionTable,
        distinct: true,
        orderBy: "$dateColumn ASC",
        limit: perPage,
        offset: offset);

    List<CEVTransactionDbModel> list = res.isNotEmpty
        ? res.map((c) => CEVTransactionDbModel.fromJson(c)).toList()
        : [];
    return list;
  }

  // / Create new transaction or update if Exists
  Future<int> newTransaction(CEVTransactionDbModel transaction) async {
    Database db = await database;
    final transactionExist = await getTransactionById(transaction.id);

    int res;
    if (transactionExist == null) {
      res = await db.insert(transactionTable, transaction.toJson());
    } else {
      res = await db.update(
          transactionTable,
          {
            dataColumn: transaction.data,
            dateColumn: transaction.date,
          },
          where: "$idColumn=?",
          whereArgs: [transaction.id]);
    }
    return res;
  }

  Future<CEVTransactionDbModel?> getTransactionById(String id) async {
    Database db = await database;
    var res = await db.query(transactionTable,
        where: "$idColumn = ?", limit: 1, whereArgs: [id]);
    // print("RES:: $res");
    CEVTransactionDbModel? tranx =
        res.isNotEmpty ? CEVTransactionDbModel.fromJson(res.first) : null;
    return tranx;
  }
}
