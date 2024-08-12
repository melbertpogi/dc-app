import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:minmalecommerce/utils/utils.dart';
import 'package:universal_platform/universal_platform.dart';

class AboutPage extends StatelessWidget {
  static String id = "AboutPage";
  const AboutPage({super.key});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Padding(
        padding: EdgeInsets.symmetric(
            vertical: Utils.getScreenHeight(context) * 0.060,
            horizontal: Utils.getScreenWidth(context) * 0.15),
        // padding: const EdgeInsets.symmetric(vertical: 75, horizontal: 400),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "About",
              style: GoogleFonts.lora(
                  fontWeight: FontWeight.bold,
                  fontSize:
                      (UniversalPlatform.isDesktop || UniversalPlatform.isWeb)
                          ? Utils.getScreenWidth(context) * 0.028
                          : Utils.getScreenWidth(context) * 0.06),
            ),
            SizedBox(
               height: Utils.getScreenHeight(context) *  0.010,
             ),
            Text(
              "Digital Clothing is a Clothing Brand located at Brgy. Calo Bay Laguna and managed by Mr. Arden Ebron. They are open 7 days a week!",
              style: GoogleFonts.lora(
                  fontSize:
                      (UniversalPlatform.isDesktop || UniversalPlatform.isWeb)
                          ? Utils.getScreenWidth(context) * 0.020
                          : Utils.getScreenWidth(context) * 0.04),
            ),
          ],
        ),
      ),
    );
  }
}
