import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shopping_list/models/list.dart';
import 'package:shopping_list/models/listItem.dart';
import 'package:uuid/uuid.dart';
import 'package:rxdart/rxdart.dart';

class ListServices {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get all lists for a specific user (where they are owner or collaborator)
  Stream<List<ShoppingList>> getUserLists(String userId) {
    // Get the user document to get their lists array
    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .asyncMap((userDoc) async {
      if (!userDoc.exists) return [];

      final userData = userDoc.data() as Map<String, dynamic>;
      final List<String> listIds = List<String>.from(userData['lists'] ?? []);

      if (listIds.isEmpty) return [];

      // Get all lists where the ID is in the user's lists array
      final listsSnapshot = await _firestore
          .collection('lists')
          .where(FieldPath.documentId, whereIn: listIds)
          .get();

      return listsSnapshot.docs
          .map((doc) => ShoppingList.fromMap(doc.data(), doc.id))
          .toList();
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

    // Update lists array for owner
    await _firestore.collection('users').doc(list.ownerUid).update({
      'lists': FieldValue.arrayUnion([docRef.id])
    });

    // Update lists array for all collaborators
    for (var collaborator in list.collaborators) {
      await _firestore.collection('users').doc(collaborator.uid).update({
        'lists': FieldValue.arrayUnion([docRef.id])
      });
    }

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

      // Get the old list to compare collaborators
      final oldList = ShoppingList.fromMap(currentData);

      // Find removed collaborators
      final removedCollaborators = oldList.collaborators
          .where((c) => !list.collaborators.any((nc) => nc.uid == c.uid))
          .toList();

      // Find new collaborators
      final newCollaborators = list.collaborators
          .where((c) => !oldList.collaborators.any((oc) => oc.uid == c.uid))
          .toList();

      // Update lists arrays for removed collaborators
      for (var collaborator in removedCollaborators) {
        await _firestore.collection('users').doc(collaborator.uid).update({
          'lists': FieldValue.arrayRemove([listId])
        });
      }

      // Update lists arrays for new collaborators
      for (var collaborator in newCollaborators) {
        await _firestore.collection('users').doc(collaborator.uid).update({
          'lists': FieldValue.arrayUnion([listId])
        });
      }
    }
    if (currentData['ownerUid'] != updatedData['ownerUid']) {
      updateData['ownerUid'] = updatedData['ownerUid'];

      // Update lists arrays for old and new owners
      await _firestore.collection('users').doc(currentData['ownerUid']).update({
        'lists': FieldValue.arrayRemove([listId])
      });
      await _firestore.collection('users').doc(updatedData['ownerUid']).update({
        'lists': FieldValue.arrayUnion([listId])
      });
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
    final listDoc = await _firestore.collection('lists').doc(listId).get();
    if (!listDoc.exists) return;

    final list = ShoppingList.fromMap(listDoc.data()!);

    // Remove list ID from owner's lists array
    await _firestore.collection('users').doc(list.ownerUid).update({
      'lists': FieldValue.arrayRemove([listId])
    });

    // Remove list ID from all collaborators' lists arrays
    for (var collaborator in list.collaborators) {
      await _firestore.collection('users').doc(collaborator.uid).update({
        'lists': FieldValue.arrayRemove([listId])
      });
    }

    // Delete the list document
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
