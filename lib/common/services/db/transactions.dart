import 'dart:async';

import 'package:charmev/common/models/enum.dart';
import 'package:charmev/common/models/transaction.dart';
import 'package:sqflite/sqflite.dart';
import 'constant.dart';

const String transactionTable = DbConstant.transactionTable;
const String dateColumn = DbConstant.date;
const String dataColumn = DbConstant.data;
const String idColumn = DbConstant.id;
const String transactionTypeColumn = DbConstant.transactionType;
const String signatoryColumn = DbConstant.signatory;

class CEVTransactionDB {
  CEVTransactionDB(this.database);

  final Future<Database> database;

  Future<List<CEVTransactionDbModel>> getTransactions(
      TransactonType type) async {
    Database db = await database;
    var txtype = transactionTypeToString(type);
    var res = await db.query(transactionTable,
        distinct: true,
        where: "$transactionTypeColumn = ? ",
        whereArgs: [txtype],
        orderBy: "$dateColumn ASC");

    List<CEVTransactionDbModel> list = res.isNotEmpty
        ? res.map((c) => CEVTransactionDbModel.fromJson(c)).toList()
        : [];
    return list;
  }

  /// Create new transaction or update if Exists
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
            signatoryColumn: transaction.signatory,
            transactionTypeColumn: transaction.transactionType.toString(),
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

    CEVTransactionDbModel? tranx =
        res.isNotEmpty ? CEVTransactionDbModel.fromJson(res.first) : null;
    return tranx;
  }

  Future<bool> hasSpentTransaction() async {
    Database db = await database;
    var type = transactionTypeToString(TransactonType.spent);
    var res = await db.query(transactionTable,
        where: "$transactionTypeColumn = ? ", whereArgs: [type], limit: 1);

    return res.isNotEmpty;
  }

  Future<int> deleteTransaction(String id) async {
    Database db = await database;
    return await db
        .delete(transactionTable, where: '$idColumn = ?', whereArgs: [id]);
  }
}
