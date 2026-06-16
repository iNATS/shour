import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth.dart';
import '../services/supabase_service.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/app_network_image.dart';

class AnimalsScreen extends StatelessWidget {
  const AnimalsScreen({this.showBottomNav = false, super.key});

  final bool showBottomNav;

  @override
  Widget build(BuildContext context) {
    return _RecordsScreen(
      title: 'الحيوانات',
      table: 'animals',
      icon: Icons.pets_rounded,
      emptyTitle: 'لا توجد حيوانات متاحة',
      emptyBody: 'ستظهر بيانات الحيوانات من قاعدة Supabase عند إضافتها.',
      detailType: 'animal',
      selectedNavIndex: 3,
      showBottomNav: showBottomNav,
      action: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(
          context,
          '/new-order',
          arguments: const {'category': 'animals'},
        ),
        icon: const Icon(Icons.add_rounded),
        label: const Text('طلب للحيوانات'),
      ),
    );
  }
}

class CarsScreen extends StatelessWidget {
  const CarsScreen({this.showBottomNav = false, super.key});

  final bool showBottomNav;

  @override
  Widget build(BuildContext context) {
    return _RecordsScreen(
      title: 'السيارات',
      table: 'cars',
      icon: Icons.directions_car_rounded,
      emptyTitle: 'لا توجد سيارات متاحة',
      emptyBody: 'ستظهر بيانات السيارات من قاعدة Supabase عند إضافتها.',
      detailType: 'car',
      selectedNavIndex: 2,
      showBottomNav: showBottomNav,
      action: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(
          context,
          '/new-order',
          arguments: const {'category': 'cars'},
        ),
        icon: const Icon(Icons.add_rounded),
        label: const Text('طلب للسيارات'),
      ),
    );
  }
}

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({this.showBottomNav = false, super.key});

  final bool showBottomNav;

  @override
  Widget build(BuildContext context) {
    return _RecordsScreen(
      title: 'الطلبات',
      table: 'orders',
      icon: Icons.receipt_long_rounded,
      emptyTitle: 'لا توجد طلبات',
      emptyBody: 'ستظهر طلبات المستخدمين هنا بعد إنشائها.',
      detailType: 'order',
      selectedNavIndex: 1,
      showBottomNav: showBottomNav,
      action: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(
          context,
          '/new-order',
          arguments: const {'category': 'general'},
        ),
        icon: const Icon(Icons.add_rounded),
        label: const Text('طلب جديد'),
      ),
    );
  }
}

class ConsultantsScreen extends StatelessWidget {
  const ConsultantsScreen({this.showBottomNav = false, super.key});

  final bool showBottomNav;

  @override
  Widget build(BuildContext context) {
    return _RecordsScreen(
      title: 'المستشارون',
      table: 'profiles',
      icon: Icons.support_agent_rounded,
      emptyTitle: 'لا يوجد مستشارون',
      emptyBody: 'ستظهر ملفات المستشارين عند إضافتها من لوحة الإدارة.',
      detailType: 'consultant',
      filterColumn: 'account_type',
      filterValue: 'consultant',
      showBottomNav: showBottomNav,
      selectedNavIndex: 4,
      action: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(
          context,
          '/new-order',
          arguments: const {'category': 'consultants'},
        ),
        icon: const Icon(Icons.add_rounded),
        label: const Text('طلب استشارة'),
      ),
    );
  }
}

class NewOrderScreen extends StatefulWidget {
  const NewOrderScreen({super.key});

  @override
  State<NewOrderScreen> createState() => _NewOrderScreenState();
}

