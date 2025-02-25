import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EditTripScreen extends StatefulWidget {
  @override
  _EditTripScreenState createState() => _EditTripScreenState();
}

class _EditTripScreenState extends State<EditTripScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _tripTitle, _destination, _selectedCategory, _description, _meetingPoint, _accommodation, _includedServices, _contactInfo;
  DateTime? _startDate, _endDate;
  TimeOfDay? _startTime, _endTime;
  double? _tripFee;
  int? _maxParticipants;
  String? selectedTransport;

  List<String> _destinations = [
    // 🌊 Beach Destinations
    "Goa, India",
    "Pondicherry, India",
    "Marina Beach, Tamil Nadu",
    "Dhanushkodi, Tamil Nadu",
    "Kanyakumari, Tamil Nadu",
    "Gokarna, Karnataka",
    "Kovalam, Kerala",
    "Varkala, Kerala",
    "Havelock Island, Andaman",
    "Neil Island, Andaman",

    // 🏔️ Hill Stations
    "Manali, Himachal Pradesh",
    "Shimla, Himachal Pradesh",
    "Kasol, Himachal Pradesh",
    "Dharamshala, Himachal Pradesh",
    "Dalhousie, Himachal Pradesh",
    "Munnar, Kerala",
    "Ooty, Tamil Nadu",
    "Kodaikanal, Tamil Nadu",
    "Coorg, Karnataka",
    "Lonavala, Maharashtra",
    "Mahabaleshwar, Maharashtra",
    "Saputara, Gujarat",
    "Mount Abu, Rajasthan",
    "Chopta, Uttarakhand",
    "Nainital, Uttarakhand",
    "Mussoorie, Uttarakhand",
    "Shillong, Meghalaya",
    "Gangtok, Sikkim",
    "Tawang, Arunachal Pradesh",

    // 🏜️ Desert & Cultural Trips
    "Jaisalmer, Rajasthan",
    "Jaipur, Rajasthan",
    "Udaipur, Rajasthan",
    "Bikaner, Rajasthan",
    "Rann of Kutch, Gujarat",
    "Pushkar, Rajasthan",
    "Jodhpur, Rajasthan",

    // 🏞️ Nature & Wildlife
    "Jim Corbett National Park, Uttarakhand",
    "Kaziranga National Park, Assam",
    "Sundarbans, West Bengal",
    "Gir National Park, Gujarat",
    "Bandipur National Park, Karnataka",
    "Ranthambore National Park, Rajasthan",
    "Periyar Wildlife Sanctuary, Kerala",

    // 🚣 Adventure & Trekking
    "Rishikesh, Uttarakhand",
    "Triund Trek, Himachal Pradesh",
    "Leh, Ladakh",
    "Spiti Valley, Himachal Pradesh",
    "Chandrashila Trek, Uttarakhand",
    "Roopkund Trek, Uttarakhand",
    "Zanskar Valley, Ladakh",
    "Sandakphu, West Bengal",
    "Valley of Flowers, Uttarakhand",

    // 🏛️ Heritage & Spiritual Destinations
    "Varanasi, Uttar Pradesh",
    "Rameswaram, Tamil Nadu",
    "Bodh Gaya, Bihar",
    "Ajanta & Ellora Caves, Maharashtra",
    "Konark Sun Temple, Odisha",
    "Amritsar, Punjab",
    "Golden Temple, Punjab",
    "Dwarka, Gujarat",
    "Somnath, Gujarat",
    "Madurai, Tamil Nadu",
    "Tirupati, Andhra Pradesh",
    "Shirdi, Maharashtra",
    "Vaishno Devi, Jammu & Kashmir",

    // 🌆 Metro City Trips
    "Mumbai, Maharashtra",
    "Bangalore, Karnataka",
    "Delhi, India",
    "Chennai, Tamil Nadu",
    "Hyderabad, Telangana",
    "Kolkata, West Bengal",
    "Ahmedabad, Gujarat",
    "Pune, Maharashtra",

    // 🎭 Unique & Hidden Gems
    "Cherrapunji, Meghalaya",
    "Ziro Valley, Arunachal Pradesh",
    "Majuli Island, Assam",
    "Mawlynnong, Meghalaya",
    "Loktak Lake, Manipur",
    "Lepchajagat, West Bengal",
    "Hampi, Karnataka",
    "Gandikota, Andhra Pradesh",
    "Bhedaghat, Madhya Pradesh",
    "Pachmarhi, Madhya Pradesh",
    "Tawang, Arunachal Pradesh",
  ];
  List<String> tripCategories = [
    "Adventure Trips",
    "Beach Vacations",
    "Cultural & Historical Tours",
    "Road Trips",
    "Volunteer & Humanitarian Trips",
    "Wellness Trips"];
  List<String> transportOptions = ["Car", "Bus", "Train", "Flight", "Bike"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Trip"),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField("Trip Title", "Enter the trip title", (value) => _tripTitle = value, true),
              _buildDestinationField(),
              _buildDropdownField("Trip Category", tripCategories, _selectedCategory, (value) => setState(() => _selectedCategory = value)),
              _buildDateField("Start Date", _startDate, (date) => setState(() => _startDate = date)),
              _buildDateField("End Date", _endDate, (date) => setState(() => _endDate = date)),
              _buildTimeField("Start Time", _startTime, (time) => setState(() => _startTime = time)),
              _buildTimeField("End Time", _endTime, (time) => setState(() => _endTime = time)),
              _buildTextField("Description", "Enter trip description", (value) => _description = value, true, maxLines: 3),
              _buildTextField("Meeting Point", "Enter the meeting point", (value) => _meetingPoint = value, true),
              _buildDropdownField("Transportation", transportOptions, selectedTransport, (value) => setState(() => selectedTransport = value!)),
              _buildTextField("Accommodation", "Enter accommodation details", (value) => _accommodation = value, true),
              _buildNumericField("Maximum Participants", (value) => _maxParticipants = int.tryParse(value)),
              _buildNumericField("Trip Fee (per person)", (value) => _tripFee = double.tryParse(value)),
              _buildTextField("Included Services", "Enter included services", (value) => _includedServices = value, true),
              _buildTextField("Contact Information", "Enter contact info", (value) => _contactInfo = value, true),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    // Handle update logic here
                  }
                },
                child: Text("Save Changes"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String hint, Function(String) onSaved, bool isRequired, {int maxLines = 1}) {
    return TextFormField(
      decoration: InputDecoration(labelText: label, hintText: hint, border: OutlineInputBorder()),
      maxLines: maxLines,
      validator: (value) => isRequired && (value == null || value.isEmpty) ? 'Please enter $label' : null,
      onSaved: (value) => onSaved(value ?? ''),
    );
  }

  Widget _buildNumericField(String label, Function(String) onSaved) {
    return TextFormField(
      decoration: InputDecoration(labelText: label, border: OutlineInputBorder()),
      keyboardType: TextInputType.number,
      validator: (value) => (value == null || value.isEmpty || !RegExp(r'^[0-9]+$').hasMatch(value)) ? 'Enter valid $label' : null,
      onSaved: (value) => onSaved(value ?? ''),
    );
  }

  Widget _buildDropdownField(String label, List<String> options, String? selectedValue, Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(labelText: label, border: OutlineInputBorder()),
      value: selectedValue,
      items: options.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: onChanged,
      validator: (value) => (value == null || value.isEmpty) ? 'Please select $label' : null,
    );
  }

  Widget _buildDateField(String label, DateTime? date, Function(DateTime) onDateSelected) {
    return ListTile(
      title: Text(label),
      subtitle: Text(date != null ? DateFormat('yyyy-MM-dd').format(date) : "Select Date"),
      trailing: Icon(Icons.calendar_today),
      onTap: () async {
        DateTime? picked = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2101),
        );
        if (picked != null) onDateSelected(picked);
      },
    );
  }

  Widget _buildTimeField(String label, TimeOfDay? time, Function(TimeOfDay) onTimeSelected) {
    return ListTile(
      title: Text(label),
      subtitle: Text(time != null ? time.format(context) : "Select Time"),
      trailing: Icon(Icons.access_time),
      onTap: () async {
        TimeOfDay? picked = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
        );
        if (picked != null) onTimeSelected(picked);
      },
    );
  }

  Widget _buildDestinationField() {
    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) return const Iterable<String>.empty();
        return _destinations.where((destination) => destination.toLowerCase().contains(textEditingValue.text.toLowerCase()));
      },
      onSelected: (String selection) {
        setState(() {
          _destination = selection;
        });
      },
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        return TextFormField(
          controller: controller,
          focusNode: focusNode,
          decoration: InputDecoration(labelText: "Destination", border: OutlineInputBorder()),
          validator: (value) => (value == null || value.isEmpty) ? 'Please enter Destination' : null,
        );
      },
    );
  }
}
