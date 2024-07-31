import 'package:flutter/material.dart';
import 'package:namer_app/constant/color.dart';
import 'package:namer_app/items/to_do_items.dart';
import 'package:namer_app/model/todo.dart';
import 'package:namer_app/favorites/FavoritesPage.dart';
import 'package:namer_app/Database/database_helper.dart';
import 'package:namer_app/login/LoginPage.dart';
import 'dart:async';

class Home extends StatefulWidget {
  final int userId; 
  Home({Key? key, required this.userId}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<ToDo> todosList = [];
  List<ToDo> _foundToDo = [];
  final _todoController = TextEditingController();
  final _todoFocusNode = FocusNode();
  bool _isSnackbarActive = false;

  @override
  void initState() {
    super.initState();
    _loadTodos();
    Timer.periodic(Duration(minutes: 1), (timer) {
      _checkDeadlines();
    });
  }

  @override
  void dispose() {
    _todoController.dispose();
    _todoFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadTodos() async {
    List<ToDo> todos = await DatabaseHelper().getTodos(widget.userId);
    setState(() {
      todosList = todos;
      _foundToDo = todosList;
    });
  }

  void _checkDeadlines() {
    setState(() {
      for (ToDo todo in todosList) {
        if (todo.deadlineDate != null && todo.deadlineDate!.isBefore(DateTime.now())) {
          todo.isDone = true;
          DatabaseHelper().updateTodo(todo);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: Yellow,
        appBar: _buildAppBar(),
        drawer: _buildDrawer(),
        body: Stack(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: Column(
                children: [
                  searchBox(),
                  Expanded(
                    child: ListView(
                      children: [
                        Container(
                          margin: EdgeInsets.only(top: 50, bottom: 20),
                          child: Text('All ToDo', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w500)),
                        ),
                        for (ToDo todo in _foundToDo.reversed)
                          ToDoItems(
                            todo: todo,
                            onToDoChanged: _handleToDoChange,
                            onDeleteItem: (id) {
                              if (id != null) {
                                _confirmDelete(context, id);
                              }
                            },
                            onFavoriteChanged: _handleFavoriteChange,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.only(bottom: 20, right: 20, left: 20),
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.grey,
                            offset: Offset(0.0, 0.0),
                            blurRadius: 10.0,
                            spreadRadius: 0.0,
                          ),
                        ],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextField(
                        controller: _todoController,
                        focusNode: _todoFocusNode,
                        decoration: InputDecoration(
                          hintText: 'Add a new todo item',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(bottom: 20, right: 20),
                    child: ElevatedButton(
                      child: Text(
                        '+',
                        style: TextStyle(fontSize: 40),
                      ),
                      onPressed: () {
                        _addToDoItem(_todoController.text);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Green,
                        minimumSize: Size(60, 60),
                        elevation: 10,
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void _handleToDoChange(ToDo todo) {
    setState(() {
      todo.isDone = !todo.isDone;
      DatabaseHelper().updateTodo(todo);
    });
  }

  void _handleFavoriteChange(ToDo todo) {
    setState(() {
      todo.isFavorite = !todo.isFavorite;
      DatabaseHelper().updateTodo(todo);
    });
  }

  void _confirmDelete(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Are you sure you want to delete this to do items?'),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Yes'),
              onPressed: () {
                _deleteToDoItem(id);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteToDoItem(String id) {
    setState(() {
      todosList.removeWhere((item) => item.id == id);
      DatabaseHelper().deleteTodo(id);
    });
  }

  void _addToDoItem(String toDo) async {
    String trimmedToDo = toDo.trim();
    if (trimmedToDo.isEmpty) {
      _showSnackbar(context, "Error, cannot add a blank todo item");
      return;
    }
    DateTime? deadline = await _selectDeadlineDate(context);
    if (deadline == null) {
      _showSnackbar(context, "Cancelled: To-Do item not added");
      return;
    }
    DateTime beginTime = DateTime.now();
    if ( deadline.hour < beginTime.hour || (deadline.hour == beginTime.hour && deadline.minute < beginTime.minute)) {
      _showSnackbar(context, "Error, deadline must be later than current date and time");
      return;
    }

    setState(() {
      ToDo newTodo = ToDo(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        todoText: trimmedToDo,
        isDone: false,
        isFavorite: false,
        createdDate: DateTime.now(),
        deadlineDate: deadline,
        userId: widget.userId,
      );
      todosList.add(newTodo);
      DatabaseHelper().insertTodo(newTodo);
    });
    _todoController.clear();
    _todoFocusNode.unfocus();
  }

  Future<DateTime?> _selectDeadlineDate(BuildContext context) async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (selectedDate != null) {
      TimeOfDay? selectedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (selectedTime != null) {
        return DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          selectedTime.hour,
          selectedTime.minute,
        );
      }
    }
    return null;
  }

  void _showSnackbar(BuildContext context, String message) {
    if (_isSnackbarActive) return;

    setState(() {
      _isSnackbarActive = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 6),
        action: SnackBarAction(
          label: 'Dismiss',
          onPressed: () {},
        ),
      ),
    ).closed.then((reason) {
      setState(() {
        _isSnackbarActive = false;
      });
    });
  }

  void _runFilter(String enteredKeyword) {
    List<ToDo> results = [];
    if (enteredKeyword.isEmpty) {
      results = todosList;
    } else {
      results = todosList
          .where((item) => item.todoText!
              .toLowerCase()
              .contains(enteredKeyword.toLowerCase()))
          .toList();
    }

    setState(() {
      _foundToDo = results;
    });
  }

  Widget searchBox() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextField(
        onChanged: (value) => _runFilter(value),
        decoration: InputDecoration(
          contentPadding: EdgeInsets.all(0),
          prefixIcon: Icon(
            Icons.search,
            color: Black,
            size: 20,
          ),
          prefixIconConstraints: BoxConstraints(
            maxHeight: 20,
            minWidth: 25,
          ),
          border: InputBorder.none,
          hintText: 'Search',
          hintStyle: TextStyle(color: Grey),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Blue,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Builder(
            builder: (context) => IconButton(
              icon: Icon(
                null,
              ),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
          Container(
            height: 40,
            width: 40,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset('assets/images/123.jpg'),
            ),
          ),
        ],
      ),
    );
  }

  Drawer _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Blue,
            ),
            child: Text(
              'Menu',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.info),
            title: Text('About'),
            onTap: () {
              Navigator.pop(context);
              _showAboutDialog(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.login),
            title: Text('Log in'),
            onTap: () {
              Navigator.pop(context);
              _navigateToLogin(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.star),
            title: Text('Favorites'),
            onTap: () {
              Navigator.pop(context);
              _navigateToFavorite(context);
            },
          )
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('About'),
          content: Text('This is To-Do list application. That make by Bill Binh'),
          actions: [
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _navigateToLogin(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LoginPage(), 
        )
    );
  }

  void _navigateToFavorite(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FavoritesPage(
          todoList: todosList,
          ),
      ),
    );
  }
}