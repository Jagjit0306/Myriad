import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:myriad/components/logo_component.dart';

class Banner1 extends StatelessWidget {
  final IconData bannerIcon;
  final double tilt;
  const Banner1({
    super.key,
    required this.bannerIcon,
    this.tilt = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(height: 80),
        Text(
          'Featuring',
          style: TextStyle(
            color: Theme.of(context).colorScheme.inversePrimary,
            fontSize: 24,
            fontWeight: FontWeight.w400,
            decorationThickness: 2,
          ),
        ),
        const SizedBox(height: 40),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            LogoComponent(size: 90),
            SizedBox(width: 10),
            Text(
              'x',
              style: TextStyle(
                color: Theme.of(context).colorScheme.inversePrimary,
                fontSize: 40,
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(width: 10),
            Transform.rotate(
              angle: tilt,
              child: Icon(
                bannerIcon,
                color: Theme.of(context).colorScheme.inversePrimary,
                size: 60,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
