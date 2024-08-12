import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:minmalecommerce/admin_pages/Transaction_list.dart';
import 'package:minmalecommerce/admin_pages/landing_page.dart';
import 'package:minmalecommerce/admin_pages/products.dart';
import 'package:minmalecommerce/components/my_list_tile.dart';
import 'package:minmalecommerce/pages/about_page.dart';
import 'package:minmalecommerce/pages/auth_page.dart';
import 'package:minmalecommerce/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../UpdateProduct.dart';
import '../admin_profile.dart';

class AdminDrawer extends StatelessWidget {
  AdminDrawer({super.key});

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
    print("size drawer");
    print(Utils.getScreenWidth(context) * 0.2);
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.background,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              //drawer header: logo
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
                text: "Home",
                icon: FontAwesomeIcons.home,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => LandingPage()),
                  );
                },
              ),
              MyListTile(
                text: "Products",
                icon: FontAwesomeIcons.shoppingCart,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => Products()),
                  );
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
                      builder: (context) =>
                          TransactionListPageAdmin(), // Navigate to TransactionListPage
                    ),
                  );
                },
              ),
              MyListTile(
                text: "Profile",
                icon: FontAwesomeIcons.user,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => SellerProfilePage()),
                  );
                },
              ),
              MyListTile(
                text: "About",
                icon: FontAwesomeIcons.info,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => AboutPage()),
                  );
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
