import "package:flutter/material.dart";
import 'package:google_fonts/google_fonts.dart';
import "./tabs/tab1.dart";
import "./tabs/tab2.dart";
import "./tabs/tab3.dart";
import "../theme_colors.dart";

class TabHomePage extends StatelessWidget {
  const TabHomePage({super.key});
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: ApplicationColors.primaryPurple,
          title: Text(
            "Acadence - Home",
            style: GoogleFonts.poppins(
              textStyle: const TextStyle(
                color: ApplicationColors.ivoryWhite,
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.account_box_rounded)),
              Tab(text: "Tab 2"),
              Tab(text: "Tab 3"),
            ],
          ),
        ),
        body: const TabBarView(children: <Widget>[Tab1(), Tab2(), Tab3()]),
      ),
    );
  }
}
