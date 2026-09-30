import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../annotations/presentation/screens/my_stuff_screen.dart';
import '../providers/profile_providers.dart';

/// Profile tab: name + avatar, and everything you've saved.
class YouScreen extends ConsumerWidget {
  const YouScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = ref.watch(displayNameProvider);
    final photoUrl = ref.watch(profilePhotoUrlProvider);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final shownName = name.isEmpty ? 'Your name' : name;
    final initial = name.isEmpty ? '?' : name.trim()[0].toUpperCase();

    return DefaultTabController(
      length: 1,
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (context, _) => [
            SliverAppBar(
              pinned: true,
              floating: true,
              titleSpacing: 20,
              title: const SizedBox.shrink(),
              actions: [
                IconButton(
                  tooltip: 'Settings',
                  icon: const Icon(Icons.settings_outlined),
                  onPressed: () => context.push(AppRoutes.settings),
                ),
                const SizedBox(width: 8),
              ],
              expandedHeight: 224,
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.pin,
                background: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 56, 20, 0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                shownName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 8),
                              InkWell(
                                borderRadius: BorderRadius.circular(8),
                                onTap: () =>
                                    context.push(AppRoutes.editProfile),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 4,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.edit_outlined,
                                        size: 18,
                                        color: scheme.onSurface,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Edit profile',
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        _Avatar(initial: initial, photoUrl: photoUrl),
                      ],
                    ),
                  ),
                ),
              ),
              bottom: const TabBar(
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                padding: EdgeInsets.symmetric(horizontal: 8),
                tabs: [Tab(text: 'Saved')],
              ),
            ),
          ],
          body: const TabBarView(children: [MyStuffBody()]),
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.initial, required this.photoUrl});
  final String initial;
  final String photoUrl;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    if (photoUrl.isNotEmpty) {
      return ClipOval(
        child: SizedBox(
          width: 84,
          height: 84,
          child: Image.network(
            photoUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: scheme.surface,
                border: Border.all(color: scheme.onSurface, width: 3),
              ),
              alignment: Alignment.center,
              child: Text(
                initial,
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      width: 84,
      height: 84,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: scheme.surface,
        border: Border.all(color: scheme.onSurface, width: 3),
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: Theme.of(
          context,
        ).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w800),
      ),
    );
  }
}
