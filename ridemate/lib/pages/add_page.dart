import 'dart:convert';

import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class AddPage extends StatefulWidget {
  const AddPage({Key? key}) : super(key: key);

  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  final _id = TextEditingController();
  final _pontodepartida = TextEditingController();
  final _destination = TextEditingController();
  final _brandcar = TextEditingController();
  final _npassager = TextEditingController();
  late var _startdate = TextEditingController();
  final _aditionalinfo = TextEditingController();
  int _selectedPassengerCount = 1;
  List<int> get passengerCountOptions => [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];

  bool _arcondicionado = false;
  bool _wifi = false;
  bool _animais = false;
  bool _eat = false;

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add a new travel'),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: 10),
              Text(
                'Add a new travel',
                style: GoogleFonts.bebasNeue(
                  fontSize: 40,
                  color: Colors.green,
                ),
              ),
              SizedBox(height: 30),
              TextFormField(
                decoration: const InputDecoration(
                  hintText: 'Starting point',
                ),
                controller: _pontodepartida,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter valid name';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(
                  hintText: 'Destination',
                ),
                controller: _destination,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter valid name';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<int>(
                value: _selectedPassengerCount,
                items: passengerCountOptions
                    .map<DropdownMenuItem<int>>((int value) {
                  return DropdownMenuItem<int>(
                    value: value,
                    child: Text(value.toString()),
                  );
                }).toList(),
                onChanged: (int? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedPassengerCount = newValue;
                    });
                  }
                },
              ),
              // startimg date
              // dateinput

              TextFormField(
                decoration: const InputDecoration(
                  hintText: 'Starting Date',
                ),
                controller: _startdate,
                // can be empty
              ),
              TextFormField(
                decoration: const InputDecoration(
                  hintText: 'Aditional information',
                ),
                controller: _brandcar,
                // can be empty
              ),
              SizedBox(height: 30),
              CheckboxListTile(
                title: const Text('Allow animals'),
                secondary: const Icon(Icons.adb),
                autofocus: false,
                activeColor: Colors.green,
                checkColor: Colors.white,
                selected: _animais,
                value: _animais,
                onChanged: (animais) {
                  setState(() {
                    _animais = animais!;
                  });
                },
              ),
              CheckboxListTile(
                title: const Text('Allow to eat'),
                secondary: const Icon(Icons.fastfood_sharp),
                autofocus: false,
                activeColor: Colors.green,
                checkColor: Colors.white,
                selected: _eat,
                value: _eat,
                onChanged: (eat) {
                  setState(() {
                    _eat = eat!;
                  });
                },
              ),
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      debugPrint('Validated!');
                      debugPrint(_startdate.text);
                      final String url =
                          'http://10.0.2.2:5015/directions/trip/';
                      final response = await http.post(
                        Uri.parse(url),
                        headers: {
                          'Content-Type': 'application/json',
                        },
                        body: jsonEncode({
                          "id": _id.text,
                          "origin": _pontodepartida.text,
                          "destination": _destination.text,
                          "available_sits": _selectedPassengerCount,
                          "starting_date": _startdate.text,
                          "owner_id": '5b77bdbade7b4fcb838f8111b68e18ae'
                        }),
                      );

                      if (response.statusCode == 201) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "Trip created successfully",
                              style: TextStyle(color: Colors.white),
                            ),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "Trip creation failed!",
                              style: TextStyle(color: Colors.white),
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  child: const Text('Submit'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
