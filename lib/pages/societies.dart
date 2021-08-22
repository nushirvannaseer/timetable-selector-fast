import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lettuce_no/models/society.dart';
import 'package:lettuce_no/pages/societyviewpage.dart';
import 'package:lettuce_no/router/router.dart';

class Societies extends StatefulWidget {
  const Societies({Key? key}) : super(key: key);

  @override
  _SocietiesState createState() => _SocietiesState();
}

class _SocietiesState extends State<Societies> {
  dynamic firestoreInstance = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Societies")),
        body: StreamBuilder<QuerySnapshot>(
          stream: firestoreInstance.collection("societies").snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              var societies = snapshot.data!.docs;
              return ListView.builder(
                  itemCount: societies.length,
                  itemBuilder: (context, i) {
                    return InkWell(
                        onTap: () {
                          print("${societies[i]['name']} tapped");
                          firestoreInstance
                              .collection('societies')
                              .where('name', isEqualTo: societies[i]["name"])
                              .get()
                              .then((data) {
                            dynamic x = data.docs[0];
                            Society s=Society(x['name'], x['username'],
                                        x['password']);
                                        s.events=Map<String, dynamic>.from(x['events']);
                                        s.executiveTeam=Map<String, String>.from(x['executiveTeam']);
                            Navigator.of(context).push(router(
                                context,
                                SocietyViewPage(
                                    society: s )));
                          });
                        },
                        child: Container(
                            child: Text(societies[i]["name"].toString())));
                  });
            } else
              return CircularProgressIndicator();
          },
        ));
  }
}
