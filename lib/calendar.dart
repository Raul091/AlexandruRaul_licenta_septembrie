import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:first_app/event_edit.dart';
import 'package:first_app/journal.dart';
import 'package:flutter/material.dart';
import 'package:first_app/dashboard.dart';
import 'package:first_app/widgets/event.dart';
import 'package:intl/intl.dart';

class CalendarScreen extends StatefulWidget {
  final String userEmail;
  const CalendarScreen({ Key? key, required this.userEmail}) :super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _CalendarScreenState();
  }
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime setDate = DateTime.now();
  TextEditingController eventController = TextEditingController();
  late Map<DateTime, List<Event>> events;
  @override

  void initState() {
    super.initState();
    _loadEvents();
  }

  void _loadEvents() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userEmail)
        .collection('events')
        .get();

    final fetchedEvents = snapshot.docs.map((doc) {
      return Event.fromMap(doc.data() as Map<String, dynamic>);
    }).toList();

    setState(() {
      events = {};
      for (var event in fetchedEvents) {
        final date = DateTime(event.start.year, event.start.month, event.start.day);
        if (events[date] == null) {
          events[date] = [];
        }
        events[date]!.add(event);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () async {
              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context)=> DashboardScreen(userEmail: widget.userEmail)));
            },
            icon: Icon(Icons.arrow_back,)

        ),
        title: Text("Event planner"),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [CalendarDatePicker(

              firstDate: DateTime.now().subtract(Duration(days: 100000)),
              initialDate: setDate,
              lastDate: DateTime.now().add(Duration(days: 100000)),
              onDateChanged: (DateTime value) {setState(() {
                setDate = value;
                  });
              },

            ),
            ..._getEventsForDay(setDate).map((event) => ListTile(
              title: Text(event.title),
              subtitle: Text(DateFormat.yMMMd().add_jm().format(event.start) + ' - ' + DateFormat.yMMMd().add_jm().format(event.end)),
            )),
          ]

        ),

      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: (){
          Navigator.push(context, MaterialPageRoute(builder: (context) => EventEditScreen(userEmail: widget.userEmail)));
        }, label: Icon(Icons.add),),
    );
  }
  List<Event> _getEventsForDay(DateTime date) {
    if (events != null) {
      final selectedDateEvents = events.entries
          .where((entry) =>
      entry.key.year == date.year &&
          entry.key.month == date.month &&
          entry.key.day == date.day)
          .map((entry) => entry.value)
          .expand((value) => value)
          .toList();
      return selectedDateEvents;
    } else {
      return [];
    }
  }
}