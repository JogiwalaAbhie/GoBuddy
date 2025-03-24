import 'package:flutter/material.dart';
import '../const.dart';
import '../models/travel_model.dart';
import '../pages/place_detail.dart';
import '../pages/user_trips_details.dart';
import '../widgets/userside_usertripedit.dart';
import 'admin_navigation.dart';

class AdminSideUserTripPage extends StatefulWidget {
  const AdminSideUserTripPage({super.key});

  @override
  State<AdminSideUserTripPage> createState() => _UserTripPageState();
}

class _UserTripPageState extends State<AdminSideUserTripPage> {

  List<Trip> trips = [];

  String searchQuery = "";
  bool isSearching = false;
  String? selectedCategory;
  String? selectedCost;
  TextEditingController searchController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: isSearching
            ? TextField(
          controller: searchController,
          decoration: InputDecoration(
            hintText: "Search trips...",
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.white70),
          ),
          style: TextStyle(color: Colors.white),
          autofocus: true,
          onChanged: (query) {
            setState(() => searchQuery = query);
          },
        )
            : Text("User Trips"),
        backgroundColor: Color(0xFF134277),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                if (isSearching) {
                  searchQuery = "";
                  searchController.clear();
                }
                isSearching = !isSearching;
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () {
              showFilterDialog(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView( // Wrap everything in a scrollable view
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              StreamBuilder<List<Trip>>(
                stream: UserTripSearchService().fetchFilteredTrips(searchQuery, selectedCategory, selectedCost),// Fetch trips in real-time
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());  // Show loading indicator
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text("No trips found."));  // Handle empty data
                  }

                  final recomendate = snapshot.data!;  // Get the trip data

                  return Column(
                    children: List.generate(
                      recomendate.length,
                          (index) {
                        final trip = recomendate[index];  // Get trip at this index
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 15),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => UserTripsDetails(trip: trip)
                                ),
                              );
                            },
                            child: UserTripWidget(trip: trip),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),

              // You can add more widgets here as needed.
            ],
          ),
        ),
      ),
    );
  }

  void showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: Text("Filter Trips", style: TextStyle(fontWeight: FontWeight.w600)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(labelText: "Category",
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFBFCFF3), width: 2),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF134277), width: 2),
                      ),),
                    value: selectedCategory,
                    items: ["Adventure", "Beach Vacations", "Historical Tours", "Road Trips", "Volunteer & Humanitarian", "Wellness"]
                        .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                        .toList(),
                    onChanged: (value) {
                      setDialogState(() => selectedCategory = value);
                    },
                  ),
                  SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(labelText: "Cost Level",
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFBFCFF3), width: 2),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF134277), width: 2),
                      ),),
                    value: selectedCost,
                    items: ["Easy", "Medium", "Premium"]
                        .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                        .toList(),
                    onChanged: (value) {
                      setDialogState(() => selectedCost = value);
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    setDialogState(() {
                      selectedCategory = null;
                      selectedCost = null;
                    });
                  },
                  child: Text("Reset",style: TextStyle(color: Color(0xFF134277)),),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {}); // Refresh UI
                    Navigator.pop(context);
                  },
                  child: Text("Apply"),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    shadowColor: Colors.black,
                    backgroundColor: const Color(0xFF134277),
                    elevation: 10, // Elevation
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding:
                    EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
