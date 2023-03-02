import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';


class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key:key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 100),
          child: Column(
            children: [
              SizedBox(
                width: 120, height: 120,
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),child: const Image(
                    image: AssetImage("assets/images/avatar.jpg"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text("Alexa Lirys",style:Theme.of(context).textTheme.headline5),
              const SizedBox(height: 10),
              Text("alexys@ua.pt",style:Theme.of(context).textTheme.bodyText1),
              const SizedBox(height: 20),
              SizedBox(
                width: 200,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green, side: BorderSide.none, shape: const StadiumBorder()),
                  child: const Text("Edit Profile" ,  style: TextStyle(color: Colors.white)),
                ),
              ),
              const Divider(),

            ],
          ),
        )
      )
    );
  }
}