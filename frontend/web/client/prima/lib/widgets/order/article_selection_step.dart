import 'package:flutter/material.dart';
import 'package:prima/providers/article_provider.dart';
import 'package:provider/provider.dart';

class ArticleSelectionStep extends StatefulWidget {
  final Map<String, int> selectedArticles;
  final Function(Map<String, int>) onArticlesUpdated;

  const ArticleSelectionStep({
    Key? key,
    required this.selectedArticles,
    required this.onArticlesUpdated,
  }) : super(key: key);

  @override
  State<ArticleSelectionStep> createState() => _ArticleSelectionStepState();
}

class _ArticleSelectionStepState extends State<ArticleSelectionStep>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  Widget build(BuildContext context) {
    return Consumer<ArticleProvider>(
      builder: (context, provider, _) {
        // ... implémentation de la sélection d'articles ...
      },
    );
  }
}
