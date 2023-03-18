import 'package:flutter/material.dart';

class Message {
  String sender;
  String recipient;
  String message;

  Message({
    required this.sender,
    required this.recipient,
    required this.message,
  });
}

class MessagePage extends StatefulWidget {
  const MessagePage({Key? key}) : super(key: key);

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  final List<Message> _messages = [
    Message(
      sender: "Alice",
      recipient: "Bob",
      message: "Hey there, how's it going?",
    ),
    Message(
      sender: "Alice",
      recipient: "Bob",
      message: "I'm doing well, thanks for asking!",
    ),
    Message(
      sender: "Alice",
      recipient: "Bob",
      message: "What have you been up to lately?",
    ),
    Message(
      sender: "Alice",
      recipient: "Bob",
      message: "Not much, just working and hanging out with friends. You?",
    ),
    Message(
      sender: "Renato",
      recipient: "Bob",
      message: "Same here, just trying to stay busy!",
    ),
    Message(
      sender: "Bruno",
      recipient: "Bob",
      message: "Oi frontend é uma seca",
    ),
    Message(
      sender: "Tiago",
      recipient: "Bob",
      message: "Adoro backend!",
    ),
    Message(
      sender: "Claudio",
      recipient: "Bob",
      message: "Adoro Jupyter!",
    ),
    Message(
      sender: "Hugo",
      recipient: "Bob",
      message: "HUGAAAAAAAA",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    Set<String> uniqueSenders = Set<String>();

// Loop through messages and add unique senders to the set
    for (var message in _messages) {
      if (!uniqueSenders.contains(message.sender)) {
        uniqueSenders.add(message.sender);
      }
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text("Messages"),
      ),
      body: ListView.builder(
        itemCount: uniqueSenders.length,
        itemBuilder: (context, index) {
          // Get the sender at the current index
          String sender = uniqueSenders.elementAt(index);

          // Find the first message with the current sender
          Message firstMessage = _messages.firstWhere((message) => message.sender == sender);

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
            subtitle: Text(firstMessage.message),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MessageConversationPage(sender: firstMessage.sender),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class MessageConversationPage extends StatefulWidget {
  final String sender;

  const MessageConversationPage({Key? key, required this.sender}) : super(key: key);

  @override
  State<MessageConversationPage> createState() => _MessageConversationPageState();
}

class _MessageConversationPageState extends State<MessageConversationPage> {
  final List<Message> _messages = [
    Message(
      sender: "Bruno",
      recipient: "Tiago",
      message: "Oi frontend é uma seca",
    ),
    Message(      sender: "Tiago",      recipient: "Bruno",      message: "eu gosto!",    ),  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.sender),
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
              alignment: isSender ? Alignment.centerLeft : Alignment.centerRight,
              child: Text(message.message, textAlign: textAlign),
            ),
            subtitle: Align(
              alignment: isSender ? Alignment.centerLeft : Alignment.centerRight,
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
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  decoration: const InputDecoration(hintText: "Type a message..."),
                  onFieldSubmitted: (value) {
                    setState(() {
                      _messages.add(Message(
                        sender: widget.sender,
                        recipient: "",
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
            ),
          ],
        ),
      ),
    );
  }
}
