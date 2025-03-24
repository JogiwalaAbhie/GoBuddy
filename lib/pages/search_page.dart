import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/travel_model.dart';
import '../widgets/recomendate.dart';
import '../const.dart';
import 'place_detail.dart';

class SearchTripPage extends StatefulWidget {
  @override
  _SearchTripPageState createState() => _SearchTripPageState();
}

class _SearchTripPageState extends State<SearchTripPage> {
  final TextEditingController _searchController = TextEditingController();
  final TripSearchService _searchService = TripSearchService();
  String searchQuery = "";

  // Categories & Transport Filters
  final List<String> tripcat = [
    "Adventure",
    "Beach Vacations",
    "Historical Tours",
    "Road Trips",
    "Volunteer & Humanitarian",
    "Wellness"
  ];
  final List<String> transport = ["Car", "Bus", "Train", "Flight"];

  String? selectedCategory;
  String? selectedTransport;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: Text("Search a Trip", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        backgroundColor: Color(0xFF134277),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Field
            TextFormField(
              controller: _searchController,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search, color: Colors.black87),
                hintText: 'Enter trip..',
                filled: true,
                fillColor: Color(0xFFBFCFF3),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
              onChanged: (query) {
                setState(() => searchQuery = query);
              },
            ),
            SizedBox(height: 10),

            // Dropdown Filters
            Row(
              children: [
                // Category Filter
                Flexible(
                  child: DropdownButtonFormField<String>(
                    isExpanded: true, // Prevents dropdown width issues
                    decoration: InputDecoration(
                      hintText: "Category",
                      filled: true,
                      fillColor: Color(0xFFBFCFF3),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    value: selectedCategory,
                    items: tripcat
                        .map((cat) => DropdownMenuItem(
                      value: cat,
                      child: Text(
                        cat,
                        overflow: TextOverflow.ellipsis, // Prevents text overflow
                        maxLines: 1,
                      ),
                    ))
                        .toList(),
                    onChanged: (value) {
                      setState(() => selectedCategory = value);
                    },
                  ),
                ),
                SizedBox(width: 10),

                // Transport Filter
                Flexible(
                  child: DropdownButtonFormField<String>(
                    isExpanded: true, // Prevents dropdown width issues
                    decoration: InputDecoration(
                      hintText: "Transport",
                      filled: true,
                      fillColor: Color(0xFFBFCFF3),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    value: selectedTransport,
                    items: transport
                        .map((t) => DropdownMenuItem(
                      value: t,
                      child: Text(
                        t,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ))
                        .toList(),
                    onChanged: (value) {
                      setState(() => selectedTransport = value);
                    },
                  ),
                ),
              ],
            ),

            SizedBox(height: 15),

            // Trip List
            Expanded(
              child: StreamBuilder<List<Trip>>(
                stream: _searchService.fetchSearchedTrips(searchQuery, selectedCategory, selectedTransport),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text("No trips found."));
                  }

                  final filteredTrips = snapshot.data!;
                  return ListView.builder(
                    itemCount: filteredTrips.length,
                    itemBuilder: (context, index) {
                      final trip = filteredTrips[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => PlaceDetailScreen(trip: trip)),
                          );
                        },
                        child: SearchTripWidget(trip: trip),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
