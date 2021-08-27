// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:lettuce_no/models/society.dart';

// class SocietyViewPage extends StatefulWidget {
//   SocietyViewPage({Key? key, required this.society}) : super(key: key);
//   Society society;

//   @override
//   _SocietyViewPageState createState() => _SocietyViewPageState();
// }

// class _SocietyViewPageState extends State<SocietyViewPage> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Lettuce No")),
//       body:  Container(
//           height: MediaQuery.of(context).size.height*0.2,
//           color: Colors.purple,
//           child: Column(children: [
//             Expanded(child: Center(child: Text("Name: "+this.widget.society.name)),),
//             Expanded(child: Center(child: Text("Username: "+ this.widget.society.username)),),
//             ElevatedButton(onPressed: ()=> print("View Executive Team button pressed. ${this.widget.society.executiveTeam!['president']}"), child: Text("View Executive Team")),
//             ElevatedButton(onPressed: ()=> print("Add an Event Request/Suggestion pressed"), child: Text("Add an Event Request/Suggestion")),
            
//           ],),
    
//       ),
//     );
//   }
// }
