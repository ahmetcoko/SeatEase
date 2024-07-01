import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class CreateEvent extends StatefulWidget {
  @override
  _CreateEventState createState() => _CreateEventState();
}

class _CreateEventState extends State<CreateEvent> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _capacityController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _rowController = TextEditingController();
  final TextEditingController _columnController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Create Event"),
        centerTitle: true,  // This will center the title text within the AppBar
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name for the event';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _rowController,
                decoration: InputDecoration(labelText: 'Row'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || int.tryParse(value) == null || int.parse(value) > 10) {
                    return 'Please enter a valid number less than 10';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _columnController,
                decoration: InputDecoration(labelText: 'Column'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || int.tryParse(value) == null || int.parse(value) > 10) {
                    return 'Please enter a valid number less than 10';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              GestureDetector(
                onTap: () => _selectDate(context),
                child: AbsorbPointer(
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: _selectedDate == null ? 'Date' : DateFormat.yMd().format(_selectedDate!),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              GestureDetector(
                onTap: () => _selectTime(context),
                child: AbsorbPointer(
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: _selectedTime == null ? 'Time' : _selectedTime!.format(context),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed: _createEvent,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    textStyle: TextStyle(
                      color: Colors.pinkAccent,
                      fontSize: 16,
                    ),
                  ),
                  child: Text('Create Event'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  void _selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (pickedTime != null && pickedTime != _selectedTime) {
      setState(() {
        _selectedTime = pickedTime;
      });
    }
  }

  void _createEvent() {
    if (_formKey.currentState!.validate()) {
      if (_selectedDate != null && _selectedTime != null) {
        // Combine the date and time into one DateTime object
        DateTime eventDateTime = DateTime(
          _selectedDate!.year,
          _selectedDate!.month,
          _selectedDate!.day,
          _selectedTime!.hour,
          _selectedTime!.minute,
        );

        print('Creating event with date: $eventDateTime');

        // Save to Firestore
        FirebaseFirestore.instance.collection('Events').add({
          'name': _nameController.text,
          'row': int.parse(_rowController.text),
          'column': int.parse(_columnController.text),
          'capacity': int.parse(_rowController.text) * int.parse(_columnController.text),
          'time': Timestamp.fromDate(eventDateTime), // Make sure to convert DateTime to Timestamp
          'description': _descriptionController.text,
          'participants': [],  // Initialize an empty list for participants
        }).then((result) {
          print('Event created successfully.');
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Event created successfully')));
          // Clear the form
          _nameController.clear();
          _capacityController.clear();
          _descriptionController.clear();
          setState(() {
            _selectedDate = null;
            _selectedTime = null;
          });
        }).catchError((error) {
          print('Failed to create event: $error');
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to create event: $error')));
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please select both date and time')));
      }
    } else {
      print('Form is not valid');
    }
  }


  @override
  void dispose() {
    _nameController.dispose();
    _capacityController.dispose();
    _descriptionController.dispose();
    _rowController.dispose();
    _columnController.dispose();
    super.dispose();
  }
}
