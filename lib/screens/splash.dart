import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'home_screen.dart';
import 'login_screen.dart';
class SplashScreen extends StatefulWidget {
  @override
  Splash createState() => Splash();
}

class Splash extends State<SplashScreen>  {

  @override
  void initState() {
    super.initState();

  }
  @override
  Widget build(BuildContext context) {
    Timer(
        Duration(seconds: 2),
            () =>
            Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (BuildContext context) => FirebaseAuth.instance.currentUser != null ? HomeScreen() : LoginScreen())));



    return MaterialApp(
      home: Scaffold(
        /* appBar: AppBar(
          title: Text("MyApp"),
          backgroundColor:
              Colors.blue, //<- background color to combine with the picture :-)
        ),*/
        body: Container(
          decoration: const BoxDecoration(color: Colors.white),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/icon/app_icon.png', scale: 5,),
                const Text('Virtual Notice Board', style: TextStyle(fontSize: 32,fontWeight: FontWeight.bold, letterSpacing: -1), textAlign: TextAlign.center,),
                const SizedBox(height: 10,),
                const Text('Admin',style: TextStyle(fontSize: 22,fontWeight: FontWeight.bold),),
                const SizedBox(height: 20,),
                const CircularProgressIndicator.adaptive(),
              ],
            ),
          ),
        ),//<- place where the image appears
      ),
    );
  }
}