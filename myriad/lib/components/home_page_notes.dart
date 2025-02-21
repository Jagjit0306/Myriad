import 'package:flutter/material.dart';

class HomePageNotes extends StatelessWidget {
  const HomePageNotes({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Quick Notes",
            style: TextStyle(
                color: Theme.of(context).colorScheme.inversePrimary,
                fontSize: 24,
                fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 15,
          ),
          Card(
            color: Theme.of(context).colorScheme.secondary,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                spacing: 10,
                children: [
                  const Text("Notes"),
                  const Text("Notes"),
                  const Text("Notes"),
                  const Text("Notes"),
                  const Text("Notes"),
                  const Text("Notes"),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
