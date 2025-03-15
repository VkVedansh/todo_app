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
  TextEditingController titlecontroller = TextEditingController();
  TextEditingController descriptioncontroller = TextEditingController();

  bool isedit = false;

  @override
  void initState() {
    super.initState(); //  to ensure proper initialization.

    final todo = widget.todo; // Get the todo item passed as a widget property.

    if (todo != null) {
      // Check if the todo item is not null (meaning we are editing an existing item).
      isedit =
          true; //! Set isedit to true, indicating the user is editing an existing todo.

      final title = todo['title']; // Extract the 'title' from the todo map.
      final description = todo["description"]; // Extract the 'description'

      //! Set the extracted values into the corresponding text controllers to display them in text fields.
      titlecontroller.text =
          title ?? ''; // If title is null, set an empty string
      descriptioncontroller.text =
          description ?? ''; // If description is null, set an empty string
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
                isedit ? updatetdata() : summitdata();
                if (titlecontroller.text.isEmpty ||
                    descriptioncontroller.text.isEmpty) {
                  ShowerrorBanner('PLESE FILL THE REQUIRED FIELDS');
                  return;
                }
              },
              child: Text(isedit ? "Update" : "Add To Todo"),
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
      ShowSucessBanner("Sucessfully Added");
    } else
      ShowerrorBanner("Failed plese try again later");
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
      //https://api.nstack.in/swagger#/Todo/TodoController_create
      "title": title,
      "description": description,
      "is_completed": false,
    };

    //update the data to server
    final url = "https://api.nstack.in/v1/todos/$id";
    final uri = Uri.parse(url);
    final response = await http.put(
      uri,
      body: jsonEncode(body),
      headers: {'Content-Type': 'application/json'},
    );
    //show sucess and fail message on basis of status

    if (response.statusCode == 200) {
      ShowSucessBanner("Updated");
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
