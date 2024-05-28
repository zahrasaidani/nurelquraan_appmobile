import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firstproject/imam/registerationformimam.dart';
import 'package:flutter/material.dart';
late String x;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: FirebaseOptions(
    apiKey: "AIzaSyD3yENJORbRRLXkkmBpTsrHg6uXf9oXzIE",
    appId: "1:134666020978:web:d86be34eda892d10b0baeb",
    messagingSenderId: "134666020978",
    projectId: "first-project-72265",
  ));
  await firebaseApi().init();
final fr = FirebaseMessaging.instance;
    final fmct = await fr.getToken();
    x=fmct!;
    print('Token $fmct');
    
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
            Image.asset(
              'lib/images/greetImg.png',
              height: 300,
              width: 300,
            ),
            const SizedBox(height: 20),
            const Text(
              'ابحث عن مسجدك',
              style: TextStyle(
                fontSize: 24,
                color: Color(0xFF8B70FD),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
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

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       builder: (context, child) {
//         return Directionality(
//           textDirection: TextDirection.rtl,
//           child: child ?? Container(),
//         );
//       },
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//         visualDensity: VisualDensity.adaptivePlatformDensity,
//       ),
//       home: GreetingScreen(),
//     );
//   }
// }

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Flutter Widget Example'),
        ),
        body: Center(
          child: TitleWidget(title: x),
        ),
      ),
    );
  }
}

class TitleWidget extends StatelessWidget {
  final String title;

  TitleWidget({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(fontSize: 24),
    );
  }
}
class firebaseApi {
  final fr = FirebaseMessaging.instance;
  Future<void> init() async {
    final fmct = await fr.getToken();
    print('Token $fmct');
  }
}
