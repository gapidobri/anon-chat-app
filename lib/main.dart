import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:acapp/chat.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.transparent,
    ),
  );
  
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ChatPage(),
    ),
  );
}
