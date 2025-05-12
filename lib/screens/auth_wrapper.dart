import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'home_screen.dart';
import 'login_screen.dart';
import 'register_screen.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  _AuthWrapperState createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool showSignIn = true;

  void toggleView() {
    setState(() => showSignIn = !showSignIn);
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);

    // Return home or authenticate screen
    if (user == null) {
      return showSignIn
          ? LoginScreen(toggleView: toggleView)
          : RegisterScreen(toggleView: toggleView);
    } else {
      return const HomeScreen();
    }
  }
}