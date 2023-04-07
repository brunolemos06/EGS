import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';

import 'catalogo_page.dart';


class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key:key);

  @override
  State<HomePage> createState() => _HomePageState();
}



class _HomePageState extends State<HomePage> {
  String? _destination;

  final List<String> _destinations = [    'All','Lisboa',    'Porto',    'Madrid',    'Coimbra',    'Braga',    'Faro',  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home Page"),
      ),
      backgroundColor: Colors.grey.shade900,
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 25.0, vertical: 30.0,),
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Join the ride  ',
                  style: GoogleFonts.bebasNeue(
                    fontSize: 80,
                  ),
                ),
                TextSpan(
                  text: ' with RIDEMATE',
                  style: GoogleFonts.bebasNeue(
                    fontSize: 55,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
        ),

        SizedBox(height: 10),
      // search bar ponto de partida

        SizedBox(height: 15),

        // search bar destino
        Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: DropdownButtonFormField<String>(
          value: _destination,
          decoration: InputDecoration(
            labelText: 'Ponto de Chegada',
            labelStyle: TextStyle(color: Colors.white),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
          style: TextStyle(color: Colors.white),
          onChanged: (newValue) {
            setState(() {
              _destination = newValue;
            });
          },
          items: _destinations
              .map(
                (destination) => DropdownMenuItem(
                  value: destination,
                  child: Text(destination),
                ),
              )
              .toList(),
        ),
      ),


        SizedBox(height: 5),

        Padding(
          padding: EdgeInsets.only(left: 295.0),
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => catalogo_page(
                    pontodechegada: _destination,
                  ),
                ),
              );
            },
            child: Text('Search'),
          ),
        ),





        SizedBox(height: 20),

        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Icon(
            size: 120,
            color: Colors.green,
            Icons.emoji_people_sharp,
          ),
        ),
      ],
      ),


    );
  }
}
