  class ToDo {
  String? id;
  String? todoText;
  bool isDone;
  DateTime createdDate;
  DateTime? deadlineDate;
  bool isFavorite; //add a new bool for favorite

  ToDo({
    required this.id,
    required this.todoText,
    this.isDone = false,
    required this.createdDate,
    this.deadlineDate,
    this.isFavorite = false,
  });

  static List<ToDo> todoList() {
    return [
      /*ToDo(id: '01', todoText: 'Moring Exe', isDone: true),
      ToDo(id: '02', todoText: 'Buy Cards', isDone: true),
      ToDo(id: '03', todoText: 'Eat', isDone: true, ),
      ToDo(id: '04', todoText: 'Team meeting', isDone: true,  ),
      ToDo(id: '05', todoText: 'Play', ),
      ToDo(id: '06', todoText: 'Sleep', ),*/
    ];
  }
}