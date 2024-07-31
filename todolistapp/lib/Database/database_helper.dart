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
      onConfigure: _onConfigure,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    username TEXT,
    email TEXT
    )
''');

    await db.execute('''
  CREATE TABLE todos (
  id TEXT PRIMARY KEY,
  todoText TEXT,
  isDone INTEGER,
  isFavorite INTEGER,
  createdDate TEXT,
  deadlineDate TEXT,
  userId INTEGER,
  FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE
  )
    ''');
  }
  
  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }
  Future<int> insertUser(String username, String email) async{
    var dbClient = await database;
    return await dbClient.insert('users', {'username': username, 'email': email});
  }

  Future<Map<String, dynamic>?> getUser(String username, String email) async {
    var dbClient = await database;
    List<Map<String, dynamic>> result = await dbClient.query('users', 
    where: 'username = ? AND email = ?', whereArgs: [username, email]);
    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }

  
  Future<void> insertTodo(ToDo todo) async {
    final db = await database;
    await db.insert(
      'todos',
      todo.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

    

  Future<List<ToDo>> getTodos(int userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('todos', where: 'userId = ?', whereArgs: [userId]);
    return List.generate(maps.length, (i) {
      return ToDo(
        id: maps[i]['id'],
        todoText: maps[i]['todoText'],
        isDone: maps[i]['isDone'] == 1,
        isFavorite: maps[i]['isFavorite'] == 1,
        createdDate: DateTime.parse(maps[i]['createdDate']),
        deadlineDate: maps[i]['deadlineDate'] != null ? DateTime.parse(maps[i]['deadlineDate']) : null,
        userId:maps[i]['userId'],
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

