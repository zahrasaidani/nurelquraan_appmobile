import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class addsessionPage extends StatelessWidget {
  const addsessionPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter une session'),
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
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 7));
  String _title = '';
  String _description = '';
  List<Map<String, dynamic>> _groups = [];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Champ de saisie pour le titre de la session
              Text('Titre', style: TextStyle(fontSize: 18)),
              SizedBox(height: 20),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Titre',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer le titre de la session';
                  }
                  return null;
                },
                onSaved: (value) {
                  _title = value!;
                },
              ),
              SizedBox(height: 20),
              // Champ de saisie pour la description de la session
              Text('Description', style: TextStyle(fontSize: 18)),
              SizedBox(height: 20),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer la description de la session';
                  }
                  return null;
                },
                onSaved: (value) {
                  _description = value!;
                },
              ),
              SizedBox(height: 20),
              // Sélection de la date de début
              Text('Date de début', style: TextStyle(fontSize: 18)),
              SizedBox(height: 20),
              InkWell(
                onTap: () => _selectDate(context, true),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(_startDate.toString(),
                      style: TextStyle(fontSize: 16)),
                ),
              ),
              SizedBox(height: 20),
              // Sélection de la date de fin
              Text('Date de fin', style: TextStyle(fontSize: 18)),
              SizedBox(height: 20),
              InkWell(
                onTap: () => _selectDate(context, false),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child:
                      Text(_endDate.toString(), style: TextStyle(fontSize: 16)),
                ),
              ),
              SizedBox(height: 20),
              // Section pour les groupes
              Text('Groupes', style: TextStyle(fontSize: 18)),
              SizedBox(height: 20),
              // Liste des formulaires de groupes
              Column(
                children: _groups.asMap().entries.map((entry) {
                  int index = entry.key;
                  Map<String, dynamic> group = entry.value;
                  return GroupForm(
                    group: group,
                    onRemove: () => _removeGroup(index),
                    onUpdate: (updatedGroup) =>
                        _updateGroup(index, updatedGroup),
                    onTeacherSelection: (selectedTeacherId) =>
                        _updateTeacher(index, selectedTeacherId),
                  );
                }).toList(),
              ),
              SizedBox(height: 20),
              // Bouton pour ajouter un groupe
              Center(
                child: ElevatedButton(
                  onPressed: _addGroup,
                  child: const Text('Ajouter un groupe'),
                ),
              ),
              SizedBox(height: 20),
              // Bouton pour enregistrer la session
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      _createSession(context);
                    }
                  },
                  child: const Text('Enregistrer'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Sélection de la date (début ou fin)
  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate : _endDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != (isStartDate ? _startDate : _endDate)) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  // Ajout d'un nouveau groupe
  void _addGroup() {
    setState(() {
      _groups.add({
        'name': '',
        'idEnseignant': '',
        'gender': '',
        'capacity': '',
        'age': '',
        'schedule': [],
      });
    });
  }

  // Suppression d'un groupe
  void _removeGroup(int index) {
    setState(() {
      _groups.removeAt(index);
    });
  }

  // Mise à jour des informations d'un groupe
  void _updateGroup(int index, Map<String, dynamic> updatedGroup) {
    setState(() {
      _groups[index] = updatedGroup;
    });
  }

  // Mise à jour de l'enseignant sélectionné pour un groupe
  void _updateTeacher(int index, String? selectedTeacherId) {
    setState(() {
      _groups[index]['idEnseignant'] = selectedTeacherId;
    });
  }

  // Création d'une nouvelle session dans Firestore
  void _createSession(BuildContext context) async {
    try {
      // Vérifier si des groupes ont été ajoutés
      if (_groups.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
                'Veuillez ajouter au moins un groupe avant de créer la session')));
        return;
      }

      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        String mosqueId = currentUser.uid;

        // Ajouter la session et obtenir la référence du document
        DocumentReference sessionRef =
            await FirebaseFirestore.instance.collection('sessions').add({
          'mosqueId': mosqueId,
          'startDate': _startDate,
          'endDate': _endDate,
          'title': _title,
          'description': _description,
        });

        // Ajouter l'ID de la session dans le document
        await sessionRef.update({'idSession': sessionRef.id});

        CollectionReference groupsRef = sessionRef.collection('groups');

        // Ajouter les groupes à la session
        for (var group in _groups) {
          DocumentReference groupRef = await groupsRef.add({
            'name': group['name'],
            'gender': group['gender'],
            'capacity': group['capacity'],
            'age': group['age'],
            'enseignants': group['idEnseignant'],
            'schedule': group['schedule'],
          });

          // Ajouter l'ID du groupe dans le document
          await groupRef.update({'idGroupe': groupRef.id});
        }

        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Session créée avec succès')));
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Erreur : Mosquée non authentifiée')));
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Erreur lors de la création de la session : $error')));
    }
  }
}

