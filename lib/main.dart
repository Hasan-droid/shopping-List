import 'package:flutter/material.dart';
import 'package:shopping_list/data/categories.dart';
import 'dart:convert';
import 'package:shopping_list/models/grocery_item.dart';
import 'package:shopping_list/widgets/new_item.dart';
import "package:http/http.dart" as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<GroceryItem> _groceryItems = [];

  void loadData() async {
    final url = Uri.https("shopping-list-296e9-default-rtdb.firebaseio.com", "shopping-list.json");
    final response = await http.get(url, headers: {"content-type": "application/json"});
    final Map<String, dynamic> listData = json.decode(response.body);

    final List<GroceryItem> _loadedItems = [];

    for (final item in listData.entries) {
      final category =
          categories.entries.firstWhere((cate) => cate.value.name == item.value['category']).value;
      _loadedItems.add(
        GroceryItem(
          id: item.key,
          name: item.value["name"],
          quantity: item.value["quantity"],
          category: category,
        ),
      );
    }
    setState(() {
      _groceryItems = _loadedItems;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadData();
  }

  void _moveToNewItemForm(BuildContext context) async {
    final newItem = await Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => NewItem()));

    loadData();
  }

  void removeItem(GroceryItem item) {
    setState(() {
      _groceryItems.remove(item);
    });
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    Widget content = Center(child: Text("You have no items yet", style: TextStyle(fontSize: 24)));

    if (_groceryItems.isNotEmpty) {
      content = ListView.builder(
        itemCount: _groceryItems.length,
        itemBuilder:
            (ctx, index) => Column(
              children: [
                Dismissible(
                  key: Key(_groceryItems[index].id),
                  child: ListTile(
                    title: Text(_groceryItems[index].name),
                    leading: Container(width: 24, height: 24, color: _groceryItems[index].category.color),
                    trailing: Text(_groceryItems[index].quantity.toString()),
                  ),
                  onDismissed: (direction) {
                    removeItem(_groceryItems[index]);
                  },
                ),
                Divider(height: 2),
              ],
            ),
      );
    }
    return MaterialApp(
      title: 'Flutter Groceries',
      theme: ThemeData.dark().copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 147, 229, 250),
          brightness: Brightness.dark,
          surface: const Color.fromARGB(255, 42, 51, 59),
        ),
        scaffoldBackgroundColor: const Color.fromARGB(255, 50, 58, 60),
      ),
      home: Builder(
        builder: (ctx) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Your Groceries'),
              actions: [
                IconButton(
                  onPressed: () {
                    _moveToNewItemForm(ctx);
                  },
                  icon: Icon(Icons.add),
                ),
              ],
            ),
            body: content,
          );
        },
      ),
    );
  }
}