class _NewOrderScreenState extends State<NewOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  String _category = 'cars';
  String? _serviceId;
  String? _consultantId;
  bool _didReadArgs = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_didReadArgs) {
      _readArgs();
      _didReadArgs = true;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('طلب جديد')),
      bottomNavigationBar: const AppBottomNav(selectedIndex: 1),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _PageHeader(
              title: 'طلب جديد',
              subtitle: 'املأ البيانات وسيتم حفظ الطلب في Supabase.',
              icon: Icons.add_task_rounded,
            ),
            const SizedBox(height: 18),
            Card.outlined(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'عنوان الطلب',
                          prefixIcon: Icon(Icons.title_rounded),
                        ),
                        validator: _required,
                      ),
                      const SizedBox(height: 14),
                      DropdownButtonFormField<String>(
                        initialValue: _category,
                        decoration: const InputDecoration(
                          labelText: 'القسم',
                          prefixIcon: Icon(Icons.category_outlined),
                        ),
                        items: const [
                          DropdownMenuItem(
                              value: 'cars', child: Text('السيارات')),
                          DropdownMenuItem(
                              value: 'animals', child: Text('الحيوانات')),
                          DropdownMenuItem(
                              value: 'consultants', child: Text('استشارة')),
                          DropdownMenuItem(
                              value: 'general', child: Text('طلب عام')),
                        ],
                        onChanged: (value) {
                          if (value != null) setState(() => _category = value);
                        },
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _locationController,
                        decoration: const InputDecoration(
                          labelText: 'الموقع',
                          prefixIcon: Icon(Icons.location_on_outlined),
                        ),
                        validator: _required,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 5,
                        decoration: const InputDecoration(
                          labelText: 'التفاصيل',
                          alignLabelWithHint: true,
                          prefixIcon: Icon(Icons.notes_rounded),
                        ),
                        validator: _required,
                      ),
                      const SizedBox(height: 18),
                      FilledButton.icon(
                        onPressed: _isSubmitting ? null : _submit,
                        icon: _isSubmitting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.send_rounded),
                        label: const Text('إرسال الطلب'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    final auth = context.read<Auth>();
    if (!auth.login_status || auth.userId?.isNotEmpty != true) {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى تسجيل الدخول قبل إرسال الطلب')),
      );
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    final saved = await SupabaseService.insert('orders', {
      'title': _titleController.text.trim(),
      'description': _descriptionController.text.trim(),
      'location': _locationController.text.trim(),
      'category': _category,
      'status': 'new',
      'user_id': auth.userId,
      if (_serviceId != null) 'service_id': _serviceId,
      if (_consultantId != null) 'consultant_id': _consultantId,
    });

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(saved
            ? 'تم إرسال الطلب'
            : 'لم يتم حفظ الطلب. تأكد من إعداد Supabase.'),
      ),
    );

    if (saved) Navigator.pop(context);
  }

  void _readArgs() {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is! Map) return;

    final category = args['category']?.toString();
    if (category != null && category.isNotEmpty) _category = category;

    final title = args['title']?.toString();
    if (title != null && title.isNotEmpty) {
      _titleController.text = title;
    }

    final serviceId = args['service_id']?.toString();
    if (serviceId != null && serviceId.isNotEmpty) _serviceId = serviceId;

    final consultantId = args['consultant_id']?.toString();
    if (consultantId != null && consultantId.isNotEmpty) {
      _consultantId = consultantId;
    }
  }
}

class CarsBookingScreen extends StatelessWidget {
  const CarsBookingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const NewOrderScreen();
  }
}

class RecordDetailScreen extends StatelessWidget {
  const RecordDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final record = args is Map<String, dynamic> ? args : <String, dynamic>{};
    final title = _recordTitle(record);

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      bottomNavigationBar: AppBottomNav(selectedIndex: _navIndex(record)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _DetailHero(record: record, title: title),
            const SizedBox(height: 16),
            _DetailHighlights(record: record),
            const SizedBox(height: 16),
            _DetailSection(
              title: 'الوصف',
              icon: Icons.notes_rounded,
              children: [
                _BodyInfoTile(
                  icon: Icons.subject_rounded,
                  value: _recordSubtitle(record).isEmpty
                      ? 'لا يوجد وصف متاح حاليا.'
                      : _recordSubtitle(record),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _SpecsSection(record: record),
            const SizedBox(height: 12),
            _ContactSection(record: record),
            const SizedBox(height: 16),
            _DetailActions(record: record),
          ],
        ),
      ),
    );
  }
}

Future<void> showRecordDetailsSheet(
  BuildContext context,
  Map<String, dynamic> record,
) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (context) => _RecordDetailsSheet(record: record),
  );
}

class _RecordDetailsSheet extends StatelessWidget {
  const _RecordDetailsSheet({required this.record});

