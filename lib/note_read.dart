import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:first_app/journal.dart';
import 'package:flutter/material.dart';

class NoteReadScreen extends StatefulWidget {
  NoteReadScreen(this.note, { Key? key,}) :super(key: key);
  QueryDocumentSnapshot note;
  @override
  State<NoteReadScreen> createState() => _NoteReadScreenState();
}

class _NoteReadScreenState extends State<NoteReadScreen> {
  @override
  Widget build(BuildContext context) {
   return Scaffold(
    appBar: AppBar(

    ),
     body: Padding(
       padding: EdgeInsets.all(16.0),
       child: Column(
         crossAxisAlignment: CrossAxisAlignment.start,
         children: [
           Text(
             widget.note["note_title"],
             style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
           ),
           SizedBox(height: 4.0),
           Text(
             widget.note["creation_date"],
           ),
           SizedBox(height: 16.0),
           Text(
             widget.note["content"],
             overflow: TextOverflow.ellipsis,
           ),
         ],
       ),
     ),
   );
  }
}