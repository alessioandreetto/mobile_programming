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
  static const String colRelatedTransactionId = 'related_transaction_id';

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
      version: 2, // Incrementa la versione del database
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
            $colRelatedTransactionId INTEGER,
            FOREIGN KEY ($colWalletid) REFERENCES $walletTable($colId)
          )
        ''');
      },
      onUpgrade: (Database db, int oldVersion, int newVersion) async {
        if (oldVersion < 2) {
          await db.execute('''
            ALTER TABLE $transactionsTable ADD COLUMN $colRelatedTransactionId INTEGER
          ''');
        }
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
  Future<int> deleteWallet(int id) async {
    Database db = await this.database;
    // Elimina prima tutte le transazioni associate al wallet
    await db
        .delete(transactionsTable, where: '$colWalletid = ?', whereArgs: [id]);
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
    // Ottieni la transazione da eliminare
    List<Map<String, dynamic>> transactionData = await db.query(
      transactionsTable,
      where: '$colId = ?',
      whereArgs: [id],
    );

    if (transactionData.isNotEmpty) {
      Transaction transaction = Transaction.fromMap(transactionData.first);

      // Elimina la transazione collegata se esiste
      if (transaction.relatedTransactionId != null) {
        await db.delete(transactionsTable,
            where: '$colId = ?', whereArgs: [transaction.relatedTransactionId]);
      }

      // Elimina la transazione corrente
      int result = await db
          .delete(transactionsTable, where: '$colId = ?', whereArgs: [id]);
      // Dopo l'eliminazione della transazione, aggiorna il saldo del wallet
      await WalletProvider().reloadWalletBalance();
      return result;
    } else {
      throw Exception('Transaction not found');
    }
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

    // Aggiorna la transazione collegata se esiste
    if (transaction.relatedTransactionId != null) {
      Transaction relatedTransaction = Transaction(
        id: transaction.relatedTransactionId,
        name: transaction.name,
        categoryId: transaction.categoryId,
        date: transaction.date,
        value: -transaction.value!,
        transactionId: transaction.transactionId,
      );
      await db.update(
        transactionsTable,
        relatedTransaction.toMap(),
        where: '$colId = ?',
        whereArgs: [relatedTransaction.id],
      );
    }

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
  int? relatedTransactionId;

  Transaction({
    this.id,
    this.name,
    this.categoryId,
    this.date,
    this.value,
    this.transactionId,
    this.relatedTransactionId,
  });

  Map<String, dynamic> toMap() {
    return {
      DatabaseHelper.colId: id,
      DatabaseHelper.colName: name,
      DatabaseHelper.colCategoryId: categoryId,
      DatabaseHelper.colDate: date,
      DatabaseHelper.colValue: value,
      DatabaseHelper.colWalletid: transactionId,
      DatabaseHelper.colRelatedTransactionId: relatedTransactionId,
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
      relatedTransactionId: map[DatabaseHelper.colRelatedTransactionId],
    );
  }
}
