import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gobuddy/Admin/admin_trip_edit.dart';
import 'package:gobuddy/const.dart';
import '../models/travel_model.dart';

class AdminSidePopularTripManage extends StatelessWidget {
  final Trip trip;
  const AdminSidePopularTripManage({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
      child: Stack(
        children: [
          Positioned(
            bottom: 0,
            right: 20,
            left: 20,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12.withOpacity(0.1),
                    spreadRadius: 8,
                    blurRadius: 5,
                  ),
                ],
              ),
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Container(
              height: 210,
              width: MediaQuery.of(context).size.width * 0.85,
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
              child: Stack(
                children: [
                  Column(
                    children: [
                      const Spacer(),
                      Container(
                        color: Colors.black.withOpacity(0.7),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "${trip.from} To ${trip.to}",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      const Icon(
                                        Icons.location_on,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        trip.location,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w200,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Icon(
                                    Icons.star_rounded,
                                    size: 22,
                                    color: Colors.amber[800],
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    trip.rate.toStringAsFixed(2),
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  //More Vert Icon on Top-Right Corner
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
            ),
          ),
        ],
      ),
    );

  }
}