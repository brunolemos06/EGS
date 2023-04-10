import 'package:flutter/material.dart';
import 'login_page.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ridemate/pages/main_page.dart';

class Message {
  String sender;
  String conversa;
  String message;

  Message({
    required this.sender,
    required this.conversa,
    required this.message,
  });
}

class MessagePage extends StatefulWidget {
  const MessagePage({Key? key}) : super(key: key);

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  final List<Message> _messages = [];
  bool loading = true;
  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final storage = FlutterSecureStorage();
    // token
    final String tokenKey = 'token';
    final String? token = await storage.read(key: tokenKey);
    if (token != null) {
      final String url = 'http://10.0.2.2:8080/service-review/v1/auth/info';
      final String url2 = 'http://10.0.2.2:8080/service-review/v1/auth/auth';
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
        return;
      }
      final response = await http.post(Uri.parse(url), headers: headers);
      // pop up 
      if (response.statusCode == 200) {
        final responseJson = json.decode(response.body);
        debugPrint('Response: ${response.body}', wrapWidth: 1024);
        final String name = responseJson['fname'];
        final String lname = responseJson['lname'];
        final String email = responseJson['email'];
        final String id = responseJson['id'];

        // get id for chat
        final String url =
            'http://10.0.2.2:8080/service-review/v1/auth/fetchdata';
        final responsefetch = await http.post(
          Uri.parse(url),
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            "auth_id": id,
            "email": email,
          }),
        );
        debugPrint('Response: ${responsefetch.body}', wrapWidth: 1024);
        if (responsefetch.statusCode == 200) {
          final responseJson = json.decode(responsefetch.body);
          final String chatid = responseJson['chat_id'];
          final responsechat = await http.get(Uri.parse('http://10.0.2.2:8080/service-review/v1/conversations?author=US1a381f88799a4768bd58018d0b64cb66'));
          if (responsechat.statusCode == 200) {
            final responseJson = json.decode(responsechat.body);
            debugPrint('Response: ${responsechat.body}', wrapWidth: 1024);
            //get the messages array in the jsonresponse;
            final messages = responseJson[0]['messages'];
            //add the messages to the list
            setState(() {
              for (var message in messages) {
                _messages.add(Message(
                    sender: message['author'],
                    conversa: 'conversa',
                    message: message['body']));
              }
              loading = false;
            });

            debugPrint(_messages.toString(), wrapWidth: 1024);
          }
        }

        //request to get chat to composer
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Set<String> uniqueSenders = Set<String>();

// Loop through messages and add unique senders to the set
    for (var message in _messages) {
      if (!uniqueSenders.contains(message.conversa)) {
        uniqueSenders.add(message.conversa);
      }
    }
    return MaterialApp(
      home: loading ? LoadingScreen() : Scaffold(
      backgroundColor : const Color(0x808080),
      
      appBar: AppBar(
        title: const Text("Messages"),
        backgroundColor: Colors.grey[800],
        // text color white
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        itemCount: uniqueSenders.length,
        itemBuilder: (context, index) {
          // Get the sender at the current index
          String sender = uniqueSenders.elementAt(index);

          // Find the first message with the current sender
          Message firstMessage =
              _messages.firstWhere((message) => message.conversa == sender);

          return ListTile(
            title: Container(
              child: Text(
                sender,
                style: TextStyle(
                  color: Colors.green, // set the text color of the title
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            subtitle: Text(
              firstMessage.message,
                style: TextStyle(
                  color: Colors.white, // set the text color of the subtitle
                )),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      MessageConversationPage(sender: firstMessage.sender),
                ),
              );
            },
          );
        },
      ),
    ),
    );
  }
}

class MessageConversationPage extends StatefulWidget {
  final String sender;

  const MessageConversationPage({Key? key, required this.sender})
      : super(key: key);

  @override
  State<MessageConversationPage> createState() =>
      _MessageConversationPageState();
}

class _MessageConversationPageState extends State<MessageConversationPage> {
  final List<Message> _messages = [
    // Message(
    //   sender: "Bruno",
    //   recipient: "Tiago",
    //   message: "Oi frontend é uma seca",
    // ),
    // Message(
    //   sender: "Tiago",
    //   recipient: "Bruno",
    //   message: "eu gosto!",
    // ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor : const Color(0x808080),
      appBar: AppBar(
        title: Text(widget.sender),
        backgroundColor: Colors.grey[800],
      ),
      body: ListView.builder(
        reverse: true,
        itemCount: _messages.length,
        itemBuilder: (context, index) {
          final message = _messages[index];
          final isSender = message.sender == widget.sender;
          final textAlign = isSender ? TextAlign.start : TextAlign.end;
          return ListTile(
            title: Align(
              alignment:
                  isSender ? Alignment.centerLeft : Alignment.centerRight,
              child: Text(message.message, textAlign: textAlign),
            ),
            subtitle: Align(
              alignment:
                  isSender ? Alignment.centerLeft : Alignment.centerRight,
              child: Text(
                message.sender,
                style: TextStyle(
                  color: Colors.green, // Replace with desired color
                ),
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: BottomAppBar(
        color : const Color(0x828282),
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  style: TextStyle(
                    color: Colors.white,
                  ),
                  decoration:
                      const InputDecoration(
                        hintText: "Type a message...",
                        hintStyle: TextStyle(
                          color: Colors.grey,
                        ),
                        // when the textfield is focused
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.green,
                          ),
                        ),
                        ),
                  onFieldSubmitted: (value) {
                    setState(() {
                      _messages.add(Message(
                        sender: widget.sender,
                        conversa: "",
                        message: value,
                      ));
                    });
                  },
                ),
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.send),
              color: Colors.green,            ),
          ],
        ),
      ),
    );
  }
}
// Define the loading screen widget
class LoadingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
        ),
      ),
    );
  }
}