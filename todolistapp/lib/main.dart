import 'package:flutter/material.dart';
import 'package:namer_app/screen/home.dart';

//This is project structure 
void main() {   
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) :super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
        title: 'Namer App',   //create a name for the app here
        home: Home(),
    );
}
}

