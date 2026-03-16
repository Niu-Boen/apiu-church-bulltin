import '../presentation/widgets/bulletin_item_model.dart';
import 'package:flutter/material.dart';

final List<BulletinItem> bulletinItems = [
    BulletinItem(
      title: 'Sabbath School Lesson',
      time: '9:30 AM',
      description: 'Join us for a deep dive into this week\'s lesson study.',
      servicePersonnel: 'Leader: Elder John Doe',
      icon: Icons.book_online,
    ),
    BulletinItem(
      title: 'Main Worship Service',
      time: '11:00 AM',
      description: 'Worship with us in the main sanctuary. All are welcome.',
      servicePersonnel: 'Speaker: Pr. Jane Smith',
      icon: Icons.church,
    ),
    BulletinItem(
      title: 'Vespers Service',
      time: 'Friday 7:00 PM',
      description: 'Start the Sabbath with a blessed vespers service.',
      servicePersonnel: 'Coordinator: Sarah Johnson',
      icon: Icons.wb_sunny,
    ),
    BulletinItem(
      title: 'Youth Program',
      time: '4:00 PM',
      description: 'Engaging activities and spiritual growth for the youth.',
      servicePersonnel: 'Leader: Mark Chen',
      icon: Icons.people,
    ),
    BulletinItem(
      title: 'Community Outreach',
      time: 'Sunday 10:00 AM',
      description: 'Join us in serving the local community.',
      servicePersonnel: 'Organizer: Emily White',
      icon: Icons.group_work,
    ),
  ];
