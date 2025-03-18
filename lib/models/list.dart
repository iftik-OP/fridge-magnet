import 'package:flutter/material.dart';
import 'package:shopping_list/models/listItem.dart';
import 'package:shopping_list/models/user.dart';

class ShoppingList {
  final String? id; // Firebase document ID
  final String name;
  final List<User> collaborators; // Store full User objects
  final Color startColor;
  final Color endColor;
  final List<ListItem> items;
  final String imageAsset;
  final String ownerUid; // Owner's Firebase UID
  final String ownerName; // Owner's name

  ShoppingList({
    this.id,
    required this.name,
    required this.collaborators,
    required this.startColor,
    required this.endColor,
    required this.items,
    required this.imageAsset,
    required this.ownerUid,
    required this.ownerName,
  });

  ShoppingList copyWith({
    String? id,
    String? name,
    List<User>? collaborators,
    Color? startColor,
    Color? endColor,
    List<ListItem>? items,
    String? imageAsset,
    String? ownerUid,
    String? ownerName,
  }) {
    return ShoppingList(
      id: id ?? this.id,
      name: name ?? this.name,
      collaborators: collaborators ?? this.collaborators,
      startColor: startColor ?? this.startColor,
      endColor: endColor ?? this.endColor,
      items: items ?? this.items,
      imageAsset: imageAsset ?? this.imageAsset,
      ownerUid: ownerUid ?? this.ownerUid,
      ownerName: ownerName ?? this.ownerName,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'collaborators': collaborators.map((user) => user.toMap()).toList(),
      'startColor': startColor.value,
      'endColor': endColor.value,
      'items': items.map((item) => item.toMap()).toList(),
      'imageAsset': imageAsset,
      'ownerUid': ownerUid,
      'ownerName': ownerName,
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }

  factory ShoppingList.fromMap(Map<String, dynamic> map, [String? documentId]) {
    return ShoppingList(
      id: documentId ?? map['id'] as String?,
      name: map['name'] as String,
      collaborators: (map['collaborators'] as List)
          .map((userMap) => User.fromMap(userMap))
          .toList(),
      startColor: Color(map['startColor'] ?? 0xFF000000),
      endColor: Color(map['endColor'] ?? 0xFF000000),
      items:
          (map['items'] as List).map((item) => ListItem.fromMap(item)).toList(),
      imageAsset: map['imageAsset'] as String,
      ownerUid: map['ownerUid'] as String,
      ownerName: map['ownerName'] as String,
    );
  }
}
