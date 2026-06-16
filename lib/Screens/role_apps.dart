import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../providers/auth.dart';
import '../services/supabase_service.dart';

class AdminAppScreen extends StatelessWidget {
  const AdminAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _RoleGate(
      requiredRole: 'admin',
      title: 'لوحة الإدارة',
      subtitle: 'إدارة المحتوى والطلبات والحسابات',
      icon: Icons.admin_panel_settings_rounded,
      child: const _AdminWorkspace(),
    );
  }
}

class ConsultantAppScreen extends StatelessWidget {
  const ConsultantAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _RoleGate(
      requiredRole: 'consultant',
      title: 'واجهة المستشار',
      subtitle: 'متابعة الطلبات والملف المهني',
      icon: Icons.support_agent_rounded,
      child: const _ConsultantWorkspace(),
    );
  }
}

class _RoleGate extends StatelessWidget {
  const _RoleGate({
    required this.requiredRole,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.child,
  });

  final String requiredRole;
  final String title;
  final String subtitle;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<Auth>();
    if (auth.login_status && auth.type == requiredRole) return child;

    return _RoleLoginScreen(
      requiredRole: requiredRole,
      title: title,
      subtitle: subtitle,
      icon: icon,
    );
  }
}

class _RoleLoginScreen extends StatefulWidget {
  const _RoleLoginScreen({
    required this.requiredRole,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String requiredRole;
  final String title;
  final String subtitle;
  final IconData icon;

  @override
  State<_RoleLoginScreen> createState() => _RoleLoginScreenState();
}

class _RoleLoginScreenState extends State<_RoleLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        leading: IconButton(
          tooltip: 'رجوع',
          onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: ListView(
              padding: const EdgeInsets.all(24),
              shrinkWrap: true,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: colorScheme.primaryContainer,
                  foregroundColor: colorScheme.onPrimaryContainer,
                  child: Icon(widget.icon, size: 38),
                ),
                const SizedBox(height: 22),
                Text(
                  widget.title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.subtitle,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 26),
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _usernameController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'اسم المستخدم',
                          prefixIcon: Icon(Icons.person_outline_rounded),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'يرجى إدخال اسم المستخدم';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                          labelText: 'كلمة السر',
                          prefixIcon: const Icon(Icons.lock_outline_rounded),
                          suffixIcon: IconButton(
                            tooltip: _obscurePassword
                                ? 'إظهار كلمة السر'
                                : 'إخفاء كلمة السر',
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'يرجى إدخال كلمة السر';
                          }
                          return null;
                        },
                      ),
                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: TextButton(
                          onPressed: _isLoading
                              ? null
                              : () => Navigator.pushNamed(
                                    context,
                                    '/reset-password',
                                  ),
                          child: const Text('نسيت كلمة السر؟'),
                        ),
                      ),
                      const SizedBox(height: 18),
                      FilledButton(
                        onPressed: _isLoading ? null : _submit,
                        child: _isLoading
                            ? const SizedBox.square(
                                dimension: 20,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('دخول'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final auth = context.read<Auth>();
    final success = await auth.loginForRole(
      username: _usernameController.text,
      password: _passwordController.text,
      requiredRole: widget.requiredRole,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);
    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.lastError ?? 'تعذر تسجيل الدخول')),
      );
    }
  }
}

class _AdminWorkspace extends StatefulWidget {
  const _AdminWorkspace();

  @override
  State<_AdminWorkspace> createState() => _AdminWorkspaceState();
}

class _AdminWorkspaceState extends State<_AdminWorkspace> {
  _AdminData? _data;
  late Future<_AdminData> _future = _loadAndStore();
  int _selectedIndex = 0;

  static const _destinations = [
    _AdminDestination(
      label: 'نظرة عامة',
      icon: Icons.space_dashboard_outlined,
      selectedIcon: Icons.space_dashboard_rounded,
    ),
    _AdminDestination(
      label: 'طلبات المستخدمين',
      icon: Icons.receipt_long_outlined,
      selectedIcon: Icons.receipt_long_rounded,
    ),
    _AdminDestination(
      label: 'المحتوى',
      icon: Icons.inventory_2_outlined,
      selectedIcon: Icons.inventory_2_rounded,
    ),
    _AdminDestination(
      label: 'المستخدمون',
      icon: Icons.groups_outlined,
      selectedIcon: Icons.groups_rounded,
    ),
    _AdminDestination(
      label: 'طلبات المستشارين',
      icon: Icons.fact_check_outlined,
      selectedIcon: Icons.fact_check_rounded,
    ),
    _AdminDestination(
      label: 'الإعدادات',
      icon: Icons.tune_outlined,
      selectedIcon: Icons.tune_rounded,
    ),
  ];

  Future<_AdminData> _load() async {
    final results = await Future.wait([
      SupabaseService.list('orders'),
      SupabaseService.list('animals'),
      SupabaseService.list('cars'),
      SupabaseService.list('home_ads'),
      SupabaseService.listWhere(
        'profiles',
        column: 'account_type',
        value: 'consultant',
      ),
      SupabaseService.list('consultant_applications'),
      SupabaseService.list('consultant_required_documents'),
      SupabaseService.list('app_settings'),
      SupabaseService.list('profiles'),
    ]);

    return _AdminData(
      orders: results[0],
      animals: results[1],
      cars: results[2],
      ads: results[3],
      consultants: results[4],
      consultantApplications: results[5],
      requiredDocuments: results[6],
      appSettings: results[7],
      users: results[8],
    );
  }

  Future<_AdminData> _loadAndStore() async {
    final data = await _load();
    if (mounted) {
      setState(() => _data = data);
    }
    return data;
  }

