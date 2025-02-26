import 'package:natify/features/User/data/models/user_model.dart';
import 'package:natify/features/User/presentation/widget/list/shimmer/shimmerLoading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:loadmore_listview/loadmore_listview.dart';
import 'package:cached_network_image/cached_network_image.dart';

class SpectateurHighLightPage extends StatefulWidget {
  final List quivoirHighLight;
  final String photoUrl; 

  const SpectateurHighLightPage({
    super.key, 
    required this.quivoirHighLight, 
    required this.photoUrl,
  });

  @override
  State<SpectateurHighLightPage> createState() => _SpectateurHighLightPageState();
}

class _SpectateurHighLightPageState extends State<SpectateurHighLightPage> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> listData = [];
  bool isLoading = true;

  Future<void> fetchSpectatorsData(List quivoirHiglight, String photoUrl) async {
    try {
      var data = quivoirHiglight.where((story) => story['photoUrl'] == photoUrl).toList();
      List<Map<String, dynamic>> list = [];

      for (var toElement in data) {
        String uid = toElement['uid'];
        try {
          final userDataSnapshot = await firestore.collection('users').doc(uid).get();
          if (userDataSnapshot.exists && userDataSnapshot.data() != null) {
            final userData = UserModel.fromJson(userDataSnapshot.data()!);
            list.add({
              "photoUrl": userData.profilePic ?? '',
              "nom": userData.name ?? '',
            });
          } else {
            // Handle case where user data is not found or is null
            print("User data not found for UID: $uid");
          }
        } catch (e) {
          print("Failed to fetch user data for UID: $uid, Error: $e");
        }
      }

      setState(() {
        listData = list;
        isLoading = false;
      });
    } catch (e) {
      print("Failed to fetch spectators data: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchSpectatorsData(widget.quivoirHighLight, widget.photoUrl);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Liste des Spectateurs', style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
            icon: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(30))
              ),
              child: Center(child: FaIcon(FontAwesomeIcons.chevronLeft,size:20,color:Colors.black))),
            onPressed: () {
              // Action for the back button
              Navigator.pop(context);
            },
          ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Découvrez qui a consulté votre highlight et suivez l'engagement de vos spectateurs",
              style: TextStyle(
                fontSize: 16.0,
                color: Colors.black45,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20.0),
            Expanded(
              child: isLoading
                  ? Shimmerloading(length: 1,horz: 1.0,vert: 8.0,)
                  : listData.isEmpty 
                  ?
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 140,
                        height: 140,
                        child: Image.asset('assets/notFoundXl.png'),
                      ),
                      SizedBox(height: 10),
                      Text(
                        textAlign: TextAlign.center,
                        "Pas encore de vues ! ",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                      SizedBox(height: 4),
                      Text(
                         textAlign: TextAlign.center,
                        "Soyez le premier à visionner cette highlight",
                        style: TextStyle(fontWeight: FontWeight.w400, fontSize: 17),
                      ),
                    ],
                    )
                    : 
                   LoadMoreListView.builder(
                      hasMoreItem: true,
                      refreshBackgroundColor: Colors.blueAccent,
                      refreshColor: Colors.white,
                      loadMoreWidget: ShimmerListTile(horz: 1, vert: 8.0),
                      itemCount: listData.length,
                      itemBuilder: (context, index) {
                        final item = listData[index];
                        return GestureDetector(
                          onTap: () => Navigator.pop(context, item),
                          child: _buildOption(
                            urlPhoto: item['photoUrl'],
                            nom: item['nom'],
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

  Widget _buildOption({
    required String urlPhoto,
    required String nom,
  }) {
    return ListTile(
      leading: CachedNetworkImage(
        imageUrl: urlPhoto,
        imageBuilder: (context, imageProvider) => Container(
          height: 40.0,
          width: 40.0,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            image: DecorationImage(
              image: imageProvider,
              fit: BoxFit.cover,
            ),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey),
          ),
        ),
        placeholder: (context, url) => Container(
          height: 40.0,
          width: 40.0,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          height: 40.0,
          width: 40.0,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey),
          ),
          child: Icon(Icons.error, color: Colors.red),
        ),
      ),
      title: Text(nom),
      contentPadding: const EdgeInsets.symmetric(vertical: 1.0, horizontal: 7.0),
    );
  }
}
