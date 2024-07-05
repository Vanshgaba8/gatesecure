import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ui/components/login_or_register.dart';
import 'package:flutter_ui/components/student_homepage.dart';
import 'package:flutter_ui/login_page.dart';
import 'home_page.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final User? user = snapshot.data;
            final String? email = user?.email;
            if (email != null &&
                (email.startsWith('1') ||
                    email.startsWith('2') ||
                    email.startsWith('3') ||
                    email.startsWith('4') ||
                    email.startsWith('5') ||
                    email.startsWith('6') ||
                    email.startsWith('7') ||
                    email.startsWith('8') ||
                    email.startsWith('9') ||
                    email.startsWith('0'))) {
              return studentpage();
            } else {
              return Homepage();
            }
            return Homepage();
          } else {
            return LoginOrRegisterPage();
          }
        },
      ),
    );
  }
}
