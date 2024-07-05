import 'package:flutter/material.dart';
import 'package:flutter_ui/components/mybutton.dart';
import 'package:flutter_ui/components/text_field.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_ui/login_page.dart';

class forgotpage extends StatefulWidget {
  forgotpage({super.key});

  @override
  State<forgotpage> createState() => _forgotpageState();
}

class _forgotpageState extends State<forgotpage> {
  final emailcon = TextEditingController();
  void dispose() {
    emailcon.dispose();
    super.dispose();
  }

  void showerror(String s) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.deepPurple,
          title: Center(
            child: Text(
              s,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        );
      },
    );
  }

  Future pwordreset() async {
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: emailcon.text.trim());
      showerror(
          'Password reset link sent (If the user exist)! Check your email');
    } on FirebaseAuthException catch (e) {
      showerror(e.code);
    }
  }

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Enter Your Email and we will send you a password reset link',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20),
            ),
          ),
          mytextfield(
            controller: emailcon,
            hintText: 'Email ID',
            obscureText: false,
          ),
          SizedBox(
            height: h / 30,
          ),
          mybutton(
            onTap: pwordreset,
            text: 'Reset Password',
          ),
        ],
      ),
    );
  }
}
