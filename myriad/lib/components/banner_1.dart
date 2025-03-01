import 'package:flutter/material.dart';
import 'package:myriad/components/logo_component.dart';

class Banner1 extends StatelessWidget {
  final IconData bannerIcon;
  final double tilt;
  final String desc;
  const Banner1({
    super.key,
    required this.bannerIcon,
    this.tilt = 0,
    this.desc = "",
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
            fontSize: 23,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.65,
            decorationThickness: 2,
          ),
        ),
        const SizedBox(height: 20),
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
        if (desc.isNotEmpty) SizedBox(height: 20),
        if (desc.isNotEmpty)
          Text(
            desc,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
      ],
    );
  }
}
