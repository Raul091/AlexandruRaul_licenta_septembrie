import 'package:first_app/dashboard.dart';
import 'package:first_app/main.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import "package:image_picker/image_picker.dart";
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:first_app/widgets/event.dart';
import 'package:first_app/widgets/emotions.dart';
import 'package:intl/intl.dart';

//void main() => runApp(MyApp());

class CameraScreen extends StatefulWidget {

  final String userEmail;
  const CameraScreen({ Key? key, required this.userEmail}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _CameraScreenState();
  }

}

class _CameraScreenState extends State<CameraScreen> {
  late File _image = File(' ');
  String finalEmotion = "";
  final ImagePicker _picker = ImagePicker();
  List<String> topActivities = [];

  Future getImage(bool isCamera) async{
    XFile? image;
    if(isCamera) {
      image = await _picker.pickImage(source: ImageSource.camera);
    }else{
      image = await _picker.pickImage(source: ImageSource.gallery);
    }
    if(image != null) {
      this.setState(() {
        _image = File(image!.path);
      });
    }
  }
  void sendImageToAPI() async {
    if(_image.path.isEmpty)
      {
        return;
      }
    var apiURL = 'http://172.23.64.1:5000/api';

    var requestAPI = http.MultipartRequest('POST', Uri.parse(apiURL));
    requestAPI.files.add(await http.MultipartFile.fromPath('image', _image.path));

    try {
      var responseAPI = await requestAPI.send();
      var responseData = await http.Response.fromStream(responseAPI);
      var responseBody = jsonDecode(responseData.body);
      print(responseBody);

      // Extract captured emotions from the response
      var capturedEmotions = responseBody['emotion_probabilities'] as Map<String, dynamic>;

      String finalEmotiontmp = capturedEmotions.entries.reduce((a, b) => a.value > b.value ? a : b).key;

      setState(() {
        finalEmotion = finalEmotiontmp;
      });
      print('Captured Emotions: $capturedEmotions');
      print('About to call activityBeforeEvent');
      saveEmotionToDataBase();
      emotionBeforeEvent();
      getTopActivities();

      //print('API response: $responseBody');
    } catch (error) {
      print('API Error: $error');
    }
  }

