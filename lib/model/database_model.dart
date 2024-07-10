import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../providers/wallet_provider.dart'; // Importa il WalletProvider per poter chiamare reloadWalletBalance()

class DatabaseHelper {
  static Database? _database;

  // Nome delle tabelle e delle colonne
  static const String walletTable = 'wallet';
  static const String transactionsTable = 'transactions_table';
  static const String colId = 'id';
  static const String colName = 'name';
  static const String colBalance = 'balance';
  static const String colWalletid = 'Wallet_id';
  static const String colCategoryId = 'category_id';
  static const String colDate = 'date';
  static const String colValue = 'value';

  // Metodo per ottenere l'istanza del database
  Future<Database> get database async {
    _database ??= await initializeDatabase();
    return _database!;
  }

  // Inizializza il database
  Future<Database> initializeDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = '${documentsDirectory.path}/flutter.db';
    print(path);
    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        // Creazione della tabella portafoglio
        await db.execute('''
          CREATE TABLE $walletTable (
            $colId INTEGER PRIMARY KEY AUTOINCREMENT,
            $colName TEXT,
            $colBalance REAL
          )
        ''');

        // Creazione della tabella transazioni
        await db.execute('''
          CREATE TABLE $transactionsTable (
            $colId INTEGER PRIMARY KEY AUTOINCREMENT,
            $colName TEXT,
            $colCategoryId INTEGER,
            $colDate TEXT,
            $colValue REAL,
            $colWalletid INTEGER,
            FOREIGN KEY ($colWalletid) REFERENCES $walletTable($colId)
          )
        ''');
      },
    );
    return _database!;
  }

  // Operazioni per la tabella portafoglio

  // Inserimento di un nuovo portafoglio
  Future<int> insertWallet(Wallet wallet) async {
    print('wallet db');
    Database db = await this.database;
    return await db.insert(walletTable, wallet.toMap());
  }

  // Ottenimento di tutti i portafogli
  Future<List<Wallet>> getWallets() async {
    Database db = await this.database;
    List<Map<String, dynamic>> result = await db.query(walletTable);
    return result.map((item) => Wallet.fromMap(item)).toList();
  }

  // Ottenimento di un portafoglio tramite ID
  Future<Wallet> getWalletById(int id) async {
    Database db = await this.database;
    List<Map<String, dynamic>> result = await db.query(
      walletTable,
      where: '$colId = ?',
      whereArgs: [id],
    );
    if (result.isNotEmpty) {
      return Wallet.fromMap(result.first);
    } else {
      throw Exception('Wallet not found');
    }
  }

  // Aggiornamento di un portafoglio
  Future<int> updateWallet(Wallet wallet) async {
    Database db = await this.database;
    return await db.update(walletTable, wallet.toMap(),
        where: '$colId = ?', whereArgs: [wallet.id]);
  }

  // Eliminazione di un portafoglio
/*   Future<int> deleteWallet(int id) async {
    Database db = await this.database;
    return await db.delete(walletTable, where: '$colId = ?', whereArgs: [id]);
  }
 */

  Future<int> deleteWallet(int id) async {
  Database db = await this.database;
  // Elimina prima tutte le transazioni associate al wallet
  await db.delete(transactionsTable, where: '$colWalletid = ?', whereArgs: [id]);
  // Poi elimina il wallet stesso
  return await db.delete(walletTable, where: '$colId = ?', whereArgs: [id]);
}


  // Operazioni per la tabella transazioni

  // Inserimento di una nuova transazione
  Future<int> insertTransaction(Transaction transaction) async {
    Database db = await this.database;
    int result = await db.insert(transactionsTable, transaction.toMap());
    // Dopo l'inserimento della transazione, aggiorna il saldo del wallet
    await WalletProvider().reloadWalletBalance();
    return result;
  }

  // Ottenimento di tutte le transazioni di un certo portafoglio
  Future<List<Transaction>> getTransactionsForWallet(int walletId) async {
    Database db = await this.database;
    List<Map<String, dynamic>> result = await db.query(transactionsTable,
        where: '$colWalletid = ?', whereArgs: [walletId]);
    return result.map((item) => Transaction.fromMap(item)).toList();
  }

  // Eliminazione di una transazione
  Future<int> deleteTransaction(int id) async {
    Database db = await this.database;
    int result = await db
        .delete(transactionsTable, where: '$colId = ?', whereArgs: [id]);
    // Dopo l'eliminazione della transazione, aggiorna il saldo del wallet
    await WalletProvider().reloadWalletBalance();
    return result;
  }

  // Aggiorna una transazione esistente nel database
  Future<int> updateTransaction(Transaction transaction) async {
    Database db = await this.database;
    int result = await db.update(
      transactionsTable,
      transaction.toMap(),
      where: '$colId = ?',
      whereArgs: [transaction.id],
    );
    // Dopo l'aggiornamento della transazione, aggiorna il saldo del wallet
    await WalletProvider().reloadWalletBalance();
    return result;
  }
}

class Wallet {
  int? id;
  String? name;
  double? balance;

  Wallet({this.id, this.name, this.balance});

  Map<String, dynamic> toMap() {
    return {
      DatabaseHelper.colId: id,
      DatabaseHelper.colName: name,
      DatabaseHelper.colBalance: balance,
    };
  }

  factory Wallet.fromMap(Map<String, dynamic> map) {
    return Wallet(
      id: map[DatabaseHelper.colId],
      name: map[DatabaseHelper.colName],
      balance: map[DatabaseHelper.colBalance],
    );
  }
}

class Transaction {
  int? id;
  String? name;
  int? categoryId;
  String? date;
  double? value;
  int? transactionId;

  Transaction({
    this.id,
    this.name,
    this.categoryId,
    this.date,
    this.value,
    this.transactionId,
  });

  Map<String, dynamic> toMap() {
    return {
      DatabaseHelper.colId: id,
      DatabaseHelper.colName: name,
      DatabaseHelper.colCategoryId: categoryId,
      DatabaseHelper.colDate: date,
      DatabaseHelper.colValue: value,
      DatabaseHelper.colWalletid: transactionId,
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map[DatabaseHelper.colId],
      name: map[DatabaseHelper.colName],
      categoryId: map[DatabaseHelper.colCategoryId],
      date: map[DatabaseHelper.colDate],
      value: map[DatabaseHelper.colValue],
      transactionId: map[DatabaseHelper.colWalletid],
    );
  }
}