  final Map<String, dynamic> record;

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    final title = _recordTitle(record);

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: height * 0.88),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: SizedBox(
              height: 220,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _DetailImage(record: record),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.62),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                  PositionedDirectional(
                    start: 18,
                    end: 18,
                    bottom: 18,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _categoryLabel(record),
                          style:
                              Theme.of(context).textTheme.labelLarge?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                  ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Chip(
                avatar: const Icon(Icons.verified_outlined, size: 18),
                label: Text(_field(record, ['status'], fallback: 'متاح')),
              ),
              Chip(
                avatar: const Icon(Icons.location_on_outlined, size: 18),
                label: Text(_field(record, ['location'], fallback: 'غير محدد')),
              ),
              Chip(
                avatar: const Icon(Icons.payments_outlined, size: 18),
                label: Text(_field(record, ['price'], fallback: 'حسب الطلب')),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _DetailSection(
            title: 'نبذة',
            icon: Icons.notes_rounded,
            children: [
              _BodyInfoTile(
                icon: Icons.subject_rounded,
                value: _recordSubtitle(record).isEmpty
                    ? 'لا يوجد وصف متاح حاليا.'
                    : _recordSubtitle(record),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _SpecsSection(record: record),
          const SizedBox(height: 12),
          _ContactSection(record: record),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(
                      context,
                      '/new-order',
                      arguments: _newOrderArgs(record),
                    );
                  },
                  icon: const Icon(Icons.add_task_rounded),
                  label: Text(_actionLabel(record)),
                ),
              ),
              const SizedBox(width: 10),
              IconButton.filledTonal(
                tooltip: 'إغلاق',
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const UserProfileScreen(showSettings: true);
  }
}

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({
    this.showSettings = false,
    this.showBottomNav = false,
    super.key,
  });

  final bool showSettings;
  final bool showBottomNav;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<Auth>();
    final colorScheme = Theme.of(context).colorScheme;
    final name = _displayName(auth);

    return Scaffold(
      appBar: AppBar(title: const Text('الحساب')),
      bottomNavigationBar:
          showBottomNav ? const AppBottomNav(selectedIndex: 5) : null,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card.outlined(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 42,
                      backgroundColor: colorScheme.primaryContainer,
                      foregroundColor: colorScheme.onPrimaryContainer,
                      child: const Icon(Icons.person_rounded, size: 42),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      auth.phone?.isNotEmpty == true
                          ? auth.phone!
                          : 'لم يتم تسجيل رقم جوال',
                      style: TextStyle(color: colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            _ProfileTile(
              icon: Icons.badge_outlined,
              title: 'الاسم الأول',
              value:
                  auth.first_name?.isNotEmpty == true ? auth.first_name! : '-',
            ),
            _ProfileTile(
              icon: Icons.badge_rounded,
              title: 'الاسم الأخير',
              value: auth.last_name?.isNotEmpty == true ? auth.last_name! : '-',
            ),
            _ProfileTile(
              icon: Icons.verified_user_outlined,
              title: 'نوع الحساب',
              value: auth.type?.isNotEmpty == true ? auth.type! : 'مستخدم',
            ),
            if (showSettings) ...[
              const SizedBox(height: 20),
              const _SettingsPanel(),
            ],
            const SizedBox(height: 20),
            FilledButton.tonalIcon(
              onPressed: () async {
                await context.read<Auth>().logout();
                if (context.mounted) {
                  Navigator.pushReplacementNamed(context, '/login');
                }
              },
              icon: const Icon(Icons.logout_rounded),
              label: const Text('تسجيل الخروج'),
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الإعدادات')),
      bottomNavigationBar: const AppBottomNav(selectedIndex: 5),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: const [_SettingsPanel()],
        ),
      ),
    );
  }
}

class _RecordsScreen extends StatefulWidget {
  const _RecordsScreen({
    required this.title,
    required this.table,
    required this.icon,
    required this.emptyTitle,
    required this.emptyBody,
    required this.detailType,
    this.action,
    this.filterColumn,
    this.filterValue,
    this.selectedNavIndex = 0,
    this.showBottomNav = false,
  });

  final String title;
  final String table;
  final IconData icon;
  final String emptyTitle;
  final String emptyBody;
  final String detailType;
  final Widget? action;
  final String? filterColumn;
  final Object? filterValue;
  final int selectedNavIndex;
  final bool showBottomNav;

