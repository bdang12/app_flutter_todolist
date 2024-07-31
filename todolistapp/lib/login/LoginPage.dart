import 'package:flutter/material.dart';
import 'package:namer_app/Database/database_helper.dart';
import 'package:namer_app/screen/home.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<void> _register() async {
    if(_formKey.currentState!.validate()) {
      String username = _usernameController.text;
      String email = _emailController.text;
      await DatabaseHelper().insertUser(username, email);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('User registered successfully'),
      ));
    }
  }
    Future<void> _login() async {
      if (_formKey.currentState!.validate()) {
        String username = _usernameController.text;
        String email = _emailController.text;
      var user = await DatabaseHelper().getUser(username, email);
      if(user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => Home(userId: user['id'])
            ),
        );
      }
      else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Invalid username or email'),
            )
          );
      }
    }
  } 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
        backgroundColor: Colors.blue,
      ),
      backgroundColor: Colors.yellow,
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(labelText: 'Username'),
                validator: (value){
                  if(value == null || value.isEmpty) {
                    return 'Plese enter your username';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value){
                  if(value == null || value.isEmpty) {
                    return 'Plese enter your email';
                  }
                  return null;
                },
              ),

              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _login,
                child: Text('Login'),
                ),
               ElevatedButton(
                onPressed: _register,
                child: Text('Register'), 
                ), 
            ],
          ),
          ),
        ),
    );
  }
}
