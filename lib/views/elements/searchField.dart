import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class SearchField extends StatelessWidget {
  final Function(String) onChanged;
  const SearchField({Key key, this.onChanged}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
        textCapitalization: TextCapitalization.none,
        autofocus: true,
        decoration: InputDecoration(
            enabledBorder: OutlineInputBorder(borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(borderSide: BorderSide.none),
            hintText: 'search'.tr(),
            hintStyle: Theme.of(context)
                .textTheme
                .subtitle1
                .merge(TextStyle(fontWeight: FontWeight.w500, fontSize: 18))),
        onChanged: onChanged);
  }
}
