import 'package:flutter/material.dart';

enum BottomToastType {
  success,
  error,
  warning,
  info,
}

class BottomToast {
  static OverlayEntry? _overlayEntry;
  static bool _isVisible = false;

  /// Show a bottom toast message
  static void show({
    required BuildContext context,
    required String message,
    BottomToastType type = BottomToastType.info,
    Duration duration = const Duration(seconds: 3),
    String? actionLabel,
    VoidCallback? onActionPressed,
  }) {
    if (_isVisible) {
      hide();
    }

    _overlayEntry = _createOverlayEntry(
      context: context,
      message: message,
      type: type,
      actionLabel: actionLabel,
      onActionPressed: onActionPressed,
    );

    Overlay.of(context).insert(_overlayEntry!);
    _isVisible = true;

    // Auto hide after duration
    Future.delayed(duration, () {
      hide();
    });
  }

  /// Show success bottom toast
  static void showSuccess({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 3),
    String? actionLabel,
    VoidCallback? onActionPressed,
  }) {
    show(
      context: context,
      message: message,
      type: BottomToastType.success,
      duration: duration,
      actionLabel: actionLabel,
      onActionPressed: onActionPressed,
    );
  }

  /// Show error bottom toast
  static void showError({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 4),
    String? actionLabel,
    VoidCallback? onActionPressed,
  }) {
    show(
      context: context,
      message: message,
      type: BottomToastType.error,
      duration: duration,
      actionLabel: actionLabel,
      onActionPressed: onActionPressed,
    );
  }

  /// Show warning bottom toast
  static void showWarning({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 3),
    String? actionLabel,
    VoidCallback? onActionPressed,
  }) {
    show(
      context: context,
      message: message,
      type: BottomToastType.warning,
      duration: duration,
      actionLabel: actionLabel,
      onActionPressed: onActionPressed,
    );
  }

  /// Show info bottom toast
  static void showInfo({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 3),
    String? actionLabel,
    VoidCallback? onActionPressed,
  }) {
    show(
      context: context,
      message: message,
      type: BottomToastType.info,
      duration: duration,
      actionLabel: actionLabel,
      onActionPressed: onActionPressed,
    );
  }

  /// Hide the current bottom toast
  static void hide() {
    if (_overlayEntry != null && _isVisible) {
      _overlayEntry!.remove();
      _overlayEntry = null;
      _isVisible = false;
    }
  }

  static OverlayEntry _createOverlayEntry({
    required BuildContext context,
    required String message,
    required BottomToastType type,
    String? actionLabel,
    VoidCallback? onActionPressed,
  }) {
    return OverlayEntry(
      builder: (context) => _BottomToastWidget(
        message: message,
        type: type,
        actionLabel: actionLabel,
        onActionPressed: onActionPressed,
        onDismiss: hide,
      ),
    );
  }
}

class _BottomToastWidget extends StatefulWidget {
  final String message;
  final BottomToastType type;
  final String? actionLabel;
  final VoidCallback? onActionPressed;
  final VoidCallback onDismiss;

  const _BottomToastWidget({
    required this.message,
    required this.type,
    this.actionLabel,
    this.onActionPressed,
    required this.onDismiss,
  });

  @override
  State<_BottomToastWidget> createState() => _BottomToastWidgetState();
}

class _BottomToastWidgetState extends State<_BottomToastWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: 100.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: MediaQuery.of(context).padding.bottom + 20,
      left: 16,
      right: 16,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _slideAnimation.value),
            child: Opacity(
              opacity: _opacityAnimation.value,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: _getBackgroundColor(),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 15,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _getIcon(),
                        color: _getIconColor(),
                        size: 22,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.message,
                          style: TextStyle(
                            color: _getTextColor(),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (widget.actionLabel != null) ...[
                        const SizedBox(width: 8),
                        TextButton(
                          onPressed: () {
                            widget.onActionPressed?.call();
                            widget.onDismiss();
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: _getActionColor(),
                            backgroundColor: _getActionBackgroundColor(),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            minimumSize: Size.zero,
                          ),
                          child: Text(
                            widget.actionLabel!,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: widget.onDismiss,
                        child: Icon(
                          Icons.close,
                          color: _getTextColor().withOpacity(0.7),
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Color _getBackgroundColor() {
    switch (widget.type) {
      case BottomToastType.success:
        return const Color(0xFF059669);
      case BottomToastType.error:
        return const Color(0xFFDC2626);
      case BottomToastType.warning:
        return const Color(0xFFD97706);
      case BottomToastType.info:
        return const Color(0xFF2563EB);
    }
  }

  Color _getIconColor() {
    return Colors.white;
  }

  Color _getTextColor() {
    return Colors.white;
  }

  Color _getActionColor() {
    switch (widget.type) {
      case BottomToastType.success:
        return const Color(0xFF059669);
      case BottomToastType.error:
        return const Color(0xFFDC2626);
      case BottomToastType.warning:
        return const Color(0xFFD97706);
      case BottomToastType.info:
        return const Color(0xFF2563EB);
    }
  }

  Color _getActionBackgroundColor() {
    return Colors.white;
  }

  IconData _getIcon() {
    switch (widget.type) {
      case BottomToastType.success:
        return Icons.check_circle;
      case BottomToastType.error:
        return Icons.error;
      case BottomToastType.warning:
        return Icons.warning;
      case BottomToastType.info:
        return Icons.info;
    }
  }
}