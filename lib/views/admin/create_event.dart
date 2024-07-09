import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:seat_ease/l10n/app_localizations.dart';

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
        title: Text(AppLocalizations.of(context)!.createEvent),
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
                decoration: InputDecoration(labelText: AppLocalizations.of(context)!.eventName),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppLocalizations.of(context)!.eventNameCheck;
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _rowController,
                decoration: InputDecoration(labelText: AppLocalizations.of(context)!.rowNumber),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || int.tryParse(value) == null || int.parse(value) > 10) {
                    return AppLocalizations.of(context)!.rowNumberCheck;
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _columnController,
                decoration: InputDecoration(labelText: AppLocalizations.of(context)!.columnNumber),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || int.tryParse(value) == null || int.parse(value) > 10) {
                    return AppLocalizations.of(context)!.columnNumberCheck;
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
                      labelText: _selectedDate == null ? AppLocalizations.of(context)!.eventDate : DateFormat.yMd().format(_selectedDate!),
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
                      labelText: _selectedTime == null ? AppLocalizations.of(context)!.eventTime : _selectedTime!.format(context),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: AppLocalizations.of(context)!.eventDescription),
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
                  child: Text(AppLocalizations.of(context)!.createEvent),
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
        DateTime eventDateTime = DateTime(
          _selectedDate!.year,
          _selectedDate!.month,
          _selectedDate!.day,
          _selectedTime!.hour,
          _selectedTime!.minute,
        );

        // Example participants added during event creation for demonstration
        List<Map<String, dynamic>> participants = [];

        FirebaseFirestore.instance.collection('Events').add({
          'name': _nameController.text,
          'row': int.parse(_rowController.text),
          'column': int.parse(_columnController.text),
          'capacity': int.parse(_rowController.text) * int.parse(_columnController.text),
          'time': Timestamp.fromDate(eventDateTime),
          'description': _descriptionController.text,
          'participants': participants,
        }).then((result) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Event created successfully')));
          _clearForm();
        }).catchError((error) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to create event')));
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please select both date and time')));
      }
    }
  }

  void _clearForm() {
    _nameController.clear();
    _rowController.clear();
    _columnController.clear();
    _capacityController.clear();
    _descriptionController.clear();
    setState(() {
      _selectedDate = null;
      _selectedTime = null;
    });
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