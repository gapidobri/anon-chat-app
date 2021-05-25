import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_socket_io/flutter_socket_io.dart';
import 'package:flutter_socket_io/socket_io_manager.dart';

final kHintTextStyle = TextStyle(
  color: Color.fromRGBO(0, 255, 0, 1.0),
  fontFamily: 'DinNext',
);

final kLabelStyle = TextStyle(
  color: Color.fromRGBO(0, 255, 0, 1.0),
  fontWeight: FontWeight.bold,
  fontFamily: 'DinNext',
);

final kBoxDecorationStyle = BoxDecoration(
  color: Color.fromRGBO(51, 51, 51, 1.0),
  borderRadius: BorderRadius.circular(10.0),
  boxShadow: [
    BoxShadow(
      color: Colors.black12,
      blurRadius: 6.0,
      offset: Offset(0, 2),
    ),
  ],
);

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  SocketIO socketIO;
  List<String> messages;
  double height, width;
  TextEditingController textController;
  ScrollController scrollController;

  var author;

  @override
  void initState() {
    //Initializing the message list
    messages = List<String>();
    //Initializing the TextEditingController and ScrollController
    textController = TextEditingController();
    scrollController = ScrollController();
    //Creating the socket
    socketIO = SocketIOManager().createSocketIO(
      'https://orb-anon-chat.herokuapp.com',
      '/',
    );
    //Call init before doing anything with socket
    print("time to init");
    socketIO.init();
    //Subscribe to an event to listen to
    print("time to subscribe");
    socketIO.subscribe('receive_message', (jsonData) {
      //Convert the JSON data received into a Map
      Map<String, dynamic> data = json.decode(jsonData);
      this.setState(() => messages.add(data['message']));
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 600),
        curve: Curves.ease,
      );
    });
    //Connect to the socket
    print("time to connect");
    socketIO.connect();
    super.initState();
  }

  Widget buildSingleMessage(int index) {
    return Container(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.all(20.0),
        margin: const EdgeInsets.only(bottom: 20.0, left: 20.0),
        decoration: BoxDecoration(
          color: Color.fromRGBO(51, 51, 51, 1.0),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Text(
          messages[index],
          style: TextStyle(color: Color.fromRGBO(0, 255, 0, 1.0), fontSize: 15.0),
        ),
      ),
    );
  }

  Widget buildMessageList() {
    return Container(
      height: height * 0.8,
      width: width,
      child: ListView.builder(
        controller: scrollController,
        itemCount: messages.length,
        itemBuilder: (BuildContext context, int index) {
          return buildSingleMessage(index);
        },
      ),
    );
  }

  Widget buildChatInput() {
    return Container(
      decoration: kBoxDecorationStyle,
      width: width * 0.7,
      height: 56.0,
      padding: const EdgeInsets.all(2.0),
      margin: const EdgeInsets.only(right: 2.0),
      child: TextField(
        cursorWidth: 2.5,
        cursorColor: Color.fromRGBO(0, 255, 0, 1.0),
        style: TextStyle(color: Color.fromRGBO(0, 255, 0, 1.0)),
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.only(top: 14.0),
          prefixIcon: Icon(
            Icons.email,
            color: Color.fromRGBO(0, 255, 0, 1.0),
          ),
          hintText: "Send message...",
          hintStyle: kHintTextStyle,
        ),
        controller: textController,
      ),
    );
  }

  Widget buildSendButton() {
    return FloatingActionButton(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      backgroundColor: Color.fromRGBO(51, 51, 51, 1.0),
      onPressed: () {
        if (textController.text.isNotEmpty) {
          socketIO.sendMessage('send_message', json.encode({'message': textController.text}));
          this.setState(() => messages.add(textController.text));
          textController.text = '';
          scrollController.animateTo(
            scrollController.position.maxScrollExtent,
            duration: Duration(milliseconds: 600),
            curve: Curves.ease,
          );
        }
      },
      child: Icon(
        Icons.send,
        size: 30,
        color: Color.fromRGBO(0, 255, 0, 1.0),
      ),
    );
  }

  Widget buildInputArea() {
    return Container(
      height: height * 0.1,
      width: width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          buildChatInput(),
          buildSendButton(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    return Scaffold(
        body: Container(
          color: Colors.black,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                SizedBox(height: height * 0.1),
                buildMessageList(),
                buildInputArea()
              ],
            ),
          ),
        )
    );
  }
}