import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:namer_app/constant/color.dart';
import 'package:namer_app/model/todo.dart';

class ToDoItems extends StatelessWidget //This is for to do item class
{
  final ToDo todo;
  final Function(ToDo) onToDoChanged;
  final Function(String) onDeleteItem;
  final Function(ToDo) onFavoriteChanged;
  final bool showDeleteIcon; //Add a flag to not or show icon

  const ToDoItems ({Key? key, required this.todo, required this.onToDoChanged, required this.onDeleteItem, required this.onFavoriteChanged, this.showDeleteIcon = true,}) : super(key: key);

  @override
  Widget build(BuildContext context)
  {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      child: ListTile(
        onTap: () {
          //print('Clicked on Todo Item.');
          onToDoChanged(todo);
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        tileColor: Colors.white,
        leading: Icon(
          todo.isDone ? Icons.check_box : Icons.check_box_outline_blank,
         color: Blue,
         ),
        title: Text(
          todo.todoText!, 
        style: TextStyle(fontSize: 16,
         color: Black,
         decoration: todo.isDone? TextDecoration.lineThrough : null,
         ),
         ),
         subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /*Text(
              'Begin: ${DateFormat('dd-MM-yyyy HH:mm').format(todo.createdDate)}',
              style: TextStyle(fontSize: 12, color: Colors.grey),
              ),*/
              if (todo.deadlineDate != null) 
                Text(
                  'Deadline: ${DateFormat('dd-MM-yyyy HH:mm').format(todo.deadlineDate!)}',
                  style: TextStyle(fontSize: 12, color: Colors.red),
                ),
              
          ],
         ),
         trailing: 
         Wrap(
          spacing: 12,
          children: <Widget>[
            IconButton(
              icon: Icon(
                todo.isFavorite ? Icons.star : Icons.star_border,
                color: todo.isFavorite ? Colors.yellow : Colors.grey,
              ),
              onPressed: () {
                onFavoriteChanged(todo);
              },
            ), 
            if(showDeleteIcon)//put condtion to show or not delete icon
         Container(
          padding: EdgeInsets.all(0),
          margin: EdgeInsets.symmetric(vertical: 12),
          height: 35,
          width: 35,
          decoration: BoxDecoration(
            color: Red,
            borderRadius: BorderRadius.circular(5),
          ), 
          child: IconButton(
            color: Colors.white,
            iconSize: 10,
            icon: Icon(Icons.delete),
            onPressed: () {
              if (todo.id != null) {
                onDeleteItem(todo.id!);
              }
            },
          )
         ),
          ],
      ),
    ),
    );
  }
}