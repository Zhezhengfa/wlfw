import 'package:flutter/material.dart';

import 'pages/board_page.dart';
import 'pages/mine_page.dart';
import 'pages/ticket_page.dart';

void main() {
  runApp(const CallNumberApp());
}

class CallNumberApp extends StatelessWidget {
  const CallNumberApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '叫号通',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        // 严格使用 Material 3 默认 seedColor（不自定义色板）
        colorSchemeSeed: const Color(0xFF6750A4),
      ),
      home: const HomeScaffold(),
    );
  }
}

/// 外壳：Scaffold + NavigationBar + 三页切换
class HomeScaffold extends StatefulWidget {
  const HomeScaffold({super.key});

  @override
  State<HomeScaffold> createState() => _HomeScaffoldState();
}

class _HomeScaffoldState extends State<HomeScaffold> {
  int _index = 0;

  final List<Widget> _pages = const [
    BoardPage(),
    TicketPage(),
    MinePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.list_alt_outlined),
            selectedIcon: Icon(Icons.list_alt),
            label: '叫号看板',
          ),
          NavigationDestination(
            icon: Icon(Icons.confirmation_num_outlined),
            selectedIcon: Icon(Icons.confirmation_num),
            label: '我的号码',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: '我的',
          ),
        ],
      ),
    );
  }
}
