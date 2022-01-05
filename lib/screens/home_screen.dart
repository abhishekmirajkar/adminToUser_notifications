import 'dart:convert';

import 'package:admin_college_project/model/message_model.dart';
import 'package:admin_college_project/model/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../drawer.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  User? user = FirebaseAuth.instance.currentUser;
  UserModel loggedInUser = UserModel();
  MessageModel messageModel = MessageModel();
  List<MessageModel> messages = [];
  List messagesId = [];
  List cateData = [];
  bool isLoading = true;
  RefreshController _refreshController =
  RefreshController(initialRefresh: false);
  late TabController _controller;


  void _onRefresh() async{
    await refreshData();
    _refreshController.refreshCompleted();
  }

  @override
  void initState() {
    super.initState();
    _controller = TabController(vsync: this, length: 3);
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

    FirebaseFirestore.instance.collection('category').get().then((value) {
      for (int i = 0; i < value.docs.length; i++) {
        cateData.add(value.docs[i].data());
      }
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
        setState(() {
          isLoading = false;
        });
      });
    });


  }
  @override
  Widget build(BuildContext context) {
    // List<String> categories = ["a", "b", "c", "d", "e", "f", "g", "h"];

    return DefaultTabController(
        length: cateData.length,
        child: new Scaffold(
          drawer: drawer(),
            appBar: new AppBar(
              title: const Text("Student Connect"),
              centerTitle: true,
            ),

            body: isLoading ? Center(child: CircularProgressIndicator.adaptive(),):SmartRefresher(
              enablePullDown: true,
              enablePullUp: true,
              header: WaterDropHeader(),
              controller: _refreshController,
              onRefresh: _onRefresh,
              child: Column(
                children: [
                  SizedBox(height: 30,),
                  Container(
                    height:30,
                    child: TabBar(
                      controller: _controller,
                      indicatorPadding: EdgeInsets.symmetric(horizontal: 25),
                      isScrollable: true,
                      indicatorColor: Color(0XFFFB9481),
                      labelColor: Colors.black,
                      unselectedLabelColor: Colors.grey,
                      tabs: List<Widget>.generate(cateData.length, (int index) {
                        return new Tab(
                            text: "${cateData[index]['cateName']}");
                      }),

                    ),
                  ),
                  Expanded(
                    // height:MediaQuery.of(context).size.height-(MediaQuery.of(context).size.height * 0.2),
                    child: new TabBarView(
                      children: List<Widget>.generate(
                          cateData.length, (int index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: new Column(children:[
                            SizedBox(height: 20,),
                            ListView.builder(
                              shrinkWrap: true,
                              itemCount: messages.length,
                              itemBuilder: (context, i) {
                                return messages[i].cateId == cateData[index]['cateId'] ? Padding(
                                  padding: const EdgeInsets.only(bottom: 15.0),
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(minHeight: 120),
                                    child: Card(
                                      shape: RoundedRectangleBorder(
                                        side: new BorderSide(color: Theme.of(context).primaryColor, width: 2.0),
                                        borderRadius: BorderRadius.circular(10.0),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(crossAxisAlignment: CrossAxisAlignment.start,children: [
                                          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,children: [
                                            Text(messages[i].admin!,style: TextStyle(fontWeight: FontWeight.w600),),
                                            Text(cateData[index]['cateName'],style: TextStyle(fontWeight: FontWeight.w600)),
                                            Text(messages[i].date!,style: TextStyle(fontWeight: FontWeight.w600)),

                                          ],),
                                          SizedBox(height: 30,),
                                          Text(messages[i].messageData!,overflow: TextOverflow.ellipsis),
                                        ],),
                                      ),
                                    ),
                                  ),
                                ): Container();
                              },
                            )
                          ]),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            )
        ));
  }
}
