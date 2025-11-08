import 'package:flutter/material.dart';

// Sorting options for the places list
enum SortOption { newestFirst, oldestFirst, alphabetical, reverseAlphabetical }

class SortButton extends StatelessWidget {
  const SortButton({
    super.key,
    required this.value,
    required this.onSelected,
  });

  final SortOption value;
  final ValueChanged<SortOption> onSelected;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(32),
      ),
      child: PopupMenuButton<SortOption>(
        tooltip: 'Sort',
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        offset: const Offset(-64, 0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        onSelected: onSelected,
        itemBuilder: (context) => [
          PopupMenuItem(
            value: SortOption.newestFirst,
            child: Row(
              children: [
                const Expanded(child: Text('Newest First')),
                if (value == SortOption.newestFirst)
                  const Icon(Icons.check, size: 18),
              ],
            ),
          ),
          PopupMenuItem(
            value: SortOption.oldestFirst,
            child: Row(
              children: [
                const Expanded(child: Text('Oldest First')),
                if (value == SortOption.oldestFirst)
                  const Icon(Icons.check, size: 18),
              ],
            ),
          ),
          PopupMenuItem(
            value: SortOption.alphabetical,
            child: Row(
              children: [
                const Expanded(child: Text('Alphabetical')),
                if (value == SortOption.alphabetical)
                  const Icon(Icons.check, size: 18),
              ],
            ),
          ),
          PopupMenuItem(
            value: SortOption.reverseAlphabetical,
            child: Row(
              children: [
                const Expanded(child: Text('Reverse Alphabetical')),
                if (value == SortOption.reverseAlphabetical)
                  const Icon(Icons.check, size: 18),
              ],
            ),
          ),
        ],
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Image.asset(
            'assets/icons/sort.png',
            color: Theme.of(context).colorScheme.secondary,
            width: 24,
            height: 24,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
