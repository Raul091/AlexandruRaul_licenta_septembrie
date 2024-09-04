import 'package:first_app/camera_screen.dart';
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
import 'package:fl_chart/fl_chart.dart';

class ChartScreen extends StatefulWidget {

  final String userEmail;
  const ChartScreen({ Key? key, required this.userEmail}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _ChartScreenState();
  }

}


class _ChartScreenState extends State<ChartScreen> {
  int weekCount = 0;
  List<double> weekEmotionMean = [];
  double weekAverage = 0.0;

  Future <void> getWeekDetails() async {
    DateTime now = DateTime.now();

    // Find the most recent Monday
    int daysSinceMonday = now.weekday - DateTime.monday;
    DateTime lastMonday = now.subtract(
        Duration(days: daysSinceMonday + 7 * weekCount)); // Last week's Monday

    DateTime lastSunday = lastMonday.add(
        Duration(days: 6)); // Last week's Sunday

    String startOfWeek = DateFormat("yyyy-MM-ddT00:00:00.SSS").format(
        lastMonday);
    String endOfWeek = DateFormat("yyyy-MM-ddTHH:mm:ss.SSS").format(lastSunday);

    print(startOfWeek.toString());
    print(endOfWeek.toString());
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userEmail)
        .collection('emotions')
        .where('start', isGreaterThanOrEqualTo: startOfWeek)
        .where('start', isLessThanOrEqualTo: endOfWeek)
        .get();

    List<Emotion> weekEmotions = snapshot.docs.map((doc) {
      return Emotion.fromMap(doc.data() as Map<String, dynamic>);
    }).toList();


    print(weekEmotions);


    List<int> weekEmotionsScore = [0, 0, 0, 0, 0, 0, 0];
    List<int> weekEmotionsCount = [0, 0, 0, 0, 0, 0, 0];
    List<double> weekEmotion = [];

    final Map<String, int> emotionScores = {
      "happy": 7,
      "surprise": 6,
      "neutral": 5,
      "disgust": 4,
      "fear": 3,
      "angry": 2,
      "sad": 1,
    };

    for (var emotion in weekEmotions) {
      int weekdayIndex = emotion.start.weekday - 1;


      if (emotionScores.containsKey(emotion.emotion)) {
        weekEmotionsScore[weekdayIndex] += emotionScores[emotion.emotion]!;
        weekEmotionsCount[weekdayIndex]++;
      }
    }

    for(int i = 0; i < weekEmotionsScore.length; i++){
      if(weekEmotionsCount[i] != 0) {
        weekEmotionMean.add(weekEmotionsScore[i] / weekEmotionsCount[i]);
        weekAverage += weekEmotionMean[i];
      }else {
        weekEmotionMean.add(0.0);
      }
    }
    weekAverage /= 7.0;

