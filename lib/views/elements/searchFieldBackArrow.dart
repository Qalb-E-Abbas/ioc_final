import 'package:flutter/material.dart';

class SearchFieldBackArrow extends StatelessWidget {
  final VoidCallback onTap;
  const SearchFieldBackArrow({Key key, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        Icons.arrow_back,
      ),
      onPressed: () => onTap(),
    );
  }
}
