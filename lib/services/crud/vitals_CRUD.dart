import 'package:flutter/material.dart';
//import 'package:flutter/physics.dart';
//import 'package:hello/services/crud/crud_exceptions.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseAlreadyOpenException implements Exception {}

class DirectoryException implements Exception {}

class DbNotOpen implements Exception {}

class UserAlreadyExists implements Exception {}

class CouldNotFindUser implements Exception {}
class EmptyId implements Exception {}

class SQLHelper {
  Database? _db;

  static final SQLHelper _shared = SQLHelper._sharedInstance();
  SQLHelper._sharedInstance();
  factory SQLHelper() => _shared;

  Future<DatabaseUser> getOrCreateUser({required int id}) async {
    try {
      final user = await getUser(id: id);
      return user;
    } on CouldNotFindUser {
      final createdUser = await createUser(
          id: id,
          tempurature: ' ',
          resprate: ' ',
          bldpres: ' ',
          pulox: ' ',
          testdate: ' ',
          entrydate: ' ',
          serno: ' ',
          uploaded: 'false');
      return createdUser;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _ensureDbIsOpen() async {
    try {
      await open();
    } on DatabaseAlreadyOpenException {}
  }

  Database _getDatabaseorThrow() {
    final db = _db;
    if (db == null) {
      throw DbNotOpen();
    } else {
      return db;
    }
  }

  Future<void> close() async {
    final db = _db;
    if (db == null) {
      throw DbNotOpen();
    } else {
      await db.close();
    }
  }

  Future<void> open() async {
    if (_db != null) {
      throw DatabaseAlreadyOpenException();
    }
    try {
      final docsPath = await getApplicationDocumentsDirectory();
      final path = join(docsPath.path, 'Vital.db');
      final db = await openDatabase(path);
      _db = db;
      db.execute(createTable);
    } on MissingPlatformDirectoryException {
      throw DirectoryException();
    }
  }

  Future<DatabaseUser> createUser(
      {required int id,
      required String tempurature,
      required String resprate,
      required String bldpres,
      required String pulox,
      required String testdate,
      required String entrydate,
      required String serno,
      required String uploaded}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseorThrow();
    final results =
        await db.query('item', limit: 1, where: 'id=?', whereArgs: [id]);
    if (results.isNotEmpty) {
      throw UserAlreadyExists();
    }
    int userId = await db.insert('item', {
      idColumn: id,
      tempuratureColumn: tempurature,
      resprateColumn: resprate,
      bldpresColumn: bldpres,
      puloxColumn: pulox,
      testdateColumn: testdate,
      entrydateColumn: entrydate,
      sernoColumn: serno,
      uploadedColumn: uploaded
    });
    return DatabaseUser(
        id: userId,
        tempurature: tempurature,
        resprate: resprate,
        bldpres: bldpres,
        pulox: pulox,
        testdate: testdate,
        entrydate: entrydate,
        serno: serno,
        uploaded: uploaded);
  }

  Future<DatabaseUser> getUser({required int id}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseorThrow();
    final results =
        await db.query('item', limit: 1, where: 'id=?', whereArgs: [id]);
    if (results.isEmpty) {
      throw CouldNotFindUser();
    } else {
      return DatabaseUser.fromRow(results.first);
    }
  }

  Future<List<Map<String, dynamic>>> getItems() async {
    await _ensureDbIsOpen();
    final db = _getDatabaseorThrow();
    return await db.query('item', orderBy: "id");
  }

  Future<int> updateItem(
      {required int id,
      required String tempurature,
      required String resprate,
      required String bldpres,
      required String pulox,
      required String testdate,
      required String entrydate,
      required String serno,
      required String uploaded}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseorThrow();
    final data = {
      'tempurature': tempurature,
      'resprate': resprate,
      'bldpres': bldpres,
      'pulox': pulox,
      'testdate': testdate,
      'entrydate': entrydate,
      'serno': serno,
      'uploaded': uploaded
    };
    final result =
        await db.update('item', data, where: 'id=?', whereArgs: [id]);
    return result;
  }

  Future<void> deleteItem({required int id}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseorThrow();
    try {
      await db.delete("item", where: "id=?", whereArgs: [id]);
    } catch (e) {
      print("Someting went W while deleting:$e");
    }
  }
}

@immutable
class DatabaseUser {
  final int id;
  final String tempurature;
  final String resprate;
  final String bldpres;
  final String pulox;
  final String testdate;
  final String entrydate;
  final String serno;
  final String uploaded;

  const DatabaseUser(
      {required this.pulox,
      required this.testdate,
      required this.entrydate,
      required this.serno,
      required this.id,
      required this.tempurature,
      required this.resprate,
      required this.bldpres,
      required this.uploaded});
  DatabaseUser.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        tempurature = map[tempuratureColumn] as String,
        resprate = map[resprateColumn] as String,
        bldpres = map[bldpresColumn] as String,
        pulox = map[puloxColumn] as String,
        testdate = map[testdateColumn] as String,
        entrydate = map[entrydateColumn] as String,
        serno = map[sernoColumn] as String,
        uploaded = map[uploadedColumn] as String;
}

const idColumn = 'id';
const tempuratureColumn = 'tempurature';
const resprateColumn = 'resprate';
const bldpresColumn = 'bldpres';
const uploadedColumn = 'uploaded';
const puloxColumn = 'pulox';
const testdateColumn = 'testdate';
const entrydateColumn = 'entrydate';
const sernoColumn = 'serno';
const createTable = """CREATE TABLE "item" (
	"id"	INTEGER NOT NULL UNIQUE,
 	"tempurature"	TEXT ,
   "resprate"	TEXT,
 	"bldpres"	TEXT,
  "pulox" TEXT,
  "testdate" TEXT,
  "entrydate" TEXT,
  "serno" TEXT,
  "uploaded"	TEXT,
   PRIMARY KEY("id")
 );
  """;