  void saveEmotionToDataBase() async{
    final now = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd – kk:mm').format(now);
    final emotion = Emotion(
      eventTitle: 'event',
      emotion: finalEmotion,
      start: now,
    );

    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userEmail)
        .collection('emotions')
        .add(emotion.toMap());

  }

  void emotionBeforeEvent() async{
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day, 0, 0, 0).toIso8601String();// format to match the database format
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59).toIso8601String();
    

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userEmail)
        .collection('events')
        .where('start', isGreaterThanOrEqualTo: startOfDay)
        .where('start', isLessThanOrEqualTo: endOfDay)
        .get();
    print("1");
    final fetchedEvents = snapshot.docs.map((doc) {
      return Event.fromMap(doc.data() as Map<String, dynamic>);
    }).toList();
    print('Today\'s events: ${fetchedEvents.length}');
    for(var event in fetchedEvents) {
      if(event.start.isAfter(now) && event.start
          .difference(now)
          .inMinutes <= 30){
        final emotion = Emotion(
          eventTitle: event.title,
          emotion: finalEmotion,
          start: now,
        );
        print(emotion);
        await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.userEmail)
            .collection('emotionsBeforeEvents')
            .add(emotion.toMap());
        print("Emotion added succesfully");
      }

      if(event.start.isBefore(now) && event.end.isAfter(now)){
        final emotion = Emotion(
          eventTitle: event.title,
          emotion: finalEmotion,
          start: now,
        );
        print(emotion);
        await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.userEmail)
            .collection('emotionsDuringEvents')
            .add(emotion.toMap());
        print("Emotion added succesfully");
      }
    }

  }

  void activityBeforeEvent() async {
    //DateTime dateAndDtime = DateTime.now();
    final now = DateTime.now();
    int countEvents = 0;
    final upcomingEvents = await FirebaseFirestore.instance
        .collection('users')
        .get();

    for (var user in upcomingEvents.docs) {
      final userEmail = user.id;
      final eventsSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userEmail)
          .collection('events')
          .get();
      countEvents++;
      print(countEvents);

      for (var doc in eventsSnapshot.docs) {
        final event = Event.fromMap(doc.data() as Map<String, dynamic>);
        final eventStartDateTime = DateTime(
          event.start.year,
          event.start.month,
          event.start.day,
          event.start.hour,
          event.start.minute,
        );
        final eventEndDateTime = DateTime(
          event.end.year,
          event.end.month,
          event.end.day,
          event.end.hour,
          event.end.minute,
        );
        print(eventStartDateTime);
        final eventName = event.title;

        if (eventStartDateTime.isAfter(now) &&
            eventStartDateTime
                .difference(now)
                .inMinutes <= 30) {
          final emotion = Emotion(
            eventTitle: eventName,
            emotion: finalEmotion,
            start: now,
          );

          print("1" + eventName);
          print("1" + finalEmotion);

          // await FirebaseFirestore.instance
          //     .collection('users')
          //     .doc(widget.userEmail)
          //     .collection('emotionsBeforeEvents')
          //     .add(emotion.toMap());
          try {
            await FirebaseFirestore.instance
                .collection('users')
                .doc(widget.userEmail)
                .collection('emotionsBeforeEvents')
                .add(emotion.toMap());

            print('Emotion before event added successfully.');
          } catch (e) {
            print('Failed to add emotion before event: $e');
          }
        }
        if(eventStartDateTime.isBefore(now) && eventEndDateTime.isAfter(now)){
          final emotion = Emotion(
            eventTitle: eventName,
            emotion: finalEmotion,
            start: now,
          );
          try{
            await FirebaseFirestore.instance
                .collection('users')
                .doc(widget.userEmail)
                .collection('emotionsDuringEvents')
                .add(emotion.toMap());
            print('Emotion during event added successfully.');
          } catch (e) {
            print('Failed to add emotion during event: $e');
          }
        }
      }
    }
  }

  void getTopActivities() async{
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month - 1, now.day, 0, 0, 0).toIso8601String();// format to match the database format
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59).toIso8601String();

    QuerySnapshot snapshotBeforeEvent = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userEmail)
        .collection('emotionsBeforeEvents')
        .where('start', isGreaterThanOrEqualTo: startOfDay)
        .where('start', isLessThanOrEqualTo: endOfDay)
        .get();

    final fetchedEmotionBefore = snapshotBeforeEvent.docs.map((doc) {
      return Emotion.fromMap(doc.data() as Map<String, dynamic>);
    }).toList();

    QuerySnapshot snapshotDuringEvent = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userEmail)
        .collection('emotionsDuringEvents')
        .where('start', isGreaterThanOrEqualTo: startOfDay)
        .where('start', isLessThanOrEqualTo: endOfDay)
        .get();

    final fetchedEmotionDuring = snapshotDuringEvent.docs.map((doc) {
      return Emotion.fromMap(doc.data() as Map<String, dynamic>);
    }).toList();

    // setState(() {
    //   activities = {};
    // var count = 0;
      for (var emotion in fetchedEmotionBefore) {
        final eventTitleBefore = emotion.eventTitle;
        final emotionBefore = emotion.emotion;
        for(var emotion2 in fetchedEmotionDuring){
          final eventTitleDuring = emotion2.eventTitle;
          final emotionDuring = emotion2.emotion;
          if(eventTitleBefore == eventTitleDuring)
            {
              if((emotionBefore == 'sad' || emotionBefore == 'angry' || emotionBefore == 'fear' || emotionBefore == 'disgust')
                  && (emotionDuring == 'happy' || emotionDuring == 'neutral'))
                {
                  topActivities ??= [];
                  if(topActivities != null){
                    if(!topActivities.contains(eventTitleDuring)) {
                      topActivities.add(eventTitleDuring);
                    }
                  }
                }
            }
        }
      }


    topActivities.shuffle();

  }

  String findActivities(String emotion){
    String activities = "";
    switch(emotion){
      case 'happy':
        {
          activities = "- go for a walk \n - go out with a friend \n - express gratitude in the journal \n";
        }break;
      case 'fear':
        {
          activities = "- talk with a friend \n - meditate about the situation and what is causing that \n - take some deep breaths \n - create some routines";
        }break;
      case 'neutral':
        {
          activities = "- talk with a friend \n - meditate \n go for a walk \n do some sort of sport";
        }break;
      case 'surprise':
        {
          activities = "- enjoy the moment if it's a good one \n - meditate about the situation and what is causing that \n - take some deep breaths";
        }break;
      case 'sad':
        {
          activities = "- go for a walk \n - meditate about the situation and what is causing that \n - try to enjoy more the present \n - listen to some music";
        }break;
      case 'disgust':
        {
          activities = "- talk with a close person about what seems wrong \n - try to not be so critical and judge easily \n ";
        }break;
      default:
        {
          //activities = "talk with a friend \n meditate ";
        }break;
    }
    return activities;
  }
  @override
  Widget build(BuildContext context) {
    final hasValidData = finalEmotion.isNotEmpty && topActivities != null && topActivities!.isNotEmpty;
    // TODO: implement build
    return MaterialApp(
      home:Scaffold(
        appBar: AppBar(
            leading: IconButton(
                onPressed: () async {
                  Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context)=> DashboardScreen(userEmail: widget.userEmail)));
                },
                icon: Icon(Icons.arrow_back,)

            ),
          title: Text("Take a photo or pick one", style: TextStyle(fontSize: 20)), // Adjust title size
          centerTitle: true,
        ),
        body: Center(
          child: Column(
           children: <Widget>[
             IconButton(
               icon: Icon(Icons.insert_drive_file_outlined),
               onPressed: () {
                 getImage(false);
               },
             ),
             SizedBox(height: 10.0,),
             IconButton(
               icon: Icon(Icons.camera_alt_outlined),
               onPressed: () {
                 getImage(true);
               },
             ),
             _image.path.isNotEmpty? Image.file(_image, height : 300.0, width: 300.0,): Container(),
           ElevatedButton(
               onPressed: sendImageToAPI,
                  child: Text('Analyze Image'),
           ),
             SizedBox(height: 20),

            //print("hasvalidData: $hasValidData");


             finalEmotion.isNotEmpty
             //topActivities!.isNotEmpty
                 ? Text('Your emotion is: $finalEmotion \nActivities that may improve your mood:\n ' + findActivities(finalEmotion) + '\n' , style: TextStyle(fontSize: 18))
                 : Container(),
             hasValidData
                 ? Text(
                   'Past events that helped:\n'
                   '${topActivities![0]}${topActivities!.length > 1 ? '\n${topActivities![1]}' : ''}${topActivities!.length > 2 ? '\n${topActivities![2]}' : ''}', // Ensure topActivities has enough elements
               style: TextStyle(fontSize: 18),
             )
                 : Container(),
           ],
          ),

        ),
      ),
    );
  }
}
