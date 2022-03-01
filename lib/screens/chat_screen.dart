import 'package:chat_app/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

final _firestore = FirebaseFirestore.instance;

//stful, buat layout yang dinamis
class ChatScreen extends StatefulWidget {
  static const String id = "CHAT_SCREEN";

  const ChatScreen({Key? key}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _auth = FirebaseAuth.instance;
  late User loggedInUser;

  late String message;

  void getCurrentUser() {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        loggedInUser = user;
        print(loggedInUser.email);
      }
    } catch (e) {}
  }

  @override
  void initState() {
    getCurrentUser();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        title: Text('Chat'),
        backgroundColor: Colors.lightBlueAccent,
        actions: [
          IconButton(
              onPressed: () {
                //for logout
              },
              icon: Icon(Icons.close))
        ],
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const MessageStream(),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: TextField(
                      style: TextStyle(color: Colors.black),
                      onChanged: (value) {
                        message = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      _firestore
                          .collection("messages")
                          .add({"text": message, "sender": loggedInUser.email});
                    },
                    child: Text('Send', style: kSendButtonTextStyle),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessageStream extends StatelessWidget {
  const MessageStream({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection("messages").snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(
                backgroundColor: Colors.lightBlue,
              ),
            );
          }

          final messages = snapshot.data!.docs;
          List<MessageBubble> messageBubbles = [];
          for (var message in messages) {
            final messageText = message["text"];
            final messageSender = message["sender"];

            final messageWidget =
                MessageBubble(sender: messageSender, text: messageText);
            messageBubbles.add(messageWidget);
          }
          return Expanded(
            child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: ListView(children: messageBubbles)),
          );
        });
  }
}

class MessageBubble extends StatelessWidget {
  final String sender;
  final String text;

  // final bool isMe;

  const MessageBubble({Key? key, required this.sender, required this.text})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        // isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            sender,
            style: TextStyle(color: Colors.black54, fontSize: 12),
          ),
          Material(
              borderRadius: BorderRadius.circular(30),
              // topLeft: isMe ? Radius.circular(30) : Radius.circular(0),
              // topRight: isMe ? Radius.circular(0) : Radius.circular(30),
              // bottomRight: Radius.circular(30),
              // bottomLeft: Radius.circular(30)),
              elevation: 5,
              // color: isMe ? Colors.lightBlue : Colors.white,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: Text(
                  text,
                  style: TextStyle(color: Colors.white, fontSize: 15),
                  // color: isMe ? Colors.white : Colors.black54, fontSize: 15),
                ),
              )
          )
        ],
      ),
    );
  }
}
