import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/bulletin_data.dart';
import '../widgets/bulletin_item_model.dart';
import '../../../../core/widgets/soft_button.dart';
import '../../../../core/services/bulletin_storage_service.dart';

class EditBulletinScreen extends StatefulWidget {
  final BulletinItem? item;
  final Function? onSave;
  final int? dayOfWeek; // 5 = Friday, 6 = Saturday

  const EditBulletinScreen({super.key, this.item, this.onSave, this.dayOfWeek});

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

  // 计算下一个指定的星期几
  DateTime _getNextDayOfWeek(int targetDayOfWeek) {
    DateTime now = DateTime.now();
    int currentDayOfWeek = now.weekday;
    int daysUntilTarget = (targetDayOfWeek - currentDayOfWeek + 7) % 7;

    // 如果今天是目标星期几，返回今天；否则返回下一天
    if (daysUntilTarget == 0) {
      return now;
    }

    return now.add(Duration(days: daysUntilTarget));
  }

  void _save() async {
    if (!_validateInputs()) return;

    try {
      if (widget.item == null) {
        // 添加新条目 - 根据指定的星期几设置 publishDate
        DateTime targetDate;
        if (widget.dayOfWeek != null) {
          // 计算下一个指定的星期几
          targetDate = _getNextDayOfWeek(widget.dayOfWeek!);
        } else {
          targetDate = DateTime.now();
        }

        final newItem = BulletinItem(
          title: _titleController.text.trim(),
          time: _timeController.text.trim(),
          description: _descriptionController.text.trim(),
          servicePersonnel: _personnelController.text.trim(),
          icon: _selectedIcon!,
          publishDate: targetDate,
          isDraft: false,
          scheduledDate: null,
        );

        // 保存到内存列表
        bulletinItems.add(newItem);

        // 保存到本地存储
        await BulletinStorageService.addBulletin(newItem);
      } else {
        // 更新现有条目
        final newItem = BulletinItem(
          title: _titleController.text.trim(),
          time: _timeController.text.trim(),
          description: _descriptionController.text.trim(),
          servicePersonnel: _personnelController.text.trim(),
          icon: _selectedIcon!,
          publishDate: widget.item!.publishDate,
          isDraft: widget.item!.isDraft,
          scheduledDate: widget.item!.scheduledDate,
        );

        // 更新内存列表
        final index = bulletinItems.indexOf(widget.item!);
        if (index != -1) {
          bulletinItems[index] = newItem;

          // 更新本地存储
          await BulletinStorageService.updateBulletin(widget.item!, newItem);
        }
      }

      widget.onSave?.call();
      if (mounted) {
        _showSnackBar('Saved successfully!');
        context.pop();
      }
    } catch (e) {
      _showSnackBar('Error saving: ${e.toString()}');
    }
  }

  void _delete() async {
    // 仅当编辑模式下且条目存在于列表中时执行删除
    if (widget.item != null && bulletinItems.contains(widget.item)) {
      try {
        // 从内存列表删除
        bulletinItems.remove(widget.item);

        // 从本地存储删除
        await BulletinStorageService.deleteBulletin(widget.item!);

        widget.onSave?.call();
        if (mounted) {
          _showSnackBar('Deleted successfully!');
          context.pop();
        }
      } catch (e) {
        _showSnackBar('Error deleting: ${e.toString()}');
      }
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
              SizedBox(
                width: double.infinity,
                height: 50,
                child: SoftButton(
                  onPressed: _save,
                  child: const Text(
                    'Save',
                    style: TextStyle(
                      color: Color(0xFF4A7A9C),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
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