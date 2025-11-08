import 'package:flutter/material.dart';
import 'package:flutter_happy_place/screens/places_screen.dart';
import 'package:flutter_happy_place/screens/gallery_screen.dart';
import 'package:flutter_happy_place/screens/map_gallery_screen.dart';
import 'package:flutter_happy_place/screens/favorites_screen.dart';
import 'package:flutter_happy_place/screens/add_place_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Custom clipper to create a smooth circular notch in the navigation bar
class NotchedBottomBarClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final centerX = size.width / 2;
    final notchRadius = 38.0; // Radius of the circular cutout
    final notchMargin = 4.0; // Small margin for smooth edges

    // Start from top-left
    path.moveTo(0, 0);

    // Draw to the left edge of the notch
    path.lineTo(centerX - notchRadius - notchMargin, 0);

    // Create smooth circular notch going down and up
    path.quadraticBezierTo(
      centerX - notchRadius - notchMargin / 2,
      notchMargin,
      centerX - notchRadius,
      notchMargin * 2,
    );

    path.arcToPoint(
      Offset(centerX + notchRadius, notchMargin * 2),
      radius: Radius.circular(notchRadius),
      clockwise: false,
    );

    path.quadraticBezierTo(
      centerX + notchRadius + notchMargin / 2,
      notchMargin,
      centerX + notchRadius + notchMargin,
      0,
    );

    // Draw to top-right corner
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

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
    final navbarHeight = MediaQuery.of(context).size.height / 9.75;
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: _screens,
      ),
      bottomNavigationBar: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          ClipPath(
            clipper: NotchedBottomBarClipper(),
            child: Container(
              height: navbarHeight,
              decoration: BoxDecoration(
                color:
                    Theme.of(
                      context,
                    ).bottomNavigationBarTheme.backgroundColor!.withValues(
                      alpha: 0.8,
                    ),
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
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
                      const SizedBox(
                        width: 80,
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
          ),
          // Floating add button positioned in the notch
          Positioned(
            top: -24,
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.primary.withAlpha(200),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withAlpha(100),
                    blurRadius: 16,
                    spreadRadius: 1,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(32),
                onTap: () {
                  Navigator.of(context).push(
                    PageRouteBuilder(
                      transitionDuration: const Duration(milliseconds: 600),
                      reverseTransitionDuration: const Duration(
                        milliseconds: 500,
                      ),
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          const AddPlaceScreen(),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                            final tween = Tween<Offset>(
                              begin: const Offset(0.0, 1.0),
                              end: Offset.zero,
                            ).chain(CurveTween(curve: Curves.easeOut));
                            return SlideTransition(
                              position: animation.drive(tween),
                              child: child,
                            );
                          },
                    ),
                  );
                },
                child: Icon(
                  Icons.add_location_alt,
                  size: 32,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),
          ),
        ],
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
