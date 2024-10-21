import 'package:flutter/material.dart';
import '../pages/menu_page.dart';

class FloatingMenuButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (BuildContext context) {
            return DraggableScrollableSheet(
              initialChildSize: 1.0,
              minChildSize: 1.0,
              maxChildSize: 1.0,
              builder:
                  (BuildContext context, ScrollController scrollController) {
                return SingleChildScrollView(
                  controller: scrollController,
                  child: MenuPage(),
                );
              },
            );
          },
        );
      },
      backgroundColor: Colors.white,
      child: Icon(
        Icons.menu,
        size: 28.0,
      ),
    );
  }
}