  @override
  State<_RecordsScreen> createState() => _RecordsScreenState();
}

class _RecordsScreenState extends State<_RecordsScreen>
    with AutomaticKeepAliveClientMixin {
  late Future<List<Map<String, dynamic>>> _future = _load();

  @override
  bool get wantKeepAlive => true;

  Future<List<Map<String, dynamic>>> _load() {
    return SupabaseService.listWhere(
      widget.table,
      column: widget.filterColumn,
      value: widget.filterValue,
    ).then((records) {
      if (widget.detailType != 'consultant') return records;
      return records.where((record) => record['active'] != false).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      floatingActionButton: widget.action,
      bottomNavigationBar: widget.showBottomNav
          ? AppBottomNav(selectedIndex: widget.selectedNavIndex)
          : null,
      body: SafeArea(
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _future,
          builder: (context, snapshot) {
            return RefreshIndicator(
              onRefresh: () async {
                setState(() => _future = _load());
                await _future;
              },
              child: _FilteredRecordsList(
                title: widget.title,
                icon: widget.icon,
                emptyTitle: widget.emptyTitle,
                emptyBody: widget.emptyBody,
                detailType: widget.detailType,
                records: snapshot.data ?? [],
                loading: snapshot.connectionState == ConnectionState.waiting,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _FilteredRecordsList extends StatefulWidget {
  const _FilteredRecordsList({
    required this.title,
    required this.icon,
    required this.emptyTitle,
    required this.emptyBody,
    required this.detailType,
    required this.records,
    required this.loading,
  });

  final String title;
  final IconData icon;
  final String emptyTitle;
  final String emptyBody;
  final String detailType;
  final List<Map<String, dynamic>> records;
  final bool loading;

  @override
  State<_FilteredRecordsList> createState() => _FilteredRecordsListState();
}

class _FilteredRecordsListState extends State<_FilteredRecordsList> {
  final _searchController = TextEditingController();
  String _status = 'all';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final statuses = {
      'all',
      ...widget.records.map((record) => _field(record, ['status'])),
    }.where((status) => status.isNotEmpty).toList();
    final query = _searchController.text.trim().toLowerCase();
    final records = widget.records.where((record) {
      final matchesQuery = query.isEmpty ||
          _recordTitle(record).toLowerCase().contains(query) ||
          _recordSubtitle(record).toLowerCase().contains(query);
      final matchesStatus =
          _status == 'all' || _field(record, ['status']) == _status;
      return matchesQuery && matchesStatus;
    }).toList();

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          sliver: SliverToBoxAdapter(
            child: _PageHeader(
                title: widget.title, subtitle: '', icon: widget.icon),
          ),
        ),
        SliverPersistentHeader(
          pinned: true,
          delegate: _FilterHeaderDelegate(
            child: _FilterBar(
              controller: _searchController,
              statuses: statuses,
              selectedStatus: _status,
              onChanged: () => setState(() {}),
              onStatusChanged: (value) => setState(() => _status = value),
            ),
          ),
        ),
        if (widget.loading)
          const SliverFillRemaining(
            hasScrollBody: false,
            child: Center(child: CircularProgressIndicator()),
          )
        else if (!SupabaseService.isConfigured)
          const SliverFillRemaining(
            hasScrollBody: false,
            child: _EmptyState(
              icon: Icons.cloud_off_rounded,
              title: 'Supabase غير مهيأ',
              body: 'مرر SUPABASE_URL و SUPABASE_ANON_KEY عند تشغيل التطبيق.',
            ),
          )
        else if (records.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: _EmptyState(
              icon: widget.icon,
              title: widget.emptyTitle,
              body: widget.emptyBody,
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
            sliver: SliverList.separated(
              itemCount: records.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) => _RecordListItem(
                record: {...records[index], '_type': widget.detailType},
              ),
            ),
          ),
      ],
    );
  }
}

class _RecordListItem extends StatelessWidget {
  const _RecordListItem({required this.record});

  final Map<String, dynamic> record;

  @override
  Widget build(BuildContext context) {
    final imageUrl = _field(record, ['image_url', 'photo_url', 'avatar_url']);
    final isConsultant = record['_type'] == 'consultant';

    return Material(
      color: Theme.of(context).colorScheme.surface,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        onTap: () => showRecordDetailsSheet(context, record),
        leading: _ListLeadingImage(record: record, imageUrl: imageUrl),
        title: Text(
          _recordTitle(record),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: isConsultant
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _recordSubtitle(record),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    _ConsultantRatingLine(record: record),
                  ],
                )
              : Text(
                  _recordSubtitle(record),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
        ),
        trailing: const Icon(Icons.chevron_left_rounded),
      ),
    );
  }
}

class _ConsultantRatingLine extends StatelessWidget {
  const _ConsultantRatingLine({required this.record});

  final Map<String, dynamic> record;

  @override
  Widget build(BuildContext context) {
    final rating = _ratingText(record);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.star_rounded,
            size: 16,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 4),
          Text(
            rating,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
        ],
      ),
    );
  }
}

