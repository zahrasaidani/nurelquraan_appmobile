// ignore_for_file: unused_field

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firstproject/otp_verification_screen.dart';

class RegistrationForm extends StatefulWidget {
  @override
  _RegistrationFormState createState() => _RegistrationFormState();
}

class _RegistrationFormState extends State<RegistrationForm> {
  // Constants
  final double buttonPadding = 10.0;
  final Color buttonColor = Colors.white;
  final double borderRadius = 10.0;
  final Color textColor = Color.fromARGB(255, 155, 159, 208);
  final FontWeight textFontWeight = FontWeight.bold;
  final double textSize = 16.0;

  // Form Controllers and State
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _mosqueNameController = TextEditingController();
  final TextEditingController _mosqueAddressController =
      TextEditingController();
  bool _isButtonPressed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 155, 159, 208),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    SizedBox(height: 20),
                    Text(
                      'سجل مسجدك',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: 'الاسم الكامل',
                        prefixIcon: Icon(Icons.person, color: Colors.grey),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'يرجى إدخال الاسم الكامل';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: 'رقم الهاتف',
                        prefixIcon: Icon(Icons.phone, color: Colors.grey),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'يرجى إدخال رقم الهاتف';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: _mosqueNameController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: 'اسم المسجد',
                        prefixIcon:
                            Icon(Icons.account_balance, color: Colors.grey),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'يرجى إدخال اسم المسجد';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: _mosqueAddressController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: 'عنوان المسجد',
                        prefixIcon: Icon(Icons.location_on, color: Colors.grey),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'يرجى إدخال عنوان المسجد';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    _buildNextButton(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Widget for the Next Button
  Widget _buildNextButton() {
    return InkWell(
      onTap: _nextButtonPressed,
      onTapDown: (_) {
        setState(() {
          _isButtonPressed = true;
        });
      },
      onTapCancel: () {
        setState(() {
          _isButtonPressed = false;
        });
      },
      onTapUp: (_) {
        setState(() {
          _isButtonPressed = false;
        });
      },
      child: Container(
        height: 60.0, // Set button height same as field height
        margin: EdgeInsets.symmetric(horizontal: 25),
        decoration: BoxDecoration(
          color: buttonColor,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: Center(
          child: Text(
            'التالي',
            style: TextStyle(
              color: textColor,
              fontWeight: textFontWeight,
              fontSize: textSize,
            ),
          ),
        ),
      ),
    );
  }

  // Method to navigate to OTP Screen
  void navigateToOtpScreen(String verificationId, String phoneNumber,
      String fullName, String mosqueName, String mosqueAddress) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OtpVerificationScreen(
          verificationId: verificationId,
          phoneNumber: phoneNumber,
          fullName: fullName,
          mosqueName: mosqueName,
          mosqueAddress: mosqueAddress,
        ),
      ),
    );
  }

  // Method for handling Next Button Press
  void _nextButtonPressed() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: '+213${_phoneController.text.trim()}',
        verificationCompleted: (PhoneAuthCredential credential) {
          // Implement automatic login here
        },
        verificationFailed: (FirebaseAuthException ex) {
          // Handle verification failure here
        },
        codeSent: (String verificationId, int? resendToken) async {
          // Navigate to the OTP screen
          navigateToOtpScreen(
            verificationId,
            _phoneController.text.trim(),
            _nameController.text.trim(),
            _mosqueNameController.text.trim(),
            _mosqueAddressController.text.trim(),
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          // Handle code retrieval timeout here
        },
      );
    }
  }
}
