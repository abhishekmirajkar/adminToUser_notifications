import 'dart:convert';

import 'package:admin_college_project/model/message_model.dart';
import 'package:admin_college_project/model/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../drawer.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  User? user = FirebaseAuth.instance.currentUser;
  UserModel loggedInUser = UserModel();
  MessageModel messageModel = MessageModel();
  List<MessageModel> messages = [];
  List messagesId = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    refreshData();
  }

  refreshData(){
    setState(() {
      isLoading = true;
    });
    messages.clear();
    messagesId.clear();
    FirebaseFirestore.instance
        .collection("admins")
        .doc(user!.uid)
        .get()
        .then((value) {
      print(value.data());
      this.loggedInUser = UserModel.fromMap(value.data());
      setState(() {});
    });

    FirebaseFirestore.instance
        .collection('messages')
        .where("adminId", isEqualTo: loggedInUser.uid)
        .get()
        .then((value) {
      for (int i = 0; i < value.docs.length; i++) {
        messageModel = messageModelFromJson(json.encode(value.docs[i].data()));
        messages.add(messageModel);
        messagesId.add(value.docs[i].id);
      }
      setState(() {});
    });

    setState(() {
      isLoading = false;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: drawer(),
      appBar: AppBar(
        title: const Text("Welcome"),
        centerTitle: true,
      ),
      body: Center(
        child: isLoading? CircularProgressIndicator.adaptive() : Padding(
          padding: EdgeInsets.all(20),
          child: ListView.builder(
            itemCount: messages.length,
            itemBuilder: (context, i) {
              return messages.isEmpty
                  ? Center(
                      child: Text("You don't have any messages"),
                    )
                  : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                          child: Text(messages[i].messageData!),
                        ),
                      IconButton(onPressed: ()async{
                        FirebaseFirestore.instance
                            .collection('messages')
                            .doc(messagesId[i])
                            .delete().then((value) => setState(() {
                          refreshData();
                        }));
                      },icon:Icon(Icons.delete),),
                    ],
                  );
            },
          ),
        ),
      ),
    );
  }
}
