import 'dart:ui';

import 'package:first_app/calendar.dart';
import 'package:first_app/camera_screen.dart';
import 'package:first_app/journal.dart';
import 'package:first_app/chart.dart';
import 'package:flutter/material.dart';
//import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';


class DashboardScreen extends StatelessWidget {
  final String userEmail;
  const DashboardScreen({ Key? key, required this.userEmail}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Dashboard"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Column(
              children: [

                ElevatedButton(
                  onPressed: () async {
                    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context)=>  JournalScreen(userEmail: userEmail)));
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.lightBlue,
                    padding: EdgeInsets.symmetric(horizontal: 80, vertical: 30),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.notes, size: 70),
                      SizedBox(height: 0), // Add space between icon and text
                      Text("Journal", style: TextStyle(fontSize: 22),),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async{
                    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context)=>  CameraScreen(userEmail: userEmail)));
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.redAccent,
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 30),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.face, size: 70),
                      SizedBox(height: 0), // Add space between icon and text
                      Text("Emotion Analyze", style: TextStyle(fontSize: 22),)
                    ],
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async{
                    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context)=>  CalendarScreen(userEmail: userEmail)));
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.lightGreenAccent,
                    padding: EdgeInsets.symmetric(horizontal: 55, vertical: 30),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.calendar_month, size: 70),
                      SizedBox(height: 0), // Add space between icon and text
                      Text("Event Planner", style: TextStyle(fontSize: 22),)
                    ],
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async{
                    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context)=>  ChartScreen(userEmail: userEmail)));
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.deepPurpleAccent,
                    padding: EdgeInsets.symmetric(horizontal: 75, vertical: 30),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.bar_chart, size: 70),
                      SizedBox(height: 0), // Add space between icon and text
                      Text("Statistics", style: TextStyle(fontSize: 22),)
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}