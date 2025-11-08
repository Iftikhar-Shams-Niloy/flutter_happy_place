import 'package:flutter/material.dart';

class AppSearchBar extends StatelessWidget {
  const AppSearchBar({
    super.key,
    required this.controller,
    required this.query,
    required this.onChanged,
    this.hintText = 'Search',
  });

  final TextEditingController controller;
  final String query;
  final ValueChanged<String> onChanged;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: TextField(
        controller: controller,
        onChanged: (v) => onChanged(v.trim().toLowerCase()),
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: hintText,
          isDense: true,
          prefixIcon: Icon(
            Icons.search,
            size: 24,
            color: Theme.of(context).colorScheme.secondary,
          ),
          suffixIcon: query.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    controller.clear();
                    onChanged('');
                  },
                )
              : null,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 0,
            horizontal: 12,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(999),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(999),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(999),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Theme.of(context).colorScheme.surfaceContainer,
        ),
      ),
    );
  }
}
