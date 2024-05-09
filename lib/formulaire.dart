import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FormScreen extends StatefulWidget {
  @override
  _FormScreenState createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _nomController = TextEditingController();
  TextEditingController _prenomController = TextEditingController();
  TextEditingController _ageController = TextEditingController();
  TextEditingController _niveauScolaireController = TextEditingController();

  // Initialize Firebase
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 155, 159, 208),
        title: const Text(
          "استمارة تسجيل",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextFormField(
                controller: _nomController,
                decoration: InputDecoration(labelText: 'اللقب'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء ادخال اللقب ';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _prenomController,
                decoration: InputDecoration(labelText: 'الاسم'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء ادخال الاسم';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _ageController,
                decoration: InputDecoration(labelText: 'العمر'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال العمر';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _niveauScolaireController,
                decoration: InputDecoration(labelText: 'المستوى الدراسي'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال المستوى';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          // Store data in Firebase
                          _firestore.collection('demandes').add({
                            'nom': _nomController.text,
                            'prenom': _prenomController.text,
                            'age': int.parse(_ageController.text),
                            'niveauScolaire': _niveauScolaireController.text,
                          }).then((value) {
                            // Clear form fields after successful submission
                            _nomController.clear();
                            _prenomController.clear();
                            _ageController.clear();
                            _niveauScolaireController.clear();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('تم الإرسال بنجاح'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }).catchError((error) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('حدث خطأ أثناء الإرسال'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          });
                        }
                      },
                      child:
                          Text('إرسال', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        primary: Color.fromARGB(255, 155, 159, 208),
                      ),
                    ),
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Clear form fields
                        _nomController.clear();
                        _prenomController.clear();
                        _ageController.clear();
                        _niveauScolaireController.clear();
                      },
                      child: Text(
                        'إلغاء',
                        style: TextStyle(
                            color: Color.fromARGB(255, 155, 159, 208)),
                      ),
                      style: ElevatedButton.styleFrom(
                        primary: Colors.white,
                        onPrimary: Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