  void _refreshInBackground() {
    final future = _loadAndStore();
    setState(() => _future = future);
  }

  void _patchData(_AdminData Function(_AdminData current) patch) {
    final current = _data;
    if (current == null) {
      _refreshInBackground();
      return;
    }
    setState(() => _data = patch(current));
    _refreshInBackground();
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 820;

    return Scaffold(
      drawer: isWide
          ? null
          : Drawer(
              child: SafeArea(
                child: _AdminDrawerMenu(
                  destinations: _destinations,
                  selectedIndex: _selectedIndex,
                  onSelected: (index) {
                    Navigator.pop(context);
                    setState(() => _selectedIndex = index);
                  },
                ),
              ),
            ),
      appBar: AppBar(
        title: Text(_destinations[_selectedIndex].label),
        leading: isWide
            ? null
            : Builder(
                builder: (context) => IconButton(
                  tooltip: 'القائمة',
                  onPressed: () => Scaffold.of(context).openDrawer(),
                  icon: const Icon(Icons.menu_rounded),
                ),
              ),
        actions: [
          IconButton(
            tooltip: 'تحديث',
            onPressed: _refreshInBackground,
            icon: const Icon(Icons.refresh_rounded),
          ),
          const _RoleLogoutButton(),
        ],
      ),
      body: FutureBuilder<_AdminData>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              _data == null) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = _data ?? snapshot.data ?? _AdminData.empty();
          final pages = _adminPages(data);

          if (!isWide) return pages[_selectedIndex];

          return Row(
            children: [
              _AdminSideRail(
                destinations: _destinations,
                selectedIndex: _selectedIndex,
                onSelected: (index) => setState(() => _selectedIndex = index),
              ),
              VerticalDivider(
                width: 1,
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
              Expanded(child: pages[_selectedIndex]),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _adminPages(_AdminData data) {
    return [
      _AdminOverview(data: data),
      _RecordListPanel(
        title: 'طلبات المستخدمين',
        records: data.orders,
        icon: Icons.receipt_long_outlined,
        emptyText: 'لا توجد طلبات حالية.',
      ),
      _AdminContentPanel(data: data),
      _UsersPanel(users: data.users),
      _ConsultantManagementPanel(
        applications: data.consultantApplications,
        onReviewed: _applyApplicationReview,
      ),
      _AdminSettingsPanel(
        settings: data.appSettings,
        requiredDocuments: data.requiredDocuments,
        onSettingSaved: _applySetting,
        onDocumentAdded: _applyDocumentAdded,
        onDocumentToggled: _applyDocumentToggled,
      ),
    ];
  }

  void _applyApplicationReview(
    Map<String, dynamic> application,
    bool approved,
  ) {
    final status = approved ? 'approved' : 'refused';
    _patchData((current) {
      return current.copyWith(
        consultantApplications: current.consultantApplications.map((item) {
          if (item['id'] != application['id']) return item;
          return {
            ...item,
            'status': status,
            'reviewed_at': DateTime.now().toIso8601String(),
          };
        }).toList(),
        users: approved
            ? current.users.map((item) {
                if (item['id'] != application['user_id']) return item;
                return {
                  ...item,
                  'account_type': 'consultant',
                  'active': true,
                };
              }).toList()
            : current.users,
      );
    });
  }

  void _applySetting(String key, String value) {
    _patchData((current) {
      final existingIndex = current.appSettings.indexWhere(
        (setting) => setting['key']?.toString() == key,
      );
      final nextSettings = [...current.appSettings];
      final setting = {
        'key': key,
        'value': value,
        'updated_at': DateTime.now().toIso8601String(),
      };
      if (existingIndex == -1) {
        nextSettings.insert(0, setting);
      } else {
        nextSettings[existingIndex] = {
          ...nextSettings[existingIndex],
          ...setting,
        };
      }
      return current.copyWith(appSettings: nextSettings);
    });
  }

  void _applyDocumentAdded(String title) {
    _patchData((current) {
      return current.copyWith(
        requiredDocuments: [
          {
            'title': title,
            'active': true,
            'created_at': DateTime.now().toIso8601String(),
          },
          ...current.requiredDocuments,
        ],
      );
    });
  }

  void _applyDocumentToggled(Map<String, dynamic> document, bool active) {
    _patchData((current) {
      return current.copyWith(
        requiredDocuments: current.requiredDocuments.map((item) {
          if (item['id'] != document['id'] &&
              item['title'] != document['title']) {
            return item;
          }
          return {...item, 'active': active};
        }).toList(),
      );
    });
  }
}

class _AdminSideRail extends StatelessWidget {
  const _AdminSideRail({
    required this.destinations,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<_AdminDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      extended: MediaQuery.sizeOf(context).width >= 1080,
      selectedIndex: selectedIndex,
      onDestinationSelected: onSelected,
      labelType: MediaQuery.sizeOf(context).width >= 1080
          ? NavigationRailLabelType.none
          : NavigationRailLabelType.selected,
      leading: const Padding(
        padding: EdgeInsets.only(top: 12, bottom: 10),
        child: Icon(Icons.admin_panel_settings_rounded),
      ),
      destinations: [
        for (final destination in destinations)
          NavigationRailDestination(
            icon: Icon(destination.icon),
            selectedIcon: Icon(destination.selectedIcon),
            label: Text(destination.label),
          ),
      ],
    );
  }
}

class _AdminDrawerMenu extends StatelessWidget {
  const _AdminDrawerMenu({
    required this.destinations,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<_AdminDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return NavigationDrawer(
      selectedIndex: selectedIndex,
      onDestinationSelected: onSelected,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
          child: Text(
            'لوحة الإدارة',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
          ),
        ),
        for (final destination in destinations)
          NavigationDrawerDestination(
            icon: Icon(destination.icon),
            selectedIcon: Icon(destination.selectedIcon),
            label: Text(destination.label),
          ),
      ],
    );
  }
}

class _AdminDestination {
  const _AdminDestination({
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

class _ConsultantWorkspace extends StatefulWidget {
  const _ConsultantWorkspace();

  @override
  State<_ConsultantWorkspace> createState() => _ConsultantWorkspaceState();
}

class _ConsultantWorkspaceState extends State<_ConsultantWorkspace> {
  late Future<_ConsultantData> _future = _load();

  Future<_ConsultantData> _load() async {
    final auth = context.read<Auth>();
    final results = await Future.wait([
      SupabaseService.listWhere('orders',
          column: 'consultant_id', value: auth.userId),
      SupabaseService.listWhere('profiles', column: 'id', value: auth.userId),
    ]);

    return _ConsultantData(
      orders: results[0],
      profile: results[1].isEmpty ? {} : results[1].first,
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('واجهة المستشار'),
          actions: const [_RoleLogoutButton()],
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.receipt_long_outlined)),
              Tab(icon: Icon(Icons.person_outline_rounded)),
            ],
          ),
        ),
        body: FutureBuilder<_ConsultantData>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final data = snapshot.data ?? _ConsultantData.empty();
            return RefreshIndicator(
              onRefresh: () async {
                setState(() => _future = _load());
                await _future;
              },
              child: TabBarView(
                children: [
                  _RecordListPanel(
                    title: 'الطلبات المسندة',
                    records: data.orders,
                    icon: Icons.receipt_long_outlined,
                    emptyText: 'لا توجد طلبات مسندة حالياً.',
                  ),
                  _ProfilePanel(profile: data.profile),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _RoleLogoutButton extends StatelessWidget {
  const _RoleLogoutButton();

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'تسجيل الخروج',
      onPressed: () async {
        await context.read<Auth>().logout();
        if (context.mounted) {
          Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
        }
      },
      icon: const Icon(Icons.logout_rounded),
    );
  }
}

class _AdminOverview extends StatelessWidget {
  const _AdminOverview({required this.data});

  final _AdminData data;

  @override
  Widget build(BuildContext context) {
    final pendingApplications = data.consultantApplications
        .where((item) => _value(item, ['status']) == 'pending')
        .length;
    final openOrders = data.orders
        .where((item) => _value(item, ['status'], fallback: 'new') != 'done')
        .length;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _MetricGrid(
          metrics: [
            _Metric('الطلبات', data.orders.length, Icons.receipt_long_outlined),
            _Metric('قيد المتابعة', openOrders, Icons.pending_actions_outlined),
            _Metric('الحيوانات', data.animals.length, Icons.pets_outlined),
            _Metric(
                'السيارات', data.cars.length, Icons.directions_car_outlined),
            _Metric('الإعلانات', data.ads.length, Icons.campaign_outlined),
            _Metric(
                'طلبات مستشار', pendingApplications, Icons.fact_check_outlined),
          ],
        ),
        const SizedBox(height: 18),
        _ResponsiveAdminGrid(
          children: [
            _AdminChartCard(
              title: 'توزيع المحتوى',
              icon: Icons.bar_chart_rounded,
              values: [
                _ChartValue('طلبات', data.orders.length),
                _ChartValue('سيارات', data.cars.length),
                _ChartValue('حيوانات', data.animals.length),
                _ChartValue('إعلانات', data.ads.length),
              ],
            ),
            _AdminChartCard(
              title: 'حالة المستشارين',
              icon: Icons.donut_large_outlined,
              values: [
                _ChartValue('نشط', data.consultants.length),
                _ChartValue('قيد المراجعة', pendingApplications),
                _ChartValue(
                  'مرفوض',
                  data.consultantApplications
                      .where((item) => _value(item, ['status']) == 'refused')
                      .length,
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 18),
        _RecordListPanel(
          title: 'أحدث الطلبات',
          records: data.orders.take(6).toList(),
          icon: Icons.receipt_long_outlined,
          emptyText: 'لا توجد طلبات حالية.',
          shrinkWrap: true,
        ),
      ],
    );
  }
}

class _AdminContentPanel extends StatelessWidget {
  const _AdminContentPanel({required this.data});

  final _AdminData data;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _RecordListPanel(
          title: 'إعلانات الصفحة الرئيسية',
          records: data.ads,
          icon: Icons.campaign_outlined,
          emptyText: 'لا توجد إعلانات.',
          shrinkWrap: true,
        ),
        const SizedBox(height: 16),
        _RecordListPanel(
          title: 'السيارات',
          records: data.cars,
          icon: Icons.directions_car_outlined,
          emptyText: 'لا توجد سيارات.',
          shrinkWrap: true,
        ),
        const SizedBox(height: 16),
        _RecordListPanel(
          title: 'الحيوانات',
          records: data.animals,
          icon: Icons.pets_outlined,
          emptyText: 'لا توجد حيوانات.',
          shrinkWrap: true,
        ),
      ],
    );
  }
}

class _ConsultantManagementPanel extends StatefulWidget {
  const _ConsultantManagementPanel({
    required this.applications,
    required this.onReviewed,
  });

  final List<Map<String, dynamic>> applications;
  final void Function(Map<String, dynamic> application, bool approved)
      onReviewed;

  @override
  State<_ConsultantManagementPanel> createState() =>
      _ConsultantManagementPanelState();
}

class _ConsultantManagementPanelState
    extends State<_ConsultantManagementPanel> {
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    final applicationsError =
        SupabaseService.errorFor('consultant_applications');
    final pendingCount = widget.applications
        .where((item) => _value(item, ['status']) == 'pending')
        .length;
    final approvedCount = widget.applications
        .where((item) => _value(item, ['status']) == 'approved')
        .length;
    final refusedCount = widget.applications
        .where((item) => _value(item, ['status']) == 'refused')
        .length;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _MetricGrid(
          metrics: [
            _Metric('كل الطلبات', widget.applications.length,
                Icons.assignment_outlined),
            _Metric('قيد المراجعة', pendingCount, Icons.pending_actions),
            _Metric('مقبولة', approvedCount, Icons.verified_outlined),
            _Metric('مرفوضة', refusedCount, Icons.block_outlined),
          ],
        ),
        const SizedBox(height: 18),
        _SectionHeader(
          title: 'طلبات انضمام المستشارين',
          icon: Icons.fact_check_outlined,
        ),
        if (applicationsError != null) ...[
          const SizedBox(height: 10),
          _PanelWarning(
            text: 'تعذر تحميل طلبات المستشارين: $applicationsError',
          ),
        ],
        const SizedBox(height: 10),
        _PanelSurface(
          child: widget.applications.isEmpty
              ? const _EmptyPanel(
                  text: 'لا توجد طلبات تسجيل مستشارين.',
                  icon: Icons.fact_check_outlined,
                )
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: widget.applications.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1, indent: 72),
                  itemBuilder: (context, index) {
                    final application = widget.applications[index];
                    return _ConsultantApplicationTile(
                      application: application,
                      isSaving: _isSaving,
                      onReview: (approved) => _reviewApplication(
                        application,
                        approved: approved,
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Future<void> _reviewApplication(
    Map<String, dynamic> application, {
    required bool approved,
  }) async {
    setState(() => _isSaving = true);
    final id = application['id'];
    final userId = application['user_id'];
    final status = approved ? 'approved' : 'refused';

    var saved = await SupabaseService.updateWhere(
      'consultant_applications',
      {
        'status': status,
        'reviewed_at': DateTime.now().toIso8601String(),
      },
      column: 'id',
      value: id,
    );

    if (approved && saved && userId != null) {
      saved = await SupabaseService.updateWhere(
        'profiles',
        {
          'account_type': 'consultant',
          'active': true,
          'updated_at': DateTime.now().toIso8601String(),
        },
        column: 'id',
        value: userId,
      );
    }

    if (!mounted) return;
    setState(() => _isSaving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          saved
              ? 'تم حفظ القرار'
              : 'تعذر حفظ القرار: ${SupabaseService.errorFor('consultant_applications') ?? SupabaseService.errorFor('profiles') ?? 'تحقق من صلاحيات قاعدة البيانات'}',
        ),
      ),
    );
    if (saved) widget.onReviewed(application, approved);
  }
}

class _ConsultantApplicationTile extends StatelessWidget {
  const _ConsultantApplicationTile({
    required this.application,
    required this.isSaving,
    required this.onReview,
  });

  final Map<String, dynamic> application;
  final bool isSaving;
  final ValueChanged<bool> onReview;

  @override
  Widget build(BuildContext context) {
    final status = _value(application, ['status'], fallback: 'pending');
    final isPending = status == 'pending';
    final name = _value(application, ['full_name'], fallback: 'طلب مستشار');
    final contact = _value(application, ['phone', 'email'], fallback: '-');
    final hasDocument = _value(application, ['document_url']).isNotEmpty;

    return InkWell(
      onTap: () => _showAdminRecordDetails(
        context,
        title: name,
        icon: Icons.fact_check_outlined,
        record: application,
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 12, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CircleAvatar(
              child: Icon(Icons.support_agent_outlined, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_statusLabel(status)} - $contact',
                    textDirection: TextDirection.rtl,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      InputChip(
                        avatar: Icon(
                          hasDocument
                              ? Icons.picture_as_pdf_outlined
                              : Icons.description_outlined,
                          size: 18,
                        ),
                        label: Text(hasDocument ? 'ملف PDF مرفق' : 'بدون ملف'),
                        onPressed: () => _showAdminRecordDetails(
                          context,
                          title: name,
                          icon: Icons.fact_check_outlined,
                          record: application,
                        ),
                      ),
                      if (isPending) ...[
                        FilledButton.tonalIcon(
                          onPressed: isSaving ? null : () => onReview(true),
                          icon: const Icon(Icons.check_rounded),
                          label: const Text('قبول'),
                        ),
                        OutlinedButton.icon(
                          onPressed: isSaving ? null : () => onReview(false),
                          icon: const Icon(Icons.close_rounded),
                          label: const Text('رفض'),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_left_rounded),
          ],
        ),
      ),
    );
  }
}

class _PanelWarning extends StatelessWidget {
  const _PanelWarning({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.errorContainer,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.error_outline_rounded, color: scheme.onErrorContainer),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                style: TextStyle(color: scheme.onErrorContainer),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminSettingsPanel extends StatefulWidget {
  const _AdminSettingsPanel({
    required this.settings,
    required this.requiredDocuments,
    required this.onSettingSaved,
    required this.onDocumentAdded,
    required this.onDocumentToggled,
  });

  final List<Map<String, dynamic>> settings;
  final List<Map<String, dynamic>> requiredDocuments;
  final void Function(String key, String value) onSettingSaved;
  final ValueChanged<String> onDocumentAdded;
  final void Function(Map<String, dynamic> document, bool active)
      onDocumentToggled;

  @override
  State<_AdminSettingsPanel> createState() => _AdminSettingsPanelState();
}

class _AdminSettingsPanelState extends State<_AdminSettingsPanel> {
  final _maintenanceController = TextEditingController();
  final _documentController = TextEditingController();
  bool _isSaving = false;

  static const _toggles = [
    _SettingDefinition(
      key: 'registration_enabled',
      title: 'تفعيل التسجيل',
      subtitle: 'السماح بإنشاء حسابات جديدة',
      icon: Icons.person_add_alt_rounded,
      defaultValue: true,
    ),
    _SettingDefinition(
      key: 'cars_orders_enabled',
      title: 'طلبات السيارات',
      subtitle: 'إظهار وإرسال طلبات خدمات السيارات',
      icon: Icons.directions_car_outlined,
      defaultValue: true,
    ),
    _SettingDefinition(
      key: 'animals_orders_enabled',
      title: 'طلبات الحيوانات',
      subtitle: 'إظهار وإرسال طلبات خدمات الحيوانات',
      icon: Icons.pets_outlined,
      defaultValue: true,
    ),
    _SettingDefinition(
      key: 'consulting_orders_enabled',
      title: 'طلبات الاستشارة',
      subtitle: 'السماح بطلبات المستشارين',
      icon: Icons.support_agent_outlined,
      defaultValue: true,
    ),
    _SettingDefinition(
      key: 'maintenance_mode',
      title: 'وضع الصيانة',
      subtitle: 'إيقاف التجربة العامة مؤقتاً',
      icon: Icons.construction_outlined,
      defaultValue: false,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _maintenanceController.text =
        _settingValue('maintenance_message', fallback: '');
  }

  @override
  void didUpdateWidget(covariant _AdminSettingsPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.settings != widget.settings) {
      _maintenanceController.text =
          _settingValue('maintenance_message', fallback: '');
    }
  }

  @override
  void dispose() {
    _maintenanceController.dispose();
    _documentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _SectionHeader(title: 'إعدادات التطبيق', icon: Icons.tune_outlined),
        const SizedBox(height: 10),
        _PanelSurface(
          child: Column(
            children: [
              for (int index = 0; index < _toggles.length; index++) ...[
                SwitchListTile(
                  secondary: CircleAvatar(
                    child: Icon(_toggles[index].icon, size: 20),
                  ),
                  title: Text(_toggles[index].title),
                  subtitle: Text(_toggles[index].subtitle),
                  value: _settingBool(
                    _toggles[index].key,
                    fallback: _toggles[index].defaultValue,
                  ),
                  onChanged: _isSaving
                      ? null
                      : (value) => _saveSetting(
                            key: _toggles[index].key,
                            value: value.toString(),
                          ),
                ),
                if (index < _toggles.length - 1)
                  const Divider(height: 1, indent: 72),
              ],
            ],
          ),
        ),
        const SizedBox(height: 18),
        _SectionHeader(
          title: 'رسالة الصيانة',
          icon: Icons.campaign_outlined,
        ),
        const SizedBox(height: 10),
        _PanelSurface(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _maintenanceController,
                  minLines: 2,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'النص الذي يظهر عند تفعيل الصيانة',
                    prefixIcon: Icon(Icons.notes_outlined),
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: _isSaving
                      ? null
                      : () => _saveSetting(
                            key: 'maintenance_message',
                            value: _maintenanceController.text.trim(),
                          ),
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('حفظ الرسالة'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),
        _SectionHeader(
          title: 'أوراق انضمام المستشار',
          icon: Icons.description_outlined,
        ),
        const SizedBox(height: 10),
        _RequiredDocumentsSettings(
          documents: widget.requiredDocuments,
          controller: _documentController,
          isSaving: _isSaving,
          onAdd: _addRequiredDocument,
          onToggle: _toggleRequiredDocument,
        ),
      ],
    );
  }

  bool _settingBool(String key, {required bool fallback}) {
    final value = _settingValue(key, fallback: fallback.toString());
    return value == 'true' || value == '1';
  }

  String _settingValue(String key, {required String fallback}) {
    for (final setting in widget.settings) {
      if (setting['key']?.toString() == key) {
        return setting['value']?.toString() ?? fallback;
      }
    }
    return fallback;
  }

  Future<void> _saveSetting({
    required String key,
    required String value,
  }) async {
    setState(() => _isSaving = true);
    final saved = await SupabaseService.upsert('app_settings', {
      'key': key,
      'value': value,
      'updated_at': DateTime.now().toIso8601String(),
    });

    if (!mounted) return;
    setState(() => _isSaving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(saved ? 'تم حفظ الإعداد' : 'تعذر حفظ الإعداد')),
    );
    if (saved) widget.onSettingSaved(key, value);
  }

  Future<void> _addRequiredDocument() async {
    final title = _documentController.text.trim();
    if (title.isEmpty) return;

    setState(() => _isSaving = true);
    final saved = await SupabaseService.insert(
      'consultant_required_documents',
      {'title': title, 'active': true},
    );

    if (!mounted) return;
    setState(() => _isSaving = false);
    if (saved) {
      _documentController.clear();
      widget.onDocumentAdded(title);
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          saved
              ? 'تمت إضافة الورقة'
              : 'تعذرت الإضافة: ${SupabaseService.errorFor('consultant_required_documents') ?? 'تحقق من صلاحيات قاعدة البيانات'}',
        ),
      ),
    );
  }

  Future<void> _toggleRequiredDocument(
    Map<String, dynamic> document,
    bool active,
  ) async {
    setState(() => _isSaving = true);
    final saved = await SupabaseService.updateWhere(
      'consultant_required_documents',
      {'active': active},
      column: 'id',
      value: document['id'],
    );

    if (!mounted) return;
    setState(() => _isSaving = false);
    if (saved) {
      widget.onDocumentToggled(document, active);
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'تعذر تغيير حالة الورقة: ${SupabaseService.errorFor('consultant_required_documents') ?? 'تحقق من صلاحيات قاعدة البيانات'}',
        ),
      ),
    );
  }
}

class _RequiredDocumentsSettings extends StatelessWidget {
  const _RequiredDocumentsSettings({
    required this.documents,
    required this.controller,
    required this.isSaving,
    required this.onAdd,
    required this.onToggle,
  });

