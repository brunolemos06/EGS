import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';


class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key:key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

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
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Select your starting point',
              prefixIcon: Icon(Icons.gps_not_fixed),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.green),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
              ),
            ),
          ),
        ),

        SizedBox(height: 15),

        // search bar destino
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Select your destination',
              prefixIcon: Icon(Icons.where_to_vote_rounded),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.green),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
              ),
            ),
          ),
        ),

        SizedBox(height: 5),

        Padding(
          padding: EdgeInsets.only(left: 295.0),
          child: ElevatedButton(
            onPressed: () {
              // add button action here
            },
            child: Icon(
                Icons.search,
                color: Colors.white,
            )
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
