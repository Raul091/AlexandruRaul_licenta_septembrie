import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:first_app/camera_screen.dart';
import 'package:first_app/dashboard.dart';
import 'package:first_app/signup_screen.dart';
import 'package:first_app/widgets/event.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:workmanager/workmanager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    await Firebase.initializeApp();
    // Add your background task logic here.
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

        if (eventStartDateTime.isAfter(now) &&
            eventStartDateTime.difference(now).inMinutes <= 30) {
          await sendNotification(userEmail, event.title, eventStartDateTime);
        }
      }
    }
    return Future.value(true);
  });
}

Future<void> sendNotification(String userEmail, String eventTitle, DateTime eventStartDateTime) async {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  var initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
  var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid);
  flutterLocalNotificationsPlugin.initialize(initializationSettings);

  var androidPlatformChannelSpecifics = AndroidNotificationDetails(
    'your_channel_id',
    'your_channel_name',
    importance: Importance.max,
    priority: Priority.high,
  );
  var platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics);

  await flutterLocalNotificationsPlugin.show(
    0,
    'Upcoming Event Reminder',
    'Reminder: Your event "$eventTitle" is starting at ${eventStartDateTime.toLocal()}.',
    platformChannelSpecifics,
  );
}

void initializeWorkManager() {
  Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: true,
  );
  Workmanager().registerPeriodicTask(
    "You have an upcoming event!",
    "You have an upcoming event!",
    frequency: Duration(minutes: 5),
  );
}
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  initializeWorkManager();
  await Firebase.initializeApp();

  FirebaseMessaging messaging = FirebaseMessaging.instance;

  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  print('User granted permission: ${settings.authorizationStatus}');

  Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
  Workmanager().registerPeriodicTask(
    '1',
    'checkUpcomingEvents',
    frequency: Duration(minutes: 1),
  );

  runApp(const MyApp());
}



class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key : key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".


  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  //Initialize Firebase App
  Future<FirebaseApp> _initializeFirebase() async{
    FirebaseApp firebaseApp = await Firebase.initializeApp();
    return firebaseApp;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: _initializeFirebase(),
        builder: (context, snapshot){
          if(snapshot.connectionState == ConnectionState.done) {
            return const LoginScreen();
          }
          return const Center(
              child: CircularProgressIndicator()
          );
        },
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key : key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  bool passToggle = true;
  //Login function
  static Future<User?> loginUsingEmailPassword({required String email, required String password, required BuildContext context}) async{
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user;
    final _formfield = GlobalKey<FormState>();
    try{
      UserCredential userCredential = await auth.signInWithEmailAndPassword(email: email, password: password);
      user = userCredential.user;

      final userEmail = userCredential.user!.email;
      SharedPreferences prefs = await SharedPreferences.getInstance();
      if (user != null) {
        await prefs.setString('lastLoggedInUser', user.email.toString());
      }

      if (user != null) {
        // Fetch events for the user and schedule notifications
        await _fetchAndScheduleNotifications(user.email);
      }
    } on FirebaseAuthException catch(e){
      if(e.code == "user-not-found"){
        print("No user found for that email");
      }
    }

    return user;
  }

  static Future<void> _fetchAndScheduleNotifications(String? userEmail) async {
    if (userEmail == null) return;

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

      if (eventStartDateTime.isAfter(DateTime.now())) {
        await sendNotification(userEmail, event.title, eventStartDateTime);
      }
    }
  }
  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Feel",
            style:TextStyle(
              color: Colors.black,
              fontSize: 40.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Text(
            "Welcome back!",
            style: TextStyle(
              color: Colors.black,
              fontSize: 28.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(
            height: 44.0,
          ),
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              hintText: "User Email",
              prefixIcon : Icon(Icons.email, color : Colors.black),
            ),
          ),
          const SizedBox(
            height: 26.0,
          ),
          TextField(
            controller: _passwordController,
            obscureText: passToggle,
            decoration: InputDecoration(
              hintText: "User Password",
              prefixIcon: Icon(Icons.lock, color: Colors.black),
              suffix: Builder(
                builder: (context) => GestureDetector(
                  onTap: () {
                    setState(() {
                      passToggle = !passToggle;
                    });
                  },
                  child: Icon(
                      passToggle ? Icons.visibility : Icons.visibility_off),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 12.0,
          ),
          const Text(
            "Forgot your Password?",
            style: TextStyle(color: Colors.blue),
          ),
          const SizedBox(
            height: 88.0,
          ),
          Container(
            width: double.infinity,
            child: RawMaterialButton(
              fillColor: Colors.lightBlue,
              elevation: 0.0,
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              onPressed: () async{
                User? user = await loginUsingEmailPassword(email: _emailController.text, password: _passwordController.text, context: context);
                print(user);
                if(user != null){
                  Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context)=>  DashboardScreen(userEmail: _emailController.text)));
                }
                else{
                  Text("User not found", style: TextStyle(fontSize: 18),);
                }
              },
              child: const Text(
                "Login",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.0,
                ),
              ),
            ),
          ),
          signUpOption(context)
        ],
      ),
    );
  }

  Row signUpOption(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Don't you have an account?", style: TextStyle(color: Colors.black)),
        GestureDetector(
          onTap: () {
            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const SignUpScreen()));
          },
          child: const Text(
            "Sign Up",
            style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

}