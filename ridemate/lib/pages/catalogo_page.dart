import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';


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

class catalogo_page extends StatefulWidget {
  const catalogo_page({Key? key}) : super(key: key);

  @override
  _catalogoPageState createState() => _catalogoPageState();
}

class _catalogoPageState extends State<catalogo_page> {

  final List<Travel> travels = [
    Travel(
      name: 'Aveiro - Porto',
      image: 'assets/beach_vacation.jpg',
      time: '1 hora',
      money: '7',
      pay: 'Pay Now',
    ),
    Travel(
      name: 'Porto - Lisboa',
      image: 'assets/mountain_retreat.jpg',
      time: '3 hora',
      money: '80',
      pay: 'Pay Now',
    ),
    Travel(
      name: 'Coimbra - Albufeira',
      image: 'assets/city_adventure.jpg',
      time: '7 hora',
      money: '36',
      pay: 'Pay Now',
    ),
    Travel(
      name: 'Lisboa - Faro',
      image: 'assets/beach_vacation.jpg',
      time: '4 hora',
      money: '20',
      pay: 'Pay Now',
    ),
    Travel(
      name: 'Porto - Faro',
      image: 'assets/mountain_retreat.jpg',
      time: '5 horas',
      money: '25',
      pay: 'Pay Now',
    ),
    Travel(
      name: 'Lisboa - Coimbra',
      image: 'assets/city_adventure.jpg',
      time: '2 horas',
      money: '10',
      pay: 'Pay Now',
    )
  ];
  final flutterWebviewPlugin = FlutterWebviewPlugin();
  
  String order_id = '';

@override
void initState() {
  super.initState();
  flutterWebviewPlugin.onUrlChanged.listen((url) {
    if (url.contains('http://10.0.2.2:8000/paypal/finish')) {
      flutterWebviewPlugin.close();
      final token_url = Uri.parse('http://10.0.2.2:8000/paypal/capture/order');
      final token_headers = {'Content-Type': 'application/json'};
      final token_payload = {'id': order_id};
      http.post(token_url, headers: token_headers, body: json.encode(token_payload)).then((token_response) {
        final token_jsonResponse = jsonDecode(token_response.body);
        final token = token_jsonResponse['status'];
        if (token == "success") {
          // Handle the success response
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(
                  "Payment successful!",
                  style: TextStyle(
                    color: Colors.green,
                  ),
                ),
                actions: <Widget>[
                  // other buttons here , dont flatbutton
                  ElevatedButton(
                    child: Text('OK'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        } else {
          // Handle the failure response
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(
                  "Payment failed",
                  style: TextStyle(
                    color: Colors.red,
                  ),
                ),
                actions: <Widget>[
                  ElevatedButton(
                    child: Text('OK'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        }
      });
    }
  });
}


  @override
  void dispose() {
    super.dispose();
    flutterWebviewPlugin.dispose();
  }

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
                // Image.asset(travels[index].image),
                ListTile(
                  title: Text(travels[index].name),
                  subtitle: Text(travels[index].time),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(travels[index].money + "€"),
                      ElevatedButton(
                        onPressed: () async {
                          final url = Uri.parse('http://10.0.2.2:8000/paypal/create/order');
                          final headers = {'Content-Type': 'application/json'};
                          final payload = {'amount': travels[index].money};
                          final response = await http.post(url, headers: headers, body: json.encode(payload));
                          final errorMessage = 'Status: ${response.statusCode.toString()}';
                          debugPrint(errorMessage, wrapWidth: 1024);
                          if (response.statusCode == 201) {
                            final jsonResponse = jsonDecode(response.body);
                            final linkForPayment = jsonResponse['linkForPayment'];
                            // save the order_id in class variable
                            order_id = jsonResponse['order_id'];
                            
                            // lauch the linkForPayment in a webview until the url contains the string 'http://10.0.2.2:8000/paypal/finish'
                            flutterWebviewPlugin.launch(linkForPayment);
                            
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

