import 'package:flutter/material.dart';
import 'google_map.dart';
import 'welcome_screen.dart';
import 'login_screen.dart';
import 'add_bin.dart';
import 'popup_form.dart';

void main() => runApp(GoogleMap ());

class GoogleMap extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        textTheme: TextTheme(
          body1: TextStyle(color: Colors.black54),
        ),
      ),
      initialRoute: 'google_map',
      routes: {
        WelcomeScreen.id : (context) => WelcomeScreen(),
        LoginScreen.id: (context) => LoginScreen(),
        'google_map': (context) => MapView(),
        '/add_bin': (context) => AddBin(),
      },
    );
  }
}
