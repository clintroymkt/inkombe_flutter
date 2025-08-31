import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../services/database_service.dart';
import '../widgets/list_card.dart';
import 'create_cow_page.dart';

class DatabasePage extends StatefulWidget {
  const DatabasePage({super.key});

  @override
  State<DatabasePage> createState() => _DatabasePageState();
}

class _DatabasePageState extends State<DatabasePage> {

  Stream<QuerySnapshot>? updates;
  User? currentUser = FirebaseAuth.instance.currentUser;


  preloadUpdates(){
    updates = DatabaseService().getCattleUpdates();
    print(currentUser?.uid);
  }

  @override
  void initState(){
    preloadUpdates();
    super.initState();
  }

  @override
  void dispose(){
    super.dispose();
    preloadUpdates();
    updates;
  }

  var doc;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          constraints: const BoxConstraints.expand(),
          color: const Color(0xFFFFFFFF),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  color: const Color(0xFFFFFFFF),
                  padding: const EdgeInsets.only( top: 41),
                  width: double.infinity,
                  height: double.infinity,
                  child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only( bottom: 17, left: 18),
                            child: Column(
                              children: [
                                const Text(
                                  'Actions',
                                  style: TextStyle(
                                    color: Color(0xFF000000),
                                    fontSize: 24,
                                  ),

                                ),

                                const SizedBox(height: 30,),

                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                                  child: GestureDetector(
                                    onTap: ()  {
                                      // Navigator.push(
                                      //   context,
                                      //   MaterialPageRoute(builder: (context) =>  const CreateCowPage()),
                                      // );
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                          color: const Color(0xFF064151),
                                          borderRadius: BorderRadius.circular(12)
                                      ),

                                      child: const Center(
                                        child: Text('Add Cow', style: TextStyle(color:Colors.white),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 30,),
                              ],
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only( bottom: 16, left: 20),
                            child: const Text(
                              'Cattle ',
                              style: TextStyle(
                                color: Color(0xFF000000),
                                fontSize: 24,
                              ),
                            ),
                          ),
                          IntrinsicHeight(
                            child: Container(
                                color: const Color(0xFFFFFFFF),
                                padding: const EdgeInsets.only( top: 20, bottom: 20, left: 16, right: 16),
                                margin: const EdgeInsets.only( bottom: 31),
                                width: double.infinity,
                                child :  StreamBuilder(
                                    stream: updates,
                                    builder: (context, AsyncSnapshot snapshot){
                                      if (snapshot.hasData){
                                        var docs = snapshot.data.docs;
                                        return  Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              for (doc in docs)
                                                ListCard(
                                                  title: doc.data()['name'],
                                                  date: doc.data()['dateAdded'],
                                                  imageUri: doc.data()['image'],
                                                  docId: doc.id,
                                                )
                                            ]
                                        );
                                      }
                                      return const SizedBox();//return empty widget here
                                    })
                            ),
                          ),
                        ],
                      )
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}