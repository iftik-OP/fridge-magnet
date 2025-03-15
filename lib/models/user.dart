import 'package:flutter/material.dart';
import 'package:shopping_list/models/list.dart';

class User {
  final String phoneNumber;
  final String name;
  final List<ShoppingList> lists;
  final String? profilePicture;

  User({
    required this.phoneNumber,
    required this.name,
    required this.lists,
    this.profilePicture,
  });

  User copyWith({
    String? phoneNumber,
    String? name, 
    List<ShoppingList>? lists,
    String? profilePicture,
  }) {
    return User(
      phoneNumber: phoneNumber ?? this.phoneNumber,
      name: name ?? this.name,
      lists: lists ?? this.lists,
      profilePicture: profilePicture ?? this.profilePicture,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'phoneNumber': phoneNumber,
      'name': name,
      'lists': lists.map((list) => list.toMap()).toList(),
      'profilePicture': profilePicture,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      phoneNumber: map['phoneNumber'] as String,
      name: map['name'] as String,
      lists: List<ShoppingList>.from(
        (map['lists'] as List).map((list) => ShoppingList.fromMap(list)),
      ),
      profilePicture: map['profilePicture'] as String?,
    );
  }
}
