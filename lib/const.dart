import 'dart:io';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

const kButtonColor = Color(0xff1b1b1b);
const kBackgroundColor = Color(0xfff2f3f4);
const blueTextColor = Color(0xff035997);


Future<File> generateInvoice(String userName, List<Map<String, dynamic>> tripList) async {
  final pdf = pw.Document();

  pdf.addPage(
    pw.Page(
      build: (pw.Context context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text("Trip Booking Invoice", style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 10),
          pw.Text("Customer: $userName", style: pw.TextStyle(fontSize: 18)),
          pw.SizedBox(height: 10),
          pw.Table.fromTextArray(
            context: context,
            data: [
              ["Trip Title", "Destination", "Trip Fee", "Persons", "Total Price"],
              ...tripList.map((trip) => [
                trip["title"] ?? "N/A",
                trip["destination"] ?? "N/A",
                "\$${trip["tripFee"] ?? "0"}",
                trip["person"]?.toString() ?? "1",
                "\$${trip["totalPrice"] ?? "0"}"
              ])
            ],
          ),
          pw.SizedBox(height: 20),
          pw.Text("Thank you for booking with us!", style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
        ],
      ),
    ),
  );

  // 🔹 Save PDF file
  final output = await getTemporaryDirectory();
  final file = File("${output.path}/invoice.pdf");
  await file.writeAsBytes(await pdf.save());

  return file;
}
