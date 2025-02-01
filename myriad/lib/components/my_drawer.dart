import 'package:flutter/material.dart';
import 'package:myriad/auth/google_auth.dart';
import 'package:myriad/pages/google_sign_in.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          //drawer header
          DrawerHeader(
            child: Icon(
              Icons.favorite,
              color: Theme.of(context).colorScheme.inversePrimary,
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Column(
                children: [
                  //home tile
                  ListTile(
                    leading: Icon(
                      Icons.home,
                      color: Theme.of(context).colorScheme.inversePrimary,
                    ),
                    title: Text('H O M E'),
                    onTap: () {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/home_page',
                        (router) => false,
                      );
                    },
                  ),

                  ListTile(
                    leading: Icon(
                      Icons.group,
                      color: Theme.of(context).colorScheme.inversePrimary,
                    ),
                    title: Text('C O M M U N I T Y'),
                    onTap: () {
                      //this is already the homescreen so pop drawer
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/community_page');
                    },
                  ),

                  //community tile
                  ListTile(
                    leading: Icon(
                      Icons.self_improvement_rounded,
                      color: Theme.of(context).colorScheme.inversePrimary,
                    ),
                    title: Text('M Y   A I'),
                    onTap: () {
                      //this is already the homescreen so pop drawer
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/gemini_chat');
                    },
                  ),

                  ListTile(
                    leading: Icon(
                      Icons.self_improvement_rounded,
                      color: Theme.of(context).colorScheme.inversePrimary,
                    ),
                    title: Text('S E R E N I F Y'),
                    onTap: () {
                      //this is already the homescreen so pop drawer
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/serenify');
                    },
                  ),

                  ListTile(
                    leading: Icon(
                      Icons.visibility,
                      color: Theme.of(context).colorScheme.inversePrimary,
                    ),
                    title: Text('S I G H T I F Y'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/sightify');
                    },
                  ),

                  ListTile(
                    leading: Icon(
                      Icons.color_lens,
                      color: Theme.of(context).colorScheme.inversePrimary,
                    ),
                    title: Text('C O L O R I F Y'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/colorify');
                    },
                  ),

                  ListTile(
                    leading: Icon(
                      Icons.record_voice_over,
                      color: Theme.of(context).colorScheme.inversePrimary,
                    ),
                    title: Text('S P E A K I F Y'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/speakify');
                    },
                  ),

                  ListTile(
                    leading: Icon(
                      Icons.hearing,
                      color: Theme.of(context).colorScheme.inversePrimary,
                    ),
                    title: Text('H E A R I F Y'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/hearify');
                    },
                  ),

                  ListTile(
                    leading: Icon(
                      Icons.loop,
                      color: Theme.of(context).colorScheme.inversePrimary,
                    ),
                    title: Text('V O I C I F Y'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/voicify');
                    },
                  ),

                  ListTile(
                    leading: Icon(
                      Icons.drag_indicator,
                      color: Theme.of(context).colorScheme.inversePrimary,
                    ),
                    title: Text('V I B R A I L L I F Y'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/vibraillify');
                    },
                  ),

                  //wheelchair map tile
                  ListTile(
                    leading: Icon(
                      Icons.accessible,
                      color: Theme.of(context).colorScheme.inversePrimary,
                    ),
                    title: Text('W H E E L I F Y'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/wheelchair_map');
                    },
                  ),

                  ListTile(
                    leading: Icon(
                      Icons.star,
                      color: Theme.of(context).colorScheme.inversePrimary,
                    ),
                    title: Text('O N B O A R D I N G'),
                    onTap: () {
                      //this is already the homescreen so pop drawer
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/on_boarding');
                    },
                  ),

                  // SOS tile
                  ListTile(
                    leading: Icon(
                      Icons.warning,
                      color: Theme.of(context).colorScheme.inversePrimary,
                    ),
                    title: Text('S O S'),
                    onTap: () {
                      //this is already the homescreen so pop drawer
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/sos_page');
                    },
                  ),
                ],
              ),
            ),
          ),

          //logout button
          ListTile(
            leading: Icon(
              Icons.logout,
              color: Theme.of(context).colorScheme.inversePrimary,
            ),
            title: Text('L O G O U T'),
            onTap: () {
              //this is already the homescreen so pop drawer
              Navigator.pop(context);
              signOutFromGoogle();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GoogleSignInScreen(),
                  ),
                  (router) => false,
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
