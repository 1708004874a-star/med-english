import '../entities/knowledge_article.dart';

abstract interface class IKnowledgeRepository {
  Future<List<KnowledgeArticle>> getAllArticles();
  Future<List<KnowledgeArticle>> getArticlesBySystem(int systemId);
  Future<KnowledgeArticle?> getArticleById(int id);
}
