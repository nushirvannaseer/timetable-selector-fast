import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:excel/excel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import 'package:lettuce_no/pages/displaycreatedtimetable.dart';
import 'package:lettuce_no/router/router.dart';
import 'package:lettuce_no/utils/checkinternet.dart';
import 'package:lettuce_no/utils/timetableparser.dart';

class TimeTableViewer extends StatefulWidget {
  const TimeTableViewer({Key? key}) : super(key: key);

  @override
  _TimeTableViewerState createState() => _TimeTableViewerState();
}

class _TimeTableViewerState extends State<TimeTableViewer> {
  firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;
  firebase_storage.Reference ref =
      firebase_storage.FirebaseStorage.instance.ref().child('/timetable.xlsx');
  dynamic userCredential = () async {
    return await FirebaseAuth.instance.signInAnonymously();
  };

  List<String> selectedCourses = [];
  List<String> courses = [];
  Map<String, dynamic> timetable = {};
  int numOfCourses = 0;
  bool timetableLoaded = false;
  bool inProgress = false;

  @override
  void initState() {
    super.initState();
    userCredential = userCredential();
    loadTimeTable();
  }

  @override
  Widget build(BuildContext context) {
    WidgetsFlutterBinding.ensureInitialized();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    // print(x.toString());
    return timetableLoaded == true
        ? Scaffold(
            resizeToAvoidBottomInset: false,
            appBar: AppBar(
              title: Text("Choose Timetable"),
            ),
            body: Center(
              child: Column(
                children: [
                  Container(
                    
                   width: MediaQuery.of(context).size.width*0.98,
                    child: Expanded(
                      flex:1,
                      child: DropdownButton<String>(
                       isExpanded: true,
                        hint: Text("Click to select a course", textAlign:TextAlign.center),
                        
                        value: null,
                        icon: const Icon(Icons.add),
                        iconSize: 21,
                        elevation: 16,
                        style: const TextStyle(color: Colors.white),
                        underline: Container(
                          width: MediaQuery.of(context).size.width*0.5,
                          height: 2,
                          color: Colors.white
                        ),
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedCourses.add(newValue!);
                          });
                        },
                        items:
                            courses.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 10,
                    child: SingleChildScrollView(
                      child: Column(
                        children: selectedCourses.map(
                          (e) {
                            return Container(
                              width: MediaQuery.of(context).size.width*0.95,
                              margin: EdgeInsets.all(1),
                              color: Colors.indigo,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Text(e,),
                                  IconButton(
                                    icon: Icon(Icons.delete),
                                    onPressed: () {
                                      setState(() {
                                        selectedCourses.remove(e);
                                      });
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        ).toList(),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                         style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(Colors.indigo)),
                        onPressed: () {
                          if (selectedCourses.length > 0) {
                            print("Selected courses $selectedCourses");
                            Navigator.push(
                                context,
                                router(
                                    context,
                                    DisplayTimetable(
                                      selectedCourses: selectedCourses,
                                      completeTimetable: timetable,
                                    )));
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              backgroundColor:Colors.yellow,
                              content: Text("Please Select At Least 1 Course!"),
                            ));
                          }
                        },
                        child: Text("Generate Table"),
                      ),
                      inProgress == false
                          ? ElevatedButton(
                             style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(Colors.indigo)),
                              onPressed: () async {
                                this.setState(() {
                                  inProgress = true;
                                });
                                String filePath = await downloadTimeTable();
                                if (filePath == "") {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                         backgroundColor:Colors.red,
                                          content: Text(
                                           
                                              "Error downloading timetable. Please check your internet connection.", style: TextStyle(color: Colors.white))));
                                } else {
                                  createCompleteTimeTableFromScratch();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        backgroundColor:Colors.green,
                                          content: Text(
                                              "Updated Successfully!", style: TextStyle(color: Colors.white))));
                                }
                                this.setState(() {
                                  inProgress = false;
                                });
                              }
                              // } else {
                              //   ScaffoldMessenger.of(context)
                              //       .showSnackBar(SnackBar(
                              //     content: Text("No internet!"),
                              //   ));
                              // }
                              ,
                              child: Text("Update Table"))
                          : CircularProgressIndicator(),
                    ],
                  ),
                ],
              ),
            ),
          )
        : Scaffold(
            body: Center(
              child: inProgress == false
                  ? ElevatedButton(
                     style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(Colors.indigo)),
                      onPressed: () async {
                        this.setState(() {
                          inProgress = true;
                        });
                        String filePath = await downloadTimeTable();
                        if (filePath == "") {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(
                                  "Error downloading timetable. Please check your internet connection.")));
                          this.setState(() {
                            inProgress = false;
                          });
                        } else {
                          createCompleteTimeTableFromScratch();
                          this.setState(() {
                            inProgress = false;
                          });
                        }
                      },
                      child: Text("Download TimeTable from Server"),
                    )
                  : CircularProgressIndicator(),
            ),
          );
  }

  Future<bool> checkFileExists(String fileName) async {
    Directory appDocumentsDirectory =
        await getApplicationDocumentsDirectory(); // 1
    String filePath = appDocumentsDirectory.path + "/" + fileName;
    File f = File(filePath);
    if (await f.exists()) {
      return true;
    }

    return false;
  }

  //gets the app directory path

  getAppDirectoryPath() async {
    Directory appDocumentsDirectory =
        await getApplicationDocumentsDirectory(); // 1
    String filePath = appDocumentsDirectory.path;
    return filePath;
  }

