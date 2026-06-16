import 'package:flutter/material.dart';

import '../app_sections.dart';
import '../../services/supabase_service.dart';
import '../../widgets/app_network_image.dart';

class HomeTabScreen extends StatefulWidget {
  const HomeTabScreen({super.key});

  @override
  State<HomeTabScreen> createState() => _HomeTabScreenState();
}

class _HomeTabScreenState extends State<HomeTabScreen>
    with AutomaticKeepAliveClientMixin {
  late final Future<_HomeData> _future = _HomeData.load();

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return FutureBuilder<_HomeData>(
      future: _future,
      builder: (context, snapshot) {
        final data = snapshot.data ?? const _HomeData();

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            _AdsCarousel(records: data.ads),
            const SizedBox(height: 20),
            _CategoriesStrip(records: data.categories),
            const SizedBox(height: 24),
            _HorizontalSection(
              title: 'الحيوانات',
              actionLabel: 'عرض الكل',
              records: data.animals,
              icon: Icons.pets_rounded,
              type: 'animal',
              emptyText: 'لا توجد حيوانات حاليا',
              onShowAll: () => Navigator.pushNamed(context, '/animals'),
            ),
            const SizedBox(height: 24),
            _HorizontalSection(
              title: 'السيارات',
              actionLabel: 'عرض كل السيارات',
              records: data.cars,
              icon: Icons.directions_car_rounded,
              type: 'car',
              emptyText: 'لا توجد سيارات حاليا',
              onShowAll: () => Navigator.pushNamed(context, '/cars'),
            ),
            const SizedBox(height: 24),
            _ConsultantsSection(records: data.consultants),
            if (snapshot.connectionState == ConnectionState.waiting)
              const Padding(
                padding: EdgeInsets.only(top: 24),
                child: Center(child: CircularProgressIndicator()),
              ),
          ],
        );
      },
    );
  }
}

class _AdsCarousel extends StatefulWidget {
  const _AdsCarousel({required this.records});

  final List<Map<String, dynamic>> records;

  @override
  State<_AdsCarousel> createState() => _AdsCarouselState();
}

class _AdsCarouselState extends State<_AdsCarousel> {
  late final CarouselController _controller;

  @override
  void initState() {
    super.initState();
    _controller = CarouselController(initialItem: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ads =
        widget.records.isEmpty ? const [<String, dynamic>{}] : widget.records;

    return LayoutBuilder(
      builder: (context, constraints) {
        return ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 280),
          child: CarouselView(
            controller: _controller,
            itemExtent: constraints.maxWidth,
            shrinkExtent: constraints.maxWidth,
            itemSnapping: true,
            children: ads.map((ad) => _AdHeroCard(record: ad)).toList(),
          ),
        );
      },
    );
  }
}

class _AdHeroCard extends StatelessWidget {
  const _AdHeroCard({required this.record});

  final Map<String, dynamic> record;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final imageUrl = _field(record, ['image_url', 'photo_url']);

