import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopping_list/models/list.dart';
import 'package:shopping_list/models/user.dart';
import 'package:shopping_list/services/listServices.dart';
import 'package:shopping_list/providers/userProvider.dart';
import 'package:shopping_list/stickers.dart';
import 'dart:math';
import 'package:shopping_list/services/userServices.dart';
import 'package:shopping_list/providers/listProvider.dart';

class ListScreen extends StatefulWidget {
  final ShoppingList list;

  const ListScreen({super.key, required this.list});

  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _listNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final ListServices _listServices = ListServices();
  String _selectedSticker = '';
  late ShoppingList _currentList;
  bool _showEmailField = false;
  bool _isLoadingCollaborator = false;

  @override
  void initState() {
    super.initState();
    _currentList = widget.list;
    _listNameController.text = _currentList.name;
    _selectedSticker = _currentList.imageAsset.split('/').last;
  }

  @override
  void dispose() {
    _textController.dispose();
    _listNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _resetDialogState() {
    setState(() {
      _showEmailField = false;
      _emailController.clear();
    });
  }

  void _addCollaborator(
      BuildContext context, String email, Function setDialogState) async {
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an email')),
      );
      return;
    }

    setDialogState(() {
      _isLoadingCollaborator = true;
    });

    try {
      final userService = UserServices();
      final collaborator = await userService.getUserByEmail(email);

      if (collaborator == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User not found')),
          );
        }
        return;
      }

      // Check if user is already a collaborator
      if (_currentList.collaborators.any((c) => c.uid == collaborator.uid)) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User is already a collaborator')),
          );
        }
        return;
      }

      // Add collaborator through ListProvider
      await Provider.of<ListProvider>(context, listen: false)
          .addCollaborator(_currentList.id!, collaborator);

      // Update local state
      setState(() {
        _currentList = _currentList.copyWith(
          collaborators: [..._currentList.collaborators, collaborator],
        );
      });

      setDialogState(() {
        _showEmailField = false;
        _emailController.clear();
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
          _isLoadingCollaborator = false;
        });
      }
    }
  }

  void _removeCollaborator(User collaborator, Function setDialogState) async {
    try {
      await Provider.of<ListProvider>(context, listen: false)
          .removeCollaborator(_currentList.id!, collaborator.uid);

      // Update local state
      setState(() {
        _currentList = _currentList.copyWith(
          collaborators: _currentList.collaborators
              .where((c) => c.uid != collaborator.uid)
              .toList(),
        );
      });

      // Update dialog state to refresh the UI
      setDialogState(() {});
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error removing collaborator: $e')),
        );
      }
    }
  }

  Future<void> _addNewItem(String name) async {
    if (name.isNotEmpty) {
      final user = Provider.of<UserProvider>(context, listen: false).user;
      if (user == null) return;

      try {
        await _listServices.addItemToList(_currentList.id!, name, user.uid);
        _textController.clear();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error adding item: $e')),
          );
        }
      }
    }
  }

  Future<void> _deleteItem(String itemId) async {
    try {
      await _listServices.removeItemFromList(_currentList.id!, itemId);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error removing item: $e')),
        );
      }
    }
  }

  Future<void> _toggleItemChecked(String itemId, bool currentValue) async {
    try {
      await _listServices.toggleItemChecked(
          _currentList.id!, itemId, !currentValue);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating item: $e')),
        );
      }
    }
  }

  Future<void> _editItem(String itemId, String newValue) async {
    if (newValue.isEmpty) {
      await _deleteItem(itemId);
    } else {
      try {
        await _listServices.updateItemName(_currentList.id!, itemId, newValue);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error updating item: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(120),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [_currentList.startColor, _currentList.endColor],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return StatefulBuilder(
                                builder: (context, setDialogState) {
                                  return Dialog(
                                    child: Stack(
                                      children: [
                                        Container(
                                          height: 270,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(16),
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
                                                      end:
                                                          Alignment.bottomRight,
                                                      colors: [
                                                        _currentList.startColor,
                                                        _currentList.endColor
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.all(
                                                      16.0),
                                                  child: Column(
                                                    children: [
                                                      TextField(
                                                        decoration:
                                                            const InputDecoration(
                                                          hintText:
                                                              'Enter list name',
                                                          enabledBorder:
                                                              InputBorder.none,
                                                          focusedBorder:
                                                              InputBorder.none,
                                                          errorBorder:
                                                              InputBorder.none,
                                                          focusedErrorBorder:
                                                              InputBorder.none,
                                                          border:
                                                              InputBorder.none,
                                                          disabledBorder:
                                                              InputBorder.none,
                                                          hintStyle: TextStyle(
                                                            color: Colors.grey,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                        ),
                                                        style: const TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 24,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                        controller:
                                                            _listNameController,
                                                      ),
                                                      const SizedBox(
                                                          height: 10),
                                                      Divider(
                                                        color: Colors
                                                            .grey.shade200,
                                                        endIndent: 50,
                                                        indent: 50,
                                                      ),
                                                      TextButton(
                                                        onPressed: () {
                                                          _resetDialogState();
                                                          showDialog(
                                                            context: context,
                                                            builder: (context) {
                                                              return StatefulBuilder(
                                                                builder: (context,
                                                                    setDialogState) {
                                                                  return Dialog(
                                                                    child:
                                                                        Container(
                                                                      height:
                                                                          500,
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        borderRadius:
                                                                            BorderRadius.circular(16),
                                                                      ),
                                                                      child:
                                                                          Padding(
                                                                        padding: const EdgeInsets
                                                                            .all(
                                                                            16.0),
                                                                        child:
                                                                            Column(
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          children: [
                                                                            Text(
                                                                              'Manage Collaborators',
                                                                              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 24),
                                                                            ),
                                                                            const SizedBox(height: 20),
                                                                            Container(
                                                                              height: 200,
                                                                              child: SingleChildScrollView(
                                                                                child: Column(
                                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                                  children: [
                                                                                    // Owner section
                                                                                    Padding(
                                                                                      padding: const EdgeInsets.all(8.0),
                                                                                      child: Row(
                                                                                        children: [
                                                                                          CircleAvatar(
                                                                                            radius: 15,
                                                                                            backgroundColor: Colors.grey.shade200,
                                                                                            backgroundImage: _currentList.ownerUid == Provider.of<UserProvider>(context).user?.uid && Provider.of<UserProvider>(context).user?.profilePicture != null ? NetworkImage(Provider.of<UserProvider>(context).user!.profilePicture!) : null,
                                                                                            child: (_currentList.ownerUid == Provider.of<UserProvider>(context).user?.uid && Provider.of<UserProvider>(context).user?.profilePicture == null) ? Text(_currentList.ownerName[0].toUpperCase()) : null,
                                                                                          ),
                                                                                          const SizedBox(width: 10),
                                                                                          Text(
                                                                                            _currentList.ownerName,
                                                                                            style: const TextStyle(
                                                                                              fontWeight: FontWeight.w500,
                                                                                            ),
                                                                                          ),
                                                                                        ],
                                                                                      ),
                                                                                    ),
                                                                                    Divider(
                                                                                      height: 1,
                                                                                      indent: 10,
                                                                                      endIndent: 10,
                                                                                      color: Colors.grey.shade300,
                                                                                    ),
                                                                                    // Collaborators list
                                                                                    ..._currentList.collaborators.where((collaborator) => collaborator.uid != Provider.of<UserProvider>(context).user?.uid).map((collaborator) => ListTile(
                                                                                          dense: true,
                                                                                          leading: CircleAvatar(
                                                                                            radius: 15,
                                                                                            backgroundColor: Colors.grey.shade200,
                                                                                            backgroundImage: collaborator.profilePicture != null ? NetworkImage(collaborator.profilePicture!) : null,
                                                                                            child: collaborator.profilePicture == null ? Text(collaborator.name[0].toUpperCase()) : null,
                                                                                          ),
                                                                                          title: Text(
                                                                                            collaborator.name,
                                                                                            style: const TextStyle(fontSize: 14),
                                                                                          ),
                                                                                          trailing: IconButton(
                                                                                            icon: const Icon(Icons.remove_circle_outline, size: 20),
                                                                                            onPressed: () => _removeCollaborator(collaborator, setDialogState),
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
                                                                                  _showEmailField = true;
                                                                                });
                                                                              },
                                                                              child: const Text(
                                                                                'Add Collaborator',
                                                                                style: TextStyle(color: Colors.grey),
                                                                              ),
                                                                            ),
                                                                            if (_showEmailField)
                                                                              Padding(
                                                                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                                                                child: Row(
                                                                                  children: [
                                                                                    Expanded(
                                                                                      child: TextField(
                                                                                        controller: _emailController,
                                                                                        decoration: InputDecoration(
                                                                                          hintText: 'Enter email address',
                                                                                          border: OutlineInputBorder(
                                                                                            borderRadius: BorderRadius.circular(8),
                                                                                          ),
                                                                                          suffixIcon: _isLoadingCollaborator
                                                                                              ? const SizedBox(
                                                                                                  width: 20,
                                                                                                  height: 20,
                                                                                                  child: Padding(
                                                                                                    padding: EdgeInsets.all(8.0),
                                                                                                    child: CircularProgressIndicator(
                                                                                                      strokeWidth: 2,
                                                                                                    ),
                                                                                                  ),
                                                                                                )
                                                                                              : IconButton(
                                                                                                  icon: const Icon(Icons.add),
                                                                                                  onPressed: () => _addCollaborator(
                                                                                                    context,
                                                                                                    _emailController.text,
                                                                                                    setDialogState,
                                                                                                  ),
                                                                                                ),
                                                                                        ),
                                                                                        keyboardType: TextInputType.emailAddress,
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                            const Spacer(),
                                                                            SizedBox(
                                                                              width: double.infinity,
                                                                              child: ElevatedButton(
                                                                                onPressed: () {
                                                                                  Navigator.pop(context);
                                                                                },
                                                                                child: const Text('Done'),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  );
                                                                },
                                                              );
                                                            },
                                                          );
                                                        },
                                                        child: const Text(
                                                          'Manage Collaborators',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.grey),
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                          height: 10),
                                                      SizedBox(
                                                        width: double.infinity,
                                                        child: ElevatedButton(
                                                          onPressed: () async {
                                                            if (_listNameController
                                                                .text.isEmpty) {
                                                              _listNameController
                                                                      .text =
                                                                  'Unknown';
                                                            }

                                                            try {
                                                              final updatedList =
                                                                  _currentList
                                                                      .copyWith(
                                                                name:
                                                                    _listNameController
                                                                        .text,
                                                                imageAsset:
                                                                    _selectedSticker,
                                                              );

                                                              // Update list through ListProvider
                                                              await Provider.of<
                                                                          ListProvider>(
                                                                      context,
                                                                      listen:
                                                                          false)
                                                                  .updateShoppingList(
                                                                _currentList
                                                                    .id!,
                                                                updatedList,
                                                              );

                                                              // Update local state
                                                              setState(() {
                                                                _currentList =
                                                                    updatedList;
                                                              });

                                                              Navigator.pop(
                                                                  context);
                                                            } catch (e) {
                                                              if (mounted) {
                                                                ScaffoldMessenger.of(
                                                                        context)
                                                                    .showSnackBar(
                                                                  SnackBar(
                                                                      content: Text(
                                                                          'Error updating list: $e')),
                                                                );
                                                              }
                                                            }
                                                          },
                                                          child: const Text(
                                                              'Update List'),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                          );
                        },
                        child: SizedBox(
                          width: _currentList.collaborators.length <= 3
                              ? _currentList.collaborators.length * 24.0
                              : 3 * 24.0 + 24.0,
                          height: 40,
                          child: Stack(
                            children: [
                              for (int i = 0;
                                  i <
                                      (_currentList.collaborators.length <= 3
                                          ? _currentList.collaborators.length
                                          : 3);
                                  i++)
                                Positioned(
                                  left: i * 16.0,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: Colors.white, width: 2),
                                    ),
                                    child: CircleAvatar(
                                      radius: 13,
                                      backgroundColor: Colors.grey[300],
                                      backgroundImage: _currentList
                                                  .collaborators[i]
                                                  .profilePicture !=
                                              null
                                          ? NetworkImage(_currentList
                                              .collaborators[i].profilePicture!)
                                          : null,
                                      child: _currentList.collaborators[i]
                                                  .profilePicture ==
                                              null
                                          ? Text(
                                              _currentList
                                                  .collaborators[i].name[0]
                                                  .toUpperCase(),
                                              style: const TextStyle(
                                                color: Colors.black87,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 10,
                                              ),
                                            )
                                          : null,
                                    ),
                                  ),
                                ),
                              if (_currentList.collaborators.length > 3)
                                Positioned(
                                  left: 3 * 16.0,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: Colors.white, width: 2),
                                    ),
                                    child: CircleAvatar(
                                      radius: 10,
                                      backgroundColor: Colors.grey[800],
                                      child: Text(
                                        "+${_currentList.collaborators.length - 3}",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                  Expanded(
                    child: Hero(
                      tag: 'list_title_${_currentList.name}',
                      child: Material(
                        color: Colors.transparent,
                        child: Text(
                          _currentList.name,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                blurRadius: 2,
                                color: Colors.black26,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: StreamBuilder<ShoppingList?>(
        stream: _listServices.getShoppingList(_currentList.id!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final currentList = snapshot.data ?? _currentList;

          return ListView.builder(
            itemCount: currentList.items.length + 1,
            itemBuilder: (context, index) {
              if (index == currentList.items.length) {
                return ListTile(
                  title: TextField(
                    controller: _textController,
                    decoration: const InputDecoration(
                      hintText: ' + Add new item',
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      focusedErrorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                    ),
                    onSubmitted: _addNewItem,
                  ),
                );
              }

              final item = currentList.items[index];
              return Dismissible(
                key: ValueKey(item.id),
                background: Container(
                  color: Colors.white,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 16),
                  child: const Icon(Icons.delete, color: Colors.red),
                ),
                direction: DismissDirection.endToStart,
                onDismissed: (direction) => _deleteItem(item.id),
                child: ListTile(
                  leading: InkWell(
                    onTap: () => _toggleItemChecked(item.id, item.isChecked),
                    child: Icon(
                      item.isChecked
                          ? Icons.check_box
                          : Icons.check_box_outline_blank,
                      color: item.isChecked ? Colors.green : Colors.grey,
                    ),
                  ),
                  title: TextField(
                    controller: TextEditingController(text: item.name),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      focusedErrorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                    ),
                    style: TextStyle(
                      decoration:
                          item.isChecked ? TextDecoration.lineThrough : null,
                      color: item.isChecked ? Colors.grey : Colors.black,
                    ),
                    onSubmitted: (value) => _editItem(item.id, value),
                  ),
                  subtitle: Text(_currentList.collaborators
                      .firstWhere((c) => c.uid == item.addedBy)
                      .name),
                  subtitleTextStyle: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