// on initial load
  loadTimeTable() async {
    //check if completeTimeTable.txt exists
    if (await checkFileExists("completeTimetable.txt")) {
      File storedTable =
          File(await getAppDirectoryPath() + "/completeTimetable.txt");
      timetable = jsonDecode(storedTable.readAsStringSync());
      for (String key in timetable.keys) {
        for (var course in timetable[key]!) {
          courses.add(course['name'] + "(" + course['section']);
        }
      }

      for (String key in timetable.keys) {
        timetable[key] = timetable[key]!.map((e) {
          return Course.fromJson(e);
        }).toList();
      }

      courses = courses.toSet().toList();
      courses.sort();
      print(courses);
      this.setState(() {
        courses = courses;
        timetable = timetable;
        timetableLoaded = true;
      });
    }
  }

//downloads Timetable excel and stores as excel file
  downloadTimeTable() async {
    HttpClient httpClient = new HttpClient();
    File file;
    String filePath = "";
    var myUrl = "";

    //this block gets the downloadURL for the timetable.xlsx file from the server
    try {
      ref.storage.setMaxOperationRetryTime(Duration(seconds: 5));
      myUrl = await ref.getDownloadURL();
      filePath = await getAppDirectoryPath() + "/timetable.xlsx";
    } on FirebaseException catch (_) {
      //print("TIMEOUT with ref\n\n\n\n, ${_.toString()}");
      return filePath;
    }

    //this block saves the timetable.xlsx file locally
    try {
      httpClient.connectionTimeout = Duration(seconds: 10);
      var request = await httpClient.getUrl(Uri.parse(myUrl));
      var response = await request.close();

      if (response.statusCode == 200) {
        if (await checkFileExists("timetable.xlsx")) {
          //if the file already exists AND internet conn
          await File(filePath).delete();
        }
        print("RESPONSE STATUS 200");
        var bytes = await consolidateHttpClientResponseBytes(response);
        file = File(filePath);
        // print(filePath);
        // print(bytes);

        await file.writeAsBytes(bytes);
        return filePath;
      } else {
        filePath = 'Error code: ' + response.statusCode.toString();
        return "";
      }
    } on TimeoutException catch (_) {
      print("TIMEOUT");
      return "";
    } catch (ex) {
      return "";
    }
  }

//creates a new timetable data structure from an excel file and also stores a copy
  createCompleteTimeTableFromScratch() async {
    String file = await getAppDirectoryPath() + "/timetable.xlsx";
    var bytes = File(file).readAsBytesSync();
    var table = Excel.decodeBytes(bytes);

    var x = timetableParser(table);
    this.setState(() {
      timetable = x;
    });

    for (String key in timetable.keys) {
      for (Course course in timetable[key]!) {
        courses.add(course.name + "(" + course.section);
      }
    }

    courses = courses.toSet().toList();
    courses.sort();
    this.setState(() {
      courses = courses;
      timetable = timetable;
      timetableLoaded = true;
    });
    //save timetable for future use
    String storedTable = await getAppDirectoryPath() + "/completeTimetable.txt";
    File(storedTable).writeAsStringSync(jsonEncode(timetable).toString());
  }

  downloadFile(String fileName) async {
    HttpClient httpClient = new HttpClient();
    File file;
    String filePath = await getAppDirectoryPath() + "/$fileName";
    var myUrl = "";

    try {
      myUrl = await ref.getDownloadURL();
    } on FirebaseException catch (_) {
      print("TIMEOUT woith ref");
      return [filePath, false, "1"];
    }

    print("FILE PATH $filePath");
    return [filePath, false];
  }

  getTimetableObject() async {
    dynamic response = await downloadFile("timetable.xlsx");
    String file = response[0];
    bool resp = response[1];
    if (response.length > 2) {
      return false;
    }
    String storedTable =
        file.substring(0, file.lastIndexOf('/')) + "/completeTimetable.txt";
    //if timetable not downloaded

    //if local data structure already exists
    if (!resp && File(storedTable).existsSync()) {
      timetable = jsonDecode(File(storedTable).readAsStringSync());
      for (String key in timetable.keys) {
        for (var course in timetable[key]!) {
          courses.add(course['name'] + "(" + course['section']);
        }
      }

      for (String key in timetable.keys) {
        timetable[key] = timetable[key]!.map((e) {
          return Course.fromJson(e);
        }).toList();
      }

      courses = courses.toSet().toList();
      courses.sort();
      print(courses);
      this.setState(() {
        courses = courses;
        timetable = timetable;
        timetableLoaded = true;
      });
    } else {
      var bytes = File(file).readAsBytesSync();
      var table = Excel.decodeBytes(bytes);

      var x = timetableParser(table);
      this.setState(() {
        timetable = x;
      });

      for (String key in timetable.keys) {
        for (Course course in timetable[key]!) {
          courses.add(course.name + "(" + course.section);
        }
      }

      courses = courses.toSet().toList();
      courses.sort();
      this.setState(() {
        courses = courses;
        timetable = timetable;
        timetableLoaded = true;
      });

      File(storedTable).writeAsStringSync(jsonEncode(timetable).toString());
    }
  }
}
