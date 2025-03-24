import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:gobuddy/const.dart';

class UserTripReportsPage extends StatefulWidget {
  const UserTripReportsPage({super.key});

  @override
  _UserTripReportsPageState createState() => _UserTripReportsPageState();
}

class _UserTripReportsPageState extends State<UserTripReportsPage> {
  String? selectedIssue;
  String selectedTripRole = "User Trip";

  final List<String> reportIssues = [
    "All Issues",
    "Inappropriate content",
    "Misleading information",
    "Scam or fraud",
    "Other issues"
  ];

  Stream<List<Map<String, dynamic>>> fetchTripReports() {
    return FirebaseFirestore.instance
        .collectionGroup('reports') // Fetch reports directly
        .snapshots()
        .map((reportsSnapshot) {
      List<Map<String, dynamic>> tripReports = [];

      for (var reportDoc in reportsSnapshot.docs) {
        Map<String, dynamic> reportData = reportDoc.data();
        String tripId = reportDoc.reference.parent.parent!.id; // Get tripId
        String reason = reportData['reason'] ?? 'No reason provided';
        String finalReason = reportData['finalReason'] ?? 'No reason provided';
        String userId = reportData['userId'] ?? '';
        Timestamp timestamp = reportData['timestamp'];
        String formattedDate = DateFormat('dd MMM yyyy, hh:mm a').format(timestamp.toDate());

        tripReports.add({
          'tripId': tripId,
          'reason': reason,
          'finalReason': finalReason,
          'reportId': reportDoc.id,
          'timestamp': formattedDate,
          'userId': userId,
        });
      }

      return tripReports;
    });
  }

  Future<Map<String, dynamic>?> fetchTripDetails(String tripId) async {
    DocumentSnapshot tripDoc = await FirebaseFirestore.instance.collection('trips').doc(tripId).get();
    if (tripDoc.exists) {
      return {
        'destination': tripDoc['destination'] ?? 'Unknown Destination',
        'firstImage': (tripDoc['photos'] as List<dynamic>?)?.first ?? '',
        'tripRole': tripDoc['tripRole'] ?? 'user',
      };
    }
    return null;
  }

  Future<Map<String, dynamic>?> fetchUserDetails(String userId) async {
    if (userId.isEmpty) return null;
    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    if (userDoc.exists) {
      return {
        'username': userDoc['username'] ?? 'Unknown User',
        'email': userDoc['email'] ?? '',
      };
    }
    return null;
  }

  void deleteReport(String tripId, String reportId) {
    FirebaseFirestore.instance.collection('trips').doc(tripId).collection('reports').doc(reportId).delete();
  }

  void showFilterDialog() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text("Filter Reports"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: reportIssues.map((issue) {
              return RadioListTile(
                title: Text(issue),
                value: issue,
                groupValue: selectedIssue,
                onChanged: (value) {
                  setState(() {
                    selectedIssue = value;
                  });
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: const Text("User Trip Reports", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF134277),
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: Icon(Icons.filter_list, color: Colors.white), onPressed: showFilterDialog),
        ],
      ),
      body: Column(
        children: [
          // Choice Chips for filtering trips
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ChoiceChip(
                  label: Text("User Trips", style: TextStyle(color: selectedTripRole == "User Trip" ? Colors.white : Colors.black)),
                  selected: selectedTripRole == "User Trip",
                  onSelected: (selected) => setState(() => selectedTripRole = "User Trip"),
                  selectedColor: Color(0xFF134277),
                  backgroundColor: Colors.grey[300],
                  showCheckmark: false,
                ),
                SizedBox(width: 10),
                ChoiceChip(
                  label: Text("Admin Trips", style: TextStyle(color: selectedTripRole == "Admin Trip" ? Colors.white : Colors.black)),
                  selected: selectedTripRole == "Admin Trip",
                  onSelected: (selected) => setState(() => selectedTripRole = "Admin Trip"),
                  selectedColor: Color(0xFF134277),
                  backgroundColor: Colors.grey[300],
                  showCheckmark: false,
                ),
              ],
            ),
          ),

          // Reports List
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: fetchTripReports(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text("No trip reports found."));
                }

                List<Map<String, dynamic>> reports = snapshot.data!;

                // Filter reports based on selected issue
                if (selectedIssue != null && selectedIssue != "All Issues") {
                  reports = reports.where((report) => report['reason'] == selectedIssue).toList();
                }

                return ListView.builder(
                  itemCount: reports.length,
                  itemBuilder: (context, index) {
                    final report = reports[index];

                    return FutureBuilder<Map<String, dynamic>?>(
                      future: fetchTripDetails(report['tripId']),
                      builder: (context, tripSnapshot) {
                        if (!tripSnapshot.hasData) return SizedBox.shrink();

                        final trip = tripSnapshot.data!;
                        if ((selectedTripRole == "User Trip" && trip['tripRole'] != "user") ||
                            (selectedTripRole == "Admin Trip" && trip['tripRole'] != "admin")) {
                          return SizedBox.shrink();
                        }

                        return FutureBuilder<Map<String, dynamic>?>(
                          future: fetchUserDetails(report['userId']),
                          builder: (context, userSnapshot) {
                            String userName = userSnapshot.data?['username'] ?? "Unknown User";
                            String email = userSnapshot.data?['email'] ?? "";

                            return Card(
                              color: Colors.white,
                              margin: EdgeInsets.all(12),
                              elevation: 4,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (trip['firstImage'].isNotEmpty)
                                    ClipRRect(
                                      borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                                      child: Image.network(trip['firstImage'], width: double.infinity, height: 180, fit: BoxFit.cover),
                                    ),
                                  Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(child: Text("Destination: ${trip['destination']}", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500))),
                                            IconButton(icon: Icon(Icons.delete, color: Colors.red), onPressed: () => deleteReport(report['tripId'], report['reportId'])),
                                          ],
                                        ),
                                        SizedBox(height: 7,),
                                        Text("Reported by: $userName ($email)", style: TextStyle(fontWeight: FontWeight.w500)),
                                        SizedBox(height: 7,),
                                        Text("Reason: ${report['finalReason']}", style: TextStyle(fontSize: 15, color: Colors.red)),
                                        SizedBox(height: 7,),
                                        Text("${report['timestamp']}", style: TextStyle(fontSize: 12, color: Colors.black87)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
