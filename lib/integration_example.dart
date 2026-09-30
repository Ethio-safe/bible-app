import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'features/lockscreen_verses/presentation/screens/lockscreen_verses_screen.dart';
import 'features/lockscreen_verses/presentation/screens/root_access_screen.dart';

/// Add these routes to your GoRouter configuration in main.dart

final settingsRoutes = [
  GoRoute(
    path: 'lock-screen-verses',
    name: 'lockscreenVerses',
    builder: (context, state) => const LockscreenVersesScreen(),
  ),
  GoRoute(
    path: 'root-access',
    name: 'rootAccess',
    builder: (context, state) => const RootAccessScreen(),
  ),
];

/// Add to your automation/settings screen to navigate to these:

class LockScreenVersesIntegration extends ConsumerWidget {
  const LockScreenVersesIntegration({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Automation')),
      body: ListView(
        children: [
          // Existing automation settings...
          
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Lock Screen Verses',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text('View Verses'),
            subtitle: const Text('Manage 10 random lock screen verses'),
            onTap: () => context.push('/settings/lock-screen-verses'),
          ),
          ListTile(
            leading: const Icon(Icons.security),
            title: const Text('Root Access'),
            subtitle: const Text('Enable automatic verse rotation on lock'),
            onTap: () => context.push('/settings/root-access'),
          ),
        ],
      ),
    );
  }
}
