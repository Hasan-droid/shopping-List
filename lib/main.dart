import 'package:flutter/material.dart';
import 'package:shopping_list/models/grocery_item.dart';
import 'package:shopping_list/widgets/new_item.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final List<GroceryItem> _groceryItems = [];

  void _moveToNewItemForm(BuildContext context) async {
    final newItem = await Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => NewItem()));

    if (newItem == null) {
      return;
    }
    setState(() {
      _groceryItems.add(newItem);
    });
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
