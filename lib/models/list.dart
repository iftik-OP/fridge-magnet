import 'package:flutter/material.dart';
import 'package:shopping_list/models/user.dart';

class ShoppingList {
  final String name;
  final List<String> items;
  final List<User> collaborators;
  final Color startColor;
  final Color endColor;
  final String imageAsset;

  ShoppingList({
    required this.name,
    required this.items,
    required this.collaborators,
    this.startColor = Colors.transparent,
    this.endColor = Colors.transparent,
    required this.imageAsset,
  });

  ShoppingList copyWith({
    String? name,
    List<String>? items,
    List<User>? collaborators,
    Color? startColor,
    Color? endColor,
    String? imageAsset,
  }) {
    return ShoppingList(
      name: name ?? this.name,
      items: items ?? this.items,
      collaborators: collaborators ?? this.collaborators,
      startColor: startColor ?? this.startColor,
      endColor: endColor ?? this.endColor,
      imageAsset: imageAsset ?? this.imageAsset,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'items': items,
      'collaborators': collaborators.map((user) => user.toMap()).toList(),
      'startColor': startColor.value,
      'endColor': endColor.value,
      'imageAsset': imageAsset,
    };
  }

  factory ShoppingList.fromMap(Map<String, dynamic> map) {
    return ShoppingList(
      name: map['name'] as String,
      items: List<String>.from(map['items']),
      collaborators: List<User>.from(
        (map['collaborators'] as List).map((user) => User.fromMap(user)),
      ),
      startColor: Color(map['startColor'] as int),
      endColor: Color(map['endColor'] as int),
      imageAsset: map['imageAsset'] as String,
    );
  }
}
