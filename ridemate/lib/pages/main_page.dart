import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_nav_bar/google_nav_bar.dart';


import 'package:ridemate/pages/messages_page.dart';
import 'package:ridemate/pages/add_page.dart';
import 'package:ridemate/pages/home_page.dart';
import 'package:ridemate/pages/profile_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key:key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentindex = 0;
  List pages = [ HomePage(),AddPage() ,ProfilePage() ,MessagePage() ];


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: pages[_currentindex],
      bottomNavigationBar: Container(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0,vertical: 7),
          child:       GNav(
            backgroundColor: Colors.transparent,
            color: Colors.white,
            activeColor: Colors.green,
            tabBackgroundColor: Colors.grey.shade800,
            gap: 3,
            onTabChange: (index) {
              setState(() {
                _currentindex = index;
              });
            },
            padding: EdgeInsets.all(16),
            tabs: const [
              GButton(
                icon: Icons.search,
                text: "Search",
              ),
              GButton(
                icon: Icons.add,
                text: "add",
              ),
              GButton(
                icon: Icons.person_outline_outlined,
                text: "Profile",
              ),
              GButton(
                icon: Icons.messenger_outline_sharp,
                text: "SMS",
              ),
            ],
          ),
        ),
      ),
    );
  }
}