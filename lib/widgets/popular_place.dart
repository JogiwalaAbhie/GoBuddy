import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gobuddy/Admin/admin_trip_edit.dart';
import 'package:gobuddy/const.dart';
import '../models/travel_model.dart';


// class PopularTripWidget extends StatelessWidget {
//   final Trip trip;
//   const PopularTripWidget({super.key, required this.trip});
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
//       child: Stack(
//         children: [
//           Positioned(
//             bottom: 0,
//             right: 20,
//             left: 20,
//             child: Container(
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black12.withOpacity(0.1),
//                     spreadRadius: 8,
//                     blurRadius: 5,
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           ClipRRect(
//             borderRadius: BorderRadius.circular(15),
//             child: Container(
//               height: 210,
//               width: MediaQuery.of(context).size.width * 0.85,
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(15),
//                 image: DecorationImage(
//                   fit: BoxFit.cover,
//                   image: NetworkImage(
//                     trip.image[0],
//                   ),
//                 ),
//               ),
//               // child: CachedNetworkImage(
//               //   imageUrl: trip.image[0], // ✅ Fetches & caches the image
//               //   fit: BoxFit.cover,
//               //   placeholder: (context, url) => Container(
//               //     decoration: BoxDecoration(
//               //       borderRadius: BorderRadius.circular(15),
//               //     ),
//               //     color: Colors.grey.shade300, // ✅ Placeholder while loading
//               //     child: const Center(child: CircularProgressIndicator()),
//               //   ),
//               //   errorWidget: (context, url, error) => Container(
//               //     color: Colors.grey.shade300,
//               //     child: const Center(
//               //       child: Icon(Icons.error, color: Colors.red, size: 40),
//               //     ),
//               //   ),
//               // ),
//             ),
//           ),
//           Positioned(
//             bottom: 0,
//             left: 0,
//             right: 0,
//             child: Container(
//               color: Colors.black.withOpacity(0.7),
//               padding: const EdgeInsets.all(12),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         "${trip.from} To ${trip.to}",
//                         style: const TextStyle(
//                           fontSize: 16,
//                           color: Colors.white,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                       Row(
//                         crossAxisAlignment: CrossAxisAlignment.end,
//                         children: [
//                           const Icon(
//                             Icons.location_on,
//                             color: Colors.white,
//                             size: 18,
//                           ),
//                           const SizedBox(width: 5),
//                           Text(
//                             trip.location,
//                             style: const TextStyle(
//                               color: Colors.white,
//                               fontWeight: FontWeight.w200,
//                             ),
//                           )
//                         ],
//                       ),
//                     ],
//                   ),
//                   Row(
//                     children: [
//                       Icon(
//                         Icons.star_rounded,
//                         size: 22,
//                         color: Colors.amber[800],
//                       ),
//                       const SizedBox(width: 5),
//                       Text(
//                         trip.rate.toStringAsFixed(2),
//                         style: const TextStyle(
//                           fontSize: 15,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.white,
//                         ),
//                       )
//                     ],
//                   )
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }


class PopularTripWidget extends StatelessWidget {
  final Trip trip;
  const PopularTripWidget({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8,0,8,0),
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
              width: MediaQuery.of(context).size.width*0.85,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image:CachedNetworkImageProvider(
                    trip.image[0],
                  ),
                ),
              ),
              child: Column(
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
                                  )
                                ],
                              )
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
          ),
        ],
      ),
    );
  }
}
