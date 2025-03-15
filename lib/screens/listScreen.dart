import 'package:flutter/material.dart';
import 'dart:math';
import 'package:shopping_list/models/user.dart';

class ListScreen extends StatefulWidget {
  final String listName;
  final List<User> collaborators;
  final Color startColor;
  final Color endColor;
  const ListScreen(
      {super.key,
      required this.listName,
      required this.collaborators,
      required this.startColor,
      required this.endColor});

  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  final List<ShoppingItem> _items = [];

  final ScrollController _scrollController = ScrollController();
  bool _isCollapsed = false;

  // Generate random gradient colors for consistency

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.offset > 100 && !_isCollapsed) {
      setState(() {
        _isCollapsed = true;
      });
    } else if (_scrollController.offset <= 100 && _isCollapsed) {
      setState(() {
        _isCollapsed = false;
      });
    }
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final ShoppingItem item = _items.removeAt(oldIndex);
      _items.insert(newIndex, item);
    });
  }

  void _toggleItem(int index) {
    setState(() {
      _items[index].isChecked = !_items[index].isChecked;

      // Move checked items to end
      if (_items[index].isChecked) {
        final item = _items.removeAt(index);
        _items.add(item);
      }
    });
  }

  void _deleteItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              automaticallyImplyLeading: false,
              expandedHeight: 120.0,
              floating: false,
              pinned: true,
              flexibleSpace: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [widget.startColor, widget.endColor],
                  ),
                ),
                child: FlexibleSpaceBar(
                  title: Hero(
                    tag: 'list_title_${widget.listName}',
                    child: Material(
                      color: Colors.transparent,
                      child: Text(
                        widget.listName,
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
                  titlePadding: EdgeInsets.only(
                    left: _isCollapsed ? 16 : 16,
                    bottom: 16,
                  ),
                ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: widget.collaborators.length <= 3
                            ? widget.collaborators.length * 24.0
                            : 3 * 24.0 + 24.0,
                        height: 40,
                        child: Stack(
                          children: [
                            for (int i = 0;
                                i <
                                    (widget.collaborators.length <= 3
                                        ? widget.collaborators.length
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
                                      widget.collaborators[i].name[0]
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
                            if (widget.collaborators.length > 3)
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
                                      "+${widget.collaborators.length - 3}",
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
                    ],
                  ),
                ),
              ],
            ),
          ];
        },
        body: ReorderableListView.builder(
          itemCount: _items.length,
          onReorder: _onReorder,
          itemBuilder: (context, index) {
            final item = _items[index];
            return Dismissible(
              key: ValueKey('${item.name}_$index'),
              background: Container(
                color: Colors.white,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 16),
                child: const Icon(Icons.delete, color: Colors.red),
              ),
              direction: DismissDirection.endToStart,
              onDismissed: (direction) => _deleteItem(index),
              child: ListTile(
                key: ValueKey('item_${item.name}_$index'),
                leading: Checkbox(
                  value: item.isChecked,
                  onChanged: (bool? value) => _toggleItem(index),
                ),
                title: Text(
                  item.name,
                  style: TextStyle(
                    decoration:
                        item.isChecked ? TextDecoration.lineThrough : null,
                  ),
                ),
                trailing: const Icon(Icons.drag_handle),
              ),
            );
          },
        ),
      ),
    );
  }
}

class ShoppingItem {
  String name;
  bool isChecked;

  ShoppingItem({
    required this.name,
    required this.isChecked,
  });
}
