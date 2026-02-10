import 'package:flutter/material.dart';
import 'package:frontend/utils/alert_box.dart';
import '../theme_colors.dart';

class RailDestination {
  const RailDestination(this.label, this.icon, this.selectedIcon);

  final String label;
  final Widget icon;
  final Widget selectedIcon;
}

const List<RailDestination> destinations = <RailDestination>[
  RailDestination('Home', Icon(Icons.home_outlined), Icon(Icons.home)),
  RailDestination(
    'Student',
    Icon(Icons.account_circle_outlined),
    Icon(Icons.account_circle),
  ),
  RailDestination(
    'Admin',
    Icon(Icons.dashboard_outlined),
    Icon(Icons.dashboard),
  ),
  RailDestination("Faculty", Icon(Icons.android_outlined), Icon(Icons.android)),
  
  RailDestination(
    'Exam Department',
    Icon(Icons.assessment_outlined),
    Icon(Icons.assessment),
  ),
  RailDestination(
    'Settings',
    Icon(Icons.settings_outlined),
    Icon(Icons.settings),
  ),
];

class NavigationRailDrawer extends StatelessWidget {
  const NavigationRailDrawer({
    super.key,
    required this.selectedIndex,
    required this.onToggle,
    required this.onDestinationSelected,
    required this.isExpanded,
  });
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final VoidCallback onToggle;
  final bool isExpanded;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(0),
      child: NavigationRail(
        minWidth: 50,
        minExtendedWidth: 150,
        extended: isExpanded,
        selectedIndex: selectedIndex,
        useIndicator: true,
        groupAlignment: 0,
        selectedIconTheme: IconThemeData(color: ApplicationColors.ivoryWhite),
        unselectedIconTheme: IconThemeData(color: ApplicationColors.adminSlate),
        indicatorColor: ApplicationColors.primaryBlue,
        labelType: isExpanded
            ? NavigationRailLabelType.none
            : NavigationRailLabelType.selected,
        leadingAtTop: true,
        leading: FloatingActionButton(
          mini: true,
          elevation: 1,
          backgroundColor: ApplicationColors.primaryBlue,
          onPressed: onToggle,
          child: Icon(isExpanded ? Icons.chevron_left : Icons.menu),
        ),
        trailingAtBottom: true,
        trailing: IconButton(
          icon: Icon(Icons.more_horiz_rounded),
          onPressed: () {
            simpleDialogue(context, whatsclicked: "setting");
          },
        ),

        onDestinationSelected: onDestinationSelected,
        destinations: destinations.map((RailDestination destination) {
          return NavigationRailDestination(
            label: Text(destination.label),
            icon: destination.icon,
            selectedIcon: destination.selectedIcon,
          );
        }).toList(),
        elevation: null,
      ),
    );
  }
}
