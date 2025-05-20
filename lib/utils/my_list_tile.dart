import 'package:flutter/material.dart';

class MyListTile extends StatefulWidget {
  final String title;
  final String imageIcon; // Changed to `imageIcon` for clarity
  final VoidCallback onTap;

  const MyListTile({
    super.key,
    required this.title,
    required this.imageIcon,
    required this.onTap,
  });

  @override
  _MyListTileState createState() => _MyListTileState();
}

class _MyListTileState extends State<MyListTile> {
  bool _isHovered = false; // To track hover state

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() {
        _isHovered = true;
      }),
      onExit: (_) => setState(() {
        _isHovered = false;
      }),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          decoration: BoxDecoration(
            color: _isHovered ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10), // Rounded border
          ),
          child: ListTile(
            leading: Image.asset(
              widget.imageIcon,
              width: 24,
              height: 24,

            ),
            title: Text(
              widget.title,
              style: TextStyle(
                color: _isHovered ? Colors.blue : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
