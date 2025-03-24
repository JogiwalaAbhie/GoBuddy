import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:workmanager/workmanager.dart';
import 'package:gobuddy/screen/splash.dart';
import 'models/notification_model.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();


Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Notification received: ${message.notification?.title}");
}


void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    await Firebase.initializeApp();
    await checkTripsAndScheduleNotifications();
    return Future.value(true);
  });
}


void listenForTokenChanges() {
  FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'fcmToken': newToken,
      });
      print("🔄 FCM Token updated: $newToken");
    }
  });
}



Future<void> checkAndUpdateTripStatus() async {
  try {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    Timestamp now = Timestamp.now();
    Timestamp cutoffTime = Timestamp.fromMillisecondsSinceEpoch(
        now.millisecondsSinceEpoch - (24 * 60 * 60 * 1000)); // 24 hours before now

    // ✅ Make sure field names are correct and without spaces
    QuerySnapshot snapshot = await firestore
        .collection("trips")
        .where("tripDone", isEqualTo: false) // ✅ No extra space
        .where("endDateTime", isLessThanOrEqualTo: cutoffTime) // ✅ Ensure correct field names
        .get();

    for (var doc in snapshot.docs) {
      await firestore.collection("trips").doc(doc.id).update({
        "tripDone": true, // ✅ Mark trip as completed
      });
    }

    print("✅ Updated ${snapshot.docs.length} trips to tripDone: true");
  } catch (e) {
    print("❌ Error updating trips: $e");
  }
}



Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Initialize Firebase
  if (Platform.isAndroid) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'AIzaSyAAqb54PkbP-L5atLFS0NRokMRgJL2MrQU',
        appId: '1:1015423722551:android:e3e3ba040120440579cbb2',
        messagingSenderId: '1015423722551',
        projectId: 'gobuddy-at1435',
      ),
    );
  } else {
    await Firebase.initializeApp();
  }

  await NotificationService().requestPermission();
  // ✅ Initialize Timezone
  tz.initializeTimeZones();
  listenForTokenChanges();

  // ✅ Initialize WorkManager
  Workmanager().initialize(callbackDispatcher, isInDebugMode: false);
  Workmanager().registerPeriodicTask(
    "check_trips_task",
    "checkTripsAndScheduleNotifications",
    frequency: Duration(hours: 1), // Runs every hour
  );

  // ✅ Initialize Local Notifications
  var androidInit = const AndroidInitializationSettings('@mipmap/ic_launcher');
  var initSettings = InitializationSettings(android: androidInit);
  await flutterLocalNotificationsPlugin.initialize(initSettings);

  // ✅ Firebase Messaging Background Handling
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // ✅ Check & Update Trip Status
  await checkAndUpdateTripStatus();

  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Color(0xFFF2F5F1),
        fontFamily: 'Rubik',
      ),
      title: 'GoBuddy',
      home: SplashScreen(),
    );
  }
}
