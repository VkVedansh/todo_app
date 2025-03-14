// ignore_for_file: non_constant_identifier_names, curly_braces_in_flow_control_structures, avoid_print

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AddTodoPage extends StatefulWidget {
  const AddTodoPage({super.key});

  @override
  State<AddTodoPage> createState() => _AddTodoPageState();
}

class _AddTodoPageState extends State<AddTodoPage> {
  TextEditingController titlecontroller = TextEditingController();
  TextEditingController descriptioncontroller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Todo"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            TextField(
              controller: titlecontroller,
              decoration: InputDecoration(hintText: "Title"),
            ),
            SizedBox(height: 7),
            TextField(
              controller: descriptioncontroller,
              decoration: InputDecoration(hintText: 'Description'),
              minLines: 5,
              maxLines: 8,
              keyboardType: TextInputType.multiline,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                summitdata();
                if (titlecontroller.text.isEmpty ||
                    descriptioncontroller.text.isEmpty) {
                  ShowerrorBanner('PLESE FILL THE REQUIRED FIELDS');
                  return;
                }
              },
              child: Text("Add To Todo"),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> summitdata() async {
    //get the data from form

    final title = titlecontroller.text;
    final description = descriptioncontroller.text;
    final body = {
      //https://api.nstack.in/swagger#/Todo/TodoController_create
      "title": title,
      "description": description,
      "is_completed": false,
    };

    //Sumit the data to server
    final url = "https://api.nstack.in/v1/todos";
    final uri = Uri.parse(url);
    final response = await http.post(
      uri,
      body: jsonEncode(body),
      headers: {'Content-Type': 'application/json'},
    );

    //show sucess and fail message on basis of status

    if (response.statusCode == 201) {
      ShowSucessBanner("Sucessfully added");
    } else
      ShowerrorBanner("Failed plese try again later");
  }

  void ShowSucessBanner(String message) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void ShowerrorBanner(String message) {
    final snackBar = SnackBar(
      backgroundColor: Colors.redAccent,
      content: Text(message, style: TextStyle(color: Colors.white)),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
