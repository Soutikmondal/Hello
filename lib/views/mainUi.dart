import 'package:flutter/material.dart';
import 'package:hello/enum/menu_items.dart';

import '../constants/routes.dart';
import '../enum/menu_action.dart';
import '../services/auth/auth_service.dart';
import 'complaint.dart';

class HealthCare extends StatefulWidget {
  const HealthCare({super.key});

  @override
  State<HealthCare> createState() => _HealthCareState();
}

class _HealthCareState extends State<HealthCare> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Care'),
        backgroundColor: Colors.amberAccent,
        actions: [
          PopupMenuButton<MenuItem>(
            onSelected: (item) => onSelected(context, item),
            itemBuilder: (context) => [
              ...MenuItems.itemsthird.map(buildItem).toList(),
            ],
          ),
        ],
      ),
    );
  }

  PopupMenuItem<MenuItem> buildItem(MenuItem item) =>
      PopupMenuItem<MenuItem>(value: item, child: Text(item.text));
  void onSelected(BuildContext context, MenuItem item) async {
    if (item.text == 'Vitals') {
      Navigator.of(context).pushNamedAndRemoveUntil(notesroute, (_) => false);
    } else if (item.text == 'logout') {
      final shouldLogout = await showLogOutDialog(context);
      if (shouldLogout) {
        await Authservice.firebase().logOut();
        Navigator.of(context).pushNamedAndRemoveUntil(loginroute, (_) => false);
      }
    } else if (item.text == 'Complaint') {
      Navigator.of(context)
          .pushNamedAndRemoveUntil(newComplaintRoute, (_) => false);
    }
  }
}
