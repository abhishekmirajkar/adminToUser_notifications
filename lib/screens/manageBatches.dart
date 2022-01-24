import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ManageBatch extends StatefulWidget {
  const ManageBatch({Key? key}) : super(key: key);

  @override
  _ManageBatchState createState() => _ManageBatchState();
}

class _ManageBatchState extends State<ManageBatch> {
  var batchData = [];
  bool isLoading = true;
  final _formKey = GlobalKey<FormState>();
  final batchEditingController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchData();
  }

  fetchData(){
    batchData.clear();
    FirebaseFirestore.instance.collection('batches').get().then((value) {
      for (int i = 0; i < value.docs.length; i++) {
        batchData.add(value.docs[i].data());
      }
      setState(() {
        isLoading = false;
      });
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Student Connect"),
        leading: GestureDetector(
            child: Icon(Icons.arrow_back_ios),
            onTap: () {
              Navigator.pop(context);
            }),
        centerTitle: true,
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator.adaptive(),
            )
          : Column(
              children: [
                SizedBox(height: 10,),
                Text("Batch Details",textAlign: TextAlign.center,style: TextStyle(fontWeight: FontWeight.w700,fontSize: 22),),

                SizedBox(height: 10,),
                ListView.builder(
                  shrinkWrap: true,
                  itemBuilder: (context, i) {
                    return ItemTile(
                      tileData: batchData,index: i,
                      removefuntion:(){
                        setState(() {
                          isLoading = true;
                          FirebaseFirestore.instance
                              .collection('batches')
                              .doc(batchData[i]['batchId'])
                              .delete().then((value) => setState(() {
                            isLoading = false;
                            batchData.removeAt(i);
                          }));

                        });
                      }
                    );
                  },
                  itemCount: batchData.length,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                        onTap: () {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return Dialog(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                  elevation: 16,
                                  child: Container(
                                    child: ListView(
                                      shrinkWrap: true,
                                      children: <Widget>[
                                        SizedBox(height: 20),
                                        Form(
                                          key: _formKey,
                                          child: Center(child: Container(
                                            width: MediaQuery.of(context).size.width/1.4,
                                            child: TextFormField(
                                                keyboardType: TextInputType.multiline,
                                                autofocus: false,
                                                controller: batchEditingController,
                                                validator: (value) {
                                                  if (batchEditingController.text.isEmpty) {
                                                    return "Batch Can't Be Empty";
                                                  }
                                                },
                                                onSaved: (value) {
                                                  batchEditingController.text = value!;
                                                },
                                                textInputAction: TextInputAction.done,
                                                decoration: InputDecoration(
                                                  prefixIcon: Icon(Icons.message),
                                                  contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
                                                  hintText: "Enter Batch Name",
                                                  border: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(10),
                                                  ),
                                                )),
                                          )),
                                        ),
                                        SizedBox(height: 20),
                                        Padding(
                                          padding: EdgeInsets.symmetric(horizontal:MediaQuery.of(context).size.width/8),
                                          child: ElevatedButton(onPressed: (){
                                            if(_formKey.currentState!.validate() && batchEditingController.text != null ){
                                              setState(() {
                                                isLoading = true;
                                              });
                                             var ref =  FirebaseFirestore.instance
                                                  .collection('batches').doc();
                                             print(ref.id);
                                              ref.set({
                                                "batchId": ref.id,
                                                "batchName": batchEditingController.text
                                              }).then((value) => setState(() {
                                                Navigator.pop(context);
                                                batchEditingController.text = "";
                                                fetchData();
                                              }));
                                            }
                                          }, child: Text("Save")),
                                        )
                                      ],
                                    ),
                                  ),
                                );
                              });
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(right:38.0),
                          child: Text("Add Batch +",style: TextStyle(fontSize: 18,decoration: TextDecoration.underline,),),
                        )),
                  ],
                )
              ],
            ),
    );
  }
}

class ItemTile extends StatefulWidget {
  var tileData;
  int index;
  VoidCallback? removefuntion;
  ItemTile({Key? key, required this.tileData,required this.index,this.removefuntion}) : super(key: key);

  @override
  _ItemTileState createState() => _ItemTileState();
}

class _ItemTileState extends State<ItemTile> {
  bool isEditable = true;
  final textEditingController = TextEditingController();
  bool isLoading = false;
  final _formKey1 = GlobalKey<FormState>();

  @override
  void initState() {
    // TODO: implement initState
    textEditingController.text = widget.tileData[widget.index]['batchName'];
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(
            child: CircularProgressIndicator.adaptive(),
          )
        : Padding(
          padding: const EdgeInsets.symmetric(vertical:8.0),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Form(
                  key: _formKey1,
                  child: Container(
                          width: MediaQuery.of(context).size.width -
                              MediaQuery.of(context).size.width / 3,
                          child: TextFormField(
                              keyboardType: TextInputType.multiline,
                              autofocus: false,
                              controller: textEditingController,
                              validator: (value) {
                                if (textEditingController.text.isEmpty) {
                                  return "Batch Can't Be Empty";
                                }
                              },
                              onChanged: (value) {
                               isEditable = false;
                              },
                              onSaved: (value) {
                                textEditingController.text = value!;
                              },
                              textInputAction: TextInputAction.done,
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
                                hintText: widget.tileData[widget.index]['batchName'],
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              )),
                        ),
                ),
                SizedBox(width: 10,),
                GestureDetector(
                    onTap: () {
                      setState(() {
                        if (_formKey1.currentState!.validate() && isEditable) {
                          setState(() {
                            isLoading = true;
                          });
                          FirebaseFirestore.instance
                              .collection('batches')
                              .doc(widget.tileData[widget.index]['batchId'])
                              .set({
                            "batchId": widget.tileData[widget.index]['batchId'],
                            "batchName": textEditingController.text
                          }).then((value) => setState(() {
                                    isEditable = false;
                                    isLoading = false;
                                    widget.tileData[widget.index]['batchName'] =
                                        textEditingController.text;
                                  }));
                        } else {
                          isEditable = !isEditable;
                        }
                      });
                    },
                    child:  Icon(Icons.save,color: Theme.of(context).primaryColor,size: 30)),
                SizedBox(width: 5,),
                GestureDetector(
                    onTap: widget.removefuntion,
                    child: Icon(Icons.delete,color: Colors.red,size: 30,))
              ],
            ),
        );
  }
}
