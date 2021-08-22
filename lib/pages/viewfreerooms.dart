import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lettuce_no/utils/timetableparser.dart';

class ViewFreeRooms extends StatefulWidget {
  ViewFreeRooms({Key? key, required this.completeTimetable}) : super(key: key);
  final Map<String, dynamic> completeTimetable;

  @override
  _ViewFreeRoomsState createState() => _ViewFreeRoomsState();
}

class _ViewFreeRoomsState extends State<ViewFreeRooms> {
  Map<String, Map<String, List<String>>> usedRooms = {};

  Map<String, List<String>> freeRooms = Map<String, List<String>>();

  Set<String> allRooms = new Set<String>();

  int currentDay = DateTime.now().weekday;
  Map<String, dynamic> completeTimetable = {};
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    completeTimetable = widget.completeTimetable;
  }

  @override
  Widget build(BuildContext context) {
    WidgetsFlutterBinding.ensureInitialized();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    populateRooms();

    return Scaffold(
      //resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text("Free Rooms"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: completeTimetable.keys.map((day) {
                  return Container(
                    margin: EdgeInsets.all(2),
                    child: ElevatedButton(
                        style: ButtonStyle(
                            backgroundColor: day == convertIntegerDay()
                                ? MaterialStateProperty.all(Colors.indigo[800])
                                : MaterialStateProperty.all(Colors.indigo)),
                        child: Text(day),
                        onPressed: () {
                          setState(() {
                            allRooms.clear();
                            freeRooms.clear();
                            usedRooms.clear();
                            currentDay = convertStringDay(day);
                            populateRooms();
                          });
                        }),
                  );
                }).toList(),
              ),
            ),
            GridView.count(
              crossAxisSpacing: 1,
              mainAxisSpacing: 1,
              shrinkWrap: true,
              childAspectRatio: 0.4,
              crossAxisCount: 3,
              physics: NeverScrollableScrollPhysics(),

              children: [
                for (String key in freeRooms.keys)
                  generateColumn(freeRooms, key, context)
              ],
              // ),SingleChildScrollView(
              //   scrollDirection: Axis.horizontal,
              //   child:
              // Row(
              //     children: completeTimetable.keys.map((day) {
              //       return ElevatedButton(
              //           style: ButtonStyle(
              //               backgroundColor: day == convertIntegerDay()
              //                   ? MaterialStateProperty.all(Colors.indigo[800])
              //                   : MaterialStateProperty.all(Colors.indigo)),
              //           child: Text(day),
              //           onPressed: () {
              //             setState(() {
              //               currentDay = convertStringDay(day);
              //               populateRooms();
              //             });
              //           });
              //     }).toList(),
              //   ),
              // ),
            ),
          ],
        ),
      ),
    );
  }

  generateColumn(
      Map<String, List<String>> freeRooms, String key, BuildContext context) {
    return Column(children: [
      Container(
        color: Colors.indigo,
        height: MediaQuery.of(context).size.height * 0.05,
        child: Center(
          child: Text("$key"),
        ),
      ),
      Flexible(
        child: SingleChildScrollView(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: freeRooms[key]!.map((room) {
                return Container(child: Text(room));
              }).toList()),
        ),
      ),
    ]);
  }

  void populateRooms() {
    //days
    for (String key in widget.completeTimetable.keys) {
      usedRooms[key] = {};
      for (Course c in widget.completeTimetable[key]) {
        allRooms.add(c.room);
        String time = convertToTime(c.start) + "-" + convertToTime(c.end);

        if (!usedRooms[key]!.keys.contains(time)) {
          //time += "-" + convertToTime(c.end);
          usedRooms[key]!.addAll({
            time: [c.room]
          });
          //usedRooms[key]![time]!.add(c.room);
        } else
          usedRooms[key]![time]!.add(c.room);
      }
    }

    String currentDay = convertIntegerDay();
    if (!usedRooms.keys.contains(currentDay)) currentDay = "Monday";
    print(allRooms);

    for (String time in usedRooms[currentDay]!.keys) {
      Set<String> used = new Set<String>();
      for (String room in usedRooms[currentDay]![time]!) {
        used.add(room);
      }
      var x = allRooms.toSet().difference(used).toList();
      if (!freeRooms.keys.contains(time)) {
        freeRooms.addAll({time: x});
        //usedRooms[key]![time]!.add(c.room);
      }
    }
    setState(() {
      allRooms = allRooms;
      freeRooms = freeRooms;
      usedRooms = usedRooms;
    });

    print(freeRooms);
  }

  convertIntegerDay() {
    switch (currentDay) {
      case 1:
        return "Monday";
      case 2:
        return "Tuesday";
      case 3:
        return "Wednesday";
      case 4:
        return "Thursday";
      case 5:
        return "Friday";
      case 6:
        return "Saturday";

      default:
        return "Monday";
    }
  }

  convertStringDay(String d) {
    switch (d) {
      case "Monday":
        return 1;
      case "Tuesday":
        return 2;
      case "Wednesday":
        return 3;
      case "Thursday":
        return 4;
      case "Friday":
        return 5;
      case "Saturday":
        return 6;

      default:
        return "1";
    }
  }
}
