import 'package:natify/features/User/presentation/provider/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

class ProfileDetailPage extends ConsumerWidget {
  final String uid;
  const ProfileDetailPage({super.key, required this.uid});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
        body: FutureBuilder(
            future: Future.delayed(Duration(milliseconds: 500), () {
              return ref.read(infoUserStateNotifier.notifier).getInfoUser(uid);
            }),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                    child: CircularProgressIndicator(
                  color: Colors.black,
                ));
              } else if (snapshot.hasError) {
                return Center(
                    child: Text(
                        'Erreur : ${snapshot.error}')); // Gérer les erreurs
              } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                final users = snapshot.data!;
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          alignment: WrapAlignment.spaceBetween,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 16.0,
                          children: [
                            Text(
                              "Uid #${users.first.uid}",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 24),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                // Logique pour supprimer le compte
                                print(
                                    "Suppression du compte UID: ${users.first.uid}");
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors
                                    .red, // Couleur rouge pour indiquer une action dangereuse
                                padding: EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                              ),
                              child: Text(
                                "Supprimer ce compte",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        // Header Section
                        Card(
                          elevation: 1,
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Stack(
                                  children: [
                                    ClipOval(
                                      child: CachedNetworkImage(
                                        key: ValueKey(
                                            users.first.profilePic.toString()),
                                        imageUrl:
                                            users.first.profilePic.toString(),
                                        placeholder: (context, url) {
                                          return Shimmer.fromColors(
                                            key: ValueKey(users.first.profilePic
                                                .toString()),
                                            baseColor: Colors.grey[300]!,
                                            highlightColor: Colors.grey[100]!,
                                            child: ClipOval(
                                              child: Container(
                                                width: 100,
                                                height: 100,
                                                decoration: BoxDecoration(
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                        errorWidget: (context, url, error) =>
                                            Icon(Icons.error),
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Positioned(
                                        bottom: 0,
                                        left: 2,
                                        child: Container(
                                          child: Text(
                                            users.first.flag.toString(),
                                            style: TextStyle(fontSize: 16),
                                          ),
                                        ))
                                  ],
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        users.first.name.toString(),
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(users.first.bio.toString()),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        // Personal Information Section
                        SectionCard(
                          title: 'Information personnel',
                          onEdit: () {
                            // Add edit functionality
                          },
                          children: [
                            InfoRow(
                                label: 'Nom',
                                value: users.first.nom.toString()),
                            InfoRow(
                                label: 'Prenom',
                                value: users.first.prenom.toString()),
                            InfoRow(
                                label: 'Genre',
                                value: users.first.sexe.toString()),
                            InfoRow(
                                label: 'Age',
                                value: users.first.ageReel == 0
                                    ? "Aucun"
                                    : "${users.first.ageReel.toString()} ans"),
                          ],
                        ),
                        SizedBox(height: 16),
                        // Address Section
                        SectionCard(
                          title: 'Adresse',
                          onEdit: () {
                            // Add edit functionality
                          },
                          children: [
                            InfoRow(
                                label: 'Pays',
                                value: users.first.pays.toString()),
                            InfoRow(
                                label: 'Nationalite',
                                value: users.first.nationalite.toString()),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              } else {
                return Center(
                    child: Container(
                  child: Text('Aucun utilisateur'),
                ));
              }
            }));
  }
}

class SectionCard extends StatelessWidget {
  final String title;
  final VoidCallback onEdit;
  final List<Widget> children;

  const SectionCard({super.key, 
    required this.title,
    required this.onEdit,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // IconButton(
                //   icon: Icon(Icons.edit),
                //   onPressed: onEdit,
                // ),
              ],
            ),
            Divider(),
            ...children,
          ],
        ),
      ),
    );
  }
}

class InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const InfoRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