    return Stack(
      fit: StackFit.expand,
      children: [
        if (imageUrl.isNotEmpty)
          AppNetworkImage(
            url: imageUrl,
            icon: Icons.campaign_outlined,
            width: double.infinity,
            height: double.infinity,
          )
        else
          ColoredBox(
            color: colorScheme.primaryContainer,
            child: Icon(
              Icons.campaign_outlined,
              color: colorScheme.onPrimaryContainer,
              size: 44,
            ),
          ),
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
                _title(record, fallback: 'شور'),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                _subtitle(record, fallback: 'إعلانات الصفحة الرئيسية'),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CategoriesStrip extends StatelessWidget {
  const _CategoriesStrip({required this.records});

  final List<Map<String, dynamic>> records;

  @override
  Widget build(BuildContext context) {
    final fallback = [
      {
        'title': 'السيارات',
        'icon': Icons.directions_car_rounded,
        'route': '/cars'
      },
      {'title': 'الحيوانات', 'icon': Icons.pets_rounded, 'route': '/animals'},
      {
        'title': 'الطلبات',
        'icon': Icons.receipt_long_rounded,
        'route': '/orders'
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الأقسام',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
              ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 104,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: records.isEmpty ? fallback.length : records.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final item = records.isEmpty ? fallback[index] : records[index];
              final title = _title(item);
              final route = _routeForCategory(title);
              final icon = item['icon'] is IconData
                  ? item['icon'] as IconData
                  : _iconForCategory(title);

              return SizedBox(
                width: 132,
                child: Card.outlined(
                  child: InkWell(
                    onTap: () => Navigator.pushNamed(context, route),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(icon,
                              color: Theme.of(context).colorScheme.primary),
                          const Spacer(),
                          Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w900),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _HorizontalSection extends StatelessWidget {
  const _HorizontalSection({
    required this.title,
    required this.actionLabel,
    required this.records,
    required this.icon,
    required this.type,
    required this.emptyText,
    required this.onShowAll,
  });

  final String title;
  final String actionLabel;
  final List<Map<String, dynamic>> records;
  final IconData icon;
  final String type;
  final String emptyText;
  final VoidCallback onShowAll;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
            title: title, actionLabel: actionLabel, onTap: onShowAll),
        const SizedBox(height: 12),
        if (records.isEmpty)
          _InlineEmpty(icon: icon, text: emptyText)
        else
          SizedBox(
            height: 258,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: records.length > 6 ? 6 : records.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final record = {...records[index], '_type': type};
                return _FeatureCard(record: record, icon: icon);
              },
            ),
          ),
      ],
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({required this.record, required this.icon});

  final Map<String, dynamic> record;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final imageUrl = _field(record, ['image_url', 'photo_url']);

    return SizedBox(
      width: 244,
      child: Card.outlined(
        child: InkWell(
          onTap: () => showRecordDetailsSheet(context, record),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
                child: imageUrl.isEmpty
                    ? _ImageFallback(icon: icon)
                    : AppNetworkImage(
                        url: imageUrl,
                        icon: icon,
                        height: 126,
                      ),
              ),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _title(record),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _subtitle(record),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: FilledButton.tonal(
                        onPressed: () =>
                            showRecordDetailsSheet(context, record),
                        child: const Text('المزيد'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConsultantsSection extends StatelessWidget {
  const _ConsultantsSection({required this.records});

  final List<Map<String, dynamic>> records;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: 'المستشارون',
          actionLabel: 'عرض الكل',
          onTap: () => Navigator.pushNamed(context, '/consultants'),
        ),
        const SizedBox(height: 12),
        if (records.isEmpty)
          const _InlineEmpty(
            icon: Icons.support_agent_rounded,
            text: 'لا يوجد مستشارون حاليا',
          )
        else
          SizedBox(
            height: 192,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: records.length > 6 ? 6 : records.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final record = {...records[index], '_type': 'consultant'};
                final imageUrl = _field(record, ['avatar_url', 'image_url']);

                return SizedBox(
                  width: 260,
                  child: Card.outlined(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 28,
                                backgroundImage: imageUrl.isEmpty
                                    ? null
                                    : NetworkImage(imageUrl),
                                child: imageUrl.isEmpty
                                    ? const Icon(Icons.person_rounded)
                                    : null,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _title(record, fallback: 'مستشار'),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w900,
                                          ),
                                    ),
                                    const SizedBox(height: 4),
                                    _RatingPill(record: record),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _subtitle(record, fallback: 'معلومات المستشار'),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const Spacer(),
                          FilledButton.tonal(
                            onPressed: () =>
                                showRecordDetailsSheet(context, record),
                            child: const Text('عرض المعلومات'),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

class _RatingPill extends StatelessWidget {
  const _RatingPill({required this.record});

  final Map<String, dynamic> record;

  @override
  Widget build(BuildContext context) {
    final rating = _field(record, ['rating', 'rate', 'average_rating']);
    final text = rating.isEmpty ? 'بدون تقييم' : '$rating من 5';
    final scheme = Theme.of(context).colorScheme;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star_rounded, size: 16, color: scheme.primary),
          const SizedBox(width: 3),
          Text(
            text,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                  fontWeight: FontWeight.w800,
                ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.actionLabel,
    required this.onTap,
  });

  final String title;
  final String actionLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
          ),
        ),
        TextButton(onPressed: onTap, child: Text(actionLabel)),
      ],
    );
  }
}

class _InlineEmpty extends StatelessWidget {
  const _InlineEmpty({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card.outlined(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Icon(icon, color: colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(child: Text(text)),
          ],
        ),
      ),
    );
  }
}

class _ImageFallback extends StatelessWidget {
  const _ImageFallback({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 126,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Icon(icon, size: 38),
    );
  }
}

class _HomeData {
  const _HomeData({
    this.ads = const [],
    this.categories = const [],
    this.animals = const [],
    this.cars = const [],
    this.consultants = const [],
  });

  final List<Map<String, dynamic>> ads;
  final List<Map<String, dynamic>> categories;
  final List<Map<String, dynamic>> animals;
  final List<Map<String, dynamic>> cars;
  final List<Map<String, dynamic>> consultants;

  static Future<_HomeData> load() async {
    final results = await Future.wait([
      SupabaseService.list('home_ads'),
      SupabaseService.list('categories'),
      SupabaseService.list('animals'),
      SupabaseService.list('cars'),
      SupabaseService.listWhere('profiles',
          column: 'account_type', value: 'consultant'),
    ]);

    return _HomeData(
      ads: results[0],
      categories: results[1],
      animals: results[2],
      cars: results[3],
      consultants:
          results[4].where((record) => record['active'] != false).toList(),
    );
  }
}

String _title(Map<String, dynamic> record, {String fallback = 'بدون عنوان'}) {
  return _field(
      record,
      [
        'title',
        'name',
        'first_name',
        'car_name',
        'animal_name',
      ],
      fallback: fallback);
}

String _subtitle(Map<String, dynamic> record, {String fallback = ''}) {
  return _field(
      record,
      [
        'description',
        'bio',
        'specialty',
        'status',
        'location',
      ],
      fallback: fallback);
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

String _routeForCategory(String title) {
  final lowered = title.toLowerCase();
  if (lowered.contains('car') || title.contains('سيار')) return '/cars';
  if (lowered.contains('animal') || title.contains('حيوان')) return '/animals';
  if (title.contains('طلب')) return '/orders';
  return '/orders';
}

IconData _iconForCategory(String title) {
  final route = _routeForCategory(title);
  if (route == '/cars') return Icons.directions_car_rounded;
  if (route == '/animals') return Icons.pets_rounded;
  return Icons.receipt_long_rounded;
}
