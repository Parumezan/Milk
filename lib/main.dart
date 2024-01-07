import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:milk/pages/home.dart';
import 'package:milk/pages/login.dart';
import 'package:milk/tools.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();

  runApp(
    MaterialApp(
      home: FutureBuilder(
        future: tokenExists(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
                child: Text('Error: ${snapshot.error}',
                    overflow: TextOverflow.ellipsis));
          } else {
            if (snapshot.data == true) {
              return const Home();
            } else {
              return const Login();
            }
          }
        },
      ),
      theme: ThemeData(),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system,
    ),
  );
}
