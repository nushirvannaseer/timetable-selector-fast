import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lettuce_no/models/society.dart';

class SocietyHomePage extends StatefulWidget {
  SocietyHomePage({Key? key, required this.society}) : super(key: key);
  Society society;

  @override
  _SocietyHomePageState createState() => _SocietyHomePageState();
}

class _SocietyHomePageState extends State<SocietyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Lettuce No")),
      body:  Container(
          height: MediaQuery.of(context).size.height*0.2,
          color: Colors.purple,
          child: Column(children: [
            Expanded(child: Center(child: Text("Name: "+this.widget.society.name)),),
            Expanded(child: Center(child: Text("Roll No: "+ this.widget.society.username)),),
            ElevatedButton(onPressed: ()=> print("View Executive Team button pressed"), child: Text("View Executive Team")),
            ElevatedButton(onPressed: ()=> print("View Student Questions/Suggestions pressed"), child: Text("View Student Questions/Suggestions")),
            
          ],),
    
      ),
    );
  }
}
