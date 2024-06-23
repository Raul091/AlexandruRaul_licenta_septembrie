import 'dart:ui';

import 'package:first_app/camera_screen.dart';
import 'package:first_app/dashboard.dart';
import 'package:first_app/note_edit.dart';
import 'package:first_app/note_read.dart';
import 'package:first_app/widgets/note_cards.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class JournalScreen extends StatefulWidget {
  final String userEmail;
  const JournalScreen({ Key? key, required this.userEmail}) : super(key: key);

  @override
  _JournalScreenState createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  final Map<String, List<String>> userNotes = {
    "user1@example.com": ["Note 1", "Note 2"],
    "user2@example.com": ["Note A", "Note B"],
  };
  @override
  Widget build(BuildContext context) {
    List<String>? notes = userNotes[widget.userEmail];
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(  //leading is used to display elements one after another
            onPressed: () async {
              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context)=>  DashboardScreen(userEmail: widget.userEmail)));
            },
            icon: Icon(Icons.arrow_back,)

        ),
        title: Text("Journal", style: TextStyle(fontSize: 20)), // Adjust title size
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Your recent Journals", style: TextStyle(fontSize: 22, color: Colors.black),),
            SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection("notes").doc(widget.userEmail).collection('user_notes').snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshots) {
                  if(snapshots.connectionState == ConnectionState.waiting){
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  if (snapshots.hasError) {
                    return Center(
                      child: Text('Something went wrong: ${snapshots.error}'),
                    );
                  }
                  if (snapshots.hasData) {
                    return GridView(gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
                    children: snapshots.data!.docs.map((note) => noteCard(() {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => NoteReadScreen(note),));
                    }, note)).toList(),
                    );
                  }
                  return Text('No journals yet. Start journaling about your day.');


                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: (){
          Navigator.push(context, MaterialPageRoute(builder: (context) => NoteEditScreen(userEmail: widget.userEmail)));
        }, label: Icon(Icons.add),),
    );
  }
}