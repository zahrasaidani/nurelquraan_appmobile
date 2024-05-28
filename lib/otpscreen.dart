import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firstproject/phoneauth.dart';
import 'package:firstproject/screens/MyHomeScreen.dart';
import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

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
  final TextEditingController otpController = TextEditingController();
  bool _isVerifying = false;
  bool _isButtonEnabled = false;

  @override
  void dispose() {
    otpController.dispose();
    super.dispose();
  }

  Future<void> _storeUserData() async {
    final User? currentUser = FirebaseAuth.instance.currentUser;
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    if (currentUser == null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => PhoneAuth()),
      );
      return;
    }

    try {
      String? id = await getToken();
      final userId = currentUser.uid;
      final existingUser = await FirebaseFirestore.instance
          .collection("parents")
          .where("phoneNumber", isEqualTo: widget.phoneNumber)
          .get();

      if (existingUser.docs.isEmpty) {
        await FirebaseFirestore.instance.collection("parents").doc(userId).set({
          "fullName": widget.fullName,
          "phoneNumber": widget.phoneNumber,
          "idParent": userId,
          "token": id,
        });
      }
    } on FirebaseException catch (firebaseError) {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Erreur Firebase: $firebaseError')),
      );
    } catch (error) {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Erreur inconnue: $error')),
      );
    }
  }

  Future<void> _verifyOtp() async {
    setState(() {
      _isVerifying = true;
    });
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: widget.verificationId, smsCode: otpController.text);
      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      await _storeUserData();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MyHomeScreen(),
        ),
      );
    } catch (ex) {
      print(ex.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('خطأ في التحقق من رمز')),
      );
    } finally {
      setState(() {
        _isVerifying = false;
      });
    }
  }

  void _onOtpChanged(String value) {
    setState(() {
      _isButtonEnabled = value.length == 6;
    });
    if (value.length == 6) {
      _verifyOtp();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF9B9FD0),
        title: const Text(
          "OTP",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 30),
                _buildLogoSection(),
                const SizedBox(height: 30),
                _buildVerificationCodeSection(),
                const SizedBox(height: 20),
                _buildCodeInputFields(context),
                const SizedBox(height: 20),
                _buildActionButtons(),
                const SizedBox(height: 30),
              ],
            ),
          ),
          if (_isVerifying)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLogoSection() {
    return Center(
      child: Image.asset(
        'lib/assets/images/logo.png',
        height: 100,
      ),
    );
  }

  Widget _buildVerificationCodeSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            "تحقق من رمز",
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 23,
            ),
          ),
          SizedBox(height: 10),
          Text(
            "لقد أرسلنا رسالة نصية قصيرة برمز تفعيل إلى هاتفك",
            style: TextStyle(
              fontWeight: FontWeight.normal,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCodeInputFields(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: PinCodeTextField(
        appContext: context,
        length: 6,
        obscureText: false,
        animationType: AnimationType.fade,
        pinTheme: PinTheme(
          shape: PinCodeFieldShape.box,
          borderRadius: BorderRadius.circular(10),
          fieldHeight: 50,
          fieldWidth: 40,
          activeFillColor: Colors.white,
          inactiveFillColor: Colors.grey.shade200,
          selectedFillColor: Colors.white,
          activeColor: const Color.fromARGB(255, 155, 159, 208),
          inactiveColor: Colors.grey.shade400,
          selectedColor: const Color.fromARGB(255, 155, 159, 208),
        ),
        animationDuration: const Duration(milliseconds: 300),
        backgroundColor: Colors.transparent,
        enableActiveFill: true,
        controller: otpController,
        onCompleted: (v) {
          print("مكتمل");
          _verifyOtp();
        },
        onChanged: _onOtpChanged,
        beforeTextPaste: (text) {
          print("السماح باللصق $text");
          return true;
        },
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: _isButtonEnabled
            ? const Color.fromARGB(255, 155, 159, 208)
            : Colors.grey,
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextButton(
        onPressed: _isButtonEnabled && !_isVerifying ? _verifyOtp : null,
        child: const Text(
          "تأكيد",
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
    );
  }

  Future<String?> getToken() async {
    final _firebaseMessaging = FirebaseMessaging.instance;
    String? token = await _firebaseMessaging.getToken();
    await _firebaseMessaging.requestPermission();
    print("token : $token");
    return token;
  }
}
