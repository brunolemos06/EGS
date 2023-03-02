import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';


class AddPage extends StatefulWidget {
  const AddPage({Key? key}) : super(key:key);

  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  final _pontodepartida = TextEditingController();
  final _destination = TextEditingController();
  final _brandcar = TextEditingController();
  final _npassager = TextEditingController();

  bool _arcondicionado = false;
  bool _wifi = false;
  bool _animais = false;
  bool _eat = false;

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0,vertical: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              'Add a new travel',
              style: GoogleFonts.bebasNeue(
                fontSize: 40,
                color: Colors.green,
              ),
            ),
            SizedBox(
                height: 30
            ),
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
            TextFormField(
              decoration: const InputDecoration(
                hintText: 'Car brand',
              ),
              controller: _brandcar,
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter valid brand';
                }
                return null;
              },
            ),
            TextFormField(
              decoration: const InputDecoration(
                hintText: 'Number of passagers',
              ),
              controller: _npassager,
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter valid number';
                }
                return null;
              },
            ),
            CheckboxListTile(
              title: const Text('Ar condicionado'),
              secondary: const Icon(Icons.air),
              autofocus: false,
              activeColor: Colors.green,
              checkColor: Colors.white,
              selected: _arcondicionado,
              value: _arcondicionado,
              onChanged: (arcondicionado) {
                setState(() {
                  _arcondicionado = arcondicionado!;
                });
              },
            ),
            CheckboxListTile(
              title: const Text('Free Wifi'),
              secondary: const Icon(Icons.wifi),
              autofocus: false,
              activeColor: Colors.green,
              checkColor: Colors.white,
              selected: _wifi,
              value: _wifi,
              onChanged: (wifi) {
                setState(() {
                  _wifi = wifi!;
                });
              },
            ),
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

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    debugPrint('Validated!');
                  }
                },
                child: const Text('Submit'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}