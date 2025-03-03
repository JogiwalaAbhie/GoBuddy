import 'package:flutter/material.dart';
import '../Admin/user_trip_edit.dart';
import '../const.dart';
import '../models/travel_model.dart';

class AdminSideUserTripManage  extends StatelessWidget {
  final Trip trip;
  const AdminSideUserTripManage({Key? key, required this.trip}) : super(key: key);


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
                          trip.name,
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
                            Text(
                              trip.location,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black.withOpacity(0.6),
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            Text(
                              "Day : ",
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
                    MaterialPageRoute(builder: (context) => UserTripEditScreen(trip: trip)),
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
                      Icon(Icons.edit, color: Colors.blue),
                      SizedBox(width: 8),
                      Text("Edit"),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
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
                        color: Colors.orange,
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
    // return SingleChildScrollView(
    //   child: Padding(
    //     padding: const EdgeInsets.fromLTRB(8, 2, 8, 2),
    //     child: Container(
    //       height: 300,
    //       decoration: BoxDecoration(
    //         color: Colors.white,
    //         borderRadius: BorderRadius.circular(12),
    //         boxShadow: [
    //           BoxShadow(
    //             color: Colors.black26,
    //             offset: Offset(0, 5),
    //             blurRadius: 7,
    //             spreadRadius: 1,
    //           )
    //         ],
    //       ),
    //       child: Column(
    //         crossAxisAlignment: CrossAxisAlignment.start,
    //         children: [
    //           Stack(
    //             children: [
    //               ClipRRect(
    //                 borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
    //                 child: Image.network(
    //                   destination.image[0],
    //                   height: 180,
    //                   width: double.infinity,
    //                   fit: BoxFit.cover,
    //                 ),
    //               ),
    //               Positioned(
    //                 top: 10,
    //                 left: 10,
    //                 child: Container(
    //                   padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    //                   decoration: BoxDecoration(
    //                     color: Colors.black.withOpacity(0.6),
    //                     borderRadius: BorderRadius.circular(8),
    //                   ),
    //                   child: Text(
    //                     destination.location,
    //                     style: TextStyle(
    //                       color: Colors.white,
    //                       fontWeight: FontWeight.w500,
    //                     ),
    //                   ),
    //                 ),
    //               ),
    //             ],
    //           ),
    //           Padding(
    //             padding: EdgeInsets.all(8),
    //             child: Column(
    //               crossAxisAlignment: CrossAxisAlignment.start,
    //               children: [
    //                 Text(
    //                   destination.name,
    //                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
    //                 ),
    //                 SizedBox(height: 3),
    //                 Row(
    //                   children: [
    //                     Icon(Icons.hiking, size: 16, color: Colors.grey),
    //                     SizedBox(width: 5),
    //                     Text(destination.tripCategory, style: TextStyle(color: Colors.grey)),
    //                   ],
    //                 ),
    //                 SizedBox(height: 4),
    //                 Row(
    //                   children: [
    //                     Text("By", style: TextStyle(color: Colors.black87)),
    //                     SizedBox(width: 3,),
    //                     Text(destination.hostName, style: TextStyle(color: Colors.black87)),
    //                   ],
    //                 ),
    //                 SizedBox(height: 5),
    //                 Row(
    //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //                   children: [
    //                     Row(
    //                       children: [
    //                         Text(
    //                           "₹ ${destination.price}",
    //                           style: TextStyle(
    //                             fontSize: 18,
    //                             fontWeight: FontWeight.w600,
    //                             color: Color(0xFF134277),
    //                           ),
    //                         ),
    //                       ],
    //                     ),
    //                     Row(
    //                       children: [
    //                         Icon(Icons.star, color: Colors.amber),
    //                         Text(
    //                           "${destination.rate.toStringAsFixed(2)}",
    //                           style: TextStyle(fontWeight: FontWeight.bold),
    //                         ),
    //                         SizedBox(width: 5),
    //                         Text("(${destination.review} Review)", style: TextStyle(color: Colors.grey)),
    //                       ],
    //                     ),
    //                   ],
    //                 ),
    //               ],
    //             ),
    //           ),
    //         ],
    //       ),
    //     ),
    //   ),
    // );
  }
}