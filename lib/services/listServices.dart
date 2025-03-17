import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shopping_list/models/list.dart';
import 'package:shopping_list/models/listItem.dart';
import 'package:uuid/uuid.dart';

class ListServices {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get all lists for a specific user (where they are owner or collaborator)
  Stream<List<ShoppingList>> getUserLists(String userId) {
    // Get lists where user is owner or collaborator
    return _firestore
        .collection('lists')
        .where(Filter.or(
          Filter('ownerUid', isEqualTo: userId),
          Filter('collaborators', arrayContains: {'id': userId}),
        ))
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ShoppingList.fromMap(doc.data(), doc.id))
          .toList();

      // Remove duplicates based on list ID
      // return lists.fold<List<ShoppingList>>(
      //   [],
      //   (list, element) {
      //     if (!list.any((item) => item.id == element.id)) {
      //       list.add(element);
      //     }
      //     return list;
      //   },
      // );
    });
  }

  // Get a stream of a specific shopping list
  Stream<ShoppingList?> getShoppingList(String listId) {
    return _firestore.collection('lists').doc(listId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return ShoppingList.fromMap(doc.data()!);
    });
  }

  // Create a new shopping list
  Future<String> createShoppingList(ShoppingList list) async {
    final docRef = await _firestore.collection('lists').add(list.toMap());
    return docRef.id;
  }

  // Update a shopping list
  Future<void> updateShoppingList(String listId, ShoppingList list) async {
    final listRef = _firestore.collection('lists').doc(listId);
    final listDoc = await listRef.get();

    if (!listDoc.exists) return;

    final currentData = listDoc.data()!;
    final updatedData = list.toMap();

    // Only update fields that have changed
    final Map<String, dynamic> updateData = {};

    if (currentData['name'] != updatedData['name']) {
      updateData['name'] = updatedData['name'];
    }
    if (currentData['imageAsset'] != updatedData['imageAsset']) {
      updateData['imageAsset'] = updatedData['imageAsset'];
    }
    if (currentData['startColor'] != updatedData['startColor']) {
      updateData['startColor'] = updatedData['startColor'];
    }
    if (currentData['endColor'] != updatedData['endColor']) {
      updateData['endColor'] = updatedData['endColor'];
    }
    if (currentData['collaborators'] != updatedData['collaborators']) {
      updateData['collaborators'] = updatedData['collaborators'];
    }
    if (currentData['ownerUid'] != updatedData['ownerUid']) {
      updateData['ownerUid'] = updatedData['ownerUid'];
    }
    if (currentData['ownerName'] != updatedData['ownerName']) {
      updateData['ownerName'] = updatedData['ownerName'];
    }

    // Always update the timestamp
    updateData['updatedAt'] = DateTime.now().toIso8601String();

    if (updateData.isNotEmpty) {
      await listRef.update(updateData);
    }
  }

  // Delete a shopping list
  Future<void> deleteShoppingList(String listId) async {
    await _firestore.collection('lists').doc(listId).delete();
  }

  // Add a new item to the list
  Future<void> addItemToList(String listId, String name, String userId) async {
    final listRef = _firestore.collection('lists').doc(listId);
    final newItem = ListItem(
      id: const Uuid().v4(),
      name: name,
      isChecked: false,
      addedBy: userId,
      addedAt: DateTime.now(),
    );

    await listRef.update({
      'items': FieldValue.arrayUnion([newItem.toMap()])
    });
  }

  // Remove an item from the list
  Future<void> removeItemFromList(String listId, String itemId) async {
    final listRef = _firestore.collection('lists').doc(listId);
    final listDoc = await listRef.get();

    if (!listDoc.exists) return;

    final list = ShoppingList.fromMap(listDoc.data()!);
    final updatedItems = list.items.where((item) => item.id != itemId).toList();

    await listRef
        .update({'items': updatedItems.map((item) => item.toMap()).toList()});
  }

  // Toggle item checked status
  Future<void> toggleItemChecked(
      String listId, String itemId, bool isChecked) async {
    final listRef = _firestore.collection('lists').doc(listId);
    final listDoc = await listRef.get();

    if (!listDoc.exists) return;

    final list = ShoppingList.fromMap(listDoc.data()!);
    final updatedItems = list.items.map((item) {
      if (item.id == itemId) {
        return item.copyWith(isChecked: isChecked);
      }
      return item;
    }).toList();

    await listRef
        .update({'items': updatedItems.map((item) => item.toMap()).toList()});
  }

  // Update item name
  Future<void> updateItemName(
      String listId, String itemId, String newName) async {
    final listRef = _firestore.collection('lists').doc(listId);
    final listDoc = await listRef.get();

    if (!listDoc.exists) return;

    final list = ShoppingList.fromMap(listDoc.data()!);
    final updatedItems = list.items.map((item) {
      if (item.id == itemId) {
        return item.copyWith(name: newName);
      }
      return item;
    }).toList();

    await listRef
        .update({'items': updatedItems.map((item) => item.toMap()).toList()});
  }
}
