import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:lettuce_no/utils/checkplatform.dart';
import 'package:lettuce_no/utils/timetableparser.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class DisplayTimetable extends StatelessWidget {
  DisplayTimetable(
      {Key? key,
      required this.selectedCourses,
      required this.completeTimetable})
      : super(key: key);

  List<String> selectedCourses;
  Map<String, dynamic> completeTimetable;

  final List<String> timings = [
    "8:30-9:50",
    "10:00-11:20",
    "11:30-12:50",
    "1:00-2:20",
    "2:30-3:50",
    "4:00-5:20",
    "5:30-6:50",
  ];
  final List<String> days = [
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
  ];

  @override
  Widget build(BuildContext context) {
    // WidgetsFlutterBinding.ensureInitialized();
    // SystemChrome.setPreferredOrientations(
    //     [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
   // SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    // Map<String, Map<String, List<Course>>> newTable =
    generateSelectedTimetable();
    return Scaffold(
      appBar: AppBar(title: Text("Timetable View") ),
      body: Container(
          child: SingleChildScrollView(
        child: Column(
          children: [
            !PlatformInfo().isWeb()?Center(
              child: Container(
                width: !PlatformInfo().isWeb()? width * 0.4: width*0.1,
                child: ElevatedButton(
                    style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(Colors.green[700])),
                    onPressed: () async {
                      print("Save clicked");
                      await saveTimeTable(context);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [Text("Save Timetable"), Icon(Icons.save)],
                    )),
              ),
            ):Container(),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: generateSelectedTimetable().map((c) {
                if (c.runtimeType == String) {
                  return Center(
                    child: Container(
                      margin: EdgeInsets.all(2),
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(5),
                        color: Colors.indigo),
                        height: height * 0.05,
                        width: !PlatformInfo().isWeb()? width * 0.5: width*0.3,
                        child: Center(
                            child: Text(
                          c,
                          textScaleFactor: 1.8,
                          
                        ))),
                  );
                } else {
                  String printable=c.printCourse();
                  return Container(
                      // decoration: BoxDecoration(borderRadius: BorderRadius.circular(5)),
                      // margin: EdgeInsets.fromLTRB(width*0.05, height*0.005, width*0.05, 0),
                      // padding: EdgeInsets.all(width*0.05),
                      height: height * 0.05,
                      child: Center(child: Text(printable)));
                }
              }).toList(),
            ),
          ],
        ),
      )),
    );
  }

  List generateSelectedTimetable() {
    String name, section;
    List<Course> courses = [];
    Map<String, List<dynamic>> generatedTable = {};
    for (String key in completeTimetable.keys) {
      generatedTable[key] = completeTimetable[key]!
          .where((element) =>
              selectedCourses.contains(element.name + "(" + element.section))
          .toList();
    }
    var tempTimings = List.from(timings);
   // tempTimings.removeAt(0);
    Map<String, Map<String, List<Course>>> newTable = {};
    for (String key in generatedTable.keys) {
      Map<String, List<Course>> timeMap = {};
      for (String t in tempTimings) {
        timeMap[t] = [];
        for (Course c in generatedTable[key]!) {
          String convert = convertToTime(c.start);
          if (t.contains(convert)) {
            timeMap[t]!.add(c);
          }
        }
        newTable[key] = timeMap;
      }
    }

    print(generatedTable);

    List gridView = [];
    for (String key in newTable.keys) {
      gridView.add(key);
      for (String t in newTable[key]!.keys) {
        if (newTable[key]![t]!.length < 1) {
          // gridView.add(Course("Free", " ", 0, 0, "-", 0));
        } else {
          for (Course c in newTable[key]![t]!) {
            // print("$key  $t  ");
            // c.printCourse();
            gridView.add(c);
          }
        }
      }
    }
    print(gridView);
    return gridView;
  }

  saveTimeTable(context) async {
    Directory appDocumentsDirectory =
        await getApplicationDocumentsDirectory(); // 1
    String appDocumentsPath = appDocumentsDirectory.path; // 2
    String filePath = '$appDocumentsPath/userTimetable.txt';
    File file = File(filePath);
    await file.writeAsString(jsonEncode( selectedCourses).toString()).then((value) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Row(
        children: [
          Text("Table saved!"),
          Icon(Icons.save),
        ],
      )));
    }).catchError((error, stackTrace) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("$error")));
    });

    var f = File(filePath);
    print(filePath);
    print(jsonDecode(await f.readAsString()));
  }
}
