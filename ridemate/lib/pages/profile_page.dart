import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'login_page.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key:key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  List<Review> _reviews = [];
  String _rating = "";
  String _id = "98221";
  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
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
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => LoginPage()),
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
                  child: const Image(
                    image: AssetImage("assets/images/avatar.jpg"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "john doe",
                style: Theme.of(context).textTheme.headline5,
              ),
              const SizedBox(height: 10),
              Text(
                "john.doe@example.com",
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