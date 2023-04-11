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
  final String id;
  final String origin;
  final String destination;
  final int available_sits;
  final String starting_date;
  final String owner_id;
  final int money;
  final LatLng origin_coords;
  final LatLng destination_coords;

  Travel(
      {required this.id,
      required this.origin,
      required this.destination,
      required this.available_sits,
      required this.starting_date,
      required this.owner_id,
      required this.money,
      required this.origin_coords,
      required this.destination_coords});
}

class catalogo_page extends StatefulWidget {
  final String? pontodechegada;
  // _pickedLocation

  const catalogo_page({Key? key, this.pontodechegada}) : super(key: key);

  @override
  _catalogoPageState createState() => _catalogoPageState();
}

class _catalogoPageState extends State<catalogo_page> {
  final _storage = FlutterSecureStorage();
  final List<Travel> travels = [];
  LatLng _pickedLocation = LatLng(39.5572, -8.0317);
  String _pickedLocationString = '39.5572, -8.0317';
  final flutterWebviewPlugin = FlutterWebviewPlugin();

  String order_id = '';

  Future<void> fetchData() async {
    final String url = 'http://10.0.2.2:8080/trip/';
    final response = await http.get(Uri.parse(url));
    final data = json.decode(response.body);

    setState(() {
      for (var trip in data['msg']) {
        var origin = trip['origin'];
        debugPrint(origin);
        var destination = trip['destination'];
        var id = trip['id'];
        var available_sits = trip['available_sits'];
        var owner_id = trip['owner_id'];
        var starting_date = trip['starting_date'];
        var info = trip['info'];
        var money = 10;
        var origin_coords = LatLng(
            trip['info']['routes'][0]['bounds']['northeast']['lat'],
            trip['info']['routes'][0]['bounds']['northeast']['lng']);
        var destination_coords = LatLng(
            trip['info']['routes'][0]['bounds']['southwest']['lat'],
            trip['info']['routes'][0]['bounds']['southwest']['lng']);
        travels.add(Travel(
            id: id,
            origin: origin,
            destination: destination,
            available_sits: available_sits,
            starting_date: starting_date,
            owner_id: owner_id,
            money: money,
            origin_coords: origin_coords,
            destination_coords: destination_coords));
      }
    });
  }

