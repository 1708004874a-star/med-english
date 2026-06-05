import '../../domain/entities/knowledge_article.dart' as entity;
import '../../domain/repositories/i_knowledge_repository.dart';
import '../database/app_database.dart';

class KnowledgeRepositoryImpl implements IKnowledgeRepository {
  KnowledgeRepositoryImpl(this._db);

  final AppDatabase _db;

  @override
  Future<List<entity.KnowledgeArticle>> getAllArticles() async {
    final rows = await _db.knowledgeDao.getAllArticles();
    return rows.map(_toEntity).toList();
  }

  @override
  Future<List<entity.KnowledgeArticle>> getArticlesBySystem(int systemId) async {
    final rows = await _db.knowledgeDao.getArticlesBySystem(systemId);
    return rows.map(_toEntity).toList();
  }

  @override
  Future<entity.KnowledgeArticle?> getArticleById(int id) async {
    final row = await _db.knowledgeDao.getArticleById(id);
    return row == null ? null : _toEntity(row);
  }

  entity.KnowledgeArticle _toEntity(KnowledgeArticle row) =>
      entity.KnowledgeArticle(
        id: row.id,
        systemId: row.systemId,
        titleEn: row.titleEn,
        titleZh: row.titleZh,
        contentEn: row.contentEn,
        contentZh: row.contentZh,
        difficulty: row.difficulty,
      );
}
