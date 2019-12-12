import 'dart:io';

import 'package:dave_app/models/Person.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

Database db;

class DatabaseCreator {
  static const String personTable = 'people';
  static const String personDeleted = 'peopleDeleted';

  Future<String> getDatabasePath(String dbName) async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, dbName);

    //make sure the folder exists
    if (await Directory(dirname(path)).exists()) {
//      await deleteDatabase(path);
    } else {
      try {
        await Directory(dirname(path)).create(recursive: true);
      } catch (e) {
        print(e);
      }
    }
    return path;
  }

  Future<void> initDatabase() async {
    final path = await getDatabasePath('people_database');
    db = await openDatabase(path, version: 2, onCreate: onCreate);
    print(db);
  }

  Future<void> onCreate(Database db, int version) async {
    await _createPersonTable(db);
    await _createDeletedPersonTable(db);
  }

  Future<void> _createPersonTable(Database db) async {
    final cardTables = '''CREATE TABLE IF NOT EXISTS $personTable
        (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name Text,
        username Text,
        email Text,
        phone Text,
        website Text
       
        )''';

    await db.execute(cardTables);
  }

  Future<void> _createDeletedPersonTable(Database db) async {
    final cardTables = '''CREATE TABLE IF NOT EXISTS $personDeleted
        (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name Text,
        username Text,
        email Text,
        phone Text,
        website Text
       
        )''';

    await db.execute(cardTables);
  }


  static Future<bool> _exists(Person p) async {
    List<Map> people = await db
        .query(personTable, where: "username=?", whereArgs: [p.username]);

    return people.length >= 1;
  }

  static Future<bool> existsInArchive(Person p) async {
    List<Map> people = await db
        .query(personDeleted, where: "username=?", whereArgs: [p.username]);

    return people.length >= 1;
  }

  static Future<List<dynamic>> getAllPersons()async{

    List<dynamic> people = await db
        .query(personTable, );

    List<dynamic> archived=await getAllArchivePersons();



    return people.where((t){
      var s=Person.fromJson(t);
      //return true;
      if(archived.length>0)
     return archived.where((s0)=>s0.username==s.username).length==0;

      return true;
    }).map((item)=>Person.fromJson(item))
        .toList();
  }

  static Future<List<dynamic>> getAllArchivePersons()async{

    List<Map> people = await db
        .query(personDeleted, );

    return people.map((item)=>Person.fromJson(item)).toList();
  }


 static void savePerson(Person person) async {
     print(person.toJson());
    //  await db.query(CardModel.CARD_TABLE,where:newCard.)
    bool exst = await _exists(person);
    print("save");
    exst
        ? print("nothing")
        : await db.insert(
      personTable,
      person.toDBJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static void _archivePerson(Person person) async {
     print(person.toJson());
    //  await db.query(CardModel.CARD_TABLE,where:newCard.)
    bool exst = await existsInArchive(person);
    exst
        ? print("nothing")
        : await db.insert(
      personDeleted,
      person.toDBJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }


  static void removePerson(Person person) async {
   await _archivePerson(person);
   var i= await db.delete(personTable, where: 'username=?', whereArgs: [
      person.username,
    ]);

   print(i);
  }
}
