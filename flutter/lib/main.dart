import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/providers/navigation_provider.dart';
import 'core/theme/app_theme.dart';
import 'features/home/home_screen.dart';
import 'features/report/discovery_screen.dart';
import 'features/profile/messages_screen.dart';
import 'features/profile/profile_screen.dart';
import 'features/auth/login_screen.dart';
import 'core/providers/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  
  runApp(
    const ProviderScope(
      child: JifouApp(),
    ),
  );
}

class JifouApp extends StatelessWidget {
  const JifouApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '记否',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    if (authState.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (authState.isAuthenticated) {
      return const MainScreen();
    }

    return const LoginScreen();
  }
}

class MainScreen extends ConsumerWidget {
  const MainScreen({super.key});

  final List<Widget> _screens = const [
    HomeScreen(),
    DiscoveryScreen(),
    MessagesScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(navigationIndexProvider);

    return Scaffold(
      body: IndexedStack(
        index: selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (index) {
          ref.read(navigationIndexProvider.notifier).state = index;
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.auto_awesome_outlined),
            activeIcon: Icon(Icons.auto_awesome),
            label: '记录',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore_outlined),
            activeIcon: Icon(Icons.explore),
            label: '发现',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            activeIcon: Icon(Icons.chat_bubble),
            label: '消息',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: '我的',
          ),
        ],
      ),
    );
  }
}
