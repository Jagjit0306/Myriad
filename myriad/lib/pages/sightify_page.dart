import 'package:flutter/material.dart';
import 'package:myriad/components/banner_1.dart';
import 'package:myriad/components/round_button.dart';

class SightifyPage extends StatelessWidget {
  const SightifyPage({super.key});

  final bool pic = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sightify"),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if(!pic) Banner1(bannerIcon: Icons.visibility, tilt: 3.14/2,),
          if(pic)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Container(
                height: double.infinity,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 3,
                    color: Theme.of(context).colorScheme.inversePrimary,
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(30)),
                ),
                // child: Banner1(bannerIcon: Icons.visibility),
              ),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RoundButton(
                icon: Icons.visibility,
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}
