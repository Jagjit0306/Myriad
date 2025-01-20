import 'package:flutter/material.dart';

class MyChips extends StatelessWidget {
  final List<dynamic> categories;
  final Function updateChips;
  const MyChips(
      {super.key, required this.categories, required this.updateChips});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 20.0),
      height: 50,
      child: ListView.builder(
        physics: BouncingScrollPhysics(),
        itemCount: categories.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          Map<dynamic, bool> currCat = categories[index];
          return Padding(
            padding: const EdgeInsets.all(5.0),
            child: GestureDetector(
              // onTap: () {
              //   setState(() {
              //     categories[index] = {
              //       currCat.keys.first: !currCat.values.first
              //     };
              //   });
              // },
              onTap: () {
                updateChips(currCat, index);
              },
              child: Chip(
                label: Text(currCat.keys.first),
                backgroundColor: currCat.values.first
                    ? Colors.blue.shade200
                    : Colors.transparent,
                elevation: 4,
              ),
            ),
          );
        },
      ),
    );
  }
}
