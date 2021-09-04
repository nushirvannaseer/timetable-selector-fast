// @dart=2.9
import 'package:flutter/material.dart';
import 'package:lettuce_no/models/society.dart';
import 'package:lettuce_no/models/student.dart';
import 'package:lettuce_no/pages/societyhomepage.dart';
import 'package:lettuce_no/pages/homepage.dart';
// Import the firebase_core plugin
import 'package:firebase_core/firebase_core.dart';

void main() async {
  await WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      // Initialize FlutterFire:
      future: _initialization,
      builder: (context, snapshot) {
        // Check for errors
        if (snapshot.hasError) {
          print("ERROR: " + snapshot.error.toString());
          // ScaffoldMessenger.of(context).showSnackBar(
          //   SnackBar(
          //     content: Text(
          //         "Not Connected to the internet. Some features may not work"),
          //   ),
          //);
          return  MaterialApp(
            title: 'Lettuce No',
            theme: ThemeData.light(),
            debugShowCheckedModeBanner: false,
            home: HomePage(),
            // routes: {
            //   '/societyhomepage': (context)=> SocietyHomePage(society:Society("NUCES ACM", "nuces.acm", "123456") ),
            // },
          );
        }

        // Once complete, show your application
        if (snapshot.connectionState == ConnectionState.done) {
          return MaterialApp(
            title: 'Timetable Manager',
            theme: ThemeData.dark(),
            debugShowCheckedModeBanner: false,
            home:HomePage(),
            // routes: {
            //   '/societyhomepage': (context)=> SocietyHomePage(society:Society("NUCES ACM", "nuces.acm", "123456") ),
            // },
          );
        }

        // Otherwise, show something whilst waiting for initialization to complete
        return MaterialApp(home: Scaffold(body: Container(color: Colors.grey, child: Center(child: CircularProgressIndicator()))));
      },
    );
  }
}
