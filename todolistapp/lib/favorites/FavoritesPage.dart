import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:namer_app/Database/database_helper.dart';
import 'package:namer_app/constant/color.dart';
import 'package:namer_app/model/todo.dart';
import 'package:namer_app/items/to_do_items.dart'; 

class FavoritesPage extends StatelessWidget{
  final List<ToDo> todoList;
  const FavoritesPage({Key? key, required this.todoList}) : super(key:key);
  @override
  Widget build(BuildContext context){
    List<ToDo> favoriteTodos = todoList.where((todo) => todo.isFavorite).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Favorite ToDos'),
        backgroundColor: Blue,
      ),
      backgroundColor: Colors.purple,
      body: favoriteTodos.isNotEmpty
      ? ListView.builder(
        itemCount: favoriteTodos.length,
        itemBuilder: (context, index) {
          ToDo todo = favoriteTodos[index];
          return ToDoItems(
            todo: todo,
            onToDoChanged: (updatedTodo) {
              todo.isDone = !todo.isDone;
              DatabaseHelper().updateTodo(todo);
              (context as Element).markNeedsBuild();
            },
            onDeleteItem: (id) {
              DatabaseHelper().deleteTodo(id);
              favoriteTodos.removeAt(index);
              (context as Element).markNeedsBuild();
            },
            onFavoriteChanged: (updatedTodo) {
              todo.isFavorite = !todo.isFavorite;
              DatabaseHelper().updateTodo(todo);
              (context as Element).markNeedsBuild();
            },
            showDeleteIcon: false, 
            );
        },
      )
      : Center(
        child: Text(
          'No favorite ToDos yet.',
          style: TextStyle(
            fontSize: 18,
            color: Colors.grey),
        ),
      ),
  );
}
}