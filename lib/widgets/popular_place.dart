import 'package:flutter/material.dart';
import 'package:gobuddy/Admin/admin_trip_edit.dart';
import 'package:gobuddy/const.dart';
import '../models/travel_model.dart';

class PopularTripWidget extends StatelessWidget {
  final Trip destination;
  const PopularTripWidget({super.key, required this.destination});

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
                  image: NetworkImage(
                    destination.image[0],
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
                                destination.name,
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
                                    destination.location,
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
                                destination.rate.toStringAsFixed(2),
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



