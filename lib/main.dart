// ignore_for_file: prefer_const_constructors, unused_import, use_key_in_widget_constructors, duplicate_import

import 'package:firebase_core/firebase_core.dart';
import 'package:firstproject/formulaire.dart';
import 'package:firstproject/imam/myhomescreenimam.dart';
import 'package:firstproject/imam/registerationformimam.dart';
import 'package:firstproject/listemosques.dart';
import 'package:firstproject/otp_verification_screen.dart';
import 'package:firstproject/registrationform.dart';
import 'package:firstproject/screens/MyHomeScreen.dart';
import 'package:firstproject/screens/SettingsScreen.dart';
import 'package:firstproject/screens/publicationscreen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firstproject/phoneauth.dart';
import 'homepage.dart'; // إضافة هذه الاستيرادات إذا لزم الأمر
import 'otpscreen.dart';
import 'phoneauth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
            apiKey: "AIzaSyD3yENJORbRRLXkkmBpTsrHg6uXf9oXzIE",
            appId: "1:134666020978:web:d86be34eda892d10b0baeb",
            messagingSenderId: "134666020978",
           projectId: "first-project-72265",)
  );
  runApp(MyApp());
}

class GreetingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // إضافة الصورة هنا
            Image.asset(
              'lib/images/greetImg.png', // تأكد من أن مسار الصورة صحيح
              height: 300, // ارتفاع الصورة الجديد
              width: 300, // عرض الصورة الجديد
            ),
            const SizedBox(height: 20),
            const Text(
              'ابحث عن مسجدك',
              style: TextStyle(
                fontSize: 24,
                color: Color(0xFF8B70FD), // تغيير اللون هنا
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // انتقل إلى الصفحة الرئيسية
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => RegistrationFormImam()),
                );
              },
              child: Text('ابدأ الآن'),
            ),
          ],
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child ?? Container(),
        );
      },
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: GreetingScreen(),
    );
  }
}
