import 'package:flutter/material.dart';
import 'package:namer_app/constant/color.dart';
import 'package:namer_app/items/to_do_items.dart';
import 'package:namer_app/model/todo.dart';

// Dart file for home screen

class Home extends StatefulWidget{
  Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final todosList = ToDo.todoList();
  List<ToDo> _foundToDo = [];
  final _todoController = TextEditingController();

  @override
  void initState() {
    _foundToDo = todosList;
    super.initState();
  }
  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      backgroundColor: Yellow,
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 20,
             vertical: 15,
             ),
            child: Column(
              children: [
                searchBox(), 
                Expanded(
                  child: ListView(
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: 50, bottom: 20),
                      child: Text('All ToDo', style: TextStyle(
                        fontSize: 30,
                       fontWeight:FontWeight.w500,
                        ),
                        ),
                    ),
          
                    for ( ToDo todo in _foundToDo.reversed)
                    ToDoItems(
                      todo: todo,
                      onToDoChanged: _handleToDoChange,
                      onDeleteItem: _deleteToDoItem,
                      ),
                  ],
                )
                ),
              ],
            
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Row(children: [
              Expanded(child: Container(
                margin: EdgeInsets.only(
                  bottom: 20,
                  right: 20,
               left: 20,
               ),
               padding: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 5,
                ),
               decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: const [BoxShadow(
                color: Colors.grey,
                offset: Offset(0.0, 0.0),
                blurRadius: 10.0,
                spreadRadius: 0.0,
                ),],
                borderRadius: BorderRadius.circular(10),
               ),
               child: TextField(
                controller: _todoController,
                decoration: InputDecoration(
                  hintText: 'Add a new todo item',
                  border: InputBorder.none,
                ),
               )
               ),
               ),
               Container(
                margin: EdgeInsets.only(
                bottom: 20,
                right:20,
                  ),
                  child: ElevatedButton(
                  child: Text('+', style: TextStyle(fontSize: 40,),),
                  onPressed: () {
                    _addToDoItem(_todoController.text); //woring on add button 
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Green,
                    minimumSize: Size(60, 60),
                    elevation: 10,
                  )
               )
               ),
            ]),
          )
        ],
      ),
    );
  }

  void _handleToDoChange(ToDo todo) {
    setState(() {
      todo.isDone = !todo.isDone;
    });
   
  }
  void _deleteToDoItem(String id) {
    setState(() {
       todosList.removeWhere((item) => item.id == id);
    });
   
  }

  void _addToDoItem(String toDo) async{
    if(toDo.trim().isEmpty)   //This make the add button not up the text if the text is blank
    {
      _showSnackbar(context, "Error, cannot add a blank todo item");
      return;
    }
    DateTime? deadline = await _selectDeadlineDate(context);
    setState(() {
       todosList.add(ToDo(
    id: DateTime.now().millisecondsSinceEpoch.toString(),
    todoText: toDo,
    createdDate: DateTime.now(),
    deadlineDate: deadline,
    ));

    });
    _todoController.clear();
   
  }

  Future<DateTime?> _selectDeadlineDate(BuildContext context) async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if(selectedDate != null) {
      TimeOfDay? selectedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if(selectedTime != null) {
        return DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          selectedDate.hour,
          selectedDate.minute,
        );
      }
    }
    return null;
  }

  //add a SnackBar Method to give notify when user input blank text
  void _showSnackbar(BuildContext context, String message)
  {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 6),
        action: SnackBarAction(
          label: 'Dismiss',
          onPressed: () {
            //Dismiss SnackBar
          },
        )
        )
      );
  }

  void _runFilter(String enteredKeyword) {
    List<ToDo> results = [];
    if( enteredKeyword.isEmpty)
    {
      results = todosList;
    }
    else
    {
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
              borderRadius: BorderRadius.circular(20)
            ),
            child: TextField(
              onChanged: (value) => _runFilter(value),
              decoration: InputDecoration(
                contentPadding: EdgeInsets.all(0),
                prefixIcon: Icon(
                  Icons.search,
                  color: Black, 
                  size:20,
                  ),
                  prefixIconConstraints: BoxConstraints(
                    maxHeight: 20, 
                    minWidth: 25, 
                    ),
                    border: InputBorder.none,
                    hintText: 'Search',
                    hintStyle: TextStyle(color:Grey), 
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
        Icon(
          Icons.menu,
          color: Black, 
        size: 30,
        ),
        Container(
          height: 40,
          width: 40,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.asset('assets/images/123.jpg'), 
          ),
        )
      ],)
    );
  }
}