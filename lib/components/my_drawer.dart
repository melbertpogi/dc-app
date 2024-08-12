import 'package:flutter/material.dart';
import 'package:font_awesome_icon_class/font_awesome_icon_class.dart';
import 'package:minmalecommerce/components/my_list_tile.dart';
import 'package:minmalecommerce/pages/TransactionHistory_user.dart';
import 'package:minmalecommerce/pages/about_page.dart';
import 'package:minmalecommerce/pages/auth_page.dart';
import 'package:minmalecommerce/pages/cart_page.dart';
import 'package:minmalecommerce/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart'; // Import FontAwesomeIcons

import '../pages/Profile.dart';

class MyDrawer extends StatelessWidget {
  MyDrawer({Key? key});

  final user = FirebaseAuth.instance.currentUser!;

  final GoogleSignIn googleSignIn = GoogleSignIn();
  void signUserOut(BuildContext context) async {
    await googleSignIn.signOut();
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) => AuthPage()), // Navigate to AuthPage
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.background,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              //drawer header  : logo
              DrawerHeader(
                child: Image.asset(
                  'lib/images/logo.png',
                  height: 200,
                ),
              ),
              SizedBox(
                height: Utils.getScreenHeight(context) * 0.02,
              ),
              // shop tile
              MyListTile(
                text: "Shop",
                icon: FontAwesomeIcons.home,
                onTap: () {
                  print("object");
                  Navigator.pop(context);
                },
              ),
              MyListTile(
                text: "Cart",
                icon: FontAwesomeIcons.shoppingCart,
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => CartPage()));
                },
              ),
              MyListTile(
                text: "Transaction List",
                icon: FontAwesomeIcons.history,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TransactionListPage(),
                      // Navigate to TransactionListPage
                    ),
                  );
                },
              ),
              MyListTile(
                text: "Profile",
                icon: FontAwesomeIcons.user,
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => ProfilePage()));
                },
              ),
              MyListTile(
                text: "About",
                icon: FontAwesomeIcons.info,
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => AboutPage()));
                },
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.symmetric(
                vertical: Utils.getScreenHeight(context) * 0.02),
            child: MyListTile(
              text: "Log Out",
              icon: FontAwesomeIcons.signOutAlt,
              onTap: () {
                signUserOut(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}
