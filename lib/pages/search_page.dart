import 'package:flutter/material.dart';
import 'package:gobuddy/pages/place_detail.dart';
import '../const.dart';
import '../models/travel_model.dart';
import '../widgets/recomendate.dart';


class SearchTripPage extends StatefulWidget {
  @override
  _SearchTripPageState createState() => _SearchTripPageState();
}

class _SearchTripPageState extends State<SearchTripPage> {

  final TextEditingController _searchController = TextEditingController();
  final TripSearchService _searchService = TripSearchService();
  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: Text("Search a Trip",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Color(0xFF134277),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
            // Navigator.push(context, MaterialPageRoute(builder: (context) => NavigationPage()));
          },
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(10.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _searchController,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  hintText: 'Enter trip name',
                  border: InputBorder.none,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF8BA7E8), width: 2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF134277), width: 2),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.red, width: 1),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.red, width: 2),
                  ),
                ),
                onChanged: (query) {
                  setState(() {
                    searchQuery = query; // Update search query
                  });
                },
              ),
              SizedBox(height: 15,),
              SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    StreamBuilder<List<Trip>>(
                      stream: _searchService.fetchSearchedTrips(searchQuery),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }

                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return Center(child: Text("No trips found."));
                        }

                        final filteredTrips = snapshot.data!;

                        return Column(
                          children: List.generate(
                            filteredTrips.length,
                                (index) {
                              final trip = filteredTrips[index];  // Get trip at this index
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 15),
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => PlaceDetailScreen(
                                          trip: trip,  // Pass selected trip to the detail screen
                                        ),
                                      ),
                                    );
                                  },
                                  child: RecomTripWidget(
                                    trip: trip,  // Pass the trip to the widget
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
