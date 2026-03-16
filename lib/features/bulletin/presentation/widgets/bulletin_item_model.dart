import 'package:flutter/material.dart';

class BulletinItem {
  final String title;
  final String time;
  final String description;
  final String? servicePersonnel;
  final IconData icon;

  BulletinItem({
    required this.title,
    required this.time,
    required this.description,
    this.servicePersonnel,
    required this.icon,
  });
}
