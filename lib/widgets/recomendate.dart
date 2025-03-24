import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../const.dart';
import '../models/travel_model.dart';


class RecomTripWidget extends StatelessWidget {
  final Trip trip;
  const RecomTripWidget({Key? key, required this.trip}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
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
            // ✅ Cached Image for Smoother Loading
            Container(
              width: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CachedNetworkImage(
                  imageUrl: trip.image[0],
                  fit: BoxFit.cover,
                  width: 100,
                  height: 120, // Match container height
                  placeholder: (context, url) => Center(
                    child: CircularProgressIndicator(),
                  ),
                  errorWidget: (context, url, error) => Icon(Icons.error, size: 50),
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
                        const Icon(Icons.location_on, color: Colors.black, size: 16),
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Text(
                              "${trip.from} To ${trip.to}",
                              style: TextStyle(fontSize: 14, color: Colors.black.withOpacity(0.6)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Text(
                          "Day:",
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black),
                        ),
                        SizedBox(width: 5),
                        Text(
                          "${trip.daysOfTrip}",
                          style: TextStyle(fontWeight: FontWeight.w400, fontSize: 12, color: Colors.black),
                        ),
                      ],
                    ),
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
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: blueTextColor),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class SearchTripWidget extends StatelessWidget {
  final Trip trip;
  const SearchTripWidget({Key? key, required this.trip}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(3, 8, 3, 8),
        child: Container(
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
              /// **CachedNetworkImage for optimized loading**
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CachedNetworkImage(
                  imageUrl: trip.image[0],
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  errorWidget: (context, url, error) => const Icon(
                    Icons.error,
                    color: Colors.red,
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
                          Expanded(
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
                          const Text(
                            "Day:",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            "${trip.daysOfTrip}",
                            style: const TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 12,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
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
                          text: "₹ ${trip.price}",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.blue,
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
      ),
    );
  }
}

