import 'package:flutter/material.dart';
import 'package:shopping_list/models/list.dart';
import 'package:shopping_list/models/user.dart';
import 'package:shopping_list/services/listServices.dart';
import 'package:shopping_list/providers/userProvider.dart';

class ListProvider with ChangeNotifier {
  final ListServices _listServices = ListServices();
  List<ShoppingList> _lists = [];
  bool _isLoading = false;

  List<ShoppingList> get lists => _lists;
  bool get isLoading => _isLoading;

  // Fetch all lists for the current user
  Future<void> fetchLists() async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = UserProvider().user;
      if (user == null) {
        _lists = [];
        return;
      }

      // Get lists where user is owner or collaborator
      final listsStream = _listServices.getUserLists(user.uid);
      await for (final lists in listsStream) {
        _lists = lists;
        notifyListeners();
      }
    } catch (e) {
      print('Error fetching lists: $e');
      _lists = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create a new shopping list
  Future<void> createList(String name, Color startColor, Color endColor,
      String imageAsset, User user, List<User> collaborators) async {
    try {
      final newList = ShoppingList(
        name: name,
        collaborators:
            collaborators, // Initially empty, owner will be added by service
        startColor: startColor,
        endColor: endColor,
        items: [],
        imageAsset: '$imageAsset',
        ownerUid: user.uid,
        ownerName: user.name,
      );

      await _listServices.createShoppingList(newList);
      await fetchLists(); // Refresh the lists
    } catch (e) {
      print('Error creating list: $e');
      rethrow;
    }
  }

  // Add a new item to a list
  Future<void> addItem(String listId, String name, String userId) async {
    try {
      await _listServices.addItemToList(listId, name, userId);
      await fetchLists(); // Refresh the lists
    } catch (e) {
      print('Error adding item: $e');
      rethrow;
    }
  }

  // Remove an item from a list
  Future<void> removeItem(String listId, String itemId) async {
    try {
      await _listServices.removeItemFromList(listId, itemId);
      await fetchLists(); // Refresh the lists
    } catch (e) {
      print('Error removing item: $e');
      rethrow;
    }
  }

  // Toggle item checked status
  Future<void> toggleItemChecked(
      String listId, String itemId, bool currentValue) async {
    try {
      await _listServices.toggleItemChecked(listId, itemId, !currentValue);
      await fetchLists(); // Refresh the lists
    } catch (e) {
      print('Error toggling item: $e');
      rethrow;
    }
  }

  // Update item name
  Future<void> updateItemName(
      String listId, String itemId, String newName) async {
    try {
      await _listServices.updateItemName(listId, itemId, newName);
      await fetchLists(); // Refresh the lists
    } catch (e) {
      print('Error updating item name: $e');
      rethrow;
    }
  }

  // Delete a shopping list
  Future<void> deleteList(String listId) async {
    try {
      await _listServices.deleteShoppingList(listId);
      await fetchLists(); // Refresh the lists
    } catch (e) {
      print('Error deleting list: $e');
      rethrow;
    }
  }

  // Update list name
  Future<void> updateListName(String listId, String newName) async {
    try {
      final list = _lists.firstWhere((l) => l.id == listId);
      final updatedList = list.copyWith(
        name: newName,
      );
      await _listServices.updateShoppingList(listId, updatedList);
      await fetchLists(); // Refresh the lists
    } catch (e) {
      print('Error updating list name: $e');
      rethrow;
    }
  }

  // Add a collaborator to a list
  Future<void> addCollaborator(String listId, User collaborator) async {
    try {
      // First try to find the list in _lists
      ShoppingList? list;
      try {
        list = _lists.firstWhere((list) => list.id == listId);
      } catch (e) {
        // If not found in _lists, try to get it from the service
        list = await _listServices.getShoppingList(listId).first;
      }

      if (list == null) {
        throw Exception('List not found');
      }

      // Check if user is already a collaborator
      if (list.collaborators.any((c) => c.uid == collaborator.uid)) {
        throw Exception('User is already a collaborator');
      }

      // Add the collaborator
      final updatedList = list.copyWith(
        collaborators: [...list.collaborators, collaborator],
      );

      // Update in Firestore
      await _listServices.updateShoppingList(listId, updatedList);

      // Update local state
      await fetchLists();
    } catch (e) {
      throw Exception('Error adding collaborator: $e');
    }
  }

  // Remove a collaborator from a list
  Future<void> removeCollaborator(String listId, String userId) async {
    try {
      // First try to find the list in _lists
      ShoppingList? list;
      try {
        list = _lists.firstWhere((l) => l.id == listId);
      } catch (e) {
        // If not found in _lists, get it from the service
        final listStream = _listServices.getShoppingList(listId);
        list = await listStream.first;
        if (list == null) {
          throw Exception('List not found');
        }
      }

      final updatedList = list.copyWith(
        collaborators:
            list.collaborators.where((c) => c.uid != userId).toList(),
      );
      await _listServices.updateShoppingList(listId, updatedList);
      await fetchLists(); // Refresh the lists
    } catch (e) {
      print('Error removing collaborator: $e');
      rethrow;
    }
  }

  // Update a shopping list
  Future<void> updateShoppingList(
      String listId, ShoppingList updatedList) async {
    try {
      await _listServices.updateShoppingList(listId, updatedList);
      await fetchLists(); // Refresh the lists
    } catch (e) {
      print('Error updating list: $e');
      rethrow;
    }
  }
}
