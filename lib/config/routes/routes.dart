import 'package:natify/features/Admin/admin_panel.dart';
import 'package:natify/features/Admin/section/dashboard.dart';
import 'package:natify/features/Admin/section/detailProfileUser.dart';
import 'package:natify/features/Admin/section/listAllUser.dart';
import 'package:natify/features/Admin/section/reportedUserPageAll.dart';
import 'package:natify/features/Admin/section/reportedUserPageGroupEnAttente.dart';
import 'package:natify/features/Admin/section/reportedUserPageGroupTraite.dart';
import 'package:natify/features/User/presentation/pages/auth/AuthUserPage.dart';
import 'package:flutter/material.dart';

class Routes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/admin':
        return MaterialPageRoute(
            builder: (_) => AdminPanel(
                route: "/admin",
                body: Center(
                  child: Text('Bienvenue sur le Espace Administrateur'),
                )));
      case '/admin/dashboard':
        return MaterialPageRoute(
            builder: (_) =>
                AdminPanel(route: "/admin/dashboard", body: Dashboard()));
      case '/admin/reported-users/group/traite':
        return MaterialPageRoute(
            builder: (_) => AdminPanel(
                route: "/admin/reported-users/group/traite",
                body: ReporteduserGrouppageTraite()));
      case '/admin/reported-users/group/en-attente':
        return MaterialPageRoute(
            builder: (_) => AdminPanel(
                route: "/admin/reported-users/group/en-attente",
                body: ReporteduserGrouppageAttente()));
      case '/admin/reported-users/all':
        return MaterialPageRoute(
            builder: (_) => AdminPanel(
                route: "/admin/reported-users/all",
                body: ReporteduserAllpage()));
      case '/admin/users':
        return MaterialPageRoute(
            builder: (_) =>
                AdminPanel(route: "/admin/users", body: ListAllUserpage()));
      case '/admin/users/detail/profile':
        final args = settings.arguments
            as Map<String, dynamic>?; // Récupération des arguments
        final uid = args?['uid']; // Extraction du UID
        return MaterialPageRoute(
            builder: (_) => AdminPanel(
                route: "/admin/users/detail/profile",
                body: ProfileDetailPage(
                  uid: uid,
                )));
      default:
        return MaterialPageRoute(builder: (_) => AuthUserPage());
    }
  }
}
