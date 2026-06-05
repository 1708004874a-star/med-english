import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/providers.dart';
import '../../../../domain/entities/body_system.dart';
import '../../../../domain/entities/knowledge_article.dart';

final knowledgeSystemsProvider = FutureProvider<List<BodySystem>>((ref) {
  return ref.watch(vocabularyRepositoryProvider).getAllSystems();
});

final articlesBySystemProvider =
    FutureProvider.family<List<KnowledgeArticle>, int>((ref, systemId) {
  return ref.watch(knowledgeRepositoryProvider).getArticlesBySystem(systemId);
});

final articleDetailProvider =
    FutureProvider.family<KnowledgeArticle?, int>((ref, articleId) {
  return ref.watch(knowledgeRepositoryProvider).getArticleById(articleId);
});
