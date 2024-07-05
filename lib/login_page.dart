import 'package:flutter/material.dart';
import 'package:flutter_ui/components/mybutton.dart';
import 'package:flutter_ui/components/text_field.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_ui/components/forgot_page.dart';

class LoginPage extends StatefulWidget {
  final Function()? onTap;
  LoginPage({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();

  final passwordController = TextEditingController();

  void signuserin() async {
    showDialog(
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
    if (emailController.text.endsWith('iiitu.ac.in')) {
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );
        Navigator.pop(context);
      } on FirebaseAuthException catch (e) {
        Navigator.pop(context);
        showerror(e.code);
      }
    } else {
      Navigator.pop(context);
      showerror("Restricted for IIITU Students");
    }
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

  void wrongEmailmessage() {
    showDialog(
      context: context,
      builder: (context) {
        return const AlertDialog(
          title: Text('Incorrect Email or Password'),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: h / 100,
                ),
                Image.asset(
                  'assets/images/logo/iiitu-logo.png',
                  height: h / 6,
                ),
                SizedBox(
                  height: h / 15,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      'IIIT UNA',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Text(
                  'Login',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 16,
                  ),
                ),
                SizedBox(
                  height: h / 30,
                ),
                mytextfield(
                  controller: emailController,
                  hintText: 'Email ID',
                  obscureText: false,
                ),
                SizedBox(
                  height: h / 30,
                ),
                mytextfield(
                  controller: passwordController,
                  hintText: 'Password',
                  obscureText: true,
                ),
                SizedBox(
                  height: h / 50,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return forgotpage();
                              },
                            ),
                          );
                        },
                        child: Text(
                          'Forgot Password?',
                          style: TextStyle(fontSize: 12, color: Colors.blue),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: h / 30,
                ),
                mybutton(
                  onTap: signuserin,
                  text: 'Sign In',
                ),
                SizedBox(
                  height: h / 50,
                ),
                // Padding(
                //   padding: const EdgeInsets.symmetric(horizontal: 25.0),
                //   child: Row(
                //     children: [
                //       Expanded(
                //         child: Divider(
                //           thickness: 0.5,
                //           color: Colors.grey[400],
                //         ),
                //       ),
                //       Padding(
                //         padding: const EdgeInsets.symmetric(horizontal: 10.0),
                //         child: Text('Or continue with'),
                //       ),
                //       Expanded(
                //         child: Divider(
                //           thickness: 0.5,
                //           color: Colors.grey[400],
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
                // SizedBox(
                //   height: h / 50,
                // ),
                // Center(
                //   child: Container(
                //     padding: EdgeInsets.all(15),
                //     child: Image.asset(
                //       'assets/images/logo/google-logo.png',
                //       height: h / 25,
                //     ),
                //     decoration: BoxDecoration(
                //       border: Border.all(color: Colors.white),
                //       borderRadius: BorderRadius.circular(20),
                //       color: Colors.grey[200],
                //     ),
                //   ),
                // ),
                // SizedBox(
                //   height: h / 60,
                // ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Not a Member?'),
                    SizedBox(
                      width: w / 50,
                    ),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: Text(
                        'Register Now',
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: h / 40,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
