// ignore_for_file: non_constant_identifier_names, curly_braces_in_flow_control_structures, avoid_print

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AddTodoPage extends StatefulWidget {
  final Map? todo;
  const AddTodoPage({super.key, this.todo});

  @override
  State<AddTodoPage> createState() => _AddTodoPageState();
}

class _AddTodoPageState extends State<AddTodoPage> {
  final TextEditingController titlecontroller = TextEditingController();
  final TextEditingController descriptioncontroller = TextEditingController();
  bool isedit = false;

  @override
  void initState() {
    super.initState();
    final todo = widget.todo;

    if (todo != null) {
      isedit = true;
      titlecontroller.text = todo['title'] ?? '';
      descriptioncontroller.text = todo['description'] ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isedit ? "Edit Todo" : "Add Todo"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            TextField(
              controller: titlecontroller,
              decoration: const InputDecoration(hintText: "Title"),
            ),
            const SizedBox(height: 7),
            TextField(
              controller: descriptioncontroller,
              decoration: const InputDecoration(hintText: "Description"),
              minLines: 5,
              maxLines: 8,
              keyboardType: TextInputType.multiline,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (titlecontroller.text.isEmpty ||
                    descriptioncontroller.text.isEmpty) {
                  ShowerrorBanner("Please fill the required fields");
                  return;
                }
                isedit ? updatetdata() : summitdata();
              },
              child: Text(isedit ? "Update" : "Add To Todo"),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> summitdata() async {
    final title = titlecontroller.text;
    final description = descriptioncontroller.text;

    final body = {
      "title": title,
      "description": description,
    };

    final url = "http://192.168.227.156:5000/todos";
    final uri = Uri.parse(url);
    final response = await http.post(
      uri,
      body: jsonEncode(body),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 201) {
      ShowSucessBanner("Successfully Added");
      Navigator.pop(context);
    } else {
      ShowerrorBanner("Failed. Please try again later.");
    }
  }

  Future<void> updatetdata() async {
    final todo = widget.todo;
    if (todo == null) {
      print("You cannot call update without todo data");
      return;
    }

    final id = todo['_id'];
    final title = titlecontroller.text;
    final description = descriptioncontroller.text;

    final body = {
      "title": title,
      "description": description,
    };

    final url = "http://192.168.227.156:5000/update/$id";
    final uri = Uri.parse(url);
    final response = await http.post(
      uri,
      body: jsonEncode(body),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      ShowSucessBanner("Updated");
      Navigator.pop(context);
    } else {
      ShowerrorBanner("Failed. Please try again later.");
    }
  }

  void ShowSucessBanner(String message) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void ShowerrorBanner(String message) {
    final snackBar = SnackBar(
      backgroundColor: Colors.redAccent,
      content: Text(message, style: const TextStyle(color: Colors.white)),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
