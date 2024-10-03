
import 'dart:developer';

import 'package:project2/Homepagge.dart';
import 'package:project2/RegisterScreen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailcontroller = TextEditingController();
  final TextEditingController passcontroller = TextEditingController();
  Future<void> login() async{
    final response = await http.post(Uri.parse("https://reqres.in/api/login"),
      body: {
        'email': emailcontroller.text,
        'password': passcontroller.text
      } );
      if (response.statusCode ==200) {
        log("login berhasil"); 
        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) =>HomePage()), (context) => false );
      } else {
        log("gagal");
      }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: emailcontroller,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: passcontroller,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                 login(); 
                },
                child: Text('Login'),
              ),
              TextButton(
                onPressed: () {
                  
                  // Switch to the Register page
                  Navigator.of(context).push(MaterialPageRoute(builder: (context)=>RegisterScreen()));
                },
                child: Text('Don\'t have an account? Register'),
              ),
            ],
          ),
        )
      ),
    );
  }
}
