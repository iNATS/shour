import 'package:flutter/material.dart';
import '../../widgets/category_widget.dart';

class CategoriesTabScreen extends StatelessWidget {
  const CategoriesTabScreen(this.screenTitle, {super.key});

  final String screenTitle;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: 7,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              screenTitle,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),
          );
        }

        return const CategoryWidget();
      },
    );
  }
}
