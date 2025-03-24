import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gobuddy/Admin/admin_trip_edit.dart';
import 'package:intl/intl.dart';
import '../Admin/user_trip_edit.dart';
import '../const.dart';
import '../models/travel_model.dart';


class UserTripWidget extends StatelessWidget {
  final Trip trip;
  const UserTripWidget({Key? key, required this.trip}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    void showParticipantsDialog(BuildContext context, String tripId) async {
      List<Map<String, dynamic>> participants = [];
      try {
        DocumentSnapshot tripSnapshot =
        await FirebaseFirestore.instance.collection('trips').doc(tripId).get();
        if (tripSnapshot.exists) {
          List<dynamic> joinedBy = tripSnapshot['joinedBy'] ?? [];
          for (String userId in joinedBy) {
            DocumentSnapshot userSnapshot =
            await FirebaseFirestore.instance.collection('users').doc(userId).get();
            if (userSnapshot.exists) {
              participants.add({
                'name': userSnapshot['username'] ?? 'Unknown',
                'number': userSnapshot['phone'] ?? 'Not Available',
                'profilePic': userSnapshot['profilePic'] ?? '',
              });
            }
          }
        }
      } catch (e) {
        print("Error fetching participants: $e");
      }

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            title: const Text("Participants :", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 22)),
            content: SizedBox(
              width: double.maxFinite,
              height: 300,
              child: participants.isNotEmpty
                  ? Scrollbar(
                thumbVisibility: true,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: participants.length,
                  itemBuilder: (context, index) {
                    final participant = participants[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: participant['profilePic'].isNotEmpty
                            ? CachedNetworkImageProvider(participant['profilePic'])
                            : const AssetImage("assets/default_user.png") as ImageProvider,
                      ),
                      title: Text(participant['name']),
                      subtitle: Text(participant['number']),
                    );
                  },
                ),
              )
                  : const Center(child: Text("No participants yet.", style: TextStyle(color: Colors.grey))),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close")),
            ],
          );
        },
      );
    }

    return SingleChildScrollView(
      child: Stack(
        children: [
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 4,
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Row(
              children: [
                Container(
                  width: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    image: trip.image.isNotEmpty
                        ? DecorationImage(
                      fit: BoxFit.cover,
                      image: CachedNetworkImageProvider(trip.image[0]),
                    )
                        : null,
                    color: trip.image.isEmpty ? Colors.grey[300] : null,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          trip.location,
                          style: const TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, color: Colors.black, size: 16),
                          Text(
                            (trip.startDate != null && trip.endDate != null)
                                ? " ${DateFormat('dd MMM yyyy').format(
                              trip.startDate is String
                                  ? DateTime.parse(trip.startDate as String)
                                  : (trip.startDate as DateTime),
                            )} - "
                                "${DateFormat('dd MMM yyyy').format(
                              trip.endDate is String
                                  ? DateTime.parse(trip.endDate as String)
                                  : (trip.endDate as DateTime),
                            )}"
                                : "Dates not available",
                            style: TextStyle(fontSize: 14, color: Colors.black.withOpacity(0.6)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          const Text("Day :", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black)),
                          const SizedBox(width: 5),
                          Text("${trip.daysOfTrip}", style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 12, color: Colors.black)),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          const Text("Cost Level :", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black)),
                          const SizedBox(width: 5),
                          Text("${trip.costLevel}", style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 14, color: Colors.black)),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


class UserTripEditWidget extends StatelessWidget {
  final Trip trip;
  const UserTripEditWidget({Key? key, required this.trip}) : super(key: key);


  @override
  Widget build(BuildContext context) {

    void showParticipantsDialog(BuildContext context, String tripId) async {
      List<Map<String, dynamic>> participants = [];

      try {
        // Fetch the trip document
        DocumentSnapshot tripSnapshot =
        await FirebaseFirestore.instance.collection('trips').doc(tripId).get();

        if (tripSnapshot.exists) {
          List<dynamic> joinedBy = tripSnapshot['joinedBy'] ?? [];

          for (String userId in joinedBy) {
            DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
                .collection('users')
                .doc(userId)
                .get();

            if (userSnapshot.exists) {
              participants.add({
                'name': userSnapshot['username'] ?? 'Unknown',  // Default value if null
                'number': userSnapshot['phone'] ?? 'Not Available',  // Default value if null
                'profilePic': userSnapshot['profilePic'] ?? '',  // Default to empty string
              });
            }
          }
        }
      } catch (e) {
        print("Error fetching participants: $e");
      }

      // Show Dialog Box
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            title: const Text("Participants :",
              style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 22
              ),
            ),
            content: SizedBox(
              width: double.maxFinite,
              height: 300, // Fixed height to enable scrolling
              child: participants.isNotEmpty
                  ? Scrollbar(
                thumbVisibility: true,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: participants.length,
                  itemBuilder: (context, index) {
                    final participant = participants[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: participant['profilePic'].isNotEmpty
                            ? NetworkImage(participant['profilePic'])
                            : const AssetImage("assets/default_user.png") as ImageProvider,
                      ),
                      title: Text(participant['name']),
                      subtitle: Text(participant['number']),
                    );
                  },
                ),
              )
                  : const Center(
                child: Text(
                  "No participants yet.",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Close"),
              ),
            ],
          );
        },
      );
    }



    return SingleChildScrollView(
      child: Stack(
        children: [
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 4,
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 10,
            ),
            child: Row(
              children: [
                Container(
                  width: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    image: trip.image.isNotEmpty // ✅ Check if image list is not empty
                        ? DecorationImage(
                      fit: BoxFit.cover,
                      image: NetworkImage(trip.image[0]),
                    )
                        : null, // No image, so avoid the error
                    color: trip.image.isEmpty ? Colors.grey[300] : null, // Placeholder color
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          trip.location,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_today,
                              color: Colors.black,
                              size: 16,
                            ),
                            Text(
                              (trip.startDate != null && trip.endDate != null)
                                  ? " ${DateFormat('dd MMM yyyy').format(
                                trip.startDate is String
                                    ? DateTime.parse(trip.startDate as String) // If stored as String, parse it
                                    : (trip.startDate as DateTime),  // If stored as DateTime, use directly
                              )} - "
                                  "${DateFormat('dd MMM yyyy').format(
                                trip.endDate is String
                                    ? DateTime.parse(trip.endDate as String)
                                    : (trip.endDate as DateTime),
                              )}"
                                  : "Dates not available",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            Text(
                              "Day :",
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black),
                            ),
                            SizedBox(width: 5),
                            Text(
                              "${trip.daysOfTrip}",
                              style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 12,
                                  color: Colors.black),
                            )
                          ],
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            Text(
                              "Cost Level :",
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black),
                            ),
                            SizedBox(width: 5),
                            Text(
                              "${trip.costLevel}",
                              style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14,
                                  color: Colors.black),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            child: PopupMenuButton<String>(
              color: kBackgroundColor,
              icon: const Icon(Icons.more_vert, color: Colors.black),
              onSelected: (value) {
               if (value == 'delete') {
                  DeleteTripService().deleteUserTrip(context, trip);
                } else if (value == 'view_participants') {
                  showParticipantsDialog(context, trip.id);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Color(0xFF134277)),
                      SizedBox(width: 8),
                      Text("Delete"),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'view_participants',
                  child: Row(
                    children: [
                      Icon(Icons.group, color: Color(0xFF134277)),
                      SizedBox(width: 8),
                      Text("View Participants"),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}