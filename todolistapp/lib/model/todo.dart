  class ToDo { // This is a class for to do item which have a id, todoText, boolean isDone, boolean is Favorite and date begin and end
  String? id;
  String? todoText;
  bool isDone;
  DateTime createdDate;
  DateTime? deadlineDate;
  bool isFavorite; //add a new bool for favorite
  int userId;

  ToDo({
    required this.id,
    required this.todoText,
    this.isDone = false,
    required this.createdDate,
    this.deadlineDate,
    this.isFavorite = false,
    required this.userId,
  });

  /*static List<ToDo> todoList() { //This create a list of to do that have the variable call out above
    return [
      /*ToDo(id: '01', todoText: 'Moring Exe', isDone: true),
      ToDo(id: '02', todoText: 'Buy Cards', isDone: true),
      ToDo(id: '03', todoText: 'Eat', isDone: true, ),
      ToDo(id: '04', todoText: 'Team meeting', isDone: true,  ),
      ToDo(id: '05', todoText: 'Play', ),
      ToDo(id: '06', todoText: 'Sleep', ),*/
    ];
  }*/

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'todoText': todoText,
      'isDone': isDone ? 1 : 0,
      'isFavorite': isFavorite ? 1 : 0,
      'createdDate': createdDate.toIso8601String(),
      'deadlineDate': deadlineDate?.toIso8601String(),
      'userId': userId, //include userid for todo.dart
    };

    
  }
}