  Future<void> _getLocation() async {
    // Get the user's current location and update `_pickedLocation`
  }
  @override
  void initState() {
    super.initState();
    fetchData();
    _getLocation();
    flutterWebviewPlugin.onUrlChanged.listen((url) {
      if (url.contains('http://10.0.2.2:8000/paypal/finish')) {
        flutterWebviewPlugin.close();
        final token_url =
            Uri.parse('http://10.0.2.2:8000/paypal/capture/order');
        final token_headers = {'Content-Type': 'application/json'};
        final token_payload = {'id': order_id};
        http
            .post(token_url,
                headers: token_headers, body: json.encode(token_payload))
            .then((token_response) {
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
          if (travels[index].destination == widget.pontodechegada ||
              widget.pontodechegada == 'All' ||
              widget.pontodechegada == null) {
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
                          urlTemplate:
                              "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                          subdomains: ['a', 'b', 'c'],
                        ),
                        MarkerLayerOptions(
                          markers: [
                            Marker(
                              width: 80.0,
                              height: 80.0,
                              point: travels[index].origin_coords,
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
                              point: travels[index].destination_coords,
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
                              points: [
                                travels[index].origin_coords,
                                travels[index].destination_coords
                              ],
                              // points: travels[index].polyline,
                              strokeWidth: 4.0,
                              color: Colors.cyan,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  ListTile(
                    title: Text(travels[index].origin +
                        " - " +
                        travels[index].destination),
                    subtitle: Text(travels[index].starting_date),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(travels[index].money.toString() + "€"),
                        ElevatedButton(
                          onPressed: () async {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text("Pick a Location"),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      // flutter map to select pick up location
                                      Container(
                                        height: 180,
                                        width: 400,
                                        child: Stack(
                                          children: [
                                            FlutterMap(
                                              options: MapOptions(
                                                center:
                                                    LatLng(39.5572, -8.0317),
                                                zoom: 5.2,
                                                onPositionChanged:
                                                    (position, hasGesture) {
                                                  debugPrint(position.center
                                                      .toString());
                                                  _pickedLocation =
                                                      position.center!;
                                                  // turn this LatLng(latitude:39.5572, longitude:-8.0317) into this "39.5572,-8.0317"
                                                  _pickedLocationString =
                                                      _pickedLocation
                                                          .toString()
                                                          .replaceFirst(
                                                              'LatLng(latitude:',
                                                              '');
                                                  _pickedLocationString =
                                                      _pickedLocationString
                                                          .replaceFirst(
                                                              ' longitude:',
                                                              '');
                                                  _pickedLocationString =
                                                      _pickedLocationString
                                                          .replaceFirst(
                                                              ')', '');
                                                  debugPrint(
                                                      _pickedLocationString);
                                                },
                                              ),
                                              layers: [
                                                TileLayerOptions(
                                                  urlTemplate:
                                                      "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                                                  subdomains: ['a', 'b', 'c'],
                                                ),
                                                MarkerLayerOptions(
                                                  markers: [
                                                    Marker(
                                                      width: 80.0,
                                                      height: 80.0,
                                                      point: travels[index]
                                                          .origin_coords,
                                                      builder: (ctx) =>
                                                          Container(
                                                        child: Icon(
                                                          Icons.location_on,
                                                          color: Colors.red,
                                                        ),
                                                      ),
                                                    ),
                                                    Marker(
                                                      width: 80.0,
                                                      height: 80.0,
                                                      point: travels[index]
                                                          .destination_coords,
                                                      builder: (ctx) =>
                                                          Container(
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
                                                      points: [
                                                        travels[index]
                                                            .origin_coords,
                                                        travels[index]
                                                            .destination_coords
                                                      ],
                                                      strokeWidth: 4.0,
                                                      color: Colors.cyan,
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            Positioned(
                                              // center of container
                                              top: 0,
                                              left: 0,
                                              right: 0,
                                              bottom: 0,
                                              child: Center(
                                                child: Icon(
                                                  Icons.location_on,
                                                  color: Colors.blue,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  actions: <Widget>[
                                    ElevatedButton(
                                      child: Text('Pay'),
                                      style: ElevatedButton.styleFrom(
                                        primary: Colors.orange[400],
                                      ),
                                      onPressed: () async {
                                        // you need to be logged in to make a payment
                                        // if you are not logged in, you will be redirected to the login page
                                        // if you are logged in, you will be redirected to the payment page
                                        // get token from local storage
                                        final String tokenKey = 'token';
                                        final String? token =
                                            await _storage.read(key: tokenKey);
                                        if (token == null) {
                                          debugPrint('Token not found',
                                              wrapWidth: 1024);
                                          // go to login page
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    LoginPage()),
                                          );
                                          return;
                                        }

                                        // verify if the pick up location is in the route

                                        //
                                        final String url2 =
                                            'http://10.0.2.2:8080/service-review/v1/auth/auth';
                                        final Map<String, String> headers2 = {
                                          'Content-Type': 'application/json',
                                          'Accept': 'application/json',
                                          'x-access-token': token
                                        };
                                        final response3 = await http.post(
                                            Uri.parse(url2),
                                            headers: headers2);
                                        if (response3.statusCode != 200) {
                                          debugPrint('Token not valid',
                                              wrapWidth: 1024);
                                          // go to login page
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    LoginPage()),
                                          );
                                          // message to user that to pay you need to be logged in
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                "To pay you need to be logged in !!",
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                          return;
                                        }
                                        //adiciona participante
                                        final String url_add_participant =
                                            'http://10.0.2.2:8080/participant/';
                                        final response_add_participant =
                                            await http.post(
                                          Uri.parse(url_add_participant),
                                          headers: {
                                            'Content-Type': 'application/json',
                                          },
                                          body: jsonEncode({
                                            'pickup_location':
                                                _pickedLocationString,
                                            'trip_id': travels[index].id,
                                            'id':
                                                "0e4aefcb-ab8a-415f-9731-32a1f4bd7705"
                                          }),
                                        );
                                        debugPrint("response_add_participant");
                                        debugPrint(
                                            response_add_participant.body,
                                            wrapWidth: 1024);

                                        final url = Uri.parse(
                                            'http://10.0.2.2:8000/paypal/create/order');
                                        final headers = {
                                          'Content-Type': 'application/json'
                                        };
                                        final payload = {
                                          'amount': json.decode(
                                              response_add_participant
                                                  .body)['money']
                                        };
                                        final response = await http.post(url,
                                            headers: headers,
                                            body: json.encode(payload));
                                        final errorMessage =
                                            'Status: ${response.statusCode.toString()}';
                                        debugPrint(errorMessage,
                                            wrapWidth: 1024);
                                        if (response.statusCode == 201) {
                                          final jsonResponse =
                                              jsonDecode(response.body);
                                          final linkForPayment =
                                              jsonResponse['linkForPayment'];
                                          // save the order_id in class variable
                                          order_id = jsonResponse['order_id'];

                                          // lauch the linkForPayment in a webview until the url contains the string 'http://10.0.2.2:8000/paypal/finish'
                                          flutterWebviewPlugin
                                              .launch(linkForPayment);
                                        } else {
                                          // Handle the failure response
                                          // remove participante porque nao conseguiu pagar
                                          // final String url_remove_participant =
                                          //     'http://10.0.2.2:8080/participant/';
                                          // final response_remove_participant =
                                          //     await http.delete(
                                          //   Uri.parse(url_remove_participant),
                                          //   headers: {
                                          //     'Content-Type':
                                          //         'application/json',
                                          //   },
                                          //   body: jsonEncode({
                                          //     'id':
                                          //         "0e4aefcb-ab8a-415f-9731-32a1f4bd7705"
                                          //   }),
                                          // );
                                          // debugPrint(
                                          //     "response_remove_participant");
                                          // debugPrint(
                                          //     response_remove_participant.body,
                                          //     wrapWidth: 1024);
                                        }
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    ElevatedButton(
                                      child: Text('Cancel'),
                                      style: ElevatedButton.styleFrom(
                                        primary: Colors.red[400],
                                      ),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          child: Text("Participate"),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          } else {
            return Container();
          }
        },
      ),
    );
  }
}
