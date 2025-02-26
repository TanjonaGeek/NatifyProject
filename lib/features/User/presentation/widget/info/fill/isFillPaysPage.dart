import 'package:natify/core/utils/helpers.dart';
import 'package:natify/core/utils/widget/paysListPage.dart';
import 'package:natify/features/HomeScreen.dart';
import 'package:natify/features/User/presentation/provider/user_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Isfillpayspage extends ConsumerStatefulWidget {
  const Isfillpayspage({super.key});

  @override
  _IsfillpayspageState createState() => _IsfillpayspageState();
}

class _IsfillpayspageState extends ConsumerState<Isfillpayspage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _paysController = TextEditingController();
  final List<Map<String, String>> listPays = Helpers.ListeNationaliteHelper;
  void _openPaysPage() async {
    final selectedPays = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaysListPage(listPays: listPays),
      ),
    );
    if (selectedPays != null) {
      setState(() {
        _paysController.text = selectedPays['country'] ?? '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          "Indiquez-nous votre pays",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
          ),
          onPressed: () {
            // Action for the back button
          },
        ),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Veuillez sélectionner votre pays en tapant sur le champ.",
                style: TextStyle(
                  fontSize: 16.0,
                ),
              ),
              SizedBox(height: 20.0),
              Expanded(
                child: ListView(
                  physics: NeverScrollableScrollPhysics(),
                  children: [
                    _buildPaysInput(),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Si le formulaire est valide, afficher un message ou exécuter une action
                    ref.read(infoUserStateNotifier.notifier).updateInfoUser(
                        FirebaseAuth.instance.currentUser!.uid,
                        'pays',
                        _paysController.text.trim(),
                        '');
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => HomeScreen(
                                index: 0,
                              )),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF2596be),
                  minimumSize: Size(double.infinity, 50), // Button size
                ),
                child: Text(
                  "Terminer",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaysInput() {
    return TextFormField(
      onTap: () => _openPaysPage(),
      readOnly: true,
      controller: _paysController,
      keyboardType: TextInputType.text,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Veuillez selectionner votre pays';
        }
        return null;
      },
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0), // Bordure arrondie
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color:
                Colors.black54, // Couleur de la bordure lorsqu'il est en focus
            width: 2.0, // Épaisseur de la bordure
          ),
          borderRadius:
              BorderRadius.circular(8.0), // Garder le même border radius
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.red, // Couleur de la bordure lorsqu'il est en focus
            width: 2.0, // Épaisseur de la bordure
          ),
          borderRadius:
              BorderRadius.circular(8.0), // Garder le même border radius
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        labelText: 'Pays',
        labelStyle: TextStyle(color: Colors.black54),
        hintText: 'Choisissez votre pays',
        hintStyle: TextStyle(color: Colors.black54),
      ),
    );
  }
}
