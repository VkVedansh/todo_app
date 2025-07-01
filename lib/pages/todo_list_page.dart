import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:todo_app/pages/add_todo_page.dart';
import 'package:http/http.dart' as http;

class TodoListPage extends StatefulWidget {
  const TodoListPage({super.key});

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  bool isloading = true;
  List items = [];

  @override
  void initState() {
    super.initState();
    fetchTodo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Todo"), centerTitle: true, elevation: 2),
      body: isloading
          ? const Center(child: CircularProgressIndicator())
          : LiquidPullToRefresh(
              onRefresh: fetchTodo,
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index] as Map;
                  final id = item['_id'] as String;

                  return ListTile(
                    leading: CircleAvatar(child: Text('${index + 1}')),
                    title: Text(item['title'] ?? ''),
                    subtitle: Text(item['description'] ?? ''),
                    trailing: PopupMenuButton(
                      onSelected: (value) {
                        if (value == 'edit') {
                          navigatetoeditpage(item);
                        } else if (value == 'delete') {
                          deletebyid(id);
                        }
                      },
                      itemBuilder: (context) {
                        return [
                          const PopupMenuItem(value: 'edit', child: Text("Edit")),
                          const PopupMenuItem(value: 'delete', child: Text("Delete")),
                        ];
                      },
                    ),
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddTodoPage()),
          );
          fetchTodo();
        },
        label: const Text("Add ToDo"),
      ),
    );
  }

  Future<void> fetchTodo() async {
    setState(() {
      isloading = true;
    });

    final url = "http://192.168.227.156:5000/todos";
    final uri = Uri.parse(url);
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map;
      final result = json['todos'] as List;
      setState(() {
        items = result;
      });
    } else {
      // Handle error
      setState(() {
        items = [];
      });
    }

    setState(() {
      isloading = false;
    });
  }

  Future<void> deletebyid(String id) async {
    final url = "http://192.168.227.156:5000/delete/$id";
    final uri = Uri.parse(url);
    final response = await http.post(uri);

    if (response.statusCode == 200) {
      final filtered = items.where((element) => element['_id'] != id).toList();
      setState(() {
        items = filtered;
      });
    } else {
      // Show error if needed
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to delete. Try again."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void navigatetoeditpage(Map item) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddTodoPage(todo: item),
      ),
    );
    fetchTodo();
  }
}
