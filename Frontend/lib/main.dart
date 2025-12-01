import 'package:flutter/material.dart';
import 'package:frontend/pages/tab.dart';
import 'package:frontend/theme_colors.dart';
import 'package:frontend/utils/alert_box.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flex_sidebar/flex_sidebar.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: HomeScreen());
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          FlexSidebar(
            controller: FlexSidebarController(resizeAnimCurve: Curves.linear),
            theme: FlexThemeData(
              normalWidth: 200,
              normalDecoration: BoxDecoration(
                color: ApplicationColors.primaryBlue,
                borderRadius: BorderRadius.horizontal(),
              ),
              minimizedDecoration: BoxDecoration(
                color: ApplicationColors.primaryBlue,
                borderRadius: BorderRadius.horizontal(),
              ),
              scrollableItems: true,
              itemsAlignment: MainAxisAlignment.start,
            ),
            primaryWidget: Icon(Icons.account_circle),
            secondaryWidget: Text(
              'User001',
              style: GoogleFonts.poppins(
                textStyle: TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
            items: [
              FlexSidebarItem(
                icon: Icon(Icons.accessibility_new_outlined),
                label: Text('Accessibility'),
                onTap: () {
                  alertboxBuilder(context, whatsclicked: "Accessibility");
                },
              ),
              FlexSidebarItem(
                icon: Icon(Icons.settings),
                label: Text('Settings'),
                onTap: () {
                  // alertboxBuilder(context, whatsclicked: "Settings");
                  // dialogueBoxFullbox(context, whatsclicked: "Settings");
                  simpleDialogue(context);
                },
              ),
            ],
          ),
          Expanded(child: TabHomePage()),
        ],
      ),
    );
  }
}
