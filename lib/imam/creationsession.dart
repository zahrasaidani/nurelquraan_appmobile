import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ConfirmationPage extends StatelessWidget {
  const ConfirmationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirmation Page'),
      ),
      body: const SessionForm(),
    );
  }
}

class SessionForm extends StatefulWidget {
  const SessionForm({super.key});

  @override
  _SessionFormState createState() => _SessionFormState();
}

class _SessionFormState extends State<SessionForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late DateTime _startDate;
  late DateTime _endDate;
  late int _capacity;

  @override
  void initState() {
    super.initState();
    _startDate = DateTime.now();
    _endDate = DateTime.now().add(const Duration(days: 7));
    _capacity = 0;
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
              'Start Date',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () {
                _selectDate(context, true);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _startDate.toString(),
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'End Date',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () {
                _selectDate(context, false);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _endDate.toString(),
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Capacity',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter session capacity';
                }
                return null;
              },
              onSaved: (value) {
                _capacity = int.parse(value!);
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
                child: const Text('Create Session'),
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
      
      // Enregistrement de la session avec l'ID du mosque connecté
      await FirebaseFirestore.instance.collection('sessions').add({
        'mosqueId': mosqueId,
        'startDate': _startDate,
        'endDate': _endDate,
        'capacity': _capacity,
        'demands': [],
      });

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Session created successfully')));
      Navigator.pop(context); // Retour à la page précédente après la création de la session
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error: Mosque not authenticated')));
    }
  } catch (error) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error creating session: $error')));
  }
}

}



