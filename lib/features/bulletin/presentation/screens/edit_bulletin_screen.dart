import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/bulletin_data.dart';
import '../widgets/bulletin_item_model.dart';

class EditBulletinScreen extends StatefulWidget {
  final BulletinItem? item;
  final Function? onSave;

  const EditBulletinScreen({super.key, this.item, this.onSave});

  @override
  State<EditBulletinScreen> createState() => _EditBulletinScreenState();
}

class _EditBulletinScreenState extends State<EditBulletinScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _timeController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _personnelController;
  IconData? _selectedIcon;

  final List<IconData> _icons = [
    Icons.article_outlined,
    Icons.book_online,
    Icons.church,
    Icons.wb_sunny,
    Icons.people,
    Icons.group_work,
    Icons.music_note,
    Icons.school,
    Icons.health_and_safety,
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.item?.title);
    _timeController = TextEditingController(text: widget.item?.time);
    _descriptionController = TextEditingController(text: widget.item?.description);
    _personnelController = TextEditingController(text: widget.item?.servicePersonnel);
    _selectedIcon = widget.item?.icon ?? _icons[0];
  }

  @override
  void dispose() {
    _titleController.dispose();
    _timeController.dispose();
    _descriptionController.dispose();
    _personnelController.dispose();
    super.dispose();
  }

  void _save() {
    if (widget.item == null) {
      bulletinItems.add(
        BulletinItem(
          title: _titleController.text,
          time: _timeController.text,
          description: _descriptionController.text,
          servicePersonnel: _personnelController.text,
          icon: _selectedIcon!,
        ),
      );
    } else {
      final index = bulletinItems.indexOf(widget.item!);
      bulletinItems[index] = BulletinItem(
        title: _titleController.text,
        time: _timeController.text,
        description: _descriptionController.text,
        servicePersonnel: _personnelController.text,
        icon: _selectedIcon!,
      );
    }
    widget.onSave?.call();
    context.pop();
  }

  void _delete() {
    bulletinItems.remove(widget.item);
    widget.onSave?.call();
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(widget.item == null ? 'Add Item' : 'Edit Item'),
        actions: [
          if (widget.item != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _delete,
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: _timeController,
                decoration: const InputDecoration(labelText: 'Time'),
              ),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              TextField(
                controller: _personnelController,
                decoration: const InputDecoration(labelText: 'Service Personnel'),
              ),
              DropdownButtonFormField<IconData>(
                value: _selectedIcon,
                items: _icons.map((icon) {
                  return DropdownMenuItem<IconData>(
                    value: icon,
                    child: Icon(icon),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedIcon = value;
                  });
                },
                decoration: const InputDecoration(labelText: 'Icon'),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _save,
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
