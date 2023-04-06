import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'login_page.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ridemate/pages/main_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key:key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final storage = FlutterSecureStorage();
  List<Review> _reviews = [];
  String _rating = "";
  String _id = "98221";
  String _fname = "";
  String _lname = "";
  String _email = "";
  String _avatar = "";
  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {


    // token
    final String tokenKey = 'token';
    final String? token = await storage.read(key: tokenKey);



    if (token != null) {
      // Perform API request with token here
        
      final String url = 'http://10.0.2.2:5000/info';
      final String url2 = 'http://10.0.2.2:5000/auth';
      final Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'x-access-token': token 
      };
      final response3 = await http.post(Uri.parse(url2), headers: headers);
      if (response3.statusCode != 200) {
          debugPrint('Token not valid', wrapWidth: 1024);
          // go to login page
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => LoginPage()),
          );
        return ;
      }
      final response = await http.post(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        final responseJson = json.decode(response.body);
        debugPrint('Response: ${response.body}', wrapWidth: 1024);
        final String name = responseJson['fname'];
        final String lname = responseJson['lname'];
        final String email = responseJson['email'];

        



        setState(() {
          _fname = name;
          _lname = lname;
          _email = email;
          try{
            final int size = responseJson['avatar'].length;
            _avatar = responseJson['avatar'];
          }
          catch(e){
            // do nothing
            debugPrint('Error: ${e}', wrapWidth: 1024);
            _avatar = "http://www.gravatar.com/avatar/?d=mp";
          }

          debugPrint("Name -> $_fname", wrapWidth: 1024);
          debugPrint("LName -> $_lname", wrapWidth: 1024);
          debugPrint("Email -> $_email", wrapWidth: 1024);
          debugPrint("Avatar -> $_avatar", wrapWidth: 1024);
          
        });        
      } else {
        debugPrint('Error: ${response.statusCode}', wrapWidth: 1024);
      }

      debugPrint('Token: $token', wrapWidth: 1024);
    } else {
      debugPrint('Token not found', wrapWidth: 1024);
      // go to login page
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    }

    final response = await http.get(Uri.parse('http://10.0.2.2:5005/api/v1/reviews/rating?personid=$_id'));
    final response2 = await http.get(Uri.parse('http://10.0.2.2:5005/api/v1/reviews/?personid=$_id'));

    final data = json.decode(response.body);
    final data2 = json.decode(response2.body);

    setState(() {
      _rating = data['reviews'][0]['rating'].toString();
      for (var review in data2["reviews"]) {
        var rating = review["rating"];
        var name = review["personid"].toString(); // Replace with the name of the person who wrote the review
        var title = review["title"];
        var description = review["description"];

        _reviews.add(Review(rating: rating, name: name, title: title, description: description));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(
      title: Text('Profile'),
      actions: [
        IconButton(
          icon: Icon(Icons.login),
        onPressed: () async {
          final storage = FlutterSecureStorage();
          await storage.delete(key: 'token');
          
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => MainPage()),
            (route) => false,
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "Logged OUT successfully!!",
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.red,
            ),
          );
        },
        ),
      ],
    ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 120, height: 120,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: Image(
                    image: NetworkImage(_avatar),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                _fname + " " + _lname,
                style: Theme.of(context).textTheme.headline5,
              ),
              const SizedBox(height: 10),
              Text(
                _email,
                style: Theme.of(context).textTheme.bodyText1,
              ),
              const SizedBox(height: 20),
              Text(
                'Number of Travels: 2',

                style: Theme.of(context).textTheme.headline6,
              ),

              Text(
                'Avg rating : $_rating',
                style: Theme.of(context).textTheme.headline6,
              ),
              const SizedBox(height: 15),
              ListView.builder(
                  shrinkWrap: true,
                  itemCount: _reviews.length,
                  physics: BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.star,
                                color: Colors.yellow,
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Text(
                                _reviews[index].rating.toString(),
                                style: Theme.of(context).textTheme.bodyText1,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text(
                                _reviews[index].name,
                                style: Theme.of(context).textTheme.subtitle1,
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Text(
                            _reviews[index].title,
                            style: Theme.of(context).textTheme.headline6,
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Text(
                            _reviews[index].description,
                            style: Theme.of(context).textTheme.bodyText1,
                          ),
                        ],
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class Review {
  final int rating;
  final String name;
  final String title;
  final String description;

  Review({
    required this.rating,
    required this.name,
    required this.title,
    required this.description,
  });
}