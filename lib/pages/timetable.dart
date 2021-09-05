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
import 'package:lettuce_no/pages/homepage.dart';
import 'package:lettuce_no/utils/checkplatform.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import 'package:lettuce_no/pages/displaycreatedtimetable.dart';
import 'package:lettuce_no/router/router.dart';
import 'package:lettuce_no/utils/checkinternet.dart';
import 'package:lettuce_no/utils/timetableparser.dart';
import 'package:flutter/services.dart' show rootBundle;

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
    if (timetableLoaded == true) {
      return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text("Choose Timetable"),
        ),
        body: Center(
          child: Column(
            children: [
              Container(
                margin:
                    EdgeInsets.all(MediaQuery.of(context).size.height * 0.01),
                child: Center(
                    child: Text(
                  selectedCourses.length > 0
                      ? "Selected Courses"
                      : "Tap On a Course to Select It",
                  textScaleFactor: selectedCourses.length > 0 ? 1.4 : 1.2,
                )),
              ),
              selectedCourses.length > 0
                  ? Expanded(
                      flex: selectedCourses.length == 1
                          ? 1
                          : selectedCourses.length == 2
                              ? 2
                              : 3,
                      child: Container(
                        width: !PlatformInfo().isWeb()
                            ? MediaQuery.of(context).size.width * 0.95
                            : MediaQuery.of(context).size.width * 0.5,
                        padding: EdgeInsets.all(
                            MediaQuery.of(context).size.height * 0.01),
                        color: Colors.black26,
                        child: SingleChildScrollView(
                          child: Center(
                            child: Wrap(
                              children: selectedCourses.map(
                                (e) {
                                  return Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      color: Colors.indigo,
                                    ),
                                    width: !PlatformInfo().isWeb()
                                        ? MediaQuery.of(context).size.width *
                                            0.95
                                        : MediaQuery.of(context).size.width *
                                            0.5,
                                    margin: EdgeInsets.all(1),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Flexible(
                                          child: Text(
                                            e,
                                            textScaleFactor: 1,
                                            softWrap: true,
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
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
                      ),
                    )
                  : Container(),
              Container(
                margin:
                    EdgeInsets.all(MediaQuery.of(context).size.height * 0.01),
                child: Center(
                    child: Text(
                  "List of Courses",
                  textScaleFactor: 1.4,
                )),
              ),
              Flexible(
                flex: 6,
                child: SingleChildScrollView(
                    child: Column(
                  children: courses
                      .map((e) => Container(
                          width: !PlatformInfo().isWeb()
                              ? MediaQuery.of(context).size.width * 0.95
                              : MediaQuery.of(context).size.width * 0.5,
                          height: MediaQuery.of(context).size.height * 0.08,
                          margin: EdgeInsets.all(
                              MediaQuery.of(context).size.height * 0.003),
                          color: selectedCourses.contains(e)
                              ? Colors.green[700]
                              : Colors.black26,
                          child: InkWell(
                              onTap: () => {
                                    if (selectedCourses.contains(e))
                                      {
                                        this.setState(() {
                                          selectedCourses.remove(e);
                                        })
                                      }
                                    else
                                      this.setState(() {
                                        selectedCourses.add(e);
                                      })
                                  },
                              child: Center(child: Text(e)))))
                      .toList(),
                )),
              ),
              Flexible(
                flex: 1,
                child: Row(
                  mainAxisAlignment:!PlatformInfo().isWeb()? MainAxisAlignment.spaceEvenly: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(Colors.indigo),
                      ),
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
                            backgroundColor: Colors.yellow,
                            content: Text("Please Select At Least 1 Course!"),
                          ));
                        }
                      },
                      child: Text("Generate Table"),
                    ),
                   !PlatformInfo().isWeb()? inProgress == false
                        ? ElevatedButton(
                            style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all(Colors.indigo)),
                            onPressed: () async {
                              this.setState(() {
                                inProgress = true;
                              });
                              String filePath = await downloadTimeTable();
                              if (filePath == "") {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                    backgroundColor: Colors.red,
                                    content: Text(
                                        "Error downloading timetable. Please check your internet connection.",
                                        style: TextStyle(color: Colors.white))));
                              } else {
                                createCompleteTimeTableFromScratch();
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        backgroundColor: Colors.green,
                                        content: Text("Updated Successfully!",
                                            style:
                                                TextStyle(color: Colors.white))));
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
                        : CircularProgressIndicator():Container(),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return Scaffold(
        body: Center(
          child: inProgress == false
              ? PlatformInfo().isWeb()
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.indigo)),
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
    if (PlatformInfo().isWeb()) {
      createCompleteTimeTableFromScratch();
    }
    //check if completeTimeTable.txt exists
    else {
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
    var table;
    if (PlatformInfo().isWeb()) {
      // if (GLOBAL_TABLE == null) {
      ByteData data = await rootBundle.load('/tables-web/timetable.xlsx');
      final buffer = data.buffer;

      //var bytes = File(file).readAsBytesSync();
      table = Excel.decodeBytes(
          buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
      // GLOBAL_TABLE = table;
      // } else
      //   table = GLOBAL_TABLE;
    } else {
      String file = await getAppDirectoryPath() + "/timetable.xlsx";
      var bytes = File(file).readAsBytesSync();
      table = Excel.decodeBytes(bytes);
    }
    if (PlatformInfo().isWeb() && GLOBAL_TABLE == null) {
      var x = timetableParser(table);
      GLOBAL_TABLE = x;
    }

    // var x = timetableParser(table);
    // GLOBAL_TABLE = x;
    this.setState(() {
      timetable = GLOBAL_TABLE;
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
    if (PlatformInfo().isAppOS()) {
      String storedTable =
          await getAppDirectoryPath() + "/completeTimetable.txt";
      File(storedTable).writeAsStringSync(jsonEncode(timetable).toString());
    }
    //save timetable for future use
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
