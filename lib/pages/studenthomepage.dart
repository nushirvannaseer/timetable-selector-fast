import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lettuce_no/models/society.dart';
import 'package:lettuce_no/models/student.dart';
import 'package:lettuce_no/pages/displaycreatedtimetable.dart';
import 'package:lettuce_no/pages/societies.dart';
import 'package:lettuce_no/pages/societyhomepage.dart';
import 'package:lettuce_no/pages/timetable.dart';
import 'package:lettuce_no/pages/viewfreerooms.dart';
import 'package:lettuce_no/router/router.dart';
import 'package:lettuce_no/utils/timetableparser.dart';
import 'package:path_provider/path_provider.dart';

class StudentHomePage extends StatefulWidget {
  StudentHomePage({Key? key, required this.student}) : super(key: key);
  Student student;

  @override
  _StudentHomePageState createState() => _StudentHomePageState();
}

class _StudentHomePageState extends State<StudentHomePage> {
  @override
  Widget build(BuildContext context) {
    WidgetsFlutterBinding.ensureInitialized();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    return MainScaffold(context);
  }

  Scaffold MainScaffold(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Timetable Manager")),
      //drawer: Drawer(),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        //crossAxisCount: 3,
        children: [
          // GridButton("View Societies", Societies()),
          // GridButton("View Departments", null),
          GridButton("Create a Timetable", TimeTableViewer(), context),
          GridButton(
            "My Timetable",
            null,
            context,
            preProcessing: () async {
              var tables = await getSavedTimetable();
              return DisplayTimetable(
                  selectedCourses: tables[0], completeTimetable: tables[1]);
            },
          ),
          GridButton(
            "Free Rooms",
            null,
            context,
            preProcessing: () async {
              var table = await getSavedTimetable();
              return ViewFreeRooms(completeTimetable: table[1]);
            },
          ),
        ],
      ),
    );
  }

  GridButton(buttonText, buttonRoute, context,{preProcessing }) {
    return InkWell(
        onTap: () async {
          if (preProcessing != null) {
            buttonRoute = await preProcessing();
          }
          if (buttonRoute != null)
            Navigator.push(context, router(context, buttonRoute));
        },
        child: Container(
          margin: EdgeInsets.all(25),
          height: MediaQuery.of(context).size.height*0.1,
            color: Colors.indigo, child: Center(child: Text(buttonText))));
  }

  getSavedTimetable() async {
    Directory appDocumentsDirectory =
        await getApplicationDocumentsDirectory(); // 1
    String appDocumentsPath = appDocumentsDirectory.path; // 2
    String filePath = '$appDocumentsPath/userTimetable.txt';
    print(filePath);
    if (File(filePath).existsSync()) {
      List<dynamic> courses = [];
      return File(filePath).readAsString().catchError((error, stackTrace) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("No Saved Timetables Found")));
        return null;
      }).then((q) {
        courses = jsonDecode(q);

        var table = jsonDecode(File(appDocumentsPath + "/completeTimetable.txt")
            .readAsStringSync());
        for (String key in table.keys) {
          table[key] = table[key]!.map((e) {
            return Course.fromJson(e);
          }).toList();
        }

        return [courses.map((e) => e.toString()).toList(), table];
      });
    }
  }
}