    // for (var emotion in weekEmotions) {
    //   switch (DateTime
    //       .parse(emotion.dateTime)
    //       .weekday) {
    //     case 1:
    //       {
    //         switch (emotion.emotion) {
    //           case 'happy':
    //             {
    //               weekEmotionsMean[0] = weekEmotionsMean[0] + 7;
    //               weekEmotionsCount[0]++;
    //             }
    //             break;
    //           case 'surprise':
    //             {
    //               weekEmotionsMean[0] = weekEmotionsMean[0] + 6;
    //               weekEmotionsCount[0]++;
    //             }
    //             break;
    //           case 'neutral':
    //             {
    //               weekEmotionsMean[0] = weekEmotionsMean[0] + 5;
    //               weekEmotionsCount[0]++;
    //             }
    //             break;
    //           case 'disgust':
    //             {
    //               weekEmotionsMean[0] = weekEmotionsMean[0] + 4;
    //               weekEmotionsCount[0]++;
    //             }
    //             break;
    //           case 'fear':
    //             {
    //               weekEmotionsMean[0] = weekEmotionsMean[0] + 3;
    //               weekEmotionsCount[0]++;
    //             }
    //             break;
    //           case 'angry':
    //             {
    //               weekEmotionsMean[0] = weekEmotionsMean[0] + 1;
    //               weekEmotionsCount[0]++;
    //             }
    //             break;
    //           case 'sad':
    //             {
    //               weekEmotionsMean[0] = weekEmotionsMean[0] + 7;
    //               weekEmotionsCount[0]++;
    //             }
    //             break;
    //           default:
    //             {
    //
    //             }
    //             break;
    //         }
    //       }break;
    //     case 2:
    //       {
    //         switch (emotion.emotion) {
    //           case 'happy':
    //             {
    //               weekEmotionsMean[1] = weekEmotionsMean[1] + 7;
    //               weekEmotionsCount[1]++;
    //             }
    //             break;
    //           case 'surprise':
    //             {
    //               weekEmotionsMean[1] = weekEmotionsMean[1] + 6;
    //               weekEmotionsCount[1]++;
    //             }
    //             break;
    //           case 'neutral':
    //             {
    //               weekEmotionsMean[1] = weekEmotionsMean[1] + 5;
    //               weekEmotionsCount[1]++;
    //             }
    //             break;
    //           case 'disgust':
    //             {
    //               weekEmotionsMean[1] = weekEmotionsMean[1] + 4;
    //               weekEmotionsCount[1]++;
    //             }
    //             break;
    //           case 'fear':
    //             {
    //               weekEmotionsMean[1] = weekEmotionsMean[1] + 3;
    //               weekEmotionsCount[1]++;
    //             }
    //             break;
    //           case 'angry':
    //             {
    //               weekEmotionsMean[1] = weekEmotionsMean[1] + 1;
    //               weekEmotionsCount[1]++;
    //             }
    //             break;
    //           case 'sad':
    //             {
    //               weekEmotionsMean[1] = weekEmotionsMean[1] + 7;
    //               weekEmotionsCount[1]++;
    //             }
    //             break;
    //           default:
    //             {
    //
    //             }
    //             break;
    //         }
    //       }break;
    //     case 3:
    //       {
    //         switch (emotion.emotion) {
    //           case 'happy':
    //             {
    //               weekEmotionsMean[2] = weekEmotionsMean[2] + 7;
    //               weekEmotionsCount[2]++;
    //             }
    //             break;
    //           case 'surprise':
    //             {
    //               weekEmotionsMean[2] = weekEmotionsMean[2] + 6;
    //               weekEmotionsCount[2]++;
    //             }
    //             break;
    //           case 'neutral':
    //             {
    //               weekEmotionsMean[2] = weekEmotionsMean[2] + 5;
    //               weekEmotionsCount[2]++;
    //             }
    //             break;
    //           case 'disgust':
    //             {
    //               weekEmotionsMean[2] = weekEmotionsMean[2] + 4;
    //               weekEmotionsCount[2]++;
    //             }
    //             break;
    //           case 'fear':
    //             {
    //               weekEmotionsMean[2] = weekEmotionsMean[2] + 3;
    //               weekEmotionsCount[2]++;
    //             }
    //             break;
    //           case 'angry':
    //             {
    //               weekEmotionsMean[2] = weekEmotionsMean[2] + 1;
    //               weekEmotionsCount[2]++;
    //             }
    //             break;
    //           case 'sad':
    //             {
    //               weekEmotionsMean[2] = weekEmotionsMean[2] + 7;
    //               weekEmotionsCount[2]++;
    //             }
    //             break;
    //           default:
    //             {
    //
    //             }
    //             break;
    //         }
    //       }break;
      //}
    //}



  }

  @override
  void initState() {
    super.initState();
    //getWeekDetails();
    getWeekDetails().then((_) {
      setState((){

      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home:Scaffold(
        appBar: AppBar(
        leading: IconButton(
        onPressed: () async {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context)=> DashboardScreen(userEmail: widget.userEmail)));
    },
    icon: Icon(Icons.arrow_back,)

    ),
    title: Text("Statistics", style: TextStyle(fontSize: 20)), // Adjust title size
    centerTitle: true,
        ),
          body: Center(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                        onPressed: () {

                            weekCount++;
                            weekEmotionMean.clear();
                            weekAverage = 0.0;
                            getWeekDetails().then((_) {
                              setState((){

                              });
                            });

                        }, child: Icon(Icons.navigate_before),),
                    ElevatedButton(
                      onPressed: () {

                          if (weekCount > 0){
                            weekCount --;
                            weekAverage = 0.0;
                            weekEmotionMean.clear();
                          }

                          getWeekDetails().then((_) {
                            setState((){

                            });
                          });

                      }, child: Icon(Icons.navigate_next),),
                  ],
                ),
            weekEmotionMean.isEmpty
                ? CircularProgressIndicator()


         : Padding(
            padding: const EdgeInsets.all(20),
            child: AspectRatio(
              aspectRatio: 1,

              child: BarChart(
                BarChartData(
                  borderData: FlBorderData(
                    border: const Border(
                      top: BorderSide.none,
                      right: BorderSide.none,
                      left: BorderSide(width: 1),
                      bottom: BorderSide(width: 1),
                    ),
                  ),
                  groupsSpace: 10,
                  barGroups: weekEmotionMean.asMap().entries.map((entry){
                    int index = entry.key;
                    double value = entry.value; //< 1.0 ? 1.0 : entry.value;


                    return BarChartGroupData(
                      x: index +1,
                      barRods: [
                        BarChartRodData(
                          fromY: 0,
                          toY: value,
                          width: 7,
                          color: Colors.greenAccent,
                        ),
                      ],
                    );
                  }).toList(),
                  // barGroups:

                    // BarChartGroupData(
                    //   x: 1,
                    // barRods: [
                    //   BarChartRodData(fromY: 0, toY: 0, width: 7, color: Colors.greenAccent),
                    // ]),
                    // BarChartGroupData(
                    //     x: 2,
                    //     barRods: [
                    //       BarChartRodData(fromY: 0, toY: 3, width: 7, color: Colors.greenAccent),
                    //     ]),
                    // BarChartGroupData(
                    //     x: 3,
                    //     barRods: [
                    //       BarChartRodData(fromY: 0, toY: 7, width: 7, color: Colors.greenAccent),
                    //     ]),
                    // BarChartGroupData(
                    //     x: 4,
                    //     barRods: [
                    //       BarChartRodData(fromY: 0, toY: 4, width: 7, color: Colors.greenAccent),
                    //     ]),
                    // BarChartGroupData(
                    //     x: 5,
                    //     barRods: [
                    //       BarChartRodData(fromY: 0, toY: 4.5, width: 7, color: Colors.greenAccent),
                    //     ]),
                    // BarChartGroupData(
                    //     x: 3,
                    //     barRods: [
                    //       BarChartRodData(fromY: 0, toY: 0, width: 7, color: Colors.greenAccent),
                    //     ]),
                    // BarChartGroupData(
                    //     x: 5,
                    //     barRods: [
                    //       BarChartRodData(fromY: 0, toY: 1, width: 7, color: Colors.greenAccent),
                    //     ]),
                    // BarChartGroupData(
                    //     x: 3,
                    //     barRods: [
                    //       BarChartRodData(fromY: 0, toY: 3.33, width: 7, color: Colors.greenAccent),
                    //     ])
                  // ],
                ),
              ),
            ),
          ),
                Text("Your week's average is ${weekAverage.toStringAsFixed(1)}", style: TextStyle(fontSize: 20),),
                SizedBox(height: 20),
                Text("Legend: ",style: TextStyle(fontSize: 22),),
                SizedBox(height: 10),
                Text(" happy: 7\n surprise: 6\n neutral: 5\n disgust: 4\n fear: 3\n angry: 2\n sad: 1\n no emotion: 0",style: TextStyle(fontSize: 20),),
            ],

          ),
          ),
      ),
    );
  }
}