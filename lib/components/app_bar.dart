import 'package:flutter/material.dart';

class TopAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Color backgroundColor = new Color(0xFFA0C5FD);
  final Text title;
  final AppBar appBar;

  TopAppBar({Key? key, required this.title, required this.appBar})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: title,
        backgroundColor: backgroundColor,
      ),
    );
  }

  @override
  Size get preferredSize => new Size.fromHeight(appBar.preferredSize.height);
}
