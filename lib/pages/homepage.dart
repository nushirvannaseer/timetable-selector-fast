import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lettuce_no/pages/displaycreatedtimetable.dart';
import 'package:lettuce_no/pages/timetable.dart';
import 'package:lettuce_no/pages/viewfreerooms.dart';
import 'package:lettuce_no/router/router.dart';
import 'package:lettuce_no/utils/timetableparser.dart';
import 'package:path_provider/path_provider.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);
  //Student student;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
      body: Center(
        child: Container(
          height: MediaQuery.of(context).size.height * 0.6,
          child: Column(
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
                  return tables != null
                      ? DisplayTimetable(
                          selectedCourses: tables[0],
                          completeTimetable: tables[1])
                      : null;
                },
              ),
              GridButton(
                "Free Rooms",
                null,
                context,
                preProcessing: () async {
                  var table = await getSavedTimetable();
                  return table != null
                      ? ViewFreeRooms(completeTimetable: table[1])
                      : null;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  GridButton(buttonText, buttonRoute, context, {preProcessing}) {
    return 
        Container(
          margin: EdgeInsets.all(10),
            height: MediaQuery.of(context).size.height * 0.1,
            
          child:Material(
            color: Colors.indigo,
            child: InkWell(
                  onTap: () async {
            if (preProcessing != null) {
              buttonRoute = await preProcessing();
            }
            if (buttonRoute != null)
              Navigator.push(context, router(context, buttonRoute));
            else
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                backgroundColor: Colors.red,
                content: Text("No Saved Timetable!", style: TextStyle(color: Colors.white),),
              ));
                  },
              
              child: Center(child: Text(buttonText))),
          ));
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
