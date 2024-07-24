import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:namer_app/model/todo.dart';
import 'dart:async';



class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();

  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
   DatabaseHelper._internal();
   static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String dbpath = join(await getDatabasesPath(), 'todo_database.db');

    return await openDatabase(
      dbpath,
      onCreate: _createDB,
      version: 1,
    );
  }

  Future _createDB(Database db, int version) async {

    await db.execute('''
  CREATE TABLE todos (
  id TEXT PRIMARY KEY,
  todoText TEXT,
  isDone INTEGER,
  isFavorite INTEGER,
  createdDate TEXT,
  deadlineDate TEXT
  )
    ''');
  }

  Future<void> insertTodo(ToDo todo) async {
    final db = await database;

    await db.insert(
      'todos',
      todo.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<ToDo>> getTodos() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('todos');
    return List.generate(maps.length, (i) {
      return ToDo(
        id: maps[i]['id'],
        todoText: maps[i]['todoText'],
        isDone: maps[i]['isDone'] == 1,
        isFavorite: maps[i]['isFavorite'] == 1,
        createdDate: DateTime.parse(maps[i]['createdDate']),
        deadlineDate: maps[i]['deadlineDate'] != null ? DateTime.parse(maps[i]['deadlineDate']) : null,
      );
    }
    );
  }

  Future<void> updateTodo(ToDo todo) async {
    final db = await database;

    await db.update(
      'todos',
      todo.toMap(),
      where: 'id = ?',
      whereArgs: [todo.id],
    );
  }

  Future<void> deleteTodo(String id) async {
    final db = await instance.database;

    await db.delete(
      'todos',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

