import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class Travel {
  final String name;
  final String image;
  final String time;
  final String money;
  final String pay;

  Travel({
    required this.name,
    required this.image,
    required this.time,
    required this.money,
    required this.pay,
  });
}

class catalogo_page extends StatelessWidget {
  final List<Travel> travels = [
    Travel(
      name: 'Aveiro - Porto',
      image: 'assets/beach_vacation.jpg',
      time: '1 horas',
      money: '7€',
      pay: 'Pay Now',
    ),
    Travel(
      name: 'Porto - Lisboa',
      image: 'assets/mountain_retreat.jpg',
      time: '3 horas',
      money: '80€',
      pay: 'Pay Now',
    ),
    Travel(
      name: 'Coimbra - Albufeira',
      image: 'assets/city_adventure.jpg',
      time: '7 horas',
      money: '36€',
      pay: 'Pay Now',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Results'),
      ),
      body: ListView.builder(
        itemCount: travels.length,
        itemBuilder: (context, index) {
          return Card(
            child: Column(
              children: [
                SizedBox(height: 24.0), // Add a SizedBox to create space
                Image.asset(travels[index].image),
                ListTile(
                  title: Text(travels[index].name),
                  subtitle: Text(travels[index].time),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(travels[index].money),
                      ElevatedButton(
                        onPressed: () async {
                          final url = Uri.parse('http://10.0.2.2:8000/paypal/create/order');
                          final headers = {'Content-Type': 'application/x-www-form-urlencoded'};
                          final payload = {'amount': '10'};
                          final response = await http.post(url, headers: headers, body: Uri(queryParameters: payload).query);
                          final errorMessage = 'Status: ${response.statusCode.toString()}';
                          debugPrint(errorMessage, wrapWidth: 1024);
                          if (response.statusCode == 201) {
                            final jsonResponse = jsonDecode(response.body);
                            final linkForPayment = jsonResponse['linkForPayment'];
                            await launch(linkForPayment); // Launch a web browser
                          } else {
                            // Handle the failure response
                          }
                        },
                        child: Text(travels[index].pay),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
