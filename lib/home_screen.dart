import 'package:divvy/core/theme/constants/color.dart';
import 'package:divvy/group_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:divvy/core/services/firebase_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseService _firebaseService = FirebaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _firebaseService.getGroups(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: primaryColor),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Ошибка загрузки данных',
                style: TextStyle(color: Colors.red[400]),
              ),
            );
          }

          final groups = snapshot.data ?? [];
          final hasGroups = groups.isNotEmpty;

          return hasGroups ? _buildGroupList(groups) : _buildEmptyState();
        },
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [primaryColor, Color(0xFF8B7FFF)],
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () => _createGroup(context),
          backgroundColor: Colors.transparent,
          elevation: 0,
          hoverElevation: 0,
          label: const Row(
            children: [
              Text(
                'Создать',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: 8),
              Icon(Icons.add, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGroupList(List<Map<String, dynamic>> groups) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: groups.length,
      itemBuilder: (context, index) {
        final group = groups[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(20),
            leading: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [primaryColor, Color(0xFF8B7FFF)],
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Icon(
                Icons.groups_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
            title: Text(
              group['name'] ?? '',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D3142),
              ),
            ),
            trailing: PopupMenuButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              icon: const Icon(Icons.more_vert, color: Color(0xFF9E9E9E)),
              onSelected: (value) async {
                if (value == 'edit') {
                  await _editGroup(group['id'], group['name']);
                } else if (value == 'delete') {
                  await _deleteGroup(group['id']);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, color: primaryColor),
                      SizedBox(width: 12),
                      Text('Редактировать'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: accentColor),
                      SizedBox(width: 12),
                      Text('Удалить'),
                    ],
                  ),
                ),
              ],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GroupDetailsScreen(
                    groupId: group['id'],
                    groupName: group['name'] ?? '',
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  primaryColor.withOpacity(0.1),
                  primaryColor.withOpacity(0.05),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.groups_sharp,
              size: 80,
              color: primaryColor.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'Нет групп',
            style: TextStyle(
              color: Color(0xFF2D3142),
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Создайте первую группу для\nразделения расходов',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 16),
          ),
        ],
      ),
    );
  }

  void _createGroup(BuildContext context) {
    final nameController = TextEditingController();

    final scaffoldMessenger = ScaffoldMessenger.of(context);

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        final formKey = GlobalKey<FormState>();

        return AlertDialog(
          backgroundColor: cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          title: const Text(
            'Создать группу',
            style: TextStyle(
              color: Color(0xFF2D3142),
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: nameController,
              style: const TextStyle(color: Color(0xFF2D3142)),
              decoration: InputDecoration(
                labelText: 'Название группы',
                labelStyle: const TextStyle(color: Color(0xFF9E9E9E)),
                hintText: 'Введите название',
                hintStyle: const TextStyle(color: Color(0xFFBDBDBD)),
                filled: true,
                fillColor: backgroundColor,
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(15),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: primaryColor, width: 2),
                  borderRadius: BorderRadius.circular(15),
                ),
                errorBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: accentColor),
                  borderRadius: BorderRadius.circular(15),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: accentColor, width: 2),
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Пожалуйста, введите название';
                }
                return null;
              },
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text(
                'Отмена',
                style: TextStyle(color: Color(0xFF9E9E9E)),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [primaryColor, Color(0xFF8B7FFF)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ElevatedButton(
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    final groupName = nameController.text.trim();
                    Navigator.of(dialogContext).pop();

                    try {
                      await _firebaseService.createGroup(groupName);

                      scaffoldMessenger.showSnackBar(
                        SnackBar(
                          content: Text('Группа "$groupName" создана'),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: secondaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                    } catch (e) {
                      scaffoldMessenger.showSnackBar(
                        SnackBar(
                          content: Text('Ошибка: $e'),
                          backgroundColor: accentColor,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Создать',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        );
      },
    ).then((_) {
      nameController.dispose();
    });
  }

  Future<void> _editGroup(String groupId, String currentName) async {
    final nameController = TextEditingController(text: currentName);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    final result =
        await showDialog(
          context: context,
          builder: (BuildContext dialogContext) {
            final formKey = GlobalKey<FormState>();

            return AlertDialog(
              backgroundColor: cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              title: const Text(
                'Редактировать группу',
                style: TextStyle(
                  color: Color(0xFF2D3142),
                  fontWeight: FontWeight.w600,
                ),
              ),
              content: Form(
                key: formKey,
                child: TextFormField(
                  controller: nameController,
                  style: const TextStyle(color: Color(0xFF2D3142)),
                  decoration: InputDecoration(
                    labelText: 'Название группы',
                    labelStyle: const TextStyle(color: Color(0xFF9E9E9E)),
                    hintText: 'Введите название',
                    hintStyle: const TextStyle(color: Color(0xFFBDBDBD)),
                    filled: true,
                    fillColor: backgroundColor,
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: primaryColor,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: accentColor),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: accentColor,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Пожалуйста, введите название';
                    }
                    return null;
                  },
                  autofocus: true,
                  textCapitalization: TextCapitalization.sentences,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                  child: const Text(
                    'Отмена',
                    style: TextStyle(color: Color(0xFF9E9E9E)),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [primaryColor, Color(0xFF8B7FFF)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        final newName = nameController.text.trim();
                        Navigator.of(dialogContext).pop(newName);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Сохранить',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            );
          },
        ).then((value) {
          nameController.dispose();
          return value;
        });

    if (result != null && result != currentName) {
      try {
        await _firebaseService.updateGroup(groupId, result);
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('Группа "$result" обновлена'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: secondaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      } catch (e) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('Ошибка обновления: $e'),
            backgroundColor: accentColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  Future<void> _deleteGroup(String groupId) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        title: const Text(
          'Удалить группу?',
          style: TextStyle(
            color: Color(0xFF2D3142),
            fontWeight: FontWeight.w600,
          ),
        ),
        content: const Text(
          'Это действие нельзя отменить',
          style: TextStyle(color: Color(0xFF9E9E9E)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Отмена',
              style: TextStyle(color: Color(0xFF9E9E9E)),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: accentColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Удалить', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _firebaseService.deleteGroup(groupId);
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: const Text('Группа удалена'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: secondaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      } catch (e) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('Ошибка удаления: $e'),
            backgroundColor: accentColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }
}
