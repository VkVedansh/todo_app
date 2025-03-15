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
  //*init state to automatically load data
  @override
  void initState() {
    super.initState();
    fetchTodo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Todo"), centerTitle: true, elevation: 2),
      body: LiquidPullToRefresh(
        onRefresh: fetchTodo,
        child: ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index] as Map;
            final id = item['_id'] as String;

            return ListTile(
              leading: CircleAvatar(child: Text('${index + 1}')),
              title: Text(item['title']),
              subtitle: Text(item['description']),
              trailing: PopupMenuButton(
                onSelected: (value) {
                  if (value == 'edit') {
                    navigatetoeditpage(item);
                    //open edit page
                  } else if (value == 'delete') {
                    deletebyid(id);
                  }
                },
                itemBuilder: (context) {
                  return [
                    PopupMenuItem(value: 'edit', child: Text("Edit")),
                    PopupMenuItem(value: 'delete', child: Text("Delete")),
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
            //async and await for data taking some time
            context,
            MaterialPageRoute(builder: (context) => AddTodoPage()),
          );
          setState(() {
            isloading = true; //set state for reload
          });
          fetchTodo(); //to complete reload
        },
        label: Text("Add ToDo"),
      ),
    );
  }

  Future<void> fetchTodo() async {
    setState(() {
      isloading = false;
    });
    final url = "https://api.nstack.in/v1/todos?page=1&limit=10";
    final uri = Uri.parse(url);
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map;
      final result = json['items'] as List;
      setState(() {
        items = result;
      });
    }
    setState(() {
      isloading = false;
    });
  }

  Future<void> deletebyid(String id) async {
    final url = "https://api.nstack.in/v1/todos/$id";
    final uri = Uri.parse(url);
    final respnse = await http.delete(uri);
    if (respnse.statusCode == 200) {
      final filtered =
          items
              .where((element) => element['_id'] != id)
              .toList(); //for without loading delete
      setState(() {
        items = filtered;
      });
    }
  }

  //? making custom button
  void navigatetoeditpage(Map item) async {
    //It takes a Map item as an argument, which represents the todo item.
    final Route = MaterialPageRoute(
      builder:
          (context) => AddTodoPage(
            todo: item,
          ), //*The todo: item part passes the selected todo item to the AddTodoPage, allowing the user to edit it.
    );
    await Navigator.push(context, Route);
    setState(() {
      isloading = true;
    });
    fetchTodo();
  }
}
