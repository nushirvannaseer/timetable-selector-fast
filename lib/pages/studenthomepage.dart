import 'package:flutter/material.dart';
import 'package:lettuce_no/models/society.dart';
import 'package:lettuce_no/models/student.dart';
import 'package:lettuce_no/pages/societyhomepage.dart';

class StudentHomePage extends StatefulWidget {
  StudentHomePage({Key? key, required this.student}) : super(key: key);
  Student student;

  @override
  _StudentHomePageState createState() => _StudentHomePageState();
}

class _StudentHomePageState extends State<StudentHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Lettuce No")),
      body: Container(
        height: MediaQuery.of(context).size.height * 0.2,
        color: Colors.purple,
        child: Column(
          children: [
            Expanded(
              child: Center(child: Text("Name: " + this.widget.student.name)),
            ),
            Expanded(
              child:
                  Center(child: Text("Roll No: " + this.widget.student.rollNo)),
            ),
            Expanded(
              child: Center(
                  child: Text("Current Semester: " +
                      this.widget.student.currentSemester.toString())),
            ),
            ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SocietyHomePage(
                          society: Society("NUCES ACM", "nuces.acm", "123456")),
                    ),
                  );
                },
                child: Text("Go to Society Page")),
                // ElevatedButton(
                // onPressed: () {
                //   Navigator.pop(context);
                //   Navigator.push(
                //     context,
                //     MaterialPageRoute(
                //       builder: (context) => SocietyHomePage(
                //           society: Society("NUCES ACM", "nuces.acm", "123456")),
                //     ),
                //   );
                // },
                // child: Text("Go to Society Page")),
          ],
        ),
      ),
    );
  }
}