class GroupForm extends StatefulWidget {
  final Map<String, dynamic> group;
  final VoidCallback onRemove;
  final Function(Map<String, dynamic>) onUpdate;
  final Function(String?) onTeacherSelection;

  const GroupForm(
      {Key? key,
      required this.group,
      required this.onRemove,
      required this.onUpdate,
      required this.onTeacherSelection})
      : super(key: key);

  @override
  _GroupFormState createState() => _GroupFormState();
}

class _GroupFormState extends State<GroupForm> {
  late TextEditingController _nameController;
  late TextEditingController _genderController;
  late TextEditingController _capacityController;
  late TextEditingController _ageController;
  late TextEditingController _scheduleController;
  List<Map<String, dynamic>> _enseignants = [];
  String? _selectedEnseignantId;

  @override
  void initState() {
    super.initState();
    // Initialisation des contrôleurs de texte avec les valeurs initiales du groupe
    _nameController = TextEditingController(text: widget.group['name']);
    _genderController = TextEditingController(text: widget.group['gender']);
    _capacityController = TextEditingController(text: widget.group['capacity']);
    _ageController = TextEditingController(text: widget.group['age']);
    _scheduleController =
        TextEditingController(text: widget.group['schedule'].join(', '));
    _fetchEnseignants();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _genderController.dispose();
    _capacityController.dispose();
    _ageController.dispose();
    _scheduleController.dispose();
    super.dispose();
  }

  Future<void> _fetchEnseignants() async {
    try {
      List<Map<String, dynamic>> enseignants =
          await _fetchEnseignantsFromFirestore();
      setState(() {
        _enseignants = enseignants;
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:
              Text('Erreur lors de la récupération des enseignants : $error')));
    }
  }

  Future<List<Map<String, dynamic>>> _fetchEnseignantsFromFirestore() async {
    // Récupération de l'ID du mosque
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      String mosqueId = currentUser.uid;

      // Récupération des enseignants associés au mosqueId
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('enseignants')
          .where('mosqueId', isEqualTo: mosqueId)
          .get();

      // Conversion des documents Firestore en une liste de Map
      return querySnapshot.docs
          .map((doc) => {
                'id': doc.id,
                'nom': doc['nom'],
                'prenom': doc['prenom'],
              })
          .toList();
    } else {
      // Gestion de l'absence de l'utilisateur connecté
      throw Exception('Utilisateur non authentifié');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Champ de saisie pour le nom du groupe
        TextFormField(
          controller: _nameController,
          decoration: InputDecoration(
            labelText: 'Nom du groupe',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            widget.onUpdate({...widget.group, 'name': value});
          },
        ),
        SizedBox(height: 20),
// Champ de saisie pour le genre du groupe
        TextFormField(
          controller: _genderController,
          decoration: InputDecoration(
            labelText: 'Genre (garçon/fille)',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            widget.onUpdate({...widget.group, 'gender': value});
          },
        ),
        SizedBox(height: 20),
// Champ de saisie pour la capacité du groupe
        TextFormField(
          controller: _capacityController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Capacité',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            widget.onUpdate({...widget.group, 'capacity': value});
          },
        ),
        SizedBox(height: 20),
// Champ de saisie pour l'âge autorisé dans le groupe
        TextFormField(
          controller: _ageController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Âge autorisé',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            widget.onUpdate({...widget.group, 'age': value});
          },
        ),
        SizedBox(height: 20),
// Champ de saisie pour l'emploi du temps du groupe
        TextFormField(
          controller: _scheduleController,
          decoration: InputDecoration(
            labelText: 'Emploi du temps',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            widget.onUpdate({...widget.group, 'schedule': value.split(', ')});
          },
        ),
        SizedBox(height: 20),
// Champ de sélection pour l'enseignant
        DropdownButtonFormField<String>(
          value: _selectedEnseignantId,
          items: _enseignants.map((enseignant) {
            return DropdownMenuItem<String>(
              value: enseignant['id'],
              child: Text('${enseignant['nom']} ${enseignant['prenom']}'),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedEnseignantId = value;
            });
            // Mise à jour du groupe avec l'enseignant sélectionné
            widget.onTeacherSelection(value);
          },
          decoration: InputDecoration(
            labelText: 'Enseignant',
            border: OutlineInputBorder(),
          ),
        ),
        SizedBox(height: 20),
// Bouton pour supprimer le groupe
        ElevatedButton(
          onPressed: widget.onRemove,
          child: Text('Supprimer ce groupe'),
        ),
        Divider(),
      ],
    );
  }
}
