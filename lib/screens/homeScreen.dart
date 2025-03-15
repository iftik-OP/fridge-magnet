import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shopping_list/screens/listScreen.dart';
import 'package:shopping_list/stickers.dart';
import 'package:shopping_list/widgets/listCard.dart';
import 'package:shopping_list/models/list.dart';
import 'package:shopping_list/models/user.dart';

class ShoppingListScreen extends StatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  State<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  final List<ShoppingList> lists = [];

  TextEditingController listNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Image.asset('assets/logo/sticker-logo.png', height: 50),
        actions: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                TimeOfDay.now().hour < 12
                    ? 'Good Morning!'
                    : TimeOfDay.now().hour < 17
                        ? 'Good Afternoon!'
                        : 'Good Evening!',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold, fontSize: 12),
              ),
              Text(
                'Iftikhar', // Replace with actual user name
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(width: 10),
          CircleAvatar(
            radius: 20,
            child: Text('I'),
          ),
          SizedBox(
            width: 20,
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 10),
                  ],
                ),
              ],
            ),
          ),
          if (lists.isEmpty)
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 150),
                Image.asset(
                  'assets/stickers/empty_fridge.png',
                  height: 200,
                  opacity: const AlwaysStoppedAnimation<double>(0.5),
                ),
                const SizedBox(height: 20),
                Text(
                  'No lists yet',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(color: Colors.grey.shade400, fontSize: 12),
                ),
              ],
            )
          else
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    ...lists.map((list) => ListCard(
                          listName: list.name,
                          collaborators: list.collaborators,
                          startColor: list.startColor,
                          endColor: list.endColor,
                          imageAsset: list.imageAsset,
                        )),
                    SizedBox(
                      height: 50,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          String imageAsset = 'fridge_sticker.png';
          showDialog(
            context: context,
            builder: (context) {
              final random = Random();
              final startColor = Color.fromRGBO(
                150 + random.nextInt(105),
                150 + random.nextInt(105),
                150 + random.nextInt(105),
                1,
              );
              final endColor = Color.fromRGBO(
                150 + random.nextInt(105),
                150 + random.nextInt(105),
                150 + random.nextInt(105),
                1,
              );

              return StatefulBuilder(builder: (context, setDialogState) {
                return Dialog(
                    child: Stack(children: [
                  Container(
                    height: 270,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(0.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                              height: 50,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [startColor, endColor],
                                ),
                              )),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                TextField(
                                  decoration: InputDecoration(
                                    hintText: 'Enter list name',
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    errorBorder: InputBorder.none,
                                    focusedErrorBorder: InputBorder.none,
                                    border: InputBorder.none,
                                    disabledBorder: InputBorder.none,
                                    hintStyle: TextStyle(
                                        color: Colors.grey,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 24,
                                      fontWeight: FontWeight.w500),
                                  controller: listNameController,
                                ),
                                SizedBox(height: 10),
                                Divider(
                                  color: Colors.grey.shade200,
                                  endIndent: 50,
                                  indent: 50,
                                ),
                                TextButton(
                                  onPressed: () {},
                                  child: Text(
                                    'Add Collaborators',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ),
                                SizedBox(height: 10),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      if (listNameController.text.isEmpty) {
                                        listNameController.text = 'Unknown';
                                      }
                                      lists.add(ShoppingList(
                                          startColor: startColor,
                                          endColor: endColor,
                                          name: listNameController.text,
                                          collaborators: [],
                                          imageAsset:
                                              'assets/stickers/$imageAsset',
                                          items: []));
                                      listNameController.clear();
                                      Navigator.pop(context);
                                      setState(() {});
                                    },
                                    child: Text(
                                      'Create List',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                      right: 0,
                      top: 20,
                      child: GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width,
                            ),
                            builder: (BuildContext context) {
                              return Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(16),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Choose your magnet',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge,
                                    ),
                                    SizedBox(height: 16),
                                    Wrap(
                                      spacing: 10,
                                      runSpacing: 10,
                                      children: stickers.map((String sticker) {
                                        return GestureDetector(
                                          onTap: () {
                                            Navigator.pop(context);
                                            setDialogState(() {
                                              imageAsset = sticker;
                                            });
                                          },
                                          child: Container(
                                            padding: EdgeInsets.all(5),
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Colors.grey.shade200),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Image.asset(
                                              'assets/stickers/$sticker',
                                              height: 60,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                        child: Image.asset(
                          'assets/stickers/$imageAsset',
                          height: 80,
                        ),
                      )),
                ]));
              });
            },
          );
        },
        foregroundColor: Colors.black,
        elevation: 0,
        shape: CircleBorder(),
        backgroundColor: Colors.white.withAlpha(150),
        child: Image.asset('assets/stickers/add.png', height: 50),
      ),
    );
  }
}
