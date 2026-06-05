import 'package:drift/drift.dart';
import '../app_database.dart';
import '../../models/knowledge_article_table.dart';
import '../../models/body_system_table.dart';

part 'knowledge_dao.g.dart';

@DriftAccessor(tables: [KnowledgeArticles, BodySystems])
class KnowledgeDao extends DatabaseAccessor<AppDatabase>
    with _$KnowledgeDaoMixin {
  KnowledgeDao(super.db);

  Future<List<KnowledgeArticle>> getAllArticles() =>
      select(knowledgeArticles).get();

  Future<List<KnowledgeArticle>> getArticlesBySystem(int systemId) =>
      (select(knowledgeArticles)
            ..where((t) => t.systemId.equals(systemId)))
          .get();

  Future<KnowledgeArticle?> getArticleById(int id) =>
      (select(knowledgeArticles)..where((t) => t.id.equals(id)))
          .getSingleOrNull();

  Future<void> batchInsertArticles(
      List<KnowledgeArticlesCompanion> companions) async {
    await batch((b) => b.insertAll(knowledgeArticles, companions));
  }
}
