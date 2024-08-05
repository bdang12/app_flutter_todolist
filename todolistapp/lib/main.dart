import 'package:flutter/material.dart';
import 'package:namer_app/login/LoginPage.dart';
import 'package:namer_app/screen/home.dart';
import 'package:firebase_core/firebase_core.dart';

//This is project structure 
Future <void> main() async{   
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) :super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
        title: 'Namer App',   //create a name for the app here
        home: LoginPage(),
    );
}
}

