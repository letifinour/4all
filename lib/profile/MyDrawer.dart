import 'package:flutter/material.dart';
import 'package:flutter_application_3/Login/signup/login.dart';
import 'package:flutter_application_3/profile/my_list_tile.dart';

class Mydrawer extends StatefulWidget {
  final void Function()? onProfileTap;
  final void Function()? onLogoutTap;
  const Mydrawer(
      {super.key, required this.onProfileTap, required this.onLogoutTap});

  @override
  State<Mydrawer> createState() => _MydrawerState();
}

class _MydrawerState extends State<Mydrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
        backgroundColor: Colors.grey[900],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                // Header
                const DrawerHeader(
                  child: Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 60,
                  ),
                ),

                //home list tile
                MyListTile(
                    icon: Icons.home,
                    text: 'H O M E',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage()),
                      );
                    }),

                //profile list tile
                MyListTile(
                  icon: Icons.person,
                  text: 'P R O F I L E',
                  onTap: widget.onProfileTap,
                ),
              ],
            ),

            //logout list tile

            Padding(
              padding: const EdgeInsets.only(bottom: 25.0),
              child: MyListTile(
                  icon: Icons.logout,
                  text: 'L O G O U T',
                  onTap: widget.onLogoutTap),
            ),
          ],
        ));
  }
}
