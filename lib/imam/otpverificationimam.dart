// ignore_for_file: deprecated_member_use, unused_import

import 'package:firstproject/imam/mappageimam.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firstproject/imam/myhomescreenimam.dart';
import 'package:flutter/services.dart'; // Import your existing home screen
// Import the new page to store data

class OtpVerificationScreenImam extends StatelessWidget {
  final String verificationId;
  final String phoneNumber;
  final String description;
  final String mosqueName;

  final TextEditingController otpController1 = TextEditingController();
  final TextEditingController otpController2 = TextEditingController();
  final TextEditingController otpController3 = TextEditingController();
  final TextEditingController otpController4 = TextEditingController();
  final TextEditingController otpController5 = TextEditingController();
  final TextEditingController otpController6 = TextEditingController();

  OtpVerificationScreenImam({
    Key? key,
    required this.verificationId,
    required this.phoneNumber,
    required this.description,
    required this.mosqueName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 155, 159, 208),
        title: const Text(
          "OTP",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 30),
            _buildVerificationCodeSection(),
            const SizedBox(height: 15),
            _buildCodeInputFields(context),
            const SizedBox(height: 20),
            _buildActionButtons(context),
            const SizedBox(height: 10),
            _buildResendCodeText(),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  Widget _buildVerificationCodeSection() {
    return Container(
      padding: const EdgeInsets.all(10),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "تحقق من رمز OTP",
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 23,
            ),
          ),
          Text(
            "لقد أرسلنا رسالة نصية قصيرة برمز تفعيل إلى هاتفك",
            style: TextStyle(
              fontWeight: FontWeight.normal,
              fontSize: 14,
            ),
          ),
          Row(
            children: [
              Text(
                "+213*******21",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCodeInputFields(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildOTPTextField(context, otpController1),
        _buildOTPTextField(context, otpController2),
        _buildOTPTextField(context, otpController3),
        _buildOTPTextField(context, otpController4),
        _buildOTPTextField(context, otpController5),
        _buildOTPTextField(context, otpController6),
      ],
    );
  }

  Widget _buildOTPTextField(
      BuildContext context, TextEditingController controller) {
    return SizedBox(
      height: 68,
      width: 64,
      child: TextField(
        controller: controller,
        onChanged: (value) {
          if (value.length == 1) {
            FocusScope.of(context).nextFocus();
          }
        },
        style: Theme.of(context).textTheme.headline6!,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        inputFormatters: [
          LengthLimitingTextInputFormatter(1),
          FilteringTextInputFormatter.digitsOnly,
        ],
        decoration: InputDecoration(
          hintText: "0",
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
              color: Color.fromARGB(255, 155, 159, 208),
              width: 2,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
              color: Color.fromARGB(255, 155, 159, 208),
              width: 2,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResendCodeText() {
    return RichText(
      text: const TextSpan(
        style: TextStyle(
          fontSize: 16,
          color: Color.fromARGB(255, 155, 159, 208),
        ),
        children: <TextSpan>[
          TextSpan(
            text: "لم تتلقَ الرمز؟ ",
            style: TextStyle(color: Colors.black),
          ),
          TextSpan(
            text: "إعادة الإرسال",
            style: TextStyle(
              color: Color.fromARGB(255, 155, 159, 208),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Container(
      height: 60,
      width: 150,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 155, 159, 208),
        border: Border.all(
          color: const Color.fromARGB(255, 155, 159, 208),
          width: 2,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextButton(
        onPressed: () async {
          if (_isOtpFilled()) {
            try {
              PhoneAuthCredential credential = PhoneAuthProvider.credential(
                verificationId: verificationId,
                smsCode: _getOtp(),
              );
              final UserCredential userCredential =
                  await FirebaseAuth.instance.signInWithCredential(credential);

              _navigateToStoreDataPage(context, userCredential.user!);
            } catch (ex) {
              print(ex.toString());
              // Handle error
            }
          } else {
            // Handle error
          }
        },
        child: const Text(
          "تأكيد",
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
    );
  }

  bool _isOtpFilled() {
    return otpController1.text.isNotEmpty &&
        otpController2.text.isNotEmpty &&
        otpController3.text.isNotEmpty &&
        otpController4.text.isNotEmpty &&
        otpController5.text.isNotEmpty &&
        otpController6.text.isNotEmpty;
  }

  String _getOtp() {
    return otpController1.text.toString() +
        otpController2.text.toString() +
        otpController3.text.toString() +
        otpController4.text.toString() +
        otpController5.text.toString() +
        otpController6.text.toString();
  }

  void _navigateToStoreDataPage(BuildContext context, User user) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ImamPage(
            description: description,
            mosqueName: mosqueName,
            phoneNumber: phoneNumber,
            user: user),
      ),
    );
  }
}
