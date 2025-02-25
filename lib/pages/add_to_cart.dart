import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gobuddy/const.dart';

class AddToCartPage extends StatefulWidget {
  @override
  _AddToCartPageState createState() => _AddToCartPageState();
}

class _AddToCartPageState extends State<AddToCartPage> {
  final CollectionReference cartRef =
  FirebaseFirestore.instance.collection('cart');

  double totalAmount = 0;

  void updatePersonCount(String docId, int newCount, double pricePerPerson) {
    cartRef.doc(docId).update({'personCount': newCount}).then((_) {
      setState(() {});
    });
  }

  void removeTrip(String docId) {
    cartRef.doc(docId).delete().then((_) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: Text("Your Cart",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF134277),
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder(
        stream: cartRef.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          double tempTotal = 0;
          List<DocumentSnapshot> cartItems = snapshot.data!.docs;
          cartItems.forEach((doc) {
            tempTotal += (doc['personCount'] * doc['pricePerPerson']);
          });
          totalAmount = tempTotal;

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    var doc = cartItems[index];
                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.all(16),
                        title: Text(
                          doc['tripTitle'],
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Destination: ${doc['destination']}',
                                style: TextStyle(color: Colors.grey[600])),
                            SizedBox(height: 5),
                            Text('Price: \₹${doc['pricePerPerson'].toStringAsFixed(2)} per person',
                                style: TextStyle(color: Colors.green, fontWeight: FontWeight.w400)),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.remove),
                              onPressed: () {
                                if (doc['personCount'] > 1) {
                                  updatePersonCount(doc.id, doc['personCount'] - 1, doc['pricePerPerson']);
                                }
                              },
                            ),
                            Text(
                              '${doc['personCount']}',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                            ),
                            IconButton(
                              icon: Icon(Icons.add),
                              onPressed: () {
                                updatePersonCount(doc.id, doc['personCount'] + 1, doc['pricePerPerson']);
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                removeTrip(doc.id);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Card(
                margin: EdgeInsets.all(10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text('Total Price',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
                      SizedBox(height: 5),
                      Text('\₹ ${totalAmount.toStringAsFixed(2)}',
                          style: TextStyle(fontSize: 24, color: Colors.blueAccent, fontWeight: FontWeight.w500)),
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          // Implement payment logic
                        },
                        child: Text('Make Payment', style: TextStyle(fontSize: 18, color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF134277),
                          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}