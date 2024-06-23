import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:first_app/calendar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:first_app/calendar.dart';
import 'package:first_app/widgets/event.dart';
import 'package:intl/intl.dart';
//import 'package:intl/intl.dart';

class EventEditScreen extends StatefulWidget{
  final String userEmail;
  final Event? event;
  EventEditScreen({Key? key, required this.userEmail, this.event}) : super(key: key);
  @override
  State<EventEditScreen> createState() => _EventEditScreenState();
}
class _EventEditScreenState extends State<EventEditScreen> {
  final formKey = GlobalKey<FormState>();
  TextEditingController _titleController = TextEditingController();
  DateTime? startDate;
  DateTime? endDate;

  TimeOfDay? startTime;
  TimeOfDay? endTime;

  @override
  void initialState() {
    this.initialState();

    if(widget.event == null) {
      startDate = DateTime.now();
      endDate = DateTime.now().add(Duration(hours: 1));
    }
  }

  String getFormattedStartDate() {
    if (startDate == null) return 'Select a date';
    return DateFormat('yyyy-MM-dd').format(startDate!);
  }

  String getFormattedEndDate() {
    if (endDate == null) return 'Select a date';
    return DateFormat('yyyy-MM-dd').format(endDate!);
  }

  String getFormattedStarTime() {
    if (startTime == null) return 'Select a time';
    //return startTime.toString();
    final now = DateTime.now();
    final formattedTime = DateTime(0, 0, 0, startTime!.hour, startTime!.minute);
    return TimeOfDay.fromDateTime(formattedTime).format(context);
  }

  String getFormattedEndTime() {
    if (endTime == null) return 'Select a time';
    //return startTime.toString();
    final now = DateTime.now();
    final formattedTime = DateTime(0, 0, 0, endTime!.hour, endTime!.minute);
    return TimeOfDay.fromDateTime(formattedTime).format(context);
  }

  DateTime combineDateWithTime(DateTime date, TimeOfDay time) {
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(  //leading is used to display elements one after another
            onPressed: () async {
              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context)=> CalendarScreen(userEmail: widget.userEmail)));
            },
            icon: Icon(Icons.arrow_back,)

        ),
        title: Text("Add new event"),
        centerTitle: true,

      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(10),
          //child: Form(
          //key: formKey,
          child: Column(
            //mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                    border: UnderlineInputBorder(),
                    hintText: 'Event name'
                ),
              ),
              SizedBox(height: 20),
              Text('FROM',style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                  child: DropdownButton<String>(
                    hint: Text(getFormattedStartDate()),
                    items: [
                      DropdownMenuItem<String>(
                        value: 'Select a date',
                        child: Text('Select a date'),
                      ),
                    ],
                    onChanged: (String? value) async {
                      //if (value == 'Select a date') {
                      DateTime? date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                      );
                      if (date != null) {
                        setState(() {
                          startDate = date;
                        });
                      }
                    },
                    // },
                    isExpanded: false,

                    //value: 'Select a date',

                  ),),
/*
                DropdownButton<String>(
                  hint: Text(getFormattedTime()),
                  items: [
                    DropdownMenuItem<String>(
                      //value: 'Select a time',
                      child: Text('Select a time'),
                    ),
                  ],
                  onChanged: (String? value) async {
                    //if (value == 'Select a date') {
                    TimeOfDay? time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                      //firstTime: DateTime(2020),
                      //lastDate: DateTime(2030),
                    );
                    if (time != null) {
                      setState(() {
                        startTime = time;
                      });
                    }
                  },
                  // },
                  isExpanded: true,
                  //value: 'Select a date',
                ),*/
                  Expanded(
                    child:TextButton(
                      onPressed: () async {
                        TimeOfDay? time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (time != null) {
                          setState(() {
                            startTime = time;
                          });
                        }
                      },
                      child: Text(
                        getFormattedStarTime(),
                        style: TextStyle(fontSize: 16.0),
                      ),
                    ),
                  ),
                ],

              ),
              SizedBox(height: 20),
              Text('TO',style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: DropdownButton<String>(
                      hint: Text(getFormattedEndDate()),
                      items: [
                        DropdownMenuItem<String>(
                          value: 'Select a date',
                          child: Text('Select a date'),
                        ),
                      ],
                      onChanged: (String? value) async {
                        //if (value == 'Select a date') {
                        DateTime? date = await showDatePicker(
                          context: context,
                          initialDate: startDate!,
                          firstDate: startDate!,
                          lastDate: DateTime(2030),
                        );
                        if (date != null) {
                          setState(() {
                            endDate = date;
                          });
                        }
                      },
                      // },
                      isExpanded: false,

                      //value: 'Select a date',

                    ),),

                  Expanded(
                    child:TextButton(
                      onPressed: () async {
                        TimeOfDay? time = await showTimePicker(
                          context: context,
                          initialTime: startTime!,
                        );
                        if (time != null) {
                          setState(() {
                            endTime = time;
                          });
                        }
                      },
                      child: Text(
                        getFormattedEndTime(),
                        style: TextStyle(fontSize: 16.0),
                      ),
                    ),
                  ),
                ],

              ),
            ]
          ),
        )
        ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          if (_titleController.text.isNotEmpty) {
            final combinedStartDate = combineDateWithTime(startDate!, startTime!);
            final combinedEndDate = combineDateWithTime(endDate!, endTime!);

            final event = Event(
              title: _titleController.text,
              description: 'Description',
              start: combinedStartDate,
              end: combinedEndDate,
              isAllDay: false,
            );

            await FirebaseFirestore.instance
                .collection('users')
                .doc(widget.userEmail)
                .collection('events')
                .add(event.toMap());

            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => CalendarScreen(userEmail: widget.userEmail),
              ),
            );
          }
        }, label: Icon(Icons.check),),
      );
    //);

  }
}