class _ListLeadingImage extends StatelessWidget {
  const _ListLeadingImage({required this.record, required this.imageUrl});

  final Map<String, dynamic> record;
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: imageUrl.isEmpty
          ? Container(
              width: 64,
              height: 64,
              color: colorScheme.primaryContainer,
              child: Icon(
                _recordIcon(record),
                color: colorScheme.onPrimaryContainer,
              ),
            )
          : AppNetworkImage(
              url: imageUrl,
              icon: _recordIcon(record),
              width: 64,
              height: 64,
            ),
    );
  }
}

class _DetailHero extends StatelessWidget {
  const _DetailHero({required this.record, required this.title});

  final Map<String, dynamic> record;
  final String title;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card.outlined(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _DetailImage(record: record),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: colorScheme.primaryContainer,
                  foregroundColor: colorScheme.onPrimaryContainer,
                  child: Icon(_recordIcon(record)),
                ),
                const SizedBox(height: 14),
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  _categoryLabel(record),
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailHighlights extends StatelessWidget {
  const _DetailHighlights({required this.record});

  final Map<String, dynamic> record;

  @override
  Widget build(BuildContext context) {
    final isConsultant = record['_type'] == 'consultant';
    final highlights = isConsultant
        ? [
            _HighlightData(
              icon: Icons.star_rounded,
              label: 'التقييم',
              value: _ratingText(record),
            ),
            _HighlightData(
              icon: Icons.workspace_premium_outlined,
              label: 'التخصص',
              value: _field(record, ['specialty'], fallback: 'استشارات عامة'),
            ),
            _HighlightData(
              icon: Icons.history_edu_outlined,
              label: 'الخبرة',
              value: _field(
                record,
                ['experience_years', 'experience'],
                fallback: 'غير محدد',
              ),
            ),
          ]
        : [
            _HighlightData(
              icon: Icons.verified_outlined,
              label: 'الحالة',
              value: _field(record, ['status'], fallback: 'متاح'),
            ),
            _HighlightData(
              icon: Icons.location_on_outlined,
              label: 'الموقع',
              value: _field(record, ['location'], fallback: 'غير محدد'),
            ),
            _HighlightData(
              icon: Icons.payments_outlined,
              label: 'السعر',
              value: _field(record, ['price'], fallback: 'حسب الطلب'),
            ),
          ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 560 ? 3 : 1;
        return GridView.count(
          crossAxisCount: columns,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: columns == 3 ? 2.4 : 4.4,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          children: [
            for (final item in highlights) _HighlightCard(data: item),
          ],
        );
      },
    );
  }
}

class _HighlightCard extends StatelessWidget {
  const _HighlightCard({required this.data});

