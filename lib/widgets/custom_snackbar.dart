import 'package:flutter/material.dart';

class CustomSnackbar {
  static void show(
    BuildContext context,
    String message, {
    bool isError = true,
    Duration duration = const Duration(seconds: 3),
    String? actionLabel,
    VoidCallback? onAction,
    double textScale = 1.2,
  }) {
    final theme = Theme.of(context);
    final background = isError
        ? theme.colorScheme.error
        : theme.colorScheme.primary;
    final onBackground = isError
        ? theme.colorScheme.onError
        : theme.colorScheme.onPrimary;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (ctx) {
        return _SlidingSnackBar(
          message: message,
          theme: theme,
          background: background,
          onBackground: onBackground,
          duration: duration,
          actionLabel: actionLabel,
          onAction: onAction,
          textScale: textScale,
          overlayEntry: entry,
        );
      },
    );

    final overlay = Overlay.of(context);
    overlay.insert(entry);
  }

  static SnackBar build(
    BuildContext context,
    String message, {
    bool isError = true,
    Duration duration = const Duration(seconds: 3),
    String? actionLabel,
    VoidCallback? onAction,
    double textScale = 1.1,
  }) {
    final theme = Theme.of(context);
    final background = isError
        ? theme.colorScheme.error
        : theme.colorScheme.primary;
    final onBackground = isError
        ? theme.colorScheme.onError
        : theme.colorScheme.onPrimary;

    return SnackBar(
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 6,
      backgroundColor: background,
      duration: duration,
      content: Text(
        message,
        textAlign: TextAlign.center,
        textScaler: TextScaler.linear(textScale),
        style: TextStyle(color: onBackground),
      ),
      action: actionLabel != null
          ? SnackBarAction(
              label: actionLabel,
              textColor: onBackground,
              onPressed:
                  onAction ??
                  () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
            )
          : null,
    );
  }
}

class _SlidingSnackBar extends StatefulWidget {
  const _SlidingSnackBar({
    required this.message,
    required this.theme,
    required this.background,
    required this.onBackground,
    required this.duration,
    this.actionLabel,
    this.onAction,
    required this.textScale,
    required this.overlayEntry,
  });

  final String message;
  final ThemeData theme;
  final Color background;
  final Color onBackground;
  final Duration duration;
  final String? actionLabel;
  final VoidCallback? onAction;
  final double textScale;
  final OverlayEntry overlayEntry;

  @override
  State<_SlidingSnackBar> createState() => _SlidingSnackBarState();
}

class _SlidingSnackBarState extends State<_SlidingSnackBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<Offset> _offset;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _offset = Tween<Offset>(
      begin: const Offset(0, 1.0),
      end: Offset.zero,
    ).chain(CurveTween(curve: Curves.easeOut)).animate(_ctrl);
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);

    _ctrl.forward();

    // auto dismiss after duration
    Future.delayed(widget.duration, () async {
      if (mounted) {
        await _ctrl.reverse();
        widget.overlayEntry.remove();
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _handleAction() async {
    widget.onAction?.call();
    await _ctrl.reverse();
    widget.overlayEntry.remove();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 12,
      child: SlideTransition(
        position: _offset,
        child: FadeTransition(
          opacity: _fade,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Material(
              color: Colors.transparent,
              child: Container(
                decoration: BoxDecoration(
                  color: widget.background,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        widget.message,
                        textAlign: TextAlign.center,
                        textScaler: TextScaler.linear(widget.textScale),
                        style: TextStyle(color: widget.onBackground),
                      ),
                    ),
                    if (widget.actionLabel != null)
                      TextButton(
                        onPressed: _handleAction,
                        style: TextButton.styleFrom(
                          foregroundColor: widget.onBackground,
                        ),
                        child: Text(widget.actionLabel!),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
