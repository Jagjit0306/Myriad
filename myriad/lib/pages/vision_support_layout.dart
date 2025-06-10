import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myriad/components/my_app_bar.dart';
import 'package:myriad/database/user.dart';
import 'package:url_launcher/url_launcher.dart';

class VisionSupportLayout extends StatelessWidget {
  const VisionSupportLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        title: 'Myriad - Vision+',
        hideSos: true,
      ),
      body: Column(children: [
        SizedBox(
          width: double.infinity,
          height: MediaQuery.of(context).size.height * 0.35,
          child: const _LayoutOption('Sightify'),
        ),
        SizedBox(
          width: double.infinity,
          height: MediaQuery.of(context).size.height * 0.35,
          child: const _LayoutOption('Serenify'),
        ),
        SizedBox(
          width: double.infinity,
          height: MediaQuery.of(context).size.height * 0.2,
          child: const _LayoutOption('Call Guardian'),
        ),
      ]),
    );
  }
}

class _LayoutOption extends StatefulWidget {

  final String name;
  const _LayoutOption(this.name);
  @override
  State<_LayoutOption> createState() => _LayoutOptionState();
}

class _LayoutOptionState extends State<_LayoutOption> {
  String guardianNumber = '';
  final UserDatabase userDatabase = UserDatabase();
  void _launchDialer(String number) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: number,
    );
    await launchUrl(launchUri);
  }

  @override
  void initState() {
    super.initState();
    _getGuardianNumber();
  }

  Future<void> _getGuardianNumber() async {
    String? temp = await userDatabase.getGuardianNumber();
    if (temp!.isNotEmpty) {
      setState(() {
        guardianNumber = temp;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: widget.name,
      child: GestureDetector(
        onTap: () {
          if (widget.name == 'Sightify') {
            context.push('/vision_support_sightify');
          } else if (widget.name == 'Serenify') {
            context.push('/serenify_meditate');
          } else if (widget.name == 'Call Guardian') {
            if (guardianNumber.isNotEmpty) {
              _launchDialer(guardianNumber);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Guardian number not found.')),
              );
            }
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: Theme.of(context).colorScheme.primary,
                width: 1.5,
              ),
            ),
            width: double.infinity,
            child: Center(
              child: Text(widget.name,
                  style: TextStyle(
                      fontSize: 20,
                      color: Theme.of(context).colorScheme.inversePrimary,
                      fontWeight: FontWeight.bold)),
            ),
          ),
        ),
      ),
    );
  }
}
