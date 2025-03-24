// import 'package:workmanager/workmanager.dart';
//
// import 'notification_model.dart';
//
// void callbackDispatcher() {
//   Workmanager().executeTask((task, inputData) async {
//     await NotificationService.init(); // Initialize notifications
//
//     String? tripStartString = inputData?['tripStart'];
//     if (tripStartString != null) {
//       DateTime tripStart = DateTime.parse(tripStartString);
//       await NotificationService.scheduleNotification(tripStart);
//     }
//
//     return Future.value(true);
//   });
// }
//
// void initWorkManager(DateTime tripStart) {
//   Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
//
//   // Schedule the background task
//   Workmanager().registerOneOffTask(
//     'tripReminderTask',
//     'sendTripNotification',
//     inputData: {'tripStart': tripStart.toIso8601String()},
//     initialDelay: tripStart.difference(DateTime.now()).abs() - Duration(days: 1),
//   );
// }
