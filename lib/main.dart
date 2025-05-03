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

  //this best practice to hold future return data only once
  late Future<List<GroceryItem>> _loadedItems;
  var _isLoadingData = true;
  String? _error;

  Future<List<GroceryItem>> loadData() async {
    final url = Uri.https("shopping-list-296e9-default-rtdb.firebaseio.com", "shopping-list.json");

    final response = await http.get(url, headers: {"content-type": "application/json"});

    if (response.statusCode >= 400) {
      throw Exception("Failed to fetch grocery items , please try again later...");
    }
    if (response.body == "null") {
      return [];
    }

    final Map<String, dynamic> listData = json.decode(response.body);

    final List<GroceryItem> loadedItems = [];

    for (final item in listData.entries) {
      final category =
          categories.entries.firstWhere((cate) => cate.value.name == item.value['category']).value;
      loadedItems.add(
        GroceryItem(
          id: item.key,
          name: item.value["name"],
          quantity: item.value["quantity"],
          category: category,
        ),
      );
    }
    return loadedItems;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadedItems = loadData();
  }

  void _moveToNewItemForm(BuildContext context) async {
    final newItem = await Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => NewItem()));
    setState(() {
      _groceryItems.add(newItem);
    });
  }

  void removeItem(GroceryItem item) async {
    final url = Uri.https("shopping-list-296e9-default-rtdb.firebaseio.com", "shopping-list/${item.id}.json");
    final index = _groceryItems.indexOf(item);
    setState(() {
      _groceryItems.remove(item);
    });

    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      setState(() {
        _groceryItems.insert(index, item);
      });
    }
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
            body: FutureBuilder(
              future: _loadedItems,
              builder: (context, snapshot) {
                //waiting means the request is sent and waiting for response
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                //future got rejected
                if (snapshot.hasError) {
                  return Center(child: Text(snapshot.error.toString()));
                }

                //if it is empty
                //"!" since i handle all error cases im sure data is there
                if (snapshot.data!.isEmpty) {
                  return Center(child: Text("You have no items yet", style: TextStyle(fontSize: 24)));
                }
                final itemsData = snapshot.data!;
                return ListView.builder(
                  itemCount: itemsData.length,
                  itemBuilder:
                      (ctx, index) => Column(
                        children: [
                          Dismissible(
                            key: Key(itemsData[index].id),
                            child: ListTile(
                              title: Text(itemsData[index].name),
                              leading: Container(
                                width: 24,
                                height: 24,
                                color: itemsData[index].category.color,
                              ),
                              trailing: Text(itemsData[index].quantity.toString()),
                            ),
                            onDismissed: (direction) {
                              removeItem(itemsData[index]);
                            },
                          ),
                          Divider(height: 2),
                        ],
                      ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