  final _HighlightData data;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card.outlined(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Icon(data.icon, color: colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    data.label,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                  ),
                  Text(
                    data.value,
                    textDirection: TextDirection.rtl,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailSection extends StatelessWidget {
  const _DetailSection({
    required this.title,
    required this.icon,
    required this.children,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.only(start: 4, bottom: 10),
          child: Row(
            children: [
              Icon(icon, color: colorScheme.primary),
              const SizedBox(width: 10),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
            ],
          ),
        ),
        Material(
          color: colorScheme.surfaceContainerLow,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: colorScheme.outlineVariant),
          ),
          child: Column(
            children: [
              for (int index = 0; index < children.length; index++) ...[
                children[index],
                if (index < children.length - 1)
                  Divider(
                    height: 1,
                    indent: 72,
                    color: colorScheme.outlineVariant,
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _SpecsSection extends StatelessWidget {
  const _SpecsSection({required this.record});

  final Map<String, dynamic> record;

  @override
  Widget build(BuildContext context) {
    final specs = _specEntries(record);

    return _DetailSection(
      title: 'المعلومات',
      icon: Icons.tune_rounded,
      children: [
        if (specs.isEmpty)
          const _EmptyInfoTile(
            icon: Icons.info_outline_rounded,
            message: 'لا توجد معلومات إضافية.',
          )
        else
          for (final entry in specs)
            _InfoTile(
              icon: _iconForSpec(entry.key),
              label: _labelFor(entry.key),
              value: entry.value.toString(),
            ),
      ],
    );
  }
}

class _ContactSection extends StatelessWidget {
  const _ContactSection({required this.record});

  final Map<String, dynamic> record;

  @override
  Widget build(BuildContext context) {
    final phone = _field(record, ['phone']);
    final email = _field(record, ['email']);

    return _DetailSection(
      title: 'التواصل والمتابعة',
      icon: Icons.contact_support_outlined,
      children: [
        if (phone.isEmpty && email.isEmpty)
          const _EmptyInfoTile(
            icon: Icons.contact_support_outlined,
            message: 'لا توجد بيانات تواصل متاحة.',
          )
        else ...[
          if (phone.isNotEmpty)
            _InfoTile(
              icon: Icons.phone_outlined,
              label: 'الجوال',
              value: phone,
            ),
          if (email.isNotEmpty)
            _InfoTile(
              icon: Icons.mail_outline_rounded,
              label: 'البريد',
              value: email,
            ),
        ],
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      minVerticalPadding: 12,
      contentPadding: const EdgeInsetsDirectional.fromSTEB(16, 4, 16, 4),
      leading: CircleAvatar(
        radius: 20,
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
        child: Icon(icon, size: 20),
      ),
      title: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 3),
        child: Text(
          value,
          textDirection: TextDirection.rtl,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w800,
                height: 1.35,
              ),
        ),
      ),
    );
  }
}

class _BodyInfoTile extends StatelessWidget {
  const _BodyInfoTile({required this.icon, required this.value});

  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      minVerticalPadding: 14,
      contentPadding: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 8),
      leading: CircleAvatar(
        radius: 20,
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
        child: Icon(icon, size: 20),
      ),
      title: Text(
        value,
        textDirection: TextDirection.rtl,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.55,
            ),
      ),
    );
  }
}

class _EmptyInfoTile extends StatelessWidget {
  const _EmptyInfoTile({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      minVerticalPadding: 14,
      contentPadding: const EdgeInsetsDirectional.fromSTEB(16, 6, 16, 6),
      leading: CircleAvatar(
        radius: 20,
        backgroundColor: colorScheme.surfaceContainerHighest,
        foregroundColor: colorScheme.onSurfaceVariant,
        child: Icon(icon, size: 20),
      ),
      title: Text(
        message,
        style: TextStyle(color: colorScheme.onSurfaceVariant),
      ),
    );
  }
}

IconData _iconForSpec(String key) {
  switch (key) {
    case 'status':
      return Icons.verified_outlined;
    case 'location':
      return Icons.location_on_outlined;
    case 'price':
      return Icons.payments_outlined;
    case 'category':
      return Icons.category_outlined;
    case 'animal_type':
    case 'breed':
    case 'age':
    case 'gender':
      return Icons.pets_outlined;
    case 'make':
    case 'model':
    case 'year':
    case 'mileage':
      return Icons.directions_car_outlined;
    case 'specialty':
      return Icons.workspace_premium_outlined;
    case 'rating':
      return Icons.star_outline_rounded;
    case 'experience_years':
      return Icons.history_edu_outlined;
    default:
      return Icons.info_outline_rounded;
  }
}

class _DetailActions extends StatelessWidget {
  const _DetailActions({required this.record});

  final Map<String, dynamic> record;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: FilledButton.icon(
            onPressed: () => Navigator.pushNamed(
              context,
              '/new-order',
              arguments: _newOrderArgs(record),
            ),
            icon: const Icon(Icons.add_task_rounded),
            label: Text(_actionLabel(record)),
          ),
        ),
        const SizedBox(width: 10),
        IconButton.filledTonal(
          tooltip: 'رجوع',
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ],
    );
  }
}

