import 'package:cloud_firestore/cloud_firestore.dart';

class ListItem {
  final String id;
  final String name;
  final bool isChecked;
  final String addedBy;
  final DateTime addedAt;

  ListItem({
    required this.id,
    required this.name,
    required this.isChecked,
    required this.addedBy,
    required this.addedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'isChecked': isChecked,
      'addedBy': addedBy,
      'addedAt': Timestamp.fromDate(addedAt),
    };
  }

  factory ListItem.fromMap(Map<String, dynamic> map) {
    return ListItem(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      isChecked: map['isChecked'] ?? false,
      addedBy: map['addedBy'] ?? '',
      addedAt: (map['addedAt'] as Timestamp).toDate(),
    );
  }

  ListItem copyWith({
    String? id,
    String? name,
    bool? isChecked,
    String? addedBy,
    DateTime? addedAt,
  }) {
    return ListItem(
      id: id ?? this.id,
      name: name ?? this.name,
      isChecked: isChecked ?? this.isChecked,
      addedBy: addedBy ?? this.addedBy,
      addedAt: addedAt ?? this.addedAt,
    );
  }
}
