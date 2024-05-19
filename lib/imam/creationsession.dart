import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ConfirmationPage extends StatelessWidget {
  const ConfirmationPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('اضافة منشور'),
      ),
      body: const SessionForm(),
    );
  }
}

class SessionForm extends StatefulWidget {
  const SessionForm({Key? key}) : super(key: key);

  @override
  _SessionFormState createState() => _SessionFormState();
}

class _SessionFormState extends State<SessionForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late DateTime _startDate;
  late DateTime _endDate;
  late int _capacity;
  late String _title;
  late String _description;

  @override
  void initState() {
    super.initState();
    _startDate = DateTime.now();
    _endDate = DateTime.now().add(const Duration(days: 7));
    _capacity = 0;
    _title = '';
    _description = '';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'تاريخ الفتح',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () {
                _selectDate(context, true);
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _startDate.toString().split(' ')[0],
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'تاريخ الاغلاق',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () {
                _selectDate(context, false);
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _endDate.toString().split(' ')[0],
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'سعة',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'الرجاء ادخل السعة الجلسة';
                }
                if (int.tryParse(value) == null) {
                  return 'الرجاء إدخال رقم صالح';
                }
                return null;
              },
              onSaved: (value) {
                _capacity = int.parse(value!);
              },
            ),
            const SizedBox(height: 20),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'عنوان',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'الرجاء إدخال عنوان الجلسة';
                }
                return null;
              },
              onSaved: (value) {
                _title = value!;
              },
            ),
            const SizedBox(height: 20),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'وصف',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'الرجاء إدخال وصف الجلسة';
                }
                return null;
              },
              onSaved: (value) {
                _description = value!;
              },
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    createSession(context);
                  }
                },
                child: const Text('انشاء جلسة'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate : _endDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (pickedDate != null) {
      setState(() {
        if (isStartDate) {
          _startDate = pickedDate;
        } else {
          _endDate = pickedDate;
        }
      });
    }
  }

  void createSession(BuildContext context) async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        String mosqueId = currentUser.uid;

        // Add a new document to the 'sessions' collection with an automatically generated unique identifier
        DocumentReference sessionRef =
            await FirebaseFirestore.instance.collection('sessions').add({
          'mosqueId': mosqueId,
          'title': _title,
          'description': _description,
          'startDate': _startDate,
          'endDate': _endDate,
          'capacity': _capacity,
        });

        // Retrieve the ID of the added document (sessionId)
        String sessionId = sessionRef.id;

        // Update the document with the session ID
        await sessionRef.update({'sessionId': sessionId});

        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم إنشاء الجلسة بنجاح')));

        // Navigate back to the previous page
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('خطأ: المسجد غير مصدق')));
      }
    } catch (error) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('خطأ في إنشاء الجلسة: $error')));
    }
  }
}
