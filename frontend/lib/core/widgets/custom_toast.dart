import 'package:flutter/material.dart';

enum ToastType {
  success,
  error,
  warning,
  info,
}

class CustomToast {
  static OverlayEntry? _overlayEntry;
  static bool _isVisible = false;

  /// Show a custom toast message
  static void show({
    required BuildContext context,
    required String message,
    ToastType type = ToastType.info,
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

  /// Show success toast
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
      type: ToastType.success,
      duration: duration,
      actionLabel: actionLabel,
      onActionPressed: onActionPressed,
    );
  }

  /// Show error toast
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
      type: ToastType.error,
      duration: duration,
      actionLabel: actionLabel,
      onActionPressed: onActionPressed,
    );
  }

  /// Show warning toast
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
      type: ToastType.warning,
      duration: duration,
      actionLabel: actionLabel,
      onActionPressed: onActionPressed,
    );
  }

  /// Show info toast
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
      type: ToastType.info,
      duration: duration,
      actionLabel: actionLabel,
      onActionPressed: onActionPressed,
    );
  }

  /// Hide the current toast
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
    required ToastType type,
    String? actionLabel,
    VoidCallback? onActionPressed,
  }) {
    return OverlayEntry(
      builder: (context) => _ToastWidget(
        message: message,
        type: type,
        actionLabel: actionLabel,
        onActionPressed: onActionPressed,
        onDismiss: hide,
      ),
    );
  }
}

class _ToastWidget extends StatefulWidget {
  final String message;
  final ToastType type;
  final String? actionLabel;
  final VoidCallback? onActionPressed;
  final VoidCallback onDismiss;

  const _ToastWidget({
    required this.message,
    required this.type,
    this.actionLabel,
    this.onActionPressed,
    required this.onDismiss,
  });

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget>
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
      begin: -100.0,
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
      top: MediaQuery.of(context).padding.top + 10,
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
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: _getBackgroundColor(),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _getIconBackgroundColor(),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          _getIcon(),
                          color: _getIconColor(),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _getTitle(),
                              style: TextStyle(
                                color: _getTextColor(),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              widget.message,
                              style: TextStyle(
                                color: _getTextColor().withOpacity(0.8),
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
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
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
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
                      IconButton(
                        onPressed: widget.onDismiss,
                        icon: Icon(
                          Icons.close,
                          color: _getTextColor().withOpacity(0.6),
                          size: 18,
                        ),
                        padding: const EdgeInsets.all(4),
                        constraints: const BoxConstraints(),
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
      case ToastType.success:
        return const Color(0xFF10B981);
      case ToastType.error:
        return const Color(0xFFEF4444);
      case ToastType.warning:
        return const Color(0xFFF59E0B);
      case ToastType.info:
        return const Color(0xFF3B82F6);
    }
  }

  Color _getIconBackgroundColor() {
    return Colors.white.withOpacity(0.2);
  }

  Color _getIconColor() {
    return Colors.white;
  }

  Color _getTextColor() {
    return Colors.white;
  }

  Color _getActionColor() {
    return Colors.white;
  }

  IconData _getIcon() {
    switch (widget.type) {
      case ToastType.success:
        return Icons.check_circle_outline;
      case ToastType.error:
        return Icons.error_outline;
      case ToastType.warning:
        return Icons.warning_amber_outlined;
      case ToastType.info:
        return Icons.info_outline;
    }
  }

  String _getTitle() {
    switch (widget.type) {
      case ToastType.success:
        return 'Success';
      case ToastType.error:
        return 'Error';
      case ToastType.warning:
        return 'Warning';
      case ToastType.info:
        return 'Info';
    }
  }
}