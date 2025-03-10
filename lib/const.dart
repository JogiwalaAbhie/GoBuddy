import 'package:flutter/material.dart';

const kButtonColor = Color(0xff1b1b1b);
const kBackgroundColor = Color(0xfff2f3f4);
const blueTextColor = Color(0xff035997);


import 'package:flutter/material.dart';
import 'second_screen.dart';

class FirstScreen extends StatefulWidget {
  @override
  _FirstScreenState createState() => _FirstScreenState();
}

class _FirstScreenState extends State<FirstScreen> {
  Map<String, List<String>> parentChildMap = {}; // Store parent-child data
  String? selectedParent;
  TextEditingController textController = TextEditingController();
  bool isAddingParent = true; // Toggle between adding parent or child

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Manage Parent-Child Data')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Parent Dropdown
            DropdownButton<String>(
              value: selectedParent,
              hint: Text("Select Parent"),
              isExpanded: true,
              items: parentChildMap.keys.map((parent) {
                return DropdownMenuItem<String>(
                  value: parent,
                  child: Text(parent),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedParent = value;
                });
              },
            ),
            SizedBox(height: 10),
            // Toggle: Add Parent or Child
            Row(
              children: [
                Text("Adding: "),
                Switch(
                  value: isAddingParent,
                  onChanged: (value) {
                    setState(() {
                      isAddingParent = value;
                    });
                  },
                ),
                Text(isAddingParent ? "Parent" : "Child"),
              ],
            ),
            SizedBox(height: 10),
            // Input Field
            TextField(
              controller: textController,
              decoration: InputDecoration(
                labelText: isAddingParent ? "Enter Parent" : "Enter Child",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            // Add Button
            ElevatedButton(
              onPressed: () {
                String inputText = textController.text.trim();
                if (inputText.isNotEmpty) {
                  setState(() {
                    if (isAddingParent) {
                      // Add as Parent
                      if (!parentChildMap.containsKey(inputText)) {
                        parentChildMap[inputText] = [];
                      }
                    } else {
                      // Add as Child (Only if Parent is selected)
                      if (selectedParent != null) {
                        parentChildMap[selectedParent]!.add(inputText);
                      }
                    }
                    textController.clear();
                  });
                }
              },
              child: Text(isAddingParent ? "Add Parent" : "Add Child"),
            ),
            SizedBox(height: 20),
            // Navigate to Second Screen
            ElevatedButton(
              onPressed: () {
                if (selectedParent != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          SecondScreen(parent: selectedParent!, childList: parentChildMap[selectedParent!] ?? []),
                    ),
                  );
                }
              },
              child: Text("Show Child Data"),
            ),
          ],
        ),
      ),
    );
  }
}
