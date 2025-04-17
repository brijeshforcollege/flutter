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

      // Store complete user details in Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        "id": userCredential.user!.uid,
        "email": emailController.text.trim(),
        "gender": genderController.text.trim(),
        "mobile": mobileController.text.trim(),
        "address": addressController.text.trim(),
        "name": emailController.text.trim().split('@').first,
        "skillsTeaching": [],
        "skillsLearning": [],
        "bio": "",
        "skillCoins": 100,
        "imageUrl": "",
        "joinDate": Timestamp.now(),
        "createdAt": Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Signup Successful!")),
      );

      // Navigate to login screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Login()),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? "Signup failed")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
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
              const SizedBox(height: 100),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 100,
                    width: 100,
                    child: Center(child: Image.asset("assets/key.png")),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              Text(
                "Sign up",
                style: GoogleFonts.poppins(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                "Create an account for buying new shoes",
                style: GoogleFonts.poppins(),
              ),
              const SizedBox(height: 40),

              CustomTextField(
                text: "Enter E-mail",
                controller: emailController,
              ),
              const SizedBox(height: 10),

              CustomTextField(
                text: "Enter Password",
                controller: passwordController,
                obscureText: true,
              ),
              const SizedBox(height: 10),

              CustomTextField(
                text: "Gender",
                controller: genderController,
              ),
              const SizedBox(height: 10),

              CustomTextField(
                text: "Mobile Number",
                controller: mobileController,
              ),
              const SizedBox(height: 10),

              CustomTextField(
                text: "Address",
                controller: addressController,
              ),
              const SizedBox(height: 40),

              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : CustomButton(
                      onTap: signUpUser,
                      text: "Sign up",
                    ),
              const SizedBox(height: 40),

              InkWell(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const Login()),
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Have an account? ",
                      style: GoogleFonts.poppins(),
                    ),
                    Text(
                      "Login",
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