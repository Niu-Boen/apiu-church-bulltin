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
  // 常量定义，提升可维护性
  static const double _padding = 16.0;
  static const double _buttonSpacing = 24.0;

  late final TextEditingController _titleController;
  late final TextEditingController _timeController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _personnelController;
  IconData? _selectedIcon;

  // 图标列表定义为静态常量，避免每次重建
  static const List<IconData> _icons = [
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
    // 初始化控制器，使用原有数据（如果有）
    _titleController = TextEditingController(text: widget.item?.title);
    _timeController = TextEditingController(text: widget.item?.time);
    _descriptionController = TextEditingController(text: widget.item?.description);
    _personnelController = TextEditingController(text: widget.item?.servicePersonnel);
    _selectedIcon = widget.item?.icon ?? _icons[0];
  }

  @override
  void dispose() {
    // 释放所有控制器，防止内存泄漏
    _titleController.dispose();
    _timeController.dispose();
    _descriptionController.dispose();
    _personnelController.dispose();
    super.dispose();
  }

  // 提取验证逻辑：确保标题和时间不为空
  bool _validateInputs() {
    if (_titleController.text.trim().isEmpty) {
      _showSnackBar('Please enter a title');
      return false;
    }
    if (_timeController.text.trim().isEmpty) {
      _showSnackBar('Please enter a time');
      return false;
    }
    return true;
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _save() {
    if (!_validateInputs()) return;

    if (widget.item == null) {
      // 添加新条目
      bulletinItems.add(
        BulletinItem(
          title: _titleController.text.trim(),
          time: _timeController.text.trim(),
          description: _descriptionController.text.trim(),
          servicePersonnel: _personnelController.text.trim(),
          icon: _selectedIcon!,
          publishDate: DateTime.now(), // 新增
          isDraft: false,               // 默认为非草稿
          scheduledDate: null,
        ),
      );
    } else {
      // 更新现有条目
      final index = bulletinItems.indexOf(widget.item!);
      if (index != -1) {
        bulletinItems[index] = BulletinItem(
          title: _titleController.text.trim(),
          time: _timeController.text.trim(),
          description: _descriptionController.text.trim(),
          servicePersonnel: _personnelController.text.trim(),
          icon: _selectedIcon!,
          publishDate: widget.item!.publishDate, // 保留原发布日期
          isDraft: widget.item!.isDraft,          // 保留原草稿状态
          scheduledDate: widget.item!.scheduledDate,
        );
      }
    }

    widget.onSave?.call();
    if (context.mounted) context.pop();
  }

  void _delete() {
    // 仅当编辑模式下且条目存在于列表中时执行删除
    if (widget.item != null && bulletinItems.contains(widget.item)) {
      bulletinItems.remove(widget.item);
      widget.onSave?.call();
      if (context.mounted) context.pop();
    }
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
        padding: const EdgeInsets.all(_padding),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // 各输入字段（保持原有顺序）
              _buildTextField(
                controller: _titleController,
                label: 'Title',
              ),
              _buildTextField(
                controller: _timeController,
                label: 'Time',
              ),
              _buildTextField(
                controller: _descriptionController,
                label: 'Description',
              ),
              _buildTextField(
                controller: _personnelController,
                label: 'Service Personnel',
              ),
              _buildIconDropdown(),
              const SizedBox(height: _buttonSpacing),
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

  // 提取通用的文本输入字段构建方法（保持样式与原来一致）
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
    );
  }

  // 提取图标下拉框构建方法
  Widget _buildIconDropdown() {
    return DropdownButtonFormField<IconData>(
      // ignore: deprecated_member_use
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
    );
  }
}