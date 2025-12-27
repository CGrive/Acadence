import "package:flutter/material.dart";
import 'package:frontend/theme_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../auth/login_page.dart';

class Tab1 extends StatelessWidget {
  const Tab1({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            "Tab1",
            style: GoogleFonts.poppins(
              textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: ApplicationColors.primaryBlue,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
              child: Text(
                "Login",
                style: GoogleFonts.poppins(
                  textStyle: TextStyle(
                    fontSize: 16,
                    color: ApplicationColors.ivoryWhite,
                    fontWeight: FontWeight.w200,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
