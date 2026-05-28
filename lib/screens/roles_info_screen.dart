import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../models/role.dart';
import '../models/roles_catalog.dart';
import '../models/team.dart';
import '../widgets/app_background.dart';
import '../widgets/role_card.dart';

class RolesInfoScreen extends StatelessWidget {
  const RolesInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<Team, List<Role>> grouped = <Team, List<Role>>{
      Team.village: <Role>[],
      Team.vampire: <Role>[],
      Team.neutral: <Role>[],
    };
    for (final Role r in RolesCatalog.all) {
      grouped[r.team]!.add(r);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Roller')),
      body: AppBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              for (final MapEntry<Team, List<Role>> entry in grouped.entries)
                if (entry.value.isNotEmpty) ...<Widget>[
                  _TeamHeader(team: entry.key, count: entry.value.length),
                  const SizedBox(height: 8),
                  ...entry.value.map(
                    (Role r) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _RoleSummaryTile(role: r),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
            ],
          ),
        ),
      ),
    );
  }
}

class _TeamHeader extends StatelessWidget {
  const _TeamHeader({required this.team, required this.count});
  final Team team;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: team.color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: team.color),
      ),
      child: Row(
        children: <Widget>[
          Text(
            team.displayName.toUpperCase(),
            style: AppTextStyles.headlineMedium.copyWith(color: team.color),
          ),
          const Spacer(),
          Text('$count rol', style: AppTextStyles.caption),
        ],
      ),
    );
  }
}

class _RoleSummaryTile extends StatelessWidget {
  const _RoleSummaryTile({required this.role});
  final Role role;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: role.accentColor.withValues(alpha: 0.3),
          child: Icon(role.icon, color: role.accentColor),
        ),
        title: Text(role.displayName, style: AppTextStyles.headlineSmall),
        subtitle: Text(role.description, style: AppTextStyles.bodySmall),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => showModalBottomSheet<void>(
          context: context,
          backgroundColor: Colors.transparent,
          isScrollControlled: true,
          builder: (BuildContext ctx) => DraggableScrollableSheet(
            initialChildSize: 0.85,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            expand: false,
            builder: (BuildContext c, ScrollController sc) => Container(
              decoration: const BoxDecoration(
                color: AppColors.background,
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SingleChildScrollView(
                controller: sc,
                padding: const EdgeInsets.all(20),
                child: RoleCard(role: role),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
