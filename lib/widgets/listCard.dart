import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shopping_list/screens/listScreen.dart';
import 'package:shopping_list/models/user.dart';

class ListCard extends StatelessWidget {
  final String listName;
  final List<User> collaborators;
  final Color startColor;
  final Color endColor;
  final String imageAsset;

  /// Creates a shopping list card with collaborator avatars.
  ///
  /// If colors are not provided, random gradient colors will be generated.
  const ListCard({
    Key? key,
    required this.listName,
    required this.collaborators,
    this.startColor = Colors.transparent,
    this.endColor = Colors.transparent,
    this.imageAsset = 'assets/stickers/cup.png',
  }) : super(key: key);

  /// Creates a shopping list card with random gradient colors.
  factory ListCard.random({
    required String listName,
    required List<User> collaborators,
  }) {
    final random = Random();

    // Generate random bright colors for better contrast with text
    final startColor = Color.fromRGBO(
      150 + random.nextInt(105), // 150-255 for brighter colors
      150 + random.nextInt(105),
      150 + random.nextInt(105),
      1,
    );

    final endColor = Color.fromRGBO(
      150 + random.nextInt(105),
      150 + random.nextInt(105),
      150 + random.nextInt(105),
      1,
    );

    return ListCard(
      listName: listName,
      collaborators: collaborators,
      startColor: startColor,
      endColor: endColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Use random colors if transparent colors were provided
    final Color actualStartColor = startColor == Colors.transparent
        ? Color.fromRGBO(
            150 + Random().nextInt(105),
            150 + Random().nextInt(105),
            150 + Random().nextInt(105),
            1,
          )
        : startColor;

    final Color actualEndColor = endColor == Colors.transparent
        ? Color.fromRGBO(
            150 + Random().nextInt(105),
            150 + Random().nextInt(105),
            150 + Random().nextInt(105),
            1,
          )
        : endColor;

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ListScreen(
              listName: listName,
              collaborators: collaborators,
              startColor: actualStartColor,
              endColor: actualEndColor,
            ),
          ),
        );
      },
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: 160,
        child: Stack(
          children: [
            Positioned(
              top: 40,
              left: 0,
              right: 0,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 0),
                child: Container(
                  height: 120,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [actualStartColor, actualEndColor],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        top: 16,
                        left: 16,
                        child: Hero(
                          tag: 'list_title_${listName}',
                          child: Material(
                            color: Colors.transparent,
                            child: Text(
                              listName,
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
                      Positioned(
                        bottom: 5,
                        right: 16,
                        child: _buildCollaboratorAvatars(),
                      ),
                      Positioned(
                        bottom: 16,
                        left: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.shopping_cart_outlined,
                                  color: Colors.white, size: 10),
                              SizedBox(width: 4),
                              Text(
                                "Tap to view items",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: Image.asset(
                imageAsset,
                width: 100,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCollaboratorAvatars() {
    // Maximum number of avatars to show before using a "+X more" indicator
    const int maxDisplayed = 3;

    final displayCount = collaborators.length <= maxDisplayed
        ? collaborators.length
        : maxDisplayed;

    final hasMoreCollaborators = collaborators.length > maxDisplayed;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: displayCount * 24.0 + (hasMoreCollaborators ? 24.0 : 0.0),
          height: 40,
          child: Stack(
            children: [
              for (int i = 0; i < displayCount; i++)
                Positioned(
                  left: i * 16.0,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: CircleAvatar(
                      radius: 10,
                      backgroundColor: Colors.grey[300],
                      child: Text(
                        collaborators[i].name[0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                ),
              if (hasMoreCollaborators)
                Positioned(
                  left: displayCount * 16.0,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: CircleAvatar(
                      radius: 10,
                      backgroundColor: Colors.grey[800],
                      child: Text(
                        "+${collaborators.length - maxDisplayed}",
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
    );
  }
}
