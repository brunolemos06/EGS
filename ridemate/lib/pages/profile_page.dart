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
  Future fetchData() async {
    final response = await http.get(Uri.parse('https://localhost'));
    if (response.statusCode == 200) {
      // If the call to the server was successful, parse the JSON
      final data = json.decode(response.body);
      return data;
    } else {
      // If that call was not successful, throw an error.
      throw Exception('Failed to load data');
    }
  }
  List<Review> _reviews = [
    Review(rating: 4.5, name: 'John Doe', title: 'Amazing Experience', description: 'I had an amazing time traveling with this company. The staff was friendly and professional.'),
    Review(rating: 3.0, name: 'Jane Smith', title: 'Average Trip', description: 'The trip was average. It was not as exciting as I expected it to be.'),
    Review(rating: 5.0, name: 'Alex Johnson', title: 'Best Vacation Ever', description: 'I had the best vacation ever with this company. The itinerary was well-planned and the staff was fantastic.'),
    Review(rating: 1.0, name: 'Alex Johnson1', title: 'Best Vacation Ever1', description: 'I had the best vacation ever with this company. The itinerary was well-planned and the staff was fantastic.'),
    Review(rating: 2.0, name: 'Alex Johnson2', title: 'Best Vacation Ever2', description: 'I had the best vacation ever with this company. The itinerary was well-planned and the staff was fantastic.'),
    Review(rating: 3.0, name: 'Alex Johnson3', title: 'Best Vacation Ever3', description: 'I had the best vacation ever with this company. The itinerary was well-planned and the staff was fantastic.'),
  ];
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
                "John Doe",
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
                'Avg rating : 3.5',
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
  final double rating;
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