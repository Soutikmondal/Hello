import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseAlreadyOpenException implements Exception {}

class DirectoryException implements Exception {}

class DbNotOpen implements Exception {}

class UserAlreadyExists implements Exception {}

class CouldNotFindUser implements Exception {}

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
          comp1: '',
          dur1: '',
          hdmy1: '',
          comp2: '',
          dur2: '',
          hdmy2: '',
          comp3: '',
          dur3: '',
          rh: '',
          reportlink: '',
          hdmy3: '',
          testdate: '',
          entrydate: '',
          serno: '',
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
      required String comp1,
      required String dur1,
      required String hdmy1,
      required String comp2,
      required String dur2,
      required String hdmy2,
      required String comp3,
      required String dur3,
      required String hdmy3,
      required String rh,
      required String reportlink,
      required String testdate,
      required String entrydate,
      required String serno,
      required String uploaded}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseorThrow();

    int userId = await db.insert('complaint', {
      idColumn: id,
      comp1Column: comp1,
      dur1Column: dur1,
      hdmy1Column: hdmy1,
      comp2Column: comp2,
      dur2Column: dur2,
      hdmy2Column: hdmy2,
      comp3Column: comp3,
      dur3Column: dur3,
      rhColumn: rh,
      reportlinkColumn: reportlink,
      hdmy3Column: hdmy3,
      testdateColumn: testdate,
      entrydateColumn: entrydate,
      sernoColumn: serno,
      uploadedColumn: uploaded
    });
    return DatabaseUser(
        id: userId,
        comp1: comp1,
        dur1: dur1,
        hdmy1: hdmy1,
        comp2: comp2,
        dur2: dur2,
        hdmy2: hdmy2,
        comp3: comp3,
        dur3: dur3,
        rh: rh,
        reportlink: reportlink,
        hdmy3: hdmy3,
        testdate: testdate,
        entrydate: entrydate,
        serno: serno,
        uploaded: uploaded);
  }

  Future<DatabaseUser> getUser({required int id}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseorThrow();
    final results =
        await db.query('complaint', limit: 1, where: 'id=?', whereArgs: [id]);
    if (results.isEmpty) {
      throw CouldNotFindUser();
    } else {
      return DatabaseUser.fromRow(results.first);
    }
  }

  Future<List<Map<String, dynamic>>> getItems() async {
    await _ensureDbIsOpen();
    final db = _getDatabaseorThrow();
    return await db.query('complaint', orderBy: "id");
  }

  Future<int> updateItem(
      {required int id,
      required String comp1,
      required String dur1,
      required String hdmy1,
      required String comp2,
      required String dur2,
      required String hdmy2,
      required String comp3,
      required String dur3,
      required String hdmy3,
      required String rh,
      required String reportlink,
      required String testdate,
      required String entrydate,
      required String serno,
      required String uploaded}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseorThrow();
    final data = {
      'comp1': comp1,
      'dur1': dur1,
      'hdmy1': hdmy1,
      'comp2': comp2,
      'dur2': dur2,
      'hdmy2': hdmy2,
      'comp3': comp3,
      'dur3': dur3,
      'hdmy3': hdmy3,
      'rh': rh,
      'reportlink': reportlink,
      'testdate': testdate,
      'entrydate': entrydate,
      'serno': serno,
      'uploaded': uploaded,
    };
    final result =
        await db.update('complaint', data, where: 'id=?', whereArgs: [id]);
    return result;
  }

  Future<void> deleteItem({required int id}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseorThrow();
    try {
      await db.delete("complaint", where: "id=?", whereArgs: [id]);
    } catch (e) {
      print("Someting went W while deleting:$e");
    }
  }
}

@immutable
class DatabaseUser {
  final int id;
  final String comp1;
  final String dur1;
  final String hdmy1;
  final String comp2;
  final String dur2;
  final String hdmy2;
  final String comp3;
  final String dur3;
  final String hdmy3;
  final String testdate;
  final String entrydate;
  final String serno;
  final String reportlink;
  final String rh;

  final String uploaded;

  const DatabaseUser(
      {required this.comp2,
      required this.testdate,
      required this.entrydate,
      required this.serno,
      required this.id,
      required this.comp1,
      required this.dur1,
      required this.hdmy1,
      required this.comp3,
      required this.dur3,
      required this.hdmy3,
      required this.dur2,
      required this.hdmy2,
      required this.rh,
      required this.reportlink,
      required this.uploaded});
  DatabaseUser.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        comp1 = map[comp1Column] as String,
        dur1 = map[dur1Column] as String,
        hdmy1 = map[hdmy1Column] as String,
        comp2 = map[comp2Column] as String,
        dur2 = map[dur2Column] as String,
        hdmy2 = map[hdmy2Column] as String,
        comp3 = map[comp3Column] as String,
        dur3 = map[dur3Column] as String,
        hdmy3 = map[hdmy3Column] as String,
        rh = map[rhColumn] as String,
        reportlink = map[reportlinkColumn] as String,
        testdate = map[testdateColumn] as String,
        entrydate = map[entrydateColumn] as String,
        serno = map[sernoColumn] as String,
        uploaded = map[uploadedColumn] as String;
}

const idColumn = 'id';
const comp1Column = 'comp1';
const dur1Column = 'dur1';
const hdmy1Column = 'hdmy1';
const uploadedColumn = 'uploaded';
const comp2Column = 'comp2';
const dur2Column = 'dur2';
const hdmy2Column = 'hdmy2';
const comp3Column = 'comp3';
const dur3Column = 'dur3';
const hdmy3Column = 'hdmy3';
const rhColumn = 'rh';
const reportlinkColumn = 'reportlink';
const testdateColumn = 'testdate';
const entrydateColumn = 'entrydate';
const sernoColumn = 'serno';
const createTable = """CREATE TABLE "complaint" (
	"id"	INTEGER NOT NULL UNIQUE,
 	"comp1"	TEXT ,
   "dur1"	TEXT,
 	"hdmy1"	TEXT,
  "comp2" TEXT,
   "dur2"	TEXT,
 	"hdmy2"	TEXT,
  "comp3" TEXT,
   "dur3"	TEXT,
 	"hdmy3"	TEXT,
  "rh"	TEXT,
 	"reportlink"	TEXT,
  "testdate" TEXT,
  "entrydate" TEXT,
  "serno" TEXT,
  "uploaded"	TEXT,
   PRIMARY KEY("id")
 );
  """;
