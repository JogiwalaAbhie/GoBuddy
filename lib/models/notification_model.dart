import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:workmanager/workmanager.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:http/http.dart' as http;


FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

// ✅ Function to fetch booked trips & schedule notification 24 hours before
Future<void> checkTripsAndScheduleNotifications() async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  QuerySnapshot bookedTrips = await firestore.collection("booked_trip").get();

  for (var doc in bookedTrips.docs) {
    Timestamp tripStartTime = doc["startDateTime"];
    DateTime startTime = tripStartTime.toDate();
    DateTime notificationTime = startTime.subtract(Duration(hours: 24));

    if (notificationTime.isAfter(DateTime.now())) {
      scheduleNotification(doc.id, notificationTime, doc["title"]);
    }
  }
}

// ✅ Function to schedule a local notification
void scheduleNotification(String tripId, DateTime scheduleTime, String tripTitle) async {
  await flutterLocalNotificationsPlugin.zonedSchedule(
    tripId.hashCode,
    "Upcoming Trip Reminder",
    "Your trip '$tripTitle' starts in 24 hours!",
    tz.TZDateTime.from(scheduleTime, tz.local),
    const NotificationDetails(
      android: AndroidNotificationDetails(
        'trip_channel_id',
        'Trip Reminders',
        importance: Importance.high,
        priority: Priority.high,
      ),
    ),
    androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle, // ✅ Required in latest version
  );
}

// ✅ Function to schedule periodic background checks
void scheduleBackgroundTask() {
  Workmanager().registerPeriodicTask(
    "check_trips_task",
    "checkTripsAndScheduleNotifications",
    frequency: Duration(hours: 1), // Runs every hour
  );
}



