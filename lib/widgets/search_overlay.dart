import 'package:flutter/material.dart';
import '../models/place.dart';
import '../screens/places_detail_screen.dart';
import '../utils/file_utils.dart';

class SearchOverlay extends StatefulWidget {
  const SearchOverlay({
    super.key,
    required this.allPlaces,
    required this.onDismiss,
  });

  final List<Place> allPlaces;
  final VoidCallback onDismiss;

  @override
  State<SearchOverlay> createState() => _SearchOverlayState();
}

class _SearchOverlayState extends State<SearchOverlay>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<Place> _searchResults = [];
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeInOut,
    );
    _animController.forward();

    // Auto-focus the search field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    if (query.isEmpty) {
      setState(() => _searchResults = []);
      return;
    }

    final lowerQuery = query.toLowerCase().trim();
    final filtered = widget.allPlaces.where((place) {
      return place.title.toLowerCase().contains(lowerQuery) ||
          place.details.toLowerCase().contains(lowerQuery);
    }).toList();

    setState(() {
      _searchResults = filtered.take(3).toList();
    });
  }

  void _dismissOverlay() async {
    _focusNode.unfocus();
    await _animController.reverse();
    widget.onDismiss();
  }

  void _navigateToPlace(Place place) {
    _focusNode.unfocus();
    Navigator.of(context)
        .push(
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 500),
            pageBuilder: (context, animation, secondaryAnimation) =>
                PlacesDetailScreen(place: place),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  final tween = Tween<Offset>(
                    begin: const Offset(0, 1),
                    end: Offset.zero,
                  ).chain(CurveTween(curve: Curves.easeInOut));
                  return SlideTransition(
                    position: animation.drive(tween),
                    child: child,
                  );
                },
          ),
        )
        .then((_) => _dismissOverlay());
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Material(
        color: Colors.black54,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _dismissOverlay,
          child: SafeArea(
            child: Column(
              children: [
                //* <--- Search bar at top (vertically centered)
                SizedBox(
                  height: screenHeight * 0.055,
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: GestureDetector(
                      onTap:
                          () {}, //* <--- Prevent dismissal when tapping search bar --->
                      child: Material(
                        elevation: 12,
                        borderRadius: BorderRadius.circular(999),
                        child: SizedBox(
                          height: 50,
                          child: TextField(
                            controller: _controller,
                            focusNode: _focusNode,
                            autofocus: true,
                            onChanged: _performSearch,
                            textInputAction: TextInputAction.search,
                            decoration: InputDecoration(
                              hintText: 'Search happy places...',
                              isDense: true,
                              prefixIcon: Icon(
                                Icons.search,
                                size: 28,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                              suffixIcon: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (_controller.text.isNotEmpty)
                                    IconButton(
                                      icon: const Icon(Icons.clear),
                                      onPressed: () {
                                        _controller.clear();
                                        _performSearch('');
                                      },
                                    ),
                                  IconButton(
                                    icon: const Icon(Icons.close),
                                    onPressed: _dismissOverlay,
                                  ),
                                ],
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 16,
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
                              fillColor: Theme.of(context).colorScheme.surface,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ), // <--- Center widget closes here
                // Search results (top 3)
                if (_searchResults.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 16,
                    ),
                    child: GestureDetector(
                      onTap: () {}, // Prevent dismissal when tapping results
                      child: Material(
                        elevation: 8,
                        borderRadius: BorderRadius.circular(12),
                        color: Theme.of(context).colorScheme.surface,
                        child: ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _searchResults.length,
                          separatorBuilder: (context, index) => Divider(
                            height: 8,
                            indent: 16,
                            endIndent: 16,
                            color: Theme.of(context).colorScheme.outlineVariant
                                .withValues(alpha: 0.75),
                          ),
                          itemBuilder: (context, index) {
                            final place = _searchResults[index];
                            return ListTile(
                              leading: CircleAvatar(
                                radius: 24,
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.secondaryContainer,
                                foregroundImage: isValidImageFile(place.image)
                                    ? FileImage(place.image!)
                                    : null,
                                child: isValidImageFile(place.image)
                                    ? null
                                    : Icon(
                                        Icons.image_not_supported,
                                        size: 20,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSecondaryContainer,
                                      ),
                              ),
                              title: Text(
                                place.title,
                                style: Theme.of(context).textTheme.titleMedium!
                                    .copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface,
                                    ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text(
                                place.details,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodySmall!
                                    .copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                    ),
                              ),
                              trailing: Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                              onTap: () => _navigateToPlace(place),
                            );
                          },
                        ),
                      ),
                    ),
                  ),

                // Show hint when no results
                if (_controller.text.isNotEmpty && _searchResults.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Text(
                      'No places found',
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
