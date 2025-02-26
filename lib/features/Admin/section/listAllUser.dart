import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:natify/core/utils/colors.dart';

class ListAllUserpage extends StatelessWidget {
  const ListAllUserpage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
                  'Liste des utilisateurs',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: SizedBox.shrink(),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: "Rechercher un utilisateur par nom",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
              ),
            ),
            SizedBox(height: 16.0),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('users').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: Text('Chargement ...'));
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Aucun utilisateur trouvé.',
                        style: TextStyle(fontSize: 16),
                      ),
                    );
                  }

                  final users = snapshot.data!.docs;

                  // Génération des lignes DataRow dynamiques
                  final List<DataRow> rows = users.map((user) {
                    final data = user.data() as Map<String, dynamic>;
                    final status = (data['nom'] == "" && data['prenom'] == "" && data['sexe'] == ""  && data['nationalite'] == "" && data['pays'] == "")  ? '' : "verifier";
                    return DataRow(cells: [
                      DataCell(Text(data["name"] ?? "Aucun nom")),
                      DataCell(Text(data["sexe"] ?? "Aucun genre")),
                      DataCell(Text(data["pays"] ?? "Aucun pays")),
                      DataCell(Text(data["nationalite"] ?? "Aucune nationalite")),
                      DataCell(
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                          decoration: BoxDecoration(
                            color: status == "verifier" ? Colors.green[100] : Colors.red[100],
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                          child: Text(
                            status == 'verifier' ? status : "Non verifier",
                            style: TextStyle(
                              color: status == "verifier" ? Colors.green[800] : Colors.red[800],
                            ),
                          ),
                        ),
                      ),
                      DataCell(
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  child:  ElevatedButton(
                                    onPressed: () {
                                     Navigator.of(context).pushNamed("/admin/users/detail/profile",arguments: {'uid': data["uid"]});
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: kPrimaryColor, // Couleur rouge pour indiquer une action dangereuse
                                      padding: EdgeInsets.symmetric(horizontal: 7, vertical: 10),
                                    ),
                                    child: Text(
                                      "Consulter",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                    ]);
                  }).toList();

                  // Retourner le tableau avec des colonnes statiques
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal, // Pour permettre le défilement horizontal
                    child: DataTable(
                      columns: [
                        DataColumn(label: Text("Nom")),
                        DataColumn(label: Text("Genre")),
                        DataColumn(label: Text("Pays")),
                        DataColumn(label: Text("Nationalite")),
                        DataColumn(label: Text("Statut")),
                        DataColumn(label: Text("")),
                      ],
                      rows: rows, // Lignes dynamiques générées
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
