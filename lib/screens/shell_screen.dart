import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/app_sidebar.dart';
import 'add_business_screen.dart';
import 'dashboard_screen.dart';

class ShellScreen extends StatefulWidget {
  const ShellScreen({super.key});

  @override
  State<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends State<ShellScreen> {
  int selectedIndex = 0;
  bool sidebarVisible = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _select(int index) => setState(() => selectedIndex = index);

  void _toggleSidebar(bool isDesktop) {
    if (isDesktop) {
      setState(() => sidebarVisible = !sidebarVisible);
    } else {
      _scaffoldKey.currentState?.openDrawer();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width >= 900;

    return Scaffold(
      key: _scaffoldKey,
      drawer: isDesktop
          ? null
          : Drawer(
              backgroundColor: AppColors.background,
              child: AppSidebar(selectedIndex: selectedIndex, onSelect: _select),
            ),
      body: SafeArea(
        child: Row(
          children: [
            if (isDesktop && sidebarVisible)
              SizedBox(
                width: 250,
                child: AppSidebar(selectedIndex: selectedIndex, onSelect: _select),
              ),
            Expanded(
              child: Column(
                children: [
                  _buildTopStrip(isDesktop),
                  Expanded(child: _buildContent(isDesktop)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopStrip(bool isDesktop) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => _toggleSidebar(isDesktop),
            icon: Icon(isDesktop && sidebarVisible ? Icons.menu_open : Icons.menu),
            color: AppColors.textPrimary,
            tooltip: 'Toggle sidebar',
          ),
        ],
      ),
    );
  }

  Widget _buildContent(bool isDesktop) {
    switch (selectedIndex) {
      case 0:
        return DashboardScreen(
          isDesktop: isDesktop,
          onAddBusiness: () => _select(2),
        );
      case 2:
        return AddBusinessScreen(onBusinessCreated: () => _select(0));
      default:
        return NotBuiltYetScreen(sectionName: kNavigationItems[selectedIndex]);
    }
  }
}

class NotBuiltYetScreen extends StatelessWidget {
  final String sectionName;

  const NotBuiltYetScreen({super.key, required this.sectionName});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.construction_outlined, size: 40, color: AppColors.textSecondary),
          const SizedBox(height: 15),
          Text(
            sectionName,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          const Text('This section has not been built yet.', style: TextStyle(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}