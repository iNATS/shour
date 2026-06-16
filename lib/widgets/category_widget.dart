import 'package:flutter/material.dart';

import 'app_network_image.dart';

class CategoryWidget extends StatelessWidget {
  const CategoryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card.outlined(
      child: InkWell(
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: const AppNetworkImage(
                  url:
                      'https://images.unsplash.com/photo-1583337130417-3346a1be7dee?auto=format&fit=crop&w=500&q=80',
                  icon: Icons.pets_outlined,
                  width: 96,
                  height: 96,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'طلب استشارة متاح',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'تفاصيل مختصرة وواضحة عن الطلب مع حالة المتابعة.',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      children: [
                        Chip(
                          avatar: const Icon(Icons.schedule_rounded, size: 18),
                          label: const Text('اليوم'),
                          visualDensity: VisualDensity.compact,
                          side: BorderSide.none,
                          backgroundColor: colorScheme.secondaryContainer,
                        ),
                        Chip(
                          avatar:
                              const Icon(Icons.location_on_outlined, size: 18),
                          label: const Text('قريب'),
                          visualDensity: VisualDensity.compact,
                          side: BorderSide.none,
                          backgroundColor: colorScheme.surfaceContainerHighest,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_left_rounded,
                  color: colorScheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}
