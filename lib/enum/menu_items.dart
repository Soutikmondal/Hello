import 'package:flutter/material.dart';
import 'package:hello/enum/menu_action.dart';

class MenuItems {
  static final List<MenuItem> itemsfirst = [complaint, logout];
  static final List<MenuItem> itemssecond = [vitals, logout];
  static final List<MenuItem> itemsthird = [vitals, complaint, logout];
  static final complaint = MenuItem(text: "Complaint", icon: Icons.settings);
  static final logout = MenuItem(text: "logout", icon: Icons.settings);
  static final vitals = MenuItem(text: "Vitals", icon: Icons.settings);
}
