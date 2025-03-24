import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gobuddy/pages/navigation_page.dart';


class EmailVerification{

  void checkEmailVerification(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return; // Safety check

    Timer? timer;
    bool isEmailVerified = user.emailVerified;

    if (!isEmailVerified) {
      user.sendEmailVerification(); // Send verification email

      showDialog(
        context: context,
        barrierDismissible: false, // Prevent dismissing
        builder: (BuildContext dialogContext) {
          return StatefulBuilder(
            builder: (context, setState) {
              timer = Timer.periodic(Duration(seconds: 3), (timer) async {
                await FirebaseAuth.instance.currentUser?.reload(); // Reload user from Firebase
                User? updatedUser = FirebaseAuth.instance.currentUser;

                if (updatedUser != null && updatedUser.emailVerified) {
                  timer.cancel();
                  Navigator.pop(dialogContext); // Close AlertDialog
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => NavigationPage()),
                        (route) => false, // Removes all previous screens from the stack
                  );

                }
              });

              return AlertDialog(
                backgroundColor: Colors.white,
                title: Text("Verify Your Email",style: TextStyle(fontWeight: FontWeight.w500, fontSize: 20),),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("A verification email has been sent to ${user.email}. Please check your inbox."),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () async {
                        await user.sendEmailVerification();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Verification email re-sent!")),
                        );
                      },
                      child: Text("Resend Email"),
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
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () async {
                        await FirebaseAuth.instance.currentUser?.reload();
                        User? updatedUser = FirebaseAuth.instance.currentUser;

                        if (updatedUser != null && updatedUser.emailVerified) {
                          timer?.cancel();
                          Navigator.pop(dialogContext);
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => NavigationPage()),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Email is not verified yet! Please check again.")),
                          );
                        }
                      },
                      child: Text("I have verified"),
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
                ),
              );
            },
          );
        },
      );
    } else {

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => NavigationPage()),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Sign Up Successfully!!")),
      );
    }
  }


}


