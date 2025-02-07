import 'package:flutter/material.dart';

import '../const.dart';
import '../models/travel_model.dart';


class TripWidget  extends StatelessWidget {
  final Trip destination;
  const TripWidget({Key? key, required this.destination}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 110,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical:10,
      ),
      child: Row(
        children: [
          Container(
            width: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              image: DecorationImage(
                fit: BoxFit.cover,
                image: NetworkImage(
                  destination.image[0],
                ),
              ),
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
                    destination.name,
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
                        destination.location,
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
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: "${destination.rate}",
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                              ),
                            ),
                            TextSpan(
                              text: " (${destination.review} reviews)",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: Colors.black.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
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
                      text: "\₹ ${destination.price}",
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: blueTextColor),
                    ),
                    TextSpan(
                      text: " /Person",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          )
        ],
      ),
    );
    // return Container(
    //   height: 110,
    //   decoration: BoxDecoration(
    //     color: Colors.white,
    //     borderRadius: BorderRadius.circular(15),
    //   ),
    //   padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
    //   child: Row(
    //     children: [
    //       Container(
    //         width: 100,
    //         decoration: BoxDecoration(
    //           borderRadius: BorderRadius.circular(10),
    //           image: DecorationImage(
    //             fit: BoxFit.cover,
    //             image: NetworkImage(destination.image.isNotEmpty ? destination.image[0] : 'https://via.placeholder.com/100'),
    //           ),
    //         ),
    //       ),
    //       const SizedBox(width: 10),
    //       Expanded(
    //         child: SingleChildScrollView(
    //           child: Column(
    //             crossAxisAlignment: CrossAxisAlignment.start,
    //             mainAxisAlignment: MainAxisAlignment.center,
    //             children: [
    //               Text(
    //                 destination.name,
    //                 style: const TextStyle(
    //                   fontSize: 16,
    //                   color: Colors.black,
    //                   fontWeight: FontWeight.w600,
    //                 ),
    //               ),
    //               const SizedBox(height: 6),
    //               Row(
    //                 children: [
    //                   const Icon(Icons.location_on, color: Colors.black, size: 16),
    //                   Text(
    //                     destination.location,
    //                     style: TextStyle(fontSize: 12, color: Colors.black.withOpacity(0.6)),
    //                   )
    //                 ],
    //               ),
    //               const SizedBox(height: 5),
    //               Row(
    //                 children: [
    //                   Text.rich(
    //                     TextSpan(
    //                       children: [
    //                         TextSpan(
    //                           text: "${destination.rate}",
    //                           style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black),
    //                         ),
    //                         TextSpan(
    //                           text: " (${destination.review} reviews)",
    //                           style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: Colors.black.withOpacity(0.6)),
    //                         ),
    //                       ],
    //                     ),
    //                   ),
    //                 ],
    //               )
    //             ],
    //           ),
    //         ),
    //       ),
    //       Column(
    //         children: [
    //           const Spacer(),
    //           Text.rich(
    //             TextSpan(
    //               children: [
    //                 TextSpan(
    //                   text: "\₹ ${destination.price}",
    //                   style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.blue),
    //                 ),
    //                 TextSpan(
    //                   text: " /Person",
    //                   style: TextStyle(fontSize: 12, color: Colors.black.withOpacity(0.6)),
    //                 ),
    //               ],
    //             ),
    //           ),
    //         ],
    //       )
    //     ],
    //   ),
    // );
  }
}