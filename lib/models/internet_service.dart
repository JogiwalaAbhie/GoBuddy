import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

/// **Internet Connection Check Function**
Future<bool> hasInternetConnection(BuildContext context) async {
  bool isConnected = await _checkInternet();

  if (!isConnected) {
    _showNoInternetDialog(context);
  }

  return isConnected;
}

/// **Check Internet via Connectivity & Ping**
Future<bool> _checkInternet() async {
  var connectivityResult = await Connectivity().checkConnectivity();
  if (connectivityResult == ConnectivityResult.none) return false;

  try {
    final result = await InternetAddress.lookup('google.com');
    return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
  } catch (e) {
    return false;
  }
}

/// **Show No Internet Dialog**
void _showNoInternetDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false, // Prevent dismissing dialog
    builder: (context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        title: const Text("No Internet Connection"),
        content: const Text("Please check your internet connection and retry."),
        actions: [
          TextButton(
            onPressed: () async {
              bool isConnected = await _checkInternet();
              if (isConnected) {
                Navigator.pop(context); // Close dialog if internet is available
              }
            },
            child: const Text("Retry"),
          ),
          TextButton(
            onPressed: () => exit(0), // Exit app
            child: const Text("Exit"),
          ),
        ],
      );
    },
  );
}
