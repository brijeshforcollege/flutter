import 'package:flutter/material.dart';
import 'package:skillxchange/screens/calendar_screen.dart';
import 'package:skillxchange/screens/home_screen.dart';
import 'package:skillxchange/screens/profile_screen.dart';
import 'package:skillxchange/widgets/navbar.dart';

class MainAppScreen extends StatefulWidget {
  const MainAppScreen({super.key});

  @override
  State<MainAppScreen> createState() => _MainAppScreenState();
}

class _MainAppScreenState extends State<MainAppScreen> {
  int _currentIndex = 0;
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const HomeScreen(),
      const CalendarScreen(),
      const ProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Optional AppBar that changes title based on current tab
      appBar: AppBar(
        title: Text(
          _getAppBarTitle(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 1,
        actions: _currentIndex == 0 // Show actions only on HomeScreen
            ? [
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => _showSearch(context),
                ),
              ]
            : null,
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavBar(
        currentIndex: _currentIndex,
        onTap: _handleTabChange,
      ),
    );
  }

  String _getAppBarTitle() {
    switch (_currentIndex) {
      case 0:
        return 'Discover Skills';
      case 1:
        return 'My Schedule';
      case 2:
        return 'My Profile';
      default:
        return 'SkillXchange';
    }
  }

  void _handleTabChange(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _showSearch(BuildContext context) {
    showSearch(
      context: context,
      delegate: SkillSearchDelegate(), // You'll need to implement this
    );
  }
}

// Optional: Implement search functionality
class SkillSearchDelegate extends SearchDelegate {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () => query = '',
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // Implement search results
    return Center(
      child: Text('Search results for: $query'),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // Implement search suggestions
    return const Center(
      child: Text('Search for skills...'),
    );
  }
}