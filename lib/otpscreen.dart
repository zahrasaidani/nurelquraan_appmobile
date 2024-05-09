// ignore_for_file: unused_local_variable

import 'dart:developer';

import 'package:firstproject/screens/MyHomeScreen.dart';
import 'package:firstproject/screens/SettingsScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Otp0 extends StatefulWidget {
  final String verificationId;
  final String phoneNumber;
  final String fullName;

  const Otp0({
    Key? key,
    required this.verificationId,
    required this.phoneNumber,
    required this.fullName,
  }) : super(key: key);

  @override
  State<Otp0> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<Otp0> {
  final TextEditingController otpController1 = TextEditingController();
  final TextEditingController otpController2 = TextEditingController();
  final TextEditingController otpController3 = TextEditingController();
  final TextEditingController otpController4 = TextEditingController();
  final TextEditingController otpController5 = TextEditingController();
  final TextEditingController otpController6 = TextEditingController();

  Future<void> _storeUserData() async {
    try {
      await FirebaseAuth.instance.currentUser
          ?.updateDisplayName(widget.fullName);
      CollectionReference parents =
          FirebaseFirestore.instance.collection('parents');

      // Vérifier si le parent existe déjà avec le même numéro de téléphone et nom complet
      QuerySnapshot querySnapshot = await parents
          .where('phoneNumber', isEqualTo: widget.phoneNumber)
          .where('fullName', isEqualTo: widget.fullName)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Si le parent existe déjà avec les mêmes informations, ne pas l'enregistrer une deuxième fois
        print('Le parent existe déjà dans la base de données.');
      } else {
        // Sinon, ajouter le nouveau parent
        await parents.add({
          'fullName': widget.fullName,
          'phoneNumber': widget.phoneNumber,
        });
      }
    } catch (e) {
      print("Erreur lors de l'enregistrement des données utilisateur : $e");
    }
  }

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
      body: Column(
        children: [
          const SizedBox(height: 30),
          _buildVerificationCodeSection(),
          const SizedBox(height: 15),
          _buildCodeInputFields(context),
          const SizedBox(height: 20),
          _buildActionButtons(),
          const SizedBox(height: 10),
          _buildResendCodeText(),
          Spacer(),
        ],
      ),
    );
  }

  Widget _buildVerificationCodeSection() {
    return Container(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "تحقق من رمز OTP",
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 23,
            ),
          ),
          const Text(
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
        _buildOTPTextField(otpController1),
        _buildOTPTextField(otpController2),
        _buildOTPTextField(otpController3),
        _buildOTPTextField(otpController4),
        _buildOTPTextField(otpController5),
        _buildOTPTextField(otpController6),
      ],
    );
  }

  Widget _buildOTPTextField(TextEditingController controller) {
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
        style: Theme.of(context).textTheme.headline6,
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
            borderSide: BorderSide(
              color: const Color.fromARGB(255, 155, 159, 208),
              width: 2,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: const Color.fromARGB(255, 155, 159, 208),
              width: 2,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResendCodeText() {
    return RichText(
      text: TextSpan(
        style: const TextStyle(
          fontSize: 16,
          color: Color.fromARGB(255, 155, 159, 208),
        ),
        children: <TextSpan>[
          const TextSpan(
            text: "لم تتلقَ الرمز؟ ",
            style: TextStyle(color: Colors.black),
          ),
          const TextSpan(
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

  Widget _buildActionButtons() {
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
          try {
            PhoneAuthCredential credential = PhoneAuthProvider.credential(
                verificationId: widget.verificationId,
                smsCode: otpController1.text.toString() +
                    otpController2.text.toString() +
                    otpController3.text.toString() +
                    otpController4.text.toString() +
                    otpController5.text.toString() +
                    otpController6.text.toString());
            final UserCredential userCredential =
                await FirebaseAuth.instance.signInWithCredential(credential);

            await _storeUserData(); // Store user data in Firestore

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MyHomeScreen(),
              ),
            );
          } catch (ex) {
            log(ex.toString());
          }
        },
        child: const Text(
          "تأكيد",
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
    );
  }
}
