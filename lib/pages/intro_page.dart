import 'package:flutter/material.dart';
import 'package:minmalecommerce/components/my_button.dart';
import 'package:minmalecommerce/pages/shop_page.dart';
import 'package:minmalecommerce/utils/utils.dart';

class IntroPage extends StatelessWidget {
  const IntroPage({super.key});
  static String id = '/intro_page';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            // logo
            children: [
              Image.asset(
                'lib/images/logo.png',
                height: 200,
              ),
              SizedBox(
                height: Utils.getScreenHeight(context) * 0.020,
              ),
              // Add other children widgets below if needed

              // title
              Text(
                "Digital Clothing".toUpperCase(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: Utils.getScreenWidth(context) * 0.06 < 40
                      ? Utils.getScreenWidth(context) * 0.06
                      : 40,
                ),
              ),
              SizedBox(
                height: Utils.getScreenHeight(context) * 0.006,
              ),
              //subtitle
              Text(
                "Clothes for a big planet.",
                style: TextStyle(
                  fontSize: Utils.getScreenWidth(context) * 0.045 < 30
                      ? Utils.getScreenWidth(context) * 0.045
                      : 30,
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
              ),

              SizedBox(
                height: Utils.getScreenHeight(context) * 0.025,
              ),
              // button
              MyButton(
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => ShopPage()));
                },
                child: const Icon(Icons.arrow_forward),
              )
            ],
          ),
        ),
      ),
    );
  }
}
