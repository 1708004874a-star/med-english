import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/providers.dart';
import '../../../../data/settings_providers.dart';
import '../../../../domain/entities/body_system.dart';
import '../../../../domain/entities/knowledge_article.dart';

final knowledgeSystemsProvider = FutureProvider<List<BodySystem>>((ref) async {
  final domain = ref.watch(domainProvider);
  return ref.watch(vocabularyRepositoryProvider).getSystemsByDomain(domain.name);
});

final articlesBySystemProvider =
    FutureProvider.family<List<KnowledgeArticle>, int>((ref, systemId) {
  return ref.watch(knowledgeRepositoryProvider).getArticlesBySystem(systemId);
});

final articleDetailProvider =
    FutureProvider.family<KnowledgeArticle?, int>((ref, articleId) {
  return ref.watch(knowledgeRepositoryProvider).getArticleById(articleId);
});
