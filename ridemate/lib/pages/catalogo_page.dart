import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart' show getBoundsZoomLevel;
import 'login_page.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Travel {
  final String partida_name;
  final String chegada_name;
  final String time;
  final String money;
  final String pay;
  final LatLng partida;
  final LatLng chegada;

  Travel({
    required this.partida_name,
    required this.chegada_name,
    required this.time,
    required this.money,
    required this.pay,
    required this.partida,
    required this.chegada,
  });
}

class catalogo_page extends StatefulWidget {
  final String? pontodechegada;

  const catalogo_page({Key? key, this.pontodechegada}) : super(key: key);

  @override
  _catalogoPageState createState() => _catalogoPageState();
}

class _catalogoPageState extends State<catalogo_page> {

  final _storage = FlutterSecureStorage();
  final List<Travel> travels = [
    Travel(
      partida_name: 'Aveiro',
      chegada_name: 'Porto',
      time: '1 hora',
      money: '7',
      pay: 'Pay Now',
      partida: LatLng(40.644270, -8.645540), // aveiro
      chegada: LatLng(41.157944, -8.629105), // porto
    ),
    Travel(
      partida_name: 'Guarda',
      chegada_name: 'Braga',
      time: '2 horas',
      money: '10',
      pay: 'Pay Now',
      partida: LatLng(40.537500, -7.263611), // guarda
      chegada: LatLng(41.557800, -8.420500), // braga
    ),
    Travel(
      partida_name: 'Lisboa',
      chegada_name: 'Madrid',
      time: '5 horas',
      money: '30',
      pay: 'Pay Now',
      partida: LatLng(38.722252, -9.139337), // lisboa
      chegada: LatLng(40.416775, -3.703790), // madrid
    ),
    Travel(
      partida_name: 'Porto',
      chegada_name: 'Lisboa',
      time: '3 horas',
      money: '80',
      pay: 'Pay Now',
      // porto lisboa cordenadas
      partida : LatLng(41.157944, -8.629105), // porto
      chegada : LatLng(38.722252, -9.139337), // lisboa
    ),
    Travel(
      partida_name: 'Lisboa',
      chegada_name: 'Porto',
      time: '7 horas',
      money: '36',
      pay: 'Pay Now',
      partida: LatLng(40.644270, -8.645540), // coimbra
      chegada: LatLng(37.089072, -8.247880), // albufeira
    ),
    Travel(
      partida_name: 'Lisboa',
      chegada_name: 'Faro',
      time: '4 horas',
      money: '20',
      pay: 'Pay Now',
      partida: LatLng(38.722252, -9.139337), // lisboa
      chegada: LatLng(37.089072, -8.247880), // faro
    ),
    Travel(
      partida_name: 'Porto',
      chegada_name: 'Faro',
      time: '5 horas',
      money: '25',
      pay: 'Pay Now',
      partida: LatLng(41.157944, -8.629105), // porto
      chegada: LatLng(37.089072, -8.247880), // faro
    ),
    Travel(
      partida_name: 'Lisboa',
      chegada_name: 'Coimbra',
      time: '2 horas',
      money: '10',
      pay: 'Pay Now',
      partida: LatLng(38.722252, -9.139337), // lisboa
      chegada: LatLng(40.644270, -8.645540), // coimbra
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
        //  just display the list of travels that have chegada_name == pontodecheegada
        itemCount: travels.length,
        itemBuilder: (context, index) {
          if(travels[index].chegada_name == widget.pontodechegada || widget.pontodechegada == 'All' || widget.pontodechegada == null){
            return Card(
              child: Column(
                children: [
                  SizedBox(height: 24.0), // Add a SizedBox to create space
                  Container(
                    height: 180,
                    width: 400,
                    // map with partida and chegada
                    child: FlutterMap(
                      options: MapOptions(
                          //  center of Portugal
                          center: LatLng(39.5572, -8.0317),
                        zoom: 5.2,
                      ),
                      layers: [
                        TileLayerOptions(
                          urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                          subdomains: ['a', 'b', 'c'],
                        ),
                        MarkerLayerOptions(
                          markers: [
                            Marker(
                              width: 80.0,
                              height: 80.0,
                              point: travels[index].partida,
                              builder: (ctx) => Container(
                                child: Icon(
                                  Icons.location_on,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                            Marker(
                              width: 80.0,
                              height: 80.0,
                              point: travels[index].chegada,
                              builder: (ctx) => Container(
                                child: Icon(
                                  Icons.location_on,
                                  color: Colors.green,
                                ),
                              ),
                            ),
                          ],
                        ),
                        PolylineLayerOptions(
                          polylines: [
                            Polyline(
                              points: [travels[index].partida, travels[index].chegada],
                              strokeWidth: 4.0,
                              color: Colors.cyan,
                            ),
                          ],
                        ),
                      ],
                    ),

                  ),
                  ListTile(
                    title: Text(travels[index].partida_name + " - " + travels[index].chegada_name),
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


                            // you need to be logged in to make a payment
                            // if you are not logged in, you will be redirected to the login page
                            // if you are logged in, you will be redirected to the payment page
                            // get token from local storage
                            final String tokenKey = 'token';
                            final String? token = await _storage.read(key: tokenKey);
                            if (token == null) {
                              debugPrint('Token not found', wrapWidth: 1024);
                              // go to login page
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => LoginPage()),
                              );
                              return ;
                            }
                            final String url2 = 'http://10.0.2.2:5000/auth';
                            final Map<String, String> headers2 = {
                              'Content-Type': 'application/json',
                              'Accept': 'application/json',
                              'x-access-token': token 
                            };
                            final response3 = await http.post(Uri.parse(url2), headers: headers2);
                            if (response3.statusCode != 200) {
                                debugPrint('Token not valid', wrapWidth: 1024);
                                // go to login page
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => LoginPage()),
                                );
                                // message to user that to pay you need to be logged in
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      "To pay you need to be logged in !!",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              return ;
                            }

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
          }else{
            return Container();
          }
        },
      ),
    );
  }
}

