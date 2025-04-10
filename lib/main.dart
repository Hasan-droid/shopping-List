import 'package:flutter/material.dart';
import 'package:shopping_list/data/dummy_items.dart';
import 'package:shopping_list/models/grocery_item.dart';
import 'package:shopping_list/widgets/new_item.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  void _moveToNewItemForm(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => NewItem()));
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
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
            body: ListView.builder(
              itemCount: groceryItems.length,
              itemBuilder:
                  (ctx, index) => Column(
                    children: [
                      ListTile(
                        title: Text(groceryItems[index].name),
                        leading: Container(width: 24, height: 24, color: groceryItems[index].category.color),
                        trailing: Text(groceryItems[index].quantity.toString()),
                      ),
                      Divider(height: 2),
                    ],
                  ),
            ),
          );
        },
      ),
    );
  }
}
