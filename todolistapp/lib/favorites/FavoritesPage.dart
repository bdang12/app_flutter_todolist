import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:namer_app/constant/color.dart';
import 'package:namer_app/model/todo.dart';

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
      body: ListView(
        children: favoriteTodos.map((todo) {
          return ListTile(
            title: Text(todo.todoText!),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Begin: ${DateFormat('dd-MM-yyyy HH:mm').format(todo.createdDate)}',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          if (todo.deadlineDate != null)
          Text(
            'Deadline: ${DateFormat('dd-MM-yyyy HH:mm').format(todo.deadlineDate!)}',
            style: TextStyle(fontSize: 12, color: Colors.red),
          ),
        ],
      ),
    );
  }).toList(),
  ),
  );
}
}