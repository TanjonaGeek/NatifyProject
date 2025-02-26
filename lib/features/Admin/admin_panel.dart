import 'package:flutter/material.dart';
import 'package:flutter_admin_scaffold/admin_scaffold.dart';
import 'package:natify/core/utils/colors.dart';

class AdminPanel extends StatefulWidget {
  final Widget body;
  final String route;
  const AdminPanel({super.key, required this.body, required this.route});

  @override
  State<AdminPanel> createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  final List<AdminMenuItem> _sideBarItems = [
    AdminMenuItem(
      title: 'Tableau de bord',
      route: '/admin/dashboard',
      icon: Icons.dashboard,
    ),
    AdminMenuItem(
      title: 'Utilisateurs',
      route: '/admin/users',
      icon: Icons.people,
    ),
    AdminMenuItem(
      title: 'Signalement',
      icon: Icons.report,
      children: [
        AdminMenuItem(
          title: 'Traité',
          route: '/admin/reported-users/group/traite',
          icon: Icons.group,
        ),
        AdminMenuItem(
          title: 'En attente',
          route: '/admin/reported-users/group/en-attente',
          icon: Icons.group,
        ),
        AdminMenuItem(
          title: 'Tout',
          route: '/admin/reported-users/all',
          icon: Icons.all_inbox,
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'NATIFY',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      sideBar: SideBar(
        backgroundColor: kPrimaryColor,
        activeBackgroundColor: Colors.black26,
        borderColor: const Color(0xFFE7E7E7),
        iconColor: Colors.white,
        activeIconColor: Colors.white,
        textStyle: const TextStyle(
          color: Colors.white,
          fontSize: 13,
        ),
        activeTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 13,
        ),
        items: _sideBarItems,
        selectedRoute: widget.route,
        onSelected: (item) {
          print(
              'sideBar: onTap(): title = ${item.title}, route = ${item.route}');
          if (item.route != null && item.route != widget.route) {
            Navigator.of(context).pushNamed(item.route!);
          }
        },
      ),
      body: widget.body,
    );
  }
}
