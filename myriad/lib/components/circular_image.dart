import 'package:flutter/material.dart';

class CircularImage extends StatelessWidget {
  final String imageUrl;
  final double size;
  final Widget? placeholder;

  const CircularImage({
    Key? key,
    required this.imageUrl,
    this.size = 50.0,
    this.placeholder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Image.network(
        imageUrl,
        width: size,
        height: size,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) {
            return child;
          }
          return placeholder ??
              Container(
                width: size,
                height: size,
                alignment: Alignment.center,
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          (loadingProgress.expectedTotalBytes ?? 1)
                      : null,
                ),
              );
        },
        errorBuilder: (context, error, stackTrace) {
          return placeholder ??
              Container(
                width: size,
                height: size,
                alignment: Alignment.center,
                color: Colors.grey[300],
                child: const Icon(
                  Icons.broken_image,
                  color: Colors.grey,
                ),
              );
        },
      ),
    );
  }
}