  final List<Map<String, dynamic>> documents;
  final TextEditingController controller;
  final bool isSaving;
  final VoidCallback onAdd;
  final void Function(Map<String, dynamic> document, bool active) onToggle;

  @override
  Widget build(BuildContext context) {
    final documentsError =
        SupabaseService.errorFor('consultant_required_documents');

    return Column(
      children: [
        if (documentsError != null) ...[
          _PanelWarning(
            text: 'تعذر تحميل أو حفظ الأوراق المطلوبة: $documentsError',
          ),
          const SizedBox(height: 10),
        ],
        _PanelSurface(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller,
                        textDirection: TextDirection.rtl,
                        decoration: const InputDecoration(
                          labelText: 'اسم الورقة المطلوبة',
                          prefixIcon: Icon(Icons.description_outlined),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filled(
                      tooltip: 'إضافة',
                      onPressed: isSaving ? null : onAdd,
                      icon: const Icon(Icons.add_rounded),
                    ),
                  ],
                ),
              ),
              if (documents.isEmpty)
                const _EmptyPanel(
                  text: 'لا توجد أوراق مطلوبة حالياً.',
                  icon: Icons.description_outlined,
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: documents.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1, indent: 72),
                  itemBuilder: (context, index) {
                    final document = documents[index];
                    final active = document['active'] != false;
                    return ListTile(
                      leading: Icon(
                        active
                            ? Icons.check_circle_outline_rounded
                            : Icons.pause_circle_outline_rounded,
                      ),
                      title: Text(
                        _value(document, ['title']),
                        textDirection: TextDirection.rtl,
                      ),
                      subtitle: Text(active ? 'نشط' : 'غير نشط'),
                      trailing: Switch(
                        value: active,
                        onChanged: isSaving
                            ? null
                            : (value) => onToggle(document, value),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProfilePanel extends StatelessWidget {
  const _ProfilePanel({required this.profile});

  final Map<String, dynamic> profile;

  @override
  Widget build(BuildContext context) {
    final entries = [
      _PanelEntry('الاسم', _recordTitle(profile), Icons.badge_outlined),
      _PanelEntry('التخصص', _value(profile, ['specialty']),
          Icons.workspace_premium_outlined),
      _PanelEntry('البريد', _value(profile, ['email']), Icons.mail_outlined),
      _PanelEntry('الجوال', _value(profile, ['phone']), Icons.phone_outlined),
      _PanelEntry('الحالة', _value(profile, ['status'], fallback: 'نشط'),
          Icons.verified_outlined),
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _SectionHeader(title: 'الملف المهني', icon: Icons.person_outline),
        const SizedBox(height: 10),
        _PanelList(
          entries: entries,
          emptyText: 'لا توجد بيانات ملف مهني.',
        ),
      ],
    );
  }
}

class _RecordListPanel extends StatelessWidget {
  const _RecordListPanel({
    required this.title,
    required this.records,
    required this.icon,
    required this.emptyText,
    this.shrinkWrap = false,
  });

  final String title;
  final List<Map<String, dynamic>> records;
  final IconData icon;
  final String emptyText;
  final bool shrinkWrap;

  @override
  Widget build(BuildContext context) {
    final content = records.isEmpty
        ? _EmptyPanel(text: emptyText, icon: icon)
        : ListView.separated(
            shrinkWrap: shrinkWrap,
            physics: shrinkWrap ? const NeverScrollableScrollPhysics() : null,
            padding: EdgeInsets.zero,
            itemCount: records.length,
            separatorBuilder: (_, __) => const Divider(height: 1, indent: 72),
            itemBuilder: (context, index) {
              final record = records[index];
              return ListTile(
                onTap: () => _showAdminRecordDetails(
                  context,
                  title: _recordTitle(record),
                  icon: icon,
                  record: record,
                ),
                leading: CircleAvatar(child: Icon(icon, size: 20)),
                title: Text(
                  _recordTitle(record),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  _recordSubtitle(record),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: const Icon(Icons.chevron_left_rounded),
              );
            },
          );

    if (!shrinkWrap) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionHeader(title: title, icon: icon),
            const SizedBox(height: 10),
            Expanded(child: _PanelSurface(child: content)),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(title: title, icon: icon),
        const SizedBox(height: 10),
        _PanelSurface(child: content),
      ],
    );
  }
}

class _UsersPanel extends StatelessWidget {
  const _UsersPanel({required this.users});

  final List<Map<String, dynamic>> users;

  @override
  Widget build(BuildContext context) {
    final admins =
        users.where((user) => _value(user, ['account_type']) == 'admin').length;
    final consultants = users
        .where((user) => _value(user, ['account_type']) == 'consultant')
        .length;
    final customers = users
        .where(
          (user) => _value(user, ['account_type'], fallback: 'user') == 'user',
        )
        .length;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _MetricGrid(
          metrics: [
            _Metric('كل المستخدمين', users.length, Icons.groups_outlined),
            _Metric('الإدارة', admins, Icons.admin_panel_settings_outlined),
            _Metric('المستشارون', consultants, Icons.support_agent_outlined),
            _Metric('المستخدمون', customers, Icons.person_outline_rounded),
          ],
        ),
        const SizedBox(height: 18),
        _RecordListPanel(
          title: 'قائمة المستخدمين',
          records: users,
          icon: Icons.groups_outlined,
          emptyText: 'لا توجد حسابات أو لا توجد صلاحية قراءة.',
          shrinkWrap: true,
        ),
      ],
    );
  }
}

class _MetricGrid extends StatelessWidget {
  const _MetricGrid({required this.metrics});

  final List<_Metric> metrics;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = width >= 1100
            ? 4
            : width >= 720
                ? 3
                : 2;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: metrics.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: width < 380 ? 1.45 : 1.85,
          ),
          itemBuilder: (context, index) {
            final metric = metrics[index];
            return Card.outlined(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    CircleAvatar(child: Icon(metric.icon, size: 20)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            metric.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                          Text(
                            metric.value.toString(),
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(fontWeight: FontWeight.w900),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _ResponsiveAdminGrid extends StatelessWidget {
  const _ResponsiveAdminGrid({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final useTwoColumns = constraints.maxWidth >= 820;
        if (!useTwoColumns) {
          return Column(
            children: [
              for (int index = 0; index < children.length; index++) ...[
                children[index],
                if (index < children.length - 1) const SizedBox(height: 12),
              ],
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (int index = 0; index < children.length; index++) ...[
              Expanded(child: children[index]),
              if (index < children.length - 1) const SizedBox(width: 12),
            ],
          ],
        );
      },
    );
  }
}

class _AdminChartCard extends StatelessWidget {
  const _AdminChartCard({
    required this.title,
    required this.icon,
    required this.values,
  });

  final String title;
  final IconData icon;
  final List<_ChartValue> values;

  @override
  Widget build(BuildContext context) {
    final maxValue = values.fold<int>(
      1,
      (previous, item) => item.value > previous ? item.value : previous,
    );
    final colorScheme = Theme.of(context).colorScheme;

    return Card.outlined(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionHeader(title: title, icon: icon),
            const SizedBox(height: 14),
            for (final item in values) ...[
              Row(
                children: [
                  SizedBox(
                    width: 82,
                    child: Text(
                      item.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: item.value / maxValue,
                        minHeight: 12,
                        backgroundColor: colorScheme.surfaceContainerHighest,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    item.value.toString(),
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ],
              ),
              if (item != values.last) const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }
}

class _PanelList extends StatelessWidget {
  const _PanelList({required this.entries, required this.emptyText});

  final List<_PanelEntry> entries;
  final String emptyText;

  @override
  Widget build(BuildContext context) {
    final visible = entries.where((entry) => entry.value.isNotEmpty).toList();
    if (visible.isEmpty) {
      return _PanelSurface(
        child: _EmptyPanel(text: emptyText, icon: Icons.info_outline_rounded),
      );
    }

    return _PanelSurface(
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: visible.length,
        separatorBuilder: (_, __) => const Divider(height: 1, indent: 72),
        itemBuilder: (context, index) {
          final entry = visible[index];
          return ListTile(
            leading: CircleAvatar(child: Icon(entry.icon, size: 20)),
            title: Text(entry.label),
            subtitle: Text(entry.value),
          );
        },
      ),
    );
  }
}

class _PanelSurface extends StatelessWidget {
  const _PanelSurface({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: colorScheme.surfaceContainerLow,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: child,
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
              ),
        ),
      ],
    );
  }
}

class _EmptyPanel extends StatelessWidget {
  const _EmptyPanel({required this.text, required this.icon});

  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(icon, size: 34, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 10),
          Text(text, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

Future<void> _showAdminRecordDetails(
  BuildContext context, {
  required String title,
  required IconData icon,
  required Map<String, dynamic> record,
}) {
  final entries = _adminVisibleEntries(record);
  final documentUrl = _value(record, ['document_url']);

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (context) {
      final height = MediaQuery.sizeOf(context).height;
      return ConstrainedBox(
        constraints: BoxConstraints(maxHeight: height * 0.86),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          children: [
            Row(
              children: [
                CircleAvatar(child: Icon(icon)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (documentUrl.isNotEmpty) ...[
              _PanelSurface(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Row(
                        children: [
                          CircleAvatar(
                            child: Icon(Icons.picture_as_pdf_outlined),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('ملف الأوراق المرفق'),
                                SizedBox(height: 2),
                                Text('افتح ملف PDF لمراجعة مستندات الطلب'),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      FilledButton.tonalIcon(
                        onPressed: () =>
                            _openExternalFile(context, documentUrl),
                        icon: const Icon(Icons.open_in_new_rounded),
                        label: const Text('عرض ملف PDF'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
            _PanelSurface(
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: entries.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final entry = entries[index];
                  return ListTile(
                    title: Text(_adminLabelFor(entry.key)),
                    subtitle: Text(
                      _adminDisplayValue(entry.key, entry.value),
                      textDirection: TextDirection.rtl,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
    },
  );
}

Future<void> _openExternalFile(BuildContext context, String url) async {
  final uri = Uri.tryParse(url);
  final messenger = ScaffoldMessenger.of(context);
  if (uri == null) {
    messenger.showSnackBar(
      const SnackBar(content: Text('رابط الملف غير صالح')),
    );
    return;
  }

  final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (!opened) {
    messenger.showSnackBar(
      const SnackBar(content: Text('تعذر فتح ملف PDF')),
    );
  }
}

class _AdminData {
  const _AdminData({
    required this.orders,
    required this.animals,
    required this.cars,
    required this.ads,
    required this.consultants,
    required this.consultantApplications,
    required this.requiredDocuments,
    required this.appSettings,
    required this.users,
  });

  factory _AdminData.empty() => const _AdminData(
        orders: [],
        animals: [],
        cars: [],
        ads: [],
        consultants: [],
        consultantApplications: [],
        requiredDocuments: [],
        appSettings: [],
        users: [],
      );

  final List<Map<String, dynamic>> orders;
  final List<Map<String, dynamic>> animals;
  final List<Map<String, dynamic>> cars;
  final List<Map<String, dynamic>> ads;
  final List<Map<String, dynamic>> consultants;
  final List<Map<String, dynamic>> consultantApplications;
  final List<Map<String, dynamic>> requiredDocuments;
  final List<Map<String, dynamic>> appSettings;
  final List<Map<String, dynamic>> users;

  _AdminData copyWith({
    List<Map<String, dynamic>>? orders,
    List<Map<String, dynamic>>? animals,
    List<Map<String, dynamic>>? cars,
    List<Map<String, dynamic>>? ads,
    List<Map<String, dynamic>>? consultants,
    List<Map<String, dynamic>>? consultantApplications,
    List<Map<String, dynamic>>? requiredDocuments,
    List<Map<String, dynamic>>? appSettings,
    List<Map<String, dynamic>>? users,
  }) {
    return _AdminData(
      orders: orders ?? this.orders,
      animals: animals ?? this.animals,
      cars: cars ?? this.cars,
      ads: ads ?? this.ads,
      consultants: consultants ?? this.consultants,
      consultantApplications:
          consultantApplications ?? this.consultantApplications,
      requiredDocuments: requiredDocuments ?? this.requiredDocuments,
      appSettings: appSettings ?? this.appSettings,
      users: users ?? this.users,
    );
  }
}

class _ConsultantData {
  const _ConsultantData({required this.orders, required this.profile});

  factory _ConsultantData.empty() => const _ConsultantData(
        orders: [],
        profile: {},
      );

  final List<Map<String, dynamic>> orders;
  final Map<String, dynamic> profile;
}

class _Metric {
  const _Metric(this.label, this.value, this.icon);

  final String label;
  final int value;
  final IconData icon;
}

class _ChartValue {
  const _ChartValue(this.label, this.value);

  final String label;
  final int value;
}

class _SettingDefinition {
  const _SettingDefinition({
    required this.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.defaultValue,
  });

  final String key;
  final String title;
  final String subtitle;
  final IconData icon;
  final bool defaultValue;
}

class _PanelEntry {
  const _PanelEntry(this.label, this.value, this.icon);

  final String label;
  final String value;
  final IconData icon;
}

String _recordTitle(Map<String, dynamic> record) {
  return _value(
    record,
    ['title', 'name', 'first_name', 'full_name', 'make'],
    fallback: 'بدون عنوان',
  );
}

String _recordSubtitle(Map<String, dynamic> record) {
  return _value(
    record,
    ['description', 'bio', 'status', 'category', 'location', 'model'],
    fallback: '',
  );
}

String _value(
  Map<String, dynamic> record,
  List<String> keys, {
  String fallback = '',
}) {
  for (final key in keys) {
    final value = record[key];
    if (value != null && value.toString().trim().isNotEmpty) {
      return value.toString();
    }
  }
  return fallback;
}

String _adminLabelFor(String key) {
  const labels = {
    'id': 'المعرف',
    'title': 'العنوان',
    'name': 'الاسم',
    'first_name': 'الاسم الأول',
    'last_name': 'الاسم الأخير',
    'full_name': 'الاسم',
    'email': 'البريد',
    'phone': 'الجوال',
    'username': 'اسم المستخدم',
    'account_type': 'نوع الحساب',
    'active': 'نشط',
    'status': 'الحالة',
    'description': 'الوصف',
    'category': 'القسم',
    'location': 'الموقع',
    'price': 'السعر',
    'user_id': 'المستخدم',
    'consultant_id': 'المستشار',
    'service_id': 'الخدمة',
    'document_url': 'ملف المستندات',
    'created_at': 'تاريخ الإنشاء',
    'updated_at': 'آخر تحديث',
    'reviewed_at': 'تاريخ المراجعة',
    'key': 'المفتاح',
    'value': 'القيمة',
  };
  return labels[key] ?? key;
}

List<MapEntry<String, dynamic>> _adminVisibleEntries(
    Map<String, dynamic> record) {
  const hiddenKeys = {
    'id',
    'user_id',
    'owner_id',
    'consultant_id',
    'service_id',
    'document_url',
  };

  return record.entries
      .where((entry) =>
          !hiddenKeys.contains(entry.key) &&
          entry.value != null &&
          entry.value.toString().trim().isNotEmpty)
      .toList();
}

String _adminDisplayValue(String key, Object? value) {
  final text = value?.toString() ?? '';
  if (key == 'status') return _statusLabel(text);
  if (key == 'account_type') return _accountTypeLabel(text);
  if (text == 'true') return 'نعم';
  if (text == 'false') return 'لا';
  return text;
}

String _accountTypeLabel(String type) {
  switch (type) {
    case 'admin':
      return 'إدارة';
    case 'consultant':
      return 'مستشار';
    case 'user':
      return 'مستخدم';
    default:
      return type;
  }
}

String _statusLabel(String status) {
  switch (status) {
    case 'pending':
      return 'قيد المراجعة';
    case 'approved':
      return 'مقبول';
    case 'refused':
      return 'مرفوض';
    case 'new':
      return 'جديد';
    case 'done':
      return 'مكتمل';
    default:
      return status;
  }
}
