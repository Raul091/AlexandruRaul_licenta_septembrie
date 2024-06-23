import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
class NoteEditScreen extends StatefulWidget{
  final String userEmail;
  NoteEditScreen({Key? key, required this.userEmail}) : super(key: key);
  @override
  State<NoteEditScreen> createState() => _NoteEditScreenState();
}
class _NoteEditScreenState extends State<NoteEditScreen> {
  String date = DateTime.now().toString();
  TextEditingController _titleController = TextEditingController();
  TextEditingController _mainController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        title: Text("Create a new journal"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
            controller: _titleController,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: 'Note Title'
            ),
          ),
            SizedBox(height: 6.0,),
            Text(date),
            SizedBox(height: 16.0,),
            TextField(
              controller: _mainController,
              keyboardType: TextInputType.multiline,
              maxLines: null,
              decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Note Content'
              ),
            ),
        ]
      ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await FirebaseFirestore.instance.collection("notes").doc(widget.userEmail).collection('user_notes').add({
            "note_title": _titleController.text,
            "creation_date": date,
            "content": _mainController.text,
          }).then((value) {
            //print(value.id);
            Navigator.pop(context);
          }).catchError((error) {
            // Handle any error
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error adding note: $error')),
            );
          });
        },
        child: Icon(Icons.check),
      ),
    );
  }
}