class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  /// 🔹 Request Notification Permissions
  Future<void> requestPermission() async {
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print("✅ User granted permission for notifications");
    } else {
      print("❌ User denied notification permissions");
    }
  }

  /// 🔹 Get FCM Token & Save in Firestore
  Future<void> saveFCMToken(String userId) async {
    try {
      String? token = await _fcm.getToken();
      if (token != null) {
        await FirebaseFirestore.instance.collection('users').doc(userId).update({
          'fcmToken': token,
        });
        print("✅ FCM Token saved: $token");
      } else {
        print("❌ FCM Token not generated!");
      }
    } catch (e) {
      print("❌ Error saving FCM Token: $e");
    }
  }

  /// 🔹 Send FCM Notification using Firebase Cloud Messaging V1 API
  Future<void> sendFCMNotification({
    required String token,
    required String title,
    required String body,
  }) async {
    try {
      final String projectId = "gobuddy-at1435"; // 🔹 Replace with your Firebase Project ID
      final String url = "https://fcm.googleapis.com/v1/projects/$projectId/messages:send";
      final String accessToken = "ya29.c.c0ASRK0GaJYVHjISfHdRFv7bETvg-9WgJq5Oij5xcS74NG7Ys-iWuXPRXCOdpJ9fQlkoTCTX227t6kK1Adv3v1jHYBnQYclI0Naztt-xD8wFhuUugW9kcVxfPejt8LeypVp05y9UlldxhOTtiFFUCr7vy5IBeQQWXeQ5FNuOy3bVWQkPPMpeV17HFEuiTxIBlHSSbPqG1TBpYXx5AzILNBVuH0ufiWpck7M8YTA_znyPcLEoZeqKQDgBJPjI1JAmEKlbvy-4I6rfaovzwOD7XAuKwQRxw0q-N4vJWrZfAqn6vaP-gRkrchrwCuH3mkPYxF6R25zPfufvMKsZfbf1FrPLa88u1Cx2nY1C4ybLG6lsCn5_CKx2i-VGEMzJcEvooJML5FgAT399PiXn4b4_X3o8_88SBmJu64erJMpe-mb8Spc8XhUQoVr_WuIVn-y-QcnpjrQWprVrxg0aUuQc0SaqyX9IJQSYZ7o8qBSY-zORQ-7hxFSaSzBvz_vXBOcncmBbitVztbtsnur_gZaI1QtcawZ7vZsmsyyOiavFOyMe_hk57QhoX-XUen6IfXcX-l3Vgb7taSpv_8__XSbv_hdZRIdlW1p44BFku1f-tucfUZuyyeIpmpyjlJO1dMg0VUXmI_6tBhgt-M15Sc1w-ycnWsgM16hFnW9gj01V-kclFdXv2vSBOckt3Z2nhgzFr2F0lryedwF8FpBp3uQVaZoJ-6XsgcnkdcnSUSk40m1xczOMiprBeqz9VUl8agdl9Vrdgek0-V0dIl2Vlttd7IR6_kVV8OXs0sapZF1V2WtpzRoeX7uUVR-1jvB-7FV8SdcuzZeRfYzORalM3dwc4xy3B5BFgR0ciyw_BWiVkM7l_Yep_cZpIapSVvkpMg4tbU02o1f9iSmof6qkRrz_9VsMvsWm5x9h97xy2z8rilgV_UfsiqU6mvc-u2e5RiIngbyjlp4zIa9ZMt1ddlnwtz64fe53YQe6pVM4fupMUcFO4_unrpBrWn7ld"; // 🔹 Replace with OAuth Access Token

      final Map<String, dynamic> message = {
        "message": {
          "token": token,
          "notification": {
            "title": title,
            "body": body,
          },
          "android": {
            "priority": "high",
          },
          "apns": {
            "payload": {
              "aps": {
                "sound": "default",
              }
            }
          }
        }
      };

      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Authorization": "Bearer $accessToken",
          "Content-Type": "application/json",
        },
        body: jsonEncode(message),
      );

      if (response.statusCode == 200) {
        print("✅ Notification sent successfully!");
      } else {
        print("❌ Failed to send notification: ${response.body}");
      }
    } catch (e) {
      print("❌ Error sending notification: $e");
    }
  }
}

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final NotificationService _notificationService = NotificationService();

  /// 🔹 Notify Admin when User Requests Trip Approval
  Future<void> sendNotificationToAdmin(String tripId, String userId) async {
    try {
      DocumentSnapshot adminDoc = await _firestore
          .collection('users')
          .doc('vwcaiZdMuXQM1KzgsY1CmWjaZXy1')
          .get();

      if (!adminDoc.exists || !adminDoc.data().toString().contains('fcmToken')) {
        print("❌ Admin FCM token not found!");
        return;
      }

      String? adminFCMToken = adminDoc['fcmToken'];
      if (adminFCMToken != null && adminFCMToken.isNotEmpty) {
        await _notificationService.sendFCMNotification(
          token: adminFCMToken,
          title: "New Trip Approval Request",
          body: "User $userId has requested approval for trip $tripId.",
        );
      } else {
        print("❌ Admin does not have a valid FCM token!");
      }
    } catch (e) {
      print("❌ Error notifying admin: $e");
    }
  }

  /// 🔹 Notify User When Admin Approves/Rejects Trip
  Future<void> sendTripStatusNotification(String userId, String status) async {
    try {
      DocumentSnapshot userDoc =
      await _firestore.collection('users').doc(userId).get();

      if (!userDoc.exists || !userDoc.data().toString().contains('fcmToken')) {
        print("❌ User FCM token not found!");
        return;
      }

      String? userFCMToken = userDoc['fcmToken'];
      if (userFCMToken != null && userFCMToken.isNotEmpty) {
        await _notificationService.sendFCMNotification(
          token: userFCMToken,
          title: "Trip Approval Update",
          body: "Your trip request has been $status.",
        );
      } else {
        print("❌ User does not have a valid FCM token!");
      }
    } catch (e) {
      print("❌ Error notifying user: $e");
    }
  }

  /// 🔹 Admin Approves a Trip
  Future<void> approveTrip(String tripId, String userId) async {
    try {
      await _firestore.collection('trips').doc(tripId).update({'isApproved': true});
      await sendTripStatusNotification(userId, "approved");
      print("✅ Trip approved successfully!");
    } catch (e) {
      print("❌ Error approving trip: $e");
    }
  }

  /// 🔹 Admin Rejects a Trip
  Future<void> rejectTrip(String tripId, String userId) async {
    try {
      await _firestore.collection('trips').doc(tripId).delete();
      await sendTripStatusNotification(userId, "rejected");
      print("✅ Trip rejected and deleted successfully!");
    } catch (e) {
      print("❌ Error rejecting trip: $e");
    }
  }
}
