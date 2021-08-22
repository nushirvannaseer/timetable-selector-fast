import 'dart:convert';

import 'package:excel/excel.dart';

class Course {
  var name = "", section = "", start = -1, end = -1, room = "", duration = -1;

  Course(
      this.name, this.section, this.start, this.end, this.room, this.duration);

  Course.fromJson(Map<String, dynamic> json) {
    this.name = json["name"];
    this.section = json["section"];
    this.start = json["start"];
    this.end = json["end"];
    this.room = json["room"];
    this.duration = json["duration"];
  }

  toJson() {
    return {
      "name": this.name,
      "section": this.section,
      "start": this.start.toInt(),
      "end": this.end.toInt(),
      "room": this.room,
      "duration": this.duration.toInt(),
    };
  }

  printCourse() {
    var str =
        "Name: $name   Section: ($section   Timings: ${convertToTime(start)} - ${convertToTime(end)} ($room)";
    print(str);
    return str;
  }
}
//((second-first)/9*)90

//if duration>

Set<String> allRooms = Set<String>();

convertToTime(int time) {
  int hours = (time ~/ 60 + 7);
  if (hours > 12) hours %= 12;

  var minutes = time % 60;
  if (minutes == 0) {
    return "$hours:${minutes}0";
  }
  return "$hours:$minutes";
}

timetableParser(Excel table) {
  print("CALLED");
  var timetable = {
    "Monday": [],
    "Tuesday": [],
    "Wednesday": [],
    "Thursday": [],
    "Friday": [],
  };
  var t = table.tables.keys.toList()[1];
  print("COlumns:${table.tables[t]!.maxCols}");
  print("Rows: ${table.tables[t]!.maxRows}");
  int i = 0;

  int rowIndex = 0;
  int numCourses = 0;
  String day = "";
  for (List<dynamic> row in table.tables[t]!.rows) {
    //print(row[15].backgroundColorHex)
    int time = 20;
    int prevTime = -1;
    //finding out the current day

    for (String key in timetable.keys) {
      if (row[0] != null) {
        if (row[0]!.value!.runtimeType == String &&
            row[0]!.value!.contains(key)) {
          day = key;
          numCourses = 0;
          //print("DAY $day");
          break;
        }
      }
    }

    if (day != "" && row[1]!= null) {
//finding out current room
      // print(row[0]!.cellStyle);
      String room = row[1]!.value!;
      allRooms.add(room);
      //finding duration

      for (var i = 2; i < row.length; ++i) {
       
        var name = "";
        var section = "";

        if (prevTime > -1 &&  row[i]!=null && row[i].value!.runtimeType == String) {
          
          int duration = time - prevTime;
          if (duration > 120 &&
              timetable[day]![numCourses - 1]
                  .name
                  .toLowerCase()
                  .contains("english")) duration = 120;
          if (duration > 120 &&
              !timetable[day]![numCourses - 1]
                  .name
                  .toLowerCase()
                  .contains("lab")) duration = 90;

          if (duration > 180) duration = 180;

          timetable[day]![numCourses - 1].end =
              timetable[day]![numCourses - 1].start + duration;
          timetable[day]![numCourses - 1].duration = duration;
        }
        if (i < row.length && row[i]!=null && row[i].value!.runtimeType == String) {
          // print('$i ${row[i].split("(")[0]}');
          // print("TIME $time");
          List<String> nameSection = row[i].value.split('(');
          if (nameSection.length > 2) {
            name = nameSection[0] + "(" + nameSection[1];
            section = nameSection[2];
          } else if (nameSection.length == 2) {
            name = nameSection[0];
            section = nameSection[1];
          }
          if (name.length > 1) {
            // if (name.toLowerCase().contains("international")) {
            //   print("IR AGYA");
            // }
            timetable[day]!
                .add(Course(name, section, time, time + 90, room, 90));
            if (name.contains("(") && name.length < 5)
              timetable[day]![numCourses].printCourse();
            numCourses += 1;
            prevTime = time;
          }
        }

        time += 10;
      }
      if (numCourses > 0) {
        int duration = time - prevTime;
        if (duration > 120 &&
            timetable[day]![numCourses - 1]
                .name
                .toLowerCase()
                .contains("english")) duration = 120;
        if (duration > 120 &&
            !timetable[day]![numCourses - 1].name.toLowerCase().contains("lab"))
          duration = 90;
        if (duration > 180) duration = 180;

        timetable[day]![numCourses - 1].end =
            timetable[day]![numCourses - 1].start + duration;
        timetable[day]![numCourses - 1].duration = duration;
      }
    }

    // for (var key in timetable.keys) {
    //   print(key);
    //   for (var course in timetable[key]!) course.printCourse();
    // }
    rowIndex++;
  }

  return timetable;
}
