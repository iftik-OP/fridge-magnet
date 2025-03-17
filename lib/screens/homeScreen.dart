import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopping_list/providers/listProvider.dart';
import 'package:shopping_list/providers/userProvider.dart';
import 'package:shopping_list/stickers.dart';
import 'package:shopping_list/widgets/listCard.dart';
import 'package:shopping_list/models/list.dart';
import 'package:shopping_list/models/user.dart';
import 'package:shopping_list/screens/listScreen.dart';
import 'package:shopping_list/services/listServices.dart';
import 'package:shopping_list/services/userServices.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ListServices _listServices = ListServices();
  TextEditingController listNameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  bool showPhoneField = false;
  List<User> collaborators = [];
  bool isLoadingCollaborator = false;

  void resetDialogState() {
    setState(() {
      showPhoneField = false;
      collaborators.clear();
      phoneController.clear();
      listNameController.clear();
    });
  }

  @override
  void dispose() {
    listNameController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  Future<void> addCollaborator(
      BuildContext context, String phoneNumber, Function setDialogState) async {
    if (phoneNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a phone number')),
      );
      return;
    }

    setDialogState(() {
      isLoadingCollaborator = true;
    });

    try {
      final userService = UserServices();
      final collaborator = await userService.getUserByPhone(phoneNumber);

      if (collaborator == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User not found')),
          );
        }
        return;
      }

      // Check if user is already a collaborator
      if (collaborators.any((c) => c.uid == collaborator.uid)) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User is already a collaborator')),
          );
        }
        return;
      }

      setDialogState(() {
        collaborators.add(collaborator);
        showPhoneField = false;
        phoneController.clear();
      });
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding collaborator: $e')),
        );
      }
    } finally {
      if (mounted) {
        setDialogState(() {
          isLoadingCollaborator = false;
        });
      }
    }
  }

  void removeCollaborator(User collaborator, Function setDialogState) {
    setDialogState(() {
      collaborators.remove(collaborator);
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;
    if (user == null) return const SizedBox.shrink();

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
                user?.name ?? 'User',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(width: 10),
          const CircleAvatar(
            radius: 20,
            child: Text('I'),
          ),
          const SizedBox(
            width: 20,
          ),
        ],
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
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
          Expanded(
            child: StreamBuilder<List<ShoppingList>>(
              stream: _listServices.getUserLists(user.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final lists = snapshot.data ?? [];

                if (lists.isEmpty) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/stickers/empty_fridge.png',
                        height: 200,
                        opacity: const AlwaysStoppedAnimation<double>(0.5),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'No lists yet',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.grey.shade400, fontSize: 12),
                      ),
                    ],
                  );
                }

                return SingleChildScrollView(
                  child: Column(
                    children: [
                      ...lists.map((list) => ListCard(list: list)),
                      const SizedBox(height: 50),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          String imageAsset = 'fridge_sticker.png';
          resetDialogState();
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
                  child: Stack(
                    children: [
                      Container(
                        height: 500,
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
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    TextField(
                                      decoration: const InputDecoration(
                                        hintText: 'Enter list name',
                                        enabledBorder: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                        errorBorder: InputBorder.none,
                                        focusedErrorBorder: InputBorder.none,
                                        border: InputBorder.none,
                                        disabledBorder: InputBorder.none,
                                        hintStyle: TextStyle(
                                          color: Colors.grey,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 24,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      controller: listNameController,
                                    ),
                                    const SizedBox(height: 10),
                                    Divider(
                                      color: Colors.grey.shade200,
                                      endIndent: 50,
                                      indent: 50,
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      'Collaborators',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge
                                          ?.copyWith(fontSize: 12),
                                    ),
                                    const SizedBox(height: 10),
                                    Container(
                                      height:
                                          110, // Fixed height for collaborators section

                                      child: SingleChildScrollView(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // Owner section
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Row(
                                                children: [
                                                  CircleAvatar(
                                                    radius: 15,
                                                    backgroundColor:
                                                        Colors.grey.shade200,
                                                    child: Text(user.name[0]
                                                        .toUpperCase()),
                                                  ),
                                                  const SizedBox(width: 10),
                                                  Text(
                                                    user.name,
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Divider(
                                                height: 1,
                                                indent: 10,
                                                endIndent: 10,
                                                color: Colors.grey.shade300),
                                            // Collaborators list
                                            ...collaborators
                                                .map((collaborator) => ListTile(
                                                      dense: true,
                                                      leading: CircleAvatar(
                                                        radius: 15,
                                                        backgroundColor: Colors
                                                            .grey.shade200,
                                                        child: Text(collaborator
                                                            .name[0]
                                                            .toUpperCase()),
                                                      ),
                                                      title: Text(
                                                        collaborator.name,
                                                        style: const TextStyle(
                                                            fontSize: 14),
                                                      ),
                                                      trailing: IconButton(
                                                        icon: const Icon(
                                                            Icons
                                                                .remove_circle_outline,
                                                            size: 20),
                                                        onPressed: () =>
                                                            removeCollaborator(
                                                          collaborator,
                                                          setDialogState,
                                                        ),
                                                      ),
                                                    )),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    TextButton(
                                      onPressed: () {
                                        setDialogState(() {
                                          showPhoneField = true;
                                        });
                                      },
                                      child: const Text(
                                        'Add Collaborator',
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                    ),
                                    if (showPhoneField)
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8.0),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: TextField(
                                                maxLength: 10,
                                                buildCounter: (BuildContext
                                                            context,
                                                        {required int
                                                            currentLength,
                                                        required bool isFocused,
                                                        required int?
                                                            maxLength}) =>
                                                    null,
                                                controller: phoneController,
                                                decoration: InputDecoration(
                                                  hintText:
                                                      'Enter phone number',
                                                  hintStyle: TextStyle(
                                                      color:
                                                          Colors.grey.shade400,
                                                      fontSize: 12),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                  suffixIcon:
                                                      isLoadingCollaborator
                                                          ? const SizedBox(
                                                              width: 20,
                                                              height: 20,
                                                              child: Padding(
                                                                padding:
                                                                    EdgeInsets
                                                                        .all(
                                                                            8.0),
                                                                child:
                                                                    CircularProgressIndicator(
                                                                  strokeWidth:
                                                                      2,
                                                                ),
                                                              ),
                                                            )
                                                          : IconButton(
                                                              icon: const Icon(
                                                                  Icons.add),
                                                              onPressed: () =>
                                                                  addCollaborator(
                                                                context,
                                                                phoneController
                                                                    .text,
                                                                setDialogState,
                                                              ),
                                                            ),
                                                ),
                                                keyboardType:
                                                    TextInputType.phone,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    const SizedBox(height: 10),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: () async {
                                          if (listNameController.text.isEmpty) {
                                            listNameController.text = 'Unknown';
                                          }

                                          try {
                                            await Provider.of<ListProvider>(
                                                    context,
                                                    listen: false)
                                                .createList(
                                                    listNameController.text,
                                                    startColor,
                                                    endColor,
                                                    imageAsset,
                                                    user,
                                                    [user, ...collaborators]);
                                            resetDialogState();
                                            Navigator.pop(context);
                                          } catch (e) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                  content: Text(
                                                      'Error creating list: $e')),
                                            );
                                          }
                                        },
                                        child: const Text('Create List'),
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
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Choose your magnet',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge,
                                      ),
                                      const SizedBox(height: 16),
                                      Wrap(
                                        spacing: 10,
                                        runSpacing: 10,
                                        children:
                                            stickers.map((String sticker) {
                                          return GestureDetector(
                                            onTap: () {
                                              Navigator.pop(context);
                                              setDialogState(() {
                                                imageAsset = sticker;
                                              });
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.all(5),
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                    color:
                                                        Colors.grey.shade200),
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
                            height: 50,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              });
            },
          );
        },
        foregroundColor: Colors.black,
        elevation: 0,
        shape: const CircleBorder(),
        backgroundColor: Colors.white.withAlpha(150),
        child: Image.asset('assets/stickers/add.png', height: 50),
      ),
    );
  }
}
