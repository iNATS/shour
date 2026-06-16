import 'package:flutter/material.dart';

class AppNetworkImage extends StatelessWidget {
  const AppNetworkImage({
    required this.url,
    required this.icon,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    super.key,
  });

  final String url;
  final IconData icon;
  final double? width;
  final double? height;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return Image.network(
      url,
      width: width,
      height: height,
      fit: fit,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded || frame != null) return child;
        return _ImagePlaceholder(
          width: width,
          height: height,
          icon: icon,
          loading: true,
        );
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return _ImagePlaceholder(
          width: width,
          height: height,
          icon: icon,
          loading: true,
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return _ImagePlaceholder(
          width: width,
          height: height,
          icon: icon,
          loading: false,
        );
      },
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder({
    required this.icon,
    required this.loading,
    this.width,
    this.height,
  });

  final IconData icon;
  final bool loading;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: width,
      height: height,
      color: colorScheme.surfaceContainerHighest,
      child: Center(
        child: loading
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: colorScheme.primary,
                ),
              )
            : Icon(
                icon,
                size: 32,
                color: colorScheme.onSurfaceVariant,
              ),
      ),
    );
  }
}
