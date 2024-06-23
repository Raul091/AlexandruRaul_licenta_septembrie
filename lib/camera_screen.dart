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
  late List<String> topActivities;

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

      // Extract captured emotions from the response
      var capturedEmotions = responseBody['captured_emotions'] as Map<String, dynamic>;

      String finalEmotiontmp = capturedEmotions.entries.reduce((a, b) => a.value > b.value ? a : b).key;

      setState(() {
        finalEmotion = finalEmotiontmp;
      });
      print('Captured Emotions: $capturedEmotions');
      activityBeforeEvent();
      //getTopActivities();
      //print('API response: $responseBody');
    } catch (error) {
      print('API Error: $error');
    }
  }

  void activityBeforeEvent() async {
    //DateTime dateAndDtime = DateTime.now();
    final now = DateTime.now();
    final upcomingEvents = await FirebaseFirestore.instance
        .collection('users')
        .get();

    for (var user in upcomingEvents.docs) {
      final userEmail = user.id;
      final eventsSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userEmail)
          .collection('events')
          .get();

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
        final eventName = event.title;

        if (eventStartDateTime.isAfter(now) &&
            eventStartDateTime
                .difference(now)
                .inMinutes <= 30) {
          final emotion = Emotion(
            eventTitle: eventName,
            emotion: finalEmotion,
          );

          await FirebaseFirestore.instance
              .collection('users')
              .doc(widget.userEmail)
              .collection('emotionsBeforeEvents')
              .add(emotion.toMap());
        }
        if(eventStartDateTime.isBefore(now) && eventEndDateTime.isAfter(now)){
          final emotion = Emotion(
            eventTitle: eventName,
            emotion: finalEmotion,
          );

          await FirebaseFirestore.instance
              .collection('users')
              .doc(widget.userEmail)
              .collection('emotionsDuringEvents')
              .add(emotion.toMap());
        }
      }
    }
  }

  void getTopActivities() async{
    QuerySnapshot snapshotBeforeEvent = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userEmail)
        .collection('emotionsBeforeEvents')
        .get();

    final fetchedEmotionBefore = snapshotBeforeEvent.docs.map((doc) {
      return Emotion.fromMap(doc.data() as Map<String, dynamic>);
    }).toList();

    QuerySnapshot snapshotDuringEvent = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userEmail)
        .collection('emotionsDuringEvents')
        .get();

    final fetchedEmotionDuring = snapshotDuringEvent.docs.map((doc) {
      return Emotion.fromMap(doc.data() as Map<String, dynamic>);
    }).toList();

    //setState(() {
      //activities = {};
    //var count = 0;
      for (var emotion in fetchedEmotionBefore) {
        final eventTitleBefore = emotion.eventTitle;
        final emotionBefore = emotion.emotion;
        for(var emotion2 in fetchedEmotionDuring){
          final eventTitleDuring = emotion2.eventTitle;
          final emotionDuring = emotion2.emotion;
          if(eventTitleBefore == eventTitleDuring)
            {
              if(emotionBefore == 'sad' && emotionDuring == 'happy')
                {
                  topActivities.add(eventTitleDuring);
                  //count++;
                }
            }
        }
      }
    //}
    //);
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
             finalEmotion.isNotEmpty
                 ? Text('Your emotion is: $finalEmotion \nActivities that may improve your mood:\n ' + findActivities(finalEmotion) + '\n' + topActivities[0] +'\n' + topActivities[1] + '\n' + topActivities[2] , style: TextStyle(fontSize: 18))
                 : Container(),
           ],
          ),

        ),
      ),
    );
  }
}
