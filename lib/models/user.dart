import 'package:shopping_list/models/list.dart';
import 'package:flutter/material.dart';

class User {
  final String email;
  final String name;
  final List<ShoppingList> lists;
  final String? profilePicture;
  final String uid;

  User({
    required this.email,
    required this.name,
    required this.lists,
    this.profilePicture,
    required this.uid,
  });

  User copyWith({
    String? email,
    String? name,
    List<ShoppingList>? lists,
    String? profilePicture,
    String? uid,
  }) {
    return User(
      email: email ?? this.email,
      name: name ?? this.name,
      lists: lists ?? this.lists,
      profilePicture: profilePicture ?? this.profilePicture,
      uid: uid ?? this.uid,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'lists': lists.map((list) => list.toMap()).toList(),
      'profilePicture': profilePicture,
      'uid': uid,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      email: map['email'] as String,
      name: map['name'] as String,
      lists: (map['lists'] as List<dynamic>?)?.map((list) {
            if (list is Map<String, dynamic>) {
              return ShoppingList.fromMap(list);
            }
            return ShoppingList(
              name: '',
              collaborators: [],
              startColor: const Color(0xFF000000),
              endColor: const Color(0xFF000000),
              items: [],
              imageAsset: '',
              ownerUid: '',
              ownerName: '',
            );
          }).toList() ??
          [],
      profilePicture: map['profilePicture'] as String?,
      uid: map['uid'] as String,
    );
  }
}
