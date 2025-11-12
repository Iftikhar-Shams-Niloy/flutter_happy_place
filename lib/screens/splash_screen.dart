import 'package:flutter/material.dart';
import 'dashboard_screen.dart';

class SplashScreen extends StatefulWidget {
  final Widget? next;
  final Duration duration;

  const SplashScreen({super.key, this.next, this.duration = const Duration(milliseconds: 2750)});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final AnimationController _logoController;
  late final AnimationController _fadeOutController;
  
  late final Animation<double> _scale;
  late final Animation<double> _fade;
  late final Animation<double> _logoPosition;

  @override
  void initState() {
    super.initState();

    //* fade-in and scale animation
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 250));
    _scale = Tween<double>(begin: 0.5, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
    _fade = Tween<double>(begin: 0.5, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    //* <--- Logo drop and bounce animation --->
    _logoController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1300));
    _logoPosition = Tween<double>(begin: -300.0, end: 0.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.bounceOut)
    );

    _fadeOutController = AnimationController(vsync: this, duration: const Duration(milliseconds: 250));

    _controller.forward();
    _logoController.forward();

    Future.delayed(widget.duration, () async {
      if (!mounted) return;
      await _fadeOutController.forward();
      if (!mounted) return;
      final next = widget.next ?? const DashboardScreen();
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => next));
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _logoController.dispose();
    _fadeOutController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedBuilder(
      animation: _fadeOutController,
      builder: (context, child) {
        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.secondary,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              child: Center(
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (_, __) {
                    final contentOpacity = _fade.value * (1.0 - _fadeOutController.value);
                    return Opacity(
                      opacity: contentOpacity,
                      child: Transform.scale(
                        scale: _scale.value,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AnimatedBuilder(
                              animation: _logoController,
                              builder: (_, child) => Transform.translate(
                                offset: Offset(0, _logoPosition.value),
                                child: child,
                              ),
                              child: const Image(
                                image: AssetImage("assets/images/app_logo.png"),
                                height: 240,
                                width: 240,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'Happy Place',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Remember Every Happy Moments',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
