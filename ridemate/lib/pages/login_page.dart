import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'CreateAccountPage.dart';
import 'home_page.dart';
import 'package:http/http.dart' as http;
import 'package:ridemate/pages/main_page.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _url = 'http://10.0.2.2:3000/'; // replace with your URL
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _shouldShowLoginForm = true;
  final _storage = FlutterSecureStorage();

  late WebViewController _webViewController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(height: 75), // empty space at the top
          Visibility(
            visible: _shouldShowLoginForm,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      labelText: 'Username',
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Password',
                    ),
                  ),
                ),
                SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 150,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {},
                        child: Text('Login'),
                      ),
                    ),
                    SizedBox(width: 20),
                    SizedBox(
                      width: 150,
                      height: 50,
                      child: ElevatedButton(
                      onPressed: () async {
                          Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => CreateAccountPage()),
                          );
                        },
                        child: Text('Create Account'),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
          Expanded(
            child: WebView(
              initialUrl: _url,
              javascriptMode: JavascriptMode.unrestricted,
              onWebViewCreated: (WebViewController controller) {
                _webViewController = controller;
              },
              onPageFinished: (url) async {
                if (url != null && (url.contains("github/callback") || url.contains("google/callback"))) {
                  // get status page
                  final statusPage = await _webViewController.currentUrl();
                  if (statusPage != null && statusPage.contains("error")) {
                    // exit webview
                    Navigator.of(context).pop();
                    
                    // show not sucess message
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "Login Failed!",
                          style: TextStyle(color: Colors.white),
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                  } else {
                    // Extract JSON data from the web page
                    final jsonString = await _webViewController.evaluateJavascript("document.body.innerText");
                    final jsonData = jsonDecode(jsonString);
                    
                    final res = jsonData.toString();
                    final out = res.split(" ");
                    final token = out[3].replaceAll('"', '').replaceAll('}', '').replaceAll('\n', '');
                    debugPrint("Token -> " + token, wrapWidth: 1024);
                    // save token to secure storage
                    await _storage.write(key: 'token', value: token);
                    Navigator.of(context).pop();
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => MainPage()),
                      (route) => false,
                    );

                    // show success message
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "Logged in successfully!",
                          style: TextStyle(color: Colors.white),
                        ),
                        backgroundColor: Colors.green,
                      ),
                    );

                    final String url = 'http://10.0.2.2:5000/info';
                    final Map<String, String> headers = {
                      'Content-Type': 'application/json',
                      'Accept': 'application/json',
                      'x-access-token': token,
                    };
                    final response = await http.post(Uri.parse(url), headers: headers);

                    if (response.statusCode == 200) {
                      final responseJson = json.decode(response.body);
                      final String name = responseJson['fname'];
                      final String lname = responseJson['lname'];
                      final String email = responseJson['email'];
                      debugPrint("Name -> $name", wrapWidth: 1024);
                      debugPrint("Lname -> $lname", wrapWidth: 1024);
                      debugPrint("Email -> $email", wrapWidth: 1024);
                      
                    } else {
                      debugPrint('Error: ${response.statusCode}', wrapWidth: 1024);
                    }
                  }
                }


                if (url.contains("google") || url.contains("github")) {
                  setState(() {
                    _shouldShowLoginForm = false;
                  });
                } else {
                  setState(() {
                    _shouldShowLoginForm = true;
                  });
                }
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () async {
                // verify i am logged in
                final storage = FlutterSecureStorage();
                final String tokenKey = 'token';
                final String? token = await storage.read(key: tokenKey);

                Navigator.of(context).pop();
                if (token == null) {
                  Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => MainPage()),
                  (route) => false,
                );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
