import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class UserTripReportsPage extends StatefulWidget {
  const UserTripReportsPage({super.key});

  @override
  _UserTripReportsPageState createState() => _UserTripReportsPageState();
}

class _UserTripReportsPageState extends State<UserTripReportsPage> {
  String? selectedIssue;

  final List<String> reportIssues = [
    "All Issues",
    "Inappropriate content",
    "Misleading information",
    "Scam or fraud",
    "Other issues"
  ];

  Stream<List<Map<String, dynamic>>> fetchTripReports() {
    return FirebaseFirestore.instance.collection('trips').snapshots().asyncMap(
          (tripSnapshot) async {
        List<Map<String, dynamic>> tripReports = [];

        for (var tripDoc in tripSnapshot.docs) {
          String tripId = tripDoc.id;
          String tripTitle = tripDoc['tripTitle'] ?? 'Unknown Trip';
          String destination = tripDoc['destination'] ?? 'Unknown Destination';
          List<dynamic> tripImages = tripDoc['photos'] ?? [];
          String firstImage = tripImages.isNotEmpty ? tripImages.first : '';

          QuerySnapshot reportsSnapshot =
          await tripDoc.reference.collection('reports').get();

          for (var reportDoc in reportsSnapshot.docs) {
            String reason = reportDoc['reason'] ?? 'No reason provided';
            String reportId = reportDoc.id;
            Timestamp timestamp = reportDoc['timestamp'];
            String userId = reportDoc['userId'] ?? '';

            String formattedDate = timestamp != null
                ? DateFormat('dd MMM yyyy, hh:mm a').format(timestamp.toDate())
                : "Unknown Date";

            String userName = 'Unknown User';
            String email = '';
            if (userId.isNotEmpty) {
              DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
                  .collection('users')
                  .doc(userId)
                  .get();
              if (userSnapshot.exists) {
                userName = userSnapshot['username'] ?? 'Unknown User';
                email = userSnapshot['email'];
              }
            }

            /// **Final Filtering Logic**
            if (selectedIssue != null && selectedIssue != "All Issues") {
              if (selectedIssue == "Other issues") {
                // ✅ Exclude predefined reasons & fetch only custom reasons
                if (["Inappropriate content", "Misleading information", "Scam or fraud"]
                    .contains(reason)) {
                  continue; // Skip these predefined issues
                }
              } else if (selectedIssue != reason) {
                continue; // Show only selected issue
              }
            }

            tripReports.add({
              'tripId': tripId,
              'tripTitle': tripTitle,
              'destination': destination,
              'firstImage': firstImage,
              'reason': reason,
              'reportId': reportId,
              'timestamp': formattedDate,
              'userName': userName,
              'userEmail': email,
            });
          }
        }
        return tripReports;
      },
    );
  }

  void showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
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
                    selectedIssue = value as String?;
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
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text(
          "User Trip Reports",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF134277),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list, color: Colors.white),
            onPressed: showFilterDialog,
          ),
        ],
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: fetchTripReports(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No trip reports found."));
          }

          List<Map<String, dynamic>> reports = snapshot.data!;

          // Apply filter
          if (selectedIssue != null && selectedIssue != "All Issues") {
            reports = reports
                .where((report) => report['reason'] == selectedIssue)
                .toList();
          }

          return ListView.builder(
            itemCount: reports.length,
            itemBuilder: (context, index) {
              final report = reports[index];

              return Card(
                color: Colors.white,
                margin: EdgeInsets.all(10),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (report['firstImage'] != '')
                      ClipRRect(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(10),
                        ),
                        child: Image.network(
                          report['firstImage'],
                          width: double.infinity,
                          height: 180,
                          fit: BoxFit.cover,
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            report['tripTitle'],
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            "Destination: ${report['destination']}",
                            style: TextStyle(fontSize: 14),
                          ),
                          SizedBox(height: 5),
                          Text(
                            "Reported by: ${report['userName']} (${report['userEmail']})",
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            "Reason: ${report['reason']}",
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.red,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            "${report['timestamp']}",
                            style:
                            TextStyle(fontSize: 12, color: Colors.black87),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
