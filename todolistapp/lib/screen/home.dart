import 'package:flutter/material.dart';
import 'package:namer_app/constant/color.dart';
import 'package:namer_app/items/to_do_items.dart';
import 'package:namer_app/model/todo.dart';
import 'package:namer_app/favorites/FavoritesPage.dart';
import 'dart:async';

// Dart file for home screen
// This is structure for Home class with a stateful widget to put action touch to home page.
class Home extends StatefulWidget{
  Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> { //This is the home state class that keep all the app bar + drawer + every thing that in the home page
  final todosList = ToDo.todoList(); 
  List<ToDo> _foundToDo = []; //list for todo
  final _todoController = TextEditingController();
  final _todoFocusNode = FocusNode(); 
  bool _isSnackbarActive = false;//set state for snack bar not turn on currently

  @override
  void initState() {
    _foundToDo = todosList;
    Timer.periodic(Duration(minutes: 1), (timer) {
      _checkDeadlines();
    });
    super.initState();
  }
@override
  void dispose() {
    _todoController.dispose();
    _todoFocusNode.dispose(); // Dispose the focus node
    super.dispose();
  }

  void _checkDeadlines() {
    setState(() {
      for(ToDo todo in todosList) {
        if(todo.deadlineDate != null && todo.deadlineDate!.isBefore(DateTime.now())) {todo.isDone = true;
        }
      }
    });
  }
  // This structure is build for the app bar
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
    
    child: Scaffold(
      backgroundColor: Yellow,
      appBar: _buildAppBar(), //make the app bar + get the place build the app bar below
      drawer: _buildDrawer(), // make the drawer + get the place build the drawer below
      body: Stack(
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 20,
             vertical: 15,
             ),
            child: Column(
              children: [
                searchBox(), //this one create a search box
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
                      onDeleteItem: (id) {
                        if (id != null) {
                          _confirmDelete(context, id);  //change this one when add confirm delete below
                        }
                      },
                      onFavoriteChanged: _handleFavoriteChange, //add this new favorite change line
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
                focusNode: _todoFocusNode, // Set the focus node
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
    ),
    );
  }

  void _handleToDoChange(ToDo todo) {
    setState(() {
      todo.isDone = !todo.isDone;
    });
   
  }

  void _handleFavoriteChange(ToDo todo) {
    setState(() {
      todo.isFavorite = !todo.isFavorite;
    });
  }
  void _confirmDelete(BuildContext context, String id)
  {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Are you sure you want to delete this to do items?'),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); //Dismiss dialog
              },
            ),
            TextButton(
              child: Text('Yes'),
              onPressed: () {
                _deleteToDoItem(id);
                Navigator.of(context).pop(); //Dismiss dialog
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
    });
   
  }
  

  void _addToDoItem(String toDo) async{
    String trimmedToDo = toDo.trim();
    if(trimmedToDo.isEmpty)   //This make the add button not up the text if the text is blank
    {
      _showSnackbar(context, "Error, cannot add a blank todo item");
      return;
    }
    DateTime? deadline = await _selectDeadlineDate(context);
    if (deadline == null) {
      _showSnackbar(context, "Cancelled: To-Do item not added");
    return;
    }
    //check for date and time of begin and deadline date
    DateTime beginTime = DateTime.now();
    if(deadline.isBefore(beginTime)) {
      _showSnackbar(context, "Error, deadline must be later than current date and time");
      return;
    }

    setState(() { //this set a state for time
       todosList.add(ToDo(
    id: DateTime.now().millisecondsSinceEpoch.toString(),
    todoText: trimmedToDo,
    createdDate: DateTime.now(),
    deadlineDate: deadline,
    ));

    });
    _todoController.clear();
    _todoFocusNode.unfocus();
    //FocusScope.of(context).unfocus(); //This will hide the keyboard when finish adding
   
  }

  Future<DateTime?> _selectDeadlineDate(BuildContext context) async { //This create a structure for create day and time

    //FocusScope.of(context).unfocus(); // Hide the keyboard
    DateTime? selectedDate = await showDatePicker( // this create a day picker to select day
      context: context,
      initialDate: DateTime.now(), //ngay khoi tao
      firstDate: DateTime.now(), //ngay bat day
      lastDate: DateTime(2100), //ngay ket thuc
    );
    if(selectedDate != null) { //set condition if date is not null it will change to select time part
      TimeOfDay? selectedTime = await showTimePicker( //this create a time picker to select time 
        context: context,
        initialTime: TimeOfDay.now(), //gio khoi tao
      );
      if(selectedTime != null) { //set condition if set a time is not null, return year month day hour and minute
        return DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          selectedTime.hour,
          selectedTime.minute,
        );
      }
    }
    return null; //else it will return null
  }

  //add a SnackBar Method to give notify when user input blank text
  void _showSnackbar(BuildContext context, String message)
  {
    if(_isSnackbarActive) return; //return if the issnackbaractive is true

    setState(() {
      _isSnackbarActive = true; //setstate issnackbar active = true
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar( //snackbar content + duration + action
        content: Text(message),
        duration: Duration(seconds: 6),
        action: SnackBarAction(
          label: 'Dismiss', //Dismiss label when user press it will exit the snackbar
          onPressed: () {
            //Dismiss SnackBar
          },
        )
        )
      ).closed.then((reason) {
    setState(() {
      _isSnackbarActive = false; //set state is snackbaractive is false
    });
  });
  }

  void _runFilter(String enteredKeyword) { //this will filter the word in the search bar to get the right to do item
    List<ToDo> results = []; //if condition 
    if( enteredKeyword.isEmpty) // if enter keyword is empty result will equal to do list
    {
      results = todosList; 
    }
    else                        //else search a word that has a letter in todo item
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
  Widget searchBox() { //create a widget for search box
    return Container(
              padding: EdgeInsets.symmetric(horizontal: 15), //create a edge move horizontally look like a search bar
              decoration: BoxDecoration( //create color, 
              color: Colors.white,
              borderRadius: BorderRadius.circular(20) //create a radius border for search bar make it not to shappy like a square
            ),
            child: TextField(
              onChanged: (value) => _runFilter(value), //insert a runfilter structure to filter the word for app bar
              decoration: InputDecoration( //decorate for the searching text word 
                contentPadding: EdgeInsets.all(0), // create a pixel for all size currently(0)
                prefixIcon: Icon( //decor for the search bar + text in search bar
                  Icons.search,
                  color: Black, 
                  size:20,
                  ), 
                  prefixIconConstraints: BoxConstraints(
                    maxHeight: 20, 
                    minWidth: 25, 
                    ),
                    border: InputBorder.none,
                    hintText: 'Search', //text for searching
                    hintStyle: TextStyle(color:Grey), 
              ),
            ),
            );
  }

  AppBar _buildAppBar() {  // Build app bar here
    return AppBar(
      backgroundColor: Blue, //background color is blue
      
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, //make the children should place in the main axis in layout
        children: [
          Builder(
        builder: (context) => IconButton(   // create a 3 line icon for the app bar
        icon: Icon( null
          //Icons.favorite,
          //color: Red, 
        //size: 30,
        ),
        onPressed: () => Scaffold.of(context).openDrawer(), //this one make the user press the menu bar it will scroll down the drawer the have icon in there
        ),
          ),
        Container( //This container is for the personal image
          height: 40,
          width: 40,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),  // make a space between menu bar and the image
            child: Image.asset('assets/images/123.jpg'),  //create myself image 
          ),
        ),
      ],
      )
    );
  }
  Drawer _buildDrawer() { //build drawer here
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero, //this one add 8 pizel around every side but currently (0)
        children: <Widget> [
          DrawerHeader(
            decoration: BoxDecoration(
            color: Blue,// Background color is blue + white below
          ),
          child: Text(
            'Menu', // create a menu text for the drawer out side the background
            style: TextStyle(
              color: Colors.white, // this one is background color, style, and size
              fontSize: 24,
            ),
          ),
      ),
      //create a tile for info about here
      ListTile(
        leading: Icon(Icons.info), //structure for info icon + 
        title: Text('About'),
        onTap: () {
          Navigator.pop(context); //this one navigate when click to about icon lead to the _showaboutdiaglog text below.
          _showAboutDialog(context); //insert _showAboutDialog text.
        },
      ),
        ListTile(
        leading: Icon(Icons.login), //this create a login icon
        title: Text('Log in'),
        onTap: () {
          Navigator.pop(context); // when click on it will navigate to login below
          _navigateToLogin(context); // insert navigate to login
        },
        ),
        ListTile(
          leading: Icon(Icons.star), //this create a favrorite('star') icon 
          title: Text('Favorites'),
          onTap: () {
            Navigator.pop(context); //when user click on the favorite it will navigate to favorite below
            _navigateToFavorite(context); // insert navigate to favorite
          }
        )
        ],
      ),
    );
  }
  void _showAboutDialog(BuildContext context)  //this show a dialog of the about info
  {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('About'),
          content: Text('This is To-Do list application. That make by Bill Binh', //this is the text about the info
           ),
          actions: [
            TextButton( // this is a button to close the dialog bar
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
  void _navigateToLogin(BuildContext context) //this one navigate to login structure when user click on navigate login but didnt implement anything yet
  {
    //Implement this later
  }
  void _navigateToFavorite(BuildContext context){// this one navigate to favorite when user click on the star icon
    Navigator.push( //this push the todoitem have a favorite turn on to the favorite bar
      context,
      MaterialPageRoute(
        builder: (context) => FavoritesPage(todoList: todosList), //this is the favorite page library
        ),
    );
  }
}