import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shimmer/shimmer.dart';

class Shimmerloading extends StatelessWidget {
  final int length;
  final double horz;
  final double vert;
  const Shimmerloading({super.key, required this.length, required this.horz, required this.vert});

  @override
  Widget build(BuildContext context) {
   return ListView.builder(
      itemCount: length,
      itemBuilder: (context, index) {
        return ShimmerListTile(horz: horz,vert:vert,);
      },
    );
  }
}

class ShimmerListTile extends StatelessWidget {
  final double horz;
  final double vert;
  const ShimmerListTile({
    super.key, required this.horz, required this.vert,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: horz, vertical: vert),
        leading: CircleAvatar(
          backgroundColor: Colors.grey,
          radius: 24.0,
        ),
        title: Container(
          color: Colors.grey,
          height: 16.0,
          width: double.infinity,
        ),
        subtitle: Container(
          color: Colors.grey,
          height: 14.0,
          width: double.infinity,
        ),
        trailing:  IconButton(
                              onPressed: (){},
                              icon: Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  color: Colors.grey,
                                  borderRadius: BorderRadius.all(Radius.circular(30))
                                ),
                                child: Center(
                                  child: FaIcon(FontAwesomeIcons.filter,size: 15),
                                ))
                            ),
      ),
    );
  }
}