import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:skillxchange/auth/login.dart';
import 'package:skillxchange/common/button.dart';
import 'package:skillxchange/common/textfield.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController genderController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  bool isLoading = false;

  void signUpUser() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Firebase authentication
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // Store additional user details in Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        "email": emailController.text.trim(),
        "gender": genderController.text.trim(),
        "mobile": mobileController.text.trim(),
        "address": addressController.text.trim(),
        "createdAt": DateTime.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Signup Successful!")),
      );

      // Navigate to login screen
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => Login()));
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? "Signup failed")),
      );
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 100,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                      height: 100,
                      width: 100,
                      child: Center(child: Image.asset("assets/key.png"))),
                ],
              ),
              SizedBox(
                height: 40,
              ),
              Text(
                "Sign up",
                style: GoogleFonts.poppins(
                    fontSize: 30, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 5,
              ),
              Text(
                "Create a account for buying new shoes",
                style: GoogleFonts.poppins(),
              ),
              SizedBox(
                height: 40,
              ),
              CustomTextField(
                text: "Enter E-mail",
              ),
              SizedBox(
                height: 10,
              ),
              CustomTextField(
                text: "Enter PassWord",
              ),
              SizedBox(
                height: 10,
              ),
              CustomTextField(
                text: "Gender",
              ),
              SizedBox(
                height: 10,
              ),
              CustomTextField(
                text: "Mobile Number",
              ),
              SizedBox(
                height: 10,
              ),
              CustomTextField(
                text: "Address",
              ),
              SizedBox(
                height: 40,
              ),
              isLoading? const Center(child: CircularProgressIndicator()):
              CustomButton(
                onTap: signUpUser,
                text: "Sign up",
              ),
              SizedBox(
                height: 40,
              ),
              InkWell(
                onTap: () {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Login(),
                      ));
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "have a account ? ",
                      style: GoogleFonts.poppins(),
                    ),
                    Text(
                      "Login into",
                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}