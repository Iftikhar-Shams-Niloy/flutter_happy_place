import 'package:flutter/material.dart';
import 'package:flutter_happy_place/screens/places_screen.dart';
import 'package:flutter_happy_place/screens/gallery_screen.dart';
import 'package:flutter_happy_place/screens/map_gallery_screen.dart';
import 'package:flutter_happy_place/screens/favorites_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _currentIndex = 0;
  late PageController _pageController;

  final List<Widget> _screens = [
    const PlacesScreen(),
    const GalleryScreen(),
    const MapGalleryScreen(),
    const FavoritesScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    if (index == _currentIndex) return;

    setState(() {
      _currentIndex = index;
    });

    // Animate the page transition
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final navbarHeight = MediaQuery.of(context).size.height / 10;
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: _screens,
      ),
      bottomNavigationBar: Container(
        height: navbarHeight,
        decoration: BoxDecoration(
          color: Theme.of(
            context,
          ).bottomNavigationBarTheme.backgroundColor!.withValues(alpha: 0.8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  index: 0,
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home,
                  label: 'Home',
                ),
                _buildNavItem(
                  index: 1,
                  icon: Icons.photo_library_outlined,
                  activeIcon: Icons.photo_library,
                  label: 'Gallery',
                ),
                _buildNavItem(
                  index: 2,
                  icon: Icons.map_outlined,
                  activeIcon: Icons.map,
                  label: 'Map',
                ),
                _buildNavItem(
                  index: 3,
                  icon: Icons.star_outline,
                  activeIcon: Icons.star,
                  label: 'Favorites',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    final isSelected = _currentIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => _onTabTapped(index),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        borderRadius: BorderRadius.circular(32),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).colorScheme.onSecondary
                : Colors.transparent,
            borderRadius: BorderRadius.circular(32),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Smoothly animate the icon color and size when selection changes
              TweenAnimationBuilder<Color?>(
                tween: ColorTween(
                  end: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.secondary,
                ),
                duration: const Duration(milliseconds: 250),
                builder: (context, color, child) {
                  return TweenAnimationBuilder<double>(
                    tween: Tween<double>(end: isSelected ? 26.0 : 24.0),
                    duration: const Duration(milliseconds: 250),
                    builder: (context, size, child2) {
                      return Icon(
                        isSelected ? activeIcon : icon,
                        size: size,
                        color: color,
                      );
                    },
                  );
                },
              ),

              const SizedBox(height: 2),

              // Animate the label's color and size when selection changes
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                style: TextStyle(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.secondary.withAlpha(204),
                  fontSize: isSelected ? 14.0 : 12.0,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
                ),
                child: Text(label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
