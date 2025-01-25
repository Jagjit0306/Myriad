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
          Column(
            children: [
              //drawer header
              DrawerHeader(
                child: Icon(
                  Icons.favorite,
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
              ),
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

              // //profile tile
              // ListTile(
              //   leading: Icon(
              //     Icons.person,
              //     color: Theme.of(context).colorScheme.inversePrimary,
              //   ),
              //   title: Text('P R O F I L E'),
              //   onTap: () {
              //     //this is already the homescreen so pop drawer
              //     Navigator.pop(context);
              //     Navigator.pushNamed(context, '/profile_page');
              //   },
              // ),

              //community tile
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
                  Icons.self_improvement_rounded ,
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
                title: Text('M Y   A I'),
                onTap: () {
                  //this is already the homescreen so pop drawer
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/gemini_chat');
                },
              ),

              //user tile
              ListTile(
                leading: Icon(
                  Icons.star,
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
                title: Text('O N B O A R D I  G'),
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