class _HighlightData {
  const _HighlightData({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({
    required this.controller,
    required this.statuses,
    required this.selectedStatus,
    required this.onChanged,
    required this.onStatusChanged,
  });

  final TextEditingController controller;
  final List<String> statuses;
  final String selectedStatus;
  final VoidCallback onChanged;
  final ValueChanged<String> onStatusChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ColoredBox(
      color: colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
        child: Column(
          children: [
            TextField(
              controller: controller,
              onChanged: (_) => onChanged(),
              decoration: const InputDecoration(
                labelText: 'بحث',
                prefixIcon: Icon(Icons.search_rounded),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 42,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: statuses.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final status = statuses[index];
                  return ChoiceChip(
                    label: Text(status == 'all' ? 'الكل' : status),
                    selected: selectedStatus == status,
                    onSelected: (_) => onStatusChanged(status),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterHeaderDelegate extends SliverPersistentHeaderDelegate {
  const _FilterHeaderDelegate({required this.child});

  final Widget child;

  @override
  double get minExtent => 134;

  @override
  double get maxExtent => 134;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  bool shouldRebuild(covariant _FilterHeaderDelegate oldDelegate) {
    return child != oldDelegate.child;
  }
}

class _DetailImage extends StatelessWidget {
  const _DetailImage({required this.record});

  final Map<String, dynamic> record;

  @override
  Widget build(BuildContext context) {
    final imageUrl = _field(record, ['image_url', 'photo_url', 'avatar_url']);
    final icon = _recordIcon(record);

    if (imageUrl.isEmpty) {
      return Container(
        height: 220,
        color: Theme.of(context).colorScheme.primaryContainer,
        child: Icon(icon, size: 56),
      );
    }

    return AppNetworkImage(
      url: imageUrl,
      icon: icon,
      height: 240,
      width: double.infinity,
    );
  }
}

class _PageHeader extends StatelessWidget {
  const _PageHeader({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        CircleAvatar(
          radius: 26,
          backgroundColor: colorScheme.primaryContainer,
          foregroundColor: colorScheme.onPrimaryContainer,
          child: Icon(icon),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
              if (subtitle.isNotEmpty)
                Text(
                  subtitle,
                  style: TextStyle(color: colorScheme.onSurfaceVariant),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card.outlined(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(value),
      ),
    );
  }
}

class _SettingsPanel extends StatefulWidget {
  const _SettingsPanel();

  @override
  State<_SettingsPanel> createState() => _SettingsPanelState();
}

class _SettingsPanelState extends State<_SettingsPanel> {
  bool _notifications = true;
  bool _location = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الإعدادات',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
              ),
        ),
        const SizedBox(height: 12),
        Card.outlined(
          child: SwitchListTile(
            secondary: const Icon(Icons.notifications_active_outlined),
            title: const Text('الإشعارات'),
            subtitle: const Text('استقبال تنبيهات الطلبات من Google FCM.'),
            value: _notifications,
            onChanged: (value) => setState(() => _notifications = value),
          ),
        ),
        Card.outlined(
          child: SwitchListTile(
            secondary: const Icon(Icons.location_on_outlined),
            title: const Text('خدمات الموقع'),
            subtitle: const Text('استخدام الموقع لتحسين الطلبات والخدمات.'),
            value: _location,
            onChanged: (value) => setState(() => _location = value),
          ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Icon(icon, size: 52, color: colorScheme.onSurfaceVariant),
          const SizedBox(height: 12),
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            body,
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.center,
            style: TextStyle(color: colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

String? _required(String? value) {
  if (value == null || value.trim().isEmpty) return 'هذا الحقل مطلوب';
  return null;
}

String _displayName(Auth auth) {
  final first = auth.first_name?.trim() ?? '';
  final last = auth.last_name?.trim() ?? '';
  final name = '$first $last'.trim();
  return name.isEmpty ? 'المستخدم' : name;
}

String _recordTitle(Map<String, dynamic> record) {
  return (record['title'] ??
          record['name'] ??
          record['request_title'] ??
          record['car_name'] ??
          record['animal_name'] ??
          'تفاصيل')
      .toString();
}

String _recordSubtitle(Map<String, dynamic> record) {
  return (record['description'] ??
          record['request_description'] ??
          record['status'] ??
          record['category'] ??
          '')
      .toString();
}

String _field(
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

List<MapEntry<String, Object>> _specEntries(Map<String, dynamic> record) {
  const hidden = {
    '_type',
    'id',
    'title',
    'name',
    'first_name',
    'last_name',
    'description',
    'bio',
    'image_url',
    'photo_url',
    'avatar_url',
    'phone',
    'email',
    'created_at',
    'updated_at',
    'owner_id',
    'user_id',
    'consultant_id',
    'service_id',
    'document_url',
    'rating',
    'rate',
    'average_rating',
  };

  return record.entries
      .where((entry) =>
          !hidden.contains(entry.key) &&
          entry.value != null &&
          entry.value.toString().trim().isNotEmpty)
      .map((entry) => MapEntry(entry.key, entry.value as Object))
      .toList();
}

String _categoryLabel(Map<String, dynamic> record) {
  switch (record['_type']) {
    case 'animal':
      return 'خدمة حيوانات';
    case 'car':
      return 'خدمة سيارات';
    case 'order':
      return 'طلب';
    case 'consultant':
      return 'مستشار';
    default:
      return 'تفاصيل';
  }
}

String _actionLabel(Map<String, dynamic> record) {
  switch (record['_type']) {
    case 'animal':
      return 'طلب خدمة للحيوان';
    case 'car':
      return 'طلب خدمة للسيارة';
    case 'consultant':
      return 'طلب استشارة';
    default:
      return 'إنشاء طلب';
  }
}

Map<String, String> _newOrderArgs(Map<String, dynamic> record) {
  final type = record['_type']?.toString() ?? '';
  final id = record['id']?.toString() ?? '';
  final args = <String, String>{
    'title': _actionLabel(record),
  };

  switch (type) {
    case 'animal':
      args['category'] = 'animals';
      if (id.isNotEmpty) args['service_id'] = id;
      break;
    case 'car':
      args['category'] = 'cars';
      if (id.isNotEmpty) args['service_id'] = id;
      break;
    case 'consultant':
      args['category'] = 'consultants';
      if (id.isNotEmpty) args['consultant_id'] = id;
      break;
    default:
      args['category'] = 'general';
  }

  return args;
}

String _labelFor(String key) {
  const labels = {
    'title': 'العنوان',
    'name': 'الاسم',
    'first_name': 'الاسم الأول',
    'last_name': 'الاسم الأخير',
    'description': 'الوصف',
    'bio': 'نبذة',
    'specialty': 'التخصص',
    'status': 'الحالة',
    'location': 'الموقع',
    'price': 'السعر',
    'category': 'القسم',
    'animal_type': 'نوع الحيوان',
    'breed': 'السلالة',
    'age': 'العمر',
    'gender': 'الجنس',
    'make': 'الشركة',
    'model': 'الموديل',
    'year': 'السنة',
    'mileage': 'الممشى',
    'email': 'البريد الإلكتروني',
    'phone': 'رقم الجوال',
    'created_at': 'تاريخ الإنشاء',
    'updated_at': 'آخر تحديث',
    'rating': 'التقييم',
    'experience': 'الخبرة',
    'experience_years': 'سنوات الخبرة',
  };
  return labels[key] ?? key;
}

String _ratingText(Map<String, dynamic> record) {
  final rating = _field(record, ['rating', 'rate', 'average_rating']);
  if (rating.isEmpty) return 'لا يوجد تقييم';
  return '$rating من 5';
}

int _navIndex(Map<String, dynamic> record) {
  switch (record['_type']) {
    case 'order':
      return 1;
    case 'car':
      return 2;
    case 'animal':
      return 3;
    case 'consultant':
      return 4;
    default:
      return 0;
  }
}

IconData _recordIcon(Map<String, dynamic> record) {
  switch (record['_type']) {
    case 'animal':
      return Icons.pets_rounded;
    case 'car':
      return Icons.directions_car_rounded;
    case 'order':
      return Icons.receipt_long_rounded;
    case 'consultant':
      return Icons.support_agent_rounded;
    default:
      return Icons.article_outlined;
  }
}
