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
  final TextEditingController _phoneController = TextEditingController();
  final ListServices _listServices = ListServices();
  String _selectedSticker = '';
  late ShoppingList _currentList;
  bool _showPhoneField = false;
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
    _phoneController.dispose();
    super.dispose();
  }

  void _resetDialogState() {
    setState(() {
      _showPhoneField = false;
      _phoneController.clear();
    });
  }

  void _addCollaborator(
      BuildContext context, String phoneNumber, Function setDialogState) async {
    if (phoneNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a phone number')),
      );
      return;
    }

    setDialogState(() {
      _isLoadingCollaborator = true;
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
        _showPhoneField = false;
        _phoneController.clear();
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
                                                                                            child: Text(_currentList.ownerName[0].toUpperCase()),
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
                                                                                    ..._currentList.collaborators.map((collaborator) => ListTile(
                                                                                          dense: true,
                                                                                          leading: CircleAvatar(
                                                                                            radius: 15,
                                                                                            backgroundColor: Colors.grey.shade200,
                                                                                            child: Text(collaborator.name[0].toUpperCase()),
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
                                                                                  _showPhoneField = true;
                                                                                });
                                                                              },
                                                                              child: const Text(
                                                                                'Add Collaborator',
                                                                                style: TextStyle(color: Colors.grey),
                                                                              ),
                                                                            ),
                                                                            if (_showPhoneField)
                                                                              Padding(
                                                                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                                                                child: Row(
                                                                                  children: [
                                                                                    Expanded(
                                                                                      child: TextField(
                                                                                        maxLength: 10,
                                                                                        buildCounter: (BuildContext context, {required int currentLength, required bool isFocused, required int? maxLength}) => null,
                                                                                        controller: _phoneController,
                                                                                        decoration: InputDecoration(
                                                                                          hintText: 'Enter phone number',
                                                                                          hintStyle: TextStyle(
                                                                                            color: Colors.grey.shade400,
                                                                                            fontSize: 12,
                                                                                          ),
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
                                                                                                    _phoneController.text,
                                                                                                    setDialogState,
                                                                                                  ),
                                                                                                ),
                                                                                        ),
                                                                                        keyboardType: TextInputType.phone,
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
                                        Positioned(
                                          right: 0,
                                          top: 20,
                                          child: GestureDetector(
                                            onTap: () {
                                              showModalBottomSheet(
                                                context: context,
                                                isScrollControlled: true,
                                                constraints: BoxConstraints(
                                                  maxWidth:
                                                      MediaQuery.of(context)
                                                          .size
                                                          .width,
                                                ),
                                                builder:
                                                    (BuildContext context) {
                                                  return Container(
                                                    width: double.infinity,
                                                    padding:
                                                        const EdgeInsets.all(
                                                            16),
                                                    child: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          'Choose your magnet',
                                                          style:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .titleLarge,
                                                        ),
                                                        const SizedBox(
                                                            height: 16),
                                                        Wrap(
                                                          spacing: 10,
                                                          runSpacing: 10,
                                                          children: stickers
                                                              .map((String
                                                                  sticker) {
                                                            return GestureDetector(
                                                              onTap: () {
                                                                Navigator.pop(
                                                                    context);
                                                                setDialogState(
                                                                    () {
                                                                  _selectedSticker =
                                                                      sticker;
                                                                });
                                                              },
                                                              child: Container(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(5),
                                                                decoration:
                                                                    BoxDecoration(
                                                                  border: Border.all(
                                                                      color: Colors
                                                                          .grey
                                                                          .shade200),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              8),
                                                                ),
                                                                child:
                                                                    Image.asset(
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
                                              'assets/stickers/$_selectedSticker',
                                              height: 50,
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
                                      radius: 10,
                                      backgroundColor: Colors.grey[300],
                                      child: Text(
                                        _currentList.collaborators[i].name[0]
                                            .toUpperCase(),
                                        style: const TextStyle(
                                          color: Colors.black87,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 10,
                                        ),
                                      ),
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
                ),
              );
            },
          );
        },
      ),
    );
  }
}
