import 'package:firstproject/imam/mappageimam.dart';
import 'package:firstproject/imam/otpverificationimam.dart';
import 'package:firstproject/imam/myhomescreenimam.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
// Import your home page

class RegistrationFormImam extends StatefulWidget {
  const RegistrationFormImam({Key? key}) : super(key: key);

  @override
  _RegistrationFormState createState() => _RegistrationFormState();
}

class _RegistrationFormState extends State<RegistrationFormImam> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _mosqueNameController = TextEditingController();

  bool _isButtonPressed = false;

  @override
  void initState() {
    super.initState();
    checkUserLoggedIn();
  }

  void checkUserLoggedIn() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // User is already authenticated, navigate to home page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) =>
                MyHomeScreenImam()), // Replace HomePage with your actual home page
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 155, 159, 208),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    const SizedBox(height: 20),
                    const Text(
                      'سجل مسجدك',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _mosqueNameController,
                      decoration: const InputDecoration(
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
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
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
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: 'وصف للمسجد',
                        prefixIcon: Icon(Icons.edit, color: Colors.grey),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'يرجى إدخال وصف للمسجد';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    InkWell(
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
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.symmetric(horizontal: 25),
                        decoration: BoxDecoration(
                          color: _isButtonPressed ? Colors.grey : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            'التالي',
                            style: TextStyle(
                              color:
                                  _isButtonPressed ? Colors.white : Colors.grey,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void navigateToOtpScreen(
    String verificationId,
    String phoneNumber,
    String description,
    String mosqueName,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OtpVerificationScreenImam(
          verificationId: verificationId,
          phoneNumber: phoneNumber,
          description: description,
          mosqueName: mosqueName,
        ),
      ),
    );
  }

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
            _descriptionController.text.trim(),
            _mosqueNameController.text.trim(),
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          // Handle code retrieval timeout here
        },
      );
    }
  }
}
