import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/travel_model.dart';
import '../pages/place_detail.dart';
import '../widgets/adminside_admintrip.dart';

class AdminTripsPage extends StatefulWidget {
  const AdminTripsPage({super.key});

  @override
  State<AdminTripsPage> createState() => _AdminTripsPageState();
}

class _AdminTripsPageState extends State<AdminTripsPage> {
  String searchQuery = "";
  bool isSearching = false;
  String? selectedCategory;
  String? selectedTransport;
  TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            : Text("Admin Trips"),
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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: StreamBuilder<List<Trip>>(
          stream: AdminTripService().fetchFilteredTrips(searchQuery, selectedCategory, selectedTransport),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text("No trips found."));
            }

            final adminTrips = snapshot.data!;

            return ListView.builder(
              padding: EdgeInsets.all(10),
              itemCount: adminTrips.length,
              itemBuilder: (context, index) {
                final trip = adminTrips[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PlaceDetailScreen(trip: trip),
                      ),
                    );
                  },
                  child: AdminSideAdminTripManage(trip: trip),
                );
              },
            );
          },
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
                    decoration: InputDecoration(labelText: "Transport",
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFBFCFF3), width: 2),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF134277), width: 2),
                      ),),
                    value: selectedTransport,
                    items: ["Car", "Bus", "Train", "Flight"]
                        .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                        .toList(),
                    onChanged: (value) {
                      setDialogState(() => selectedTransport = value);
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    setDialogState(() {
                      selectedCategory = null;
                      selectedTransport = null;
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
