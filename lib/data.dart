import 'dart:async';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

final String tableMeds = 'meds';
final String columnId = 'id';
final String columnName = 'name';
final String columnDateTime = 'medDateTime';
final String columnNote = 'note';
final String columnDisplay = 'display';

class MedInfo {
  int id;
  String name;
  DateTime medDateTime;
  String note;
  int display;

  MedInfo({
    this.id,
    this.name,
    this.medDateTime,
    this.note,
    this.display,
  });

  factory MedInfo.fromMap(Map<String, dynamic> json) => MedInfo(
      id: json["id"],
      name: json["name"],
      medDateTime: DateTime.parse(json["medDateTime"]),
      note: json["note"],
      display: json["display"]);
  Map<String, dynamic> toMap() => {
        "id": id,
        "name": name,
        "medDateTime": medDateTime.toIso8601String(),
        "note": note,
        "display": display,
      };
}

class DatabaseHelper {
  static Database _database;
  static DatabaseHelper _databaseHelper;

  DatabaseHelper._createInstance();
  factory DatabaseHelper() {
    if (_databaseHelper == null) {
      _databaseHelper = DatabaseHelper._createInstance();
    }
    return _databaseHelper;
  }

  Future<Database> get database async {
    if (_database == null) {
      _database = await initializeDatabase();
    }
    return _database;
  }

  Future<Database> initializeDatabase() async {
    var dir = await getDatabasesPath();
    var path = dir + "meds.db";

    var database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        db.execute('''
          create table $tableMeds (
          $columnId integer primary key autoincrement,
          $columnName text not null,
          $columnDateTime text not null,
          $columnNote text not null,
          $columnDisplay integer
          )
        ''');
      },
    );
    return database;
  }

  void insertMed(MedInfo medInfo) async {
    var db = await this.database;
    var result = await db.insert(tableMeds, medInfo.toMap());
    print('result : $result');
  }

  getMeds() async {
    List<MedInfo> _meds = [];

    var db = await this.database;
    var result = await db.query(tableMeds);
    result.forEach((element) {
      var medInfo = MedInfo.fromMap(element);
      _meds.add(medInfo);
    });

    return _meds;
  }

  Future<int> delete(int id) async {
    var db = await this.database;
    return await db.delete(tableMeds, where: '$columnId = ?', whereArgs: [id]);
  }
}
