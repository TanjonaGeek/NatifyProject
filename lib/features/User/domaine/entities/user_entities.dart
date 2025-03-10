import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String? name;
  final List<String>? nameParts;
  final String? nom;
  final String? prenom;
  final String? uid;
  final String? flag;
  final String? pays;
  final String? nationalite;
  final String? codeCountry;
  final String? profilePic;
  final bool? isOnline;
  final List<String>? groupId;
  final String? tokenNotification;
  final List<Map<String, dynamic>>? age;
  final String? sexe;
  final String? bio;
  final List<Map<String, dynamic>>? situationamoureux;
  final List<Map<String, dynamic>>? universite;
  final List<Map<String, dynamic>>? college;
  final List<Map<String, dynamic>>? emploi;
  final String? LastActivetime;
  final int? ageReel;
  final List<String>? abonnee;
  final List<String>? abonnement;
  final List<String>? invitation;
  final List<String>? friendBlocked;
  final GeoPoint? position;
  final bool hiddenPosition;
  final bool alertLocation;
  final bool alertPublication;
  final bool partageMedia;
  final List<String>? availableSendNotification;

  const UserEntity({
    required this.name,
    required this.nameParts,
    required this.nom,
    required this.prenom,
    required this.flag,
    required this.pays,
    required this.nationalite,
    required this.codeCountry,
    required this.uid,
    required this.profilePic,
    required this.isOnline,
    required this.groupId,
    required this.tokenNotification,
    required this.age,
    required this.sexe,
    required this.bio,
    required this.situationamoureux,
    required this.universite,
    required this.college,
    required this.emploi,
    required this.LastActivetime,
    required this.ageReel,
    required this.abonnee,
    required this.abonnement,
    required this.invitation,
    required this.friendBlocked,
    required this.position,
    required this.hiddenPosition,
    required this.alertLocation,
    required this.alertPublication,
    required this.partageMedia,
    required this.availableSendNotification,
  });

  @override
  List<Object?> get props {
    return [
      name,
      nameParts,
      nom,
      prenom,
      uid,
      flag,
      pays,
      nationalite,
      codeCountry,
      profilePic,
      isOnline,
      groupId,
      tokenNotification,
      age,
      sexe,
      bio,
      situationamoureux,
      universite,
      college,
      emploi,
      LastActivetime,
      ageReel,
      abonnee,
      abonnement,
      invitation,
      friendBlocked,
      position,
      hiddenPosition,
      alertLocation,
      alertPublication,
      partageMedia,
      availableSendNotification
    ];
  }
}
