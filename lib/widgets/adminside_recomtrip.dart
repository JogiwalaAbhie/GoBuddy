import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gobuddy/Admin/admin_trip_edit.dart';
import '../Admin/user_trip_edit.dart';
import '../const.dart';
import '../models/travel_model.dart';

class AdminSideRecomTripManage  extends StatelessWidget {
  final Trip trip;
  const AdminSideRecomTripManage({Key? key, required this.trip}) : super(key: key);


  @override
  Widget build(BuildContext context) {
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
                      image: CachedNetworkImageProvider(trip.image[0]),
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
                              Icons.location_on,
                              color: Colors.black,
                              size: 16,
                            ),
                            Expanded( // ✅ Ensures proper layout distribution
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Text(
                                  "${trip.from} To ${trip.to}",

                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black.withOpacity(0.6),
                                  ),
                                ),
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
                        )
                      ],
                    ),
                  ),
                ),
                Column(
                  children: [
                    const Spacer(),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: "\₹ ${trip.price}",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: blueTextColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
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
                if (value == 'edit') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AdminTripEditScreen(trip: trip)),
                  );
                } else if (value == 'delete') {
                  DeleteTripService().deleteUserTrip(context, trip);
                } else if (value == 'toggle_popular') {
                  PopularTripService().togglePopularStatus(context, trip);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, color: Color(0xFF134277)),
                      SizedBox(width: 8),
                      Text("Edit"),
                    ],
                  ),
                ),
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
                PopupMenuItem(
                  value: 'toggle_popular',
                  child: Row(
                    children: [
                      Icon(
                        trip.popular ? Icons.star_border : Icons.star,
                        color: Color(0xFF134277),
                      ),
                      SizedBox(width: 8),
                      Text(trip.popular ? "Make Unpopular" : "Make Popular"),
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