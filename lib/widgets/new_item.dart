import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shopping_list/data/categories.dart';
import 'package:shopping_list/models/category.dart';
import "package:http/http.dart" as http;
import 'package:shopping_list/models/grocery_item.dart';

class NewItem extends StatefulWidget {
  const NewItem({super.key});

  @override
  State<NewItem> createState() {
    return _NewItemState();
  }
}

class _NewItemState extends State<NewItem> {
  final _formKey = GlobalKey<FormState>();
  var _enteredName = '';
  var _enteredQuantity = 1;
  var _selectedCategory = categories[Categories.vegetables]!;
  var _isSending = false;

  void saveItem() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isSending = true;
      });
      final url = Uri.https("shopping-list-296e9-default-rtdb.firebaseio.com", "shopping-list.json");
      final response = await http.post(
        url,
        headers: {"content-type": "application/json"},
        body: json.encode({
          "category": _selectedCategory.name,
          "name": _enteredName,
          "quantity": _enteredQuantity,
        }),
      );
      final Map<String, dynamic> resData = json.decode(response.body);
      // checks if the widget's context is still "mounted" (valid and attached to the widget tree)
      //before continuing with operations that use that context (like navigation).
      if (!context.mounted) {
        return;
      }

      Navigator.of(context).pop(
        GroceryItem(
          id: resData["name"],
          name: _enteredName,
          quantity: _enteredQuantity,
          category: _selectedCategory,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add a new item')),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              maxLength: 50,
              decoration: const InputDecoration(label: Text("name")),
              validator: (value) {
                if (value == null || value.isEmpty || value.trim().length <= 1 || value.trim().length > 50) {
                  return "Must be 1 and 50 characters";
                }
                return null;
              },
              onSaved: (value) {
                _enteredName = value!;
              },
            ),
            SizedBox(width: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: TextFormField(
                    keyboardType: TextInputType.numberWithOptions(),
                    initialValue: "1",
                    decoration: const InputDecoration(label: Text("Quantity")),
                    validator: (value) {
                      {
                        if (value == null ||
                            value.isEmpty ||
                            int.tryParse(value) == null ||
                            int.tryParse(value)! <= 0) {
                          return "Must be valid positive number";
                        }
                        return null;
                      }
                    },
                    onSaved: (value) {
                      _enteredQuantity = int.parse(value!);
                    },
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField(
                    value: _selectedCategory,
                    items: [
                      for (final category in categories.entries)
                        DropdownMenuItem(
                          value: category.value,
                          child: Row(
                            children: [
                              Container(height: 16, width: 16, color: category.value.color),
                              SizedBox(width: 4),
                              Text(category.value.name),
                            ],
                          ),
                        ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    _formKey.currentState!.reset();
                  },
                  child: Text("Reset"),
                ),
                SizedBox(width: 4),
                ElevatedButton(
                  onPressed: _isSending ? () {} : saveItem,
                  child:
                      _isSending
                          ? SizedBox(width: 16, height: 16, child: CircularProgressIndicator())
                          : Text("add Item"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
