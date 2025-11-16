import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final user = "dd";

  void _createGroup() async {
    TextEditingController nameGroupController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog.adaptive(
          title: const Text('Создание группы', style: TextStyle(fontSize: 18)),
          content: TextFormField(
            controller: nameGroupController,
            decoration: InputDecoration(
              label: Text('Введите название', style: TextStyle(fontSize: 16)),
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            Row(
              children: [
                TextButton(
                  child: const Text('Отменить'),
                  onPressed: () => Navigator.pop(context),
                ),
                SizedBox(width: 60),
                TextButton(child: const Text('Создать'), onPressed: () {}),
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(child: Text('Пока не создано групп')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createGroup,
        label: Row(
          children: [
            Text('Создать', style: TextStyle(color: Colors.white)),
            SizedBox(width: 15),
            Icon(Icons.add, color: Colors.white),
          ],
        ),
        backgroundColor: Colors.blueGrey[200],
      ),
    );
  }
}
