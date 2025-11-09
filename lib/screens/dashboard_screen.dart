import 'package:flutter/material.dart';
import 'package:flutter_happy_place/screens/places_screen.dart';
import 'package:flutter_happy_place/screens/gallery_screen.dart';
import 'package:flutter_happy_place/screens/map_gallery_screen.dart';
import 'package:flutter_happy_place/screens/favorites_screen.dart';
import 'package:flutter_happy_place/screens/add_place_screen.dart';
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
      extendBody: true,
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: _screens,
      ),
      floatingActionButton: Container(
        height: 72,
        width: 72,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.75),
              offset: const Offset(0, 0),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).push(
              PageRouteBuilder(
                transitionDuration: const Duration(milliseconds: 600),
                reverseTransitionDuration: const Duration(milliseconds: 500),
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
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          elevation: 0,
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          child: const Icon(Icons.add_location_alt, size:40,),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        height: navbarHeight,
        color: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: SafeArea(
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
              
              const SizedBox(width: 72),

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
                label: 'Super',
              ),
            ],
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
        borderRadius: BorderRadius.circular(64),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).colorScheme.onSecondary
                : Colors.transparent,
            borderRadius: BorderRadius.circular(64),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //* <-- Animate the icon color and size -->
              TweenAnimationBuilder<Color?>(
                tween: ColorTween(
                  end: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.secondary,
                ),
                duration: const Duration(milliseconds: 250),
                builder: (context, color, child) {
                  return TweenAnimationBuilder<double>(
                    tween: Tween<double>(end: isSelected ? 32.0 : 28.0),
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

              //* <-- Animate the label color and size -->
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                style: TextStyle(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.secondary.withAlpha(204),
                  fontSize: isSelected ? 16.0 : 12.0,
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
