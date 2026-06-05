// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => '医英通';

  @override
  String get appTagline => '掌握医学英语';

  @override
  String get disclaimerTitle => '仅供教育用途';

  @override
  String get disclaimerBody =>
      '本应用仅用于教育和语言学习目的，不提供任何医学诊断、治疗建议或专业医疗意见。如有健康问题，请咨询执业医疗专业人员。';

  @override
  String get disclaimerAccept => '我已了解';

  @override
  String get languageSettingTitle => '语言';

  @override
  String get languageFollowSystem => '跟随系统';

  @override
  String get tabVocabulary => '词汇';

  @override
  String get tabKnowledge => '知识库';

  @override
  String get tabQuiz => '自测';

  @override
  String get tabNotebook => '生词本';

  @override
  String get moduleWordRootsTitle => '词根词缀';

  @override
  String get moduleWordRootsSubtitle => '前缀、后缀与词根';

  @override
  String get moduleVocabTitle => '医学词汇';

  @override
  String moduleVocabSubtitle(int count, int systems) {
    return '$systems大系统共$count个词汇';
  }

  @override
  String get moduleKnowledgeTitle => '知识库';

  @override
  String get moduleKnowledgeSubtitle => '解剖学与生理学';

  @override
  String get moduleQuizTitle => '自我测试';

  @override
  String get moduleQuizSubtitle => '测验你的掌握程度';

  @override
  String get vocabListTitle => '医学词汇';

  @override
  String get morphemeListTitle => '词根词缀';

  @override
  String get morphemeDetailTitle => '词根详情';

  @override
  String get allSystems => '全部系统';

  @override
  String get difficultyLabel => '难度';

  @override
  String get etymologyLabel => '词源';

  @override
  String get exampleLabel => '例句';

  @override
  String get morphemesLabel => '单词组成';

  @override
  String get wordsWithThisRoot => '含此词根的单词';

  @override
  String get speakWord => '发音';

  @override
  String get knowledgeTitle => '知识库';

  @override
  String get systemsTitle => '人体系统';

  @override
  String articleReadTime(int minutes) {
    return '约$minutes分钟';
  }

  @override
  String get flashcardTitle => '闪卡学习';

  @override
  String get startSession => '开始学习';

  @override
  String get tapToFlip => '点击翻转';

  @override
  String get iKnowThis => '我会了';

  @override
  String get needsReview => '需复习';

  @override
  String get sessionComplete => '本轮完成！';

  @override
  String scoreLabel(int correct, int total) {
    return '$total题中答对$correct题';
  }

  @override
  String get studyAgain => '再练一次';

  @override
  String get backToVocab => '返回词汇表';

  @override
  String get quizTitle => '自我测试';

  @override
  String get startQuiz => '开始测试';

  @override
  String questionOf(int current, int total) {
    return '第$current题，共$total题';
  }

  @override
  String get correct => '回答正确！';

  @override
  String get incorrect => '回答错误';

  @override
  String get nextQuestion => '下一题';

  @override
  String get seeResults => '查看结果';

  @override
  String get quizResult => '测试结果';

  @override
  String get yourScore => '你的得分';

  @override
  String get reviewMistakes => '复习错题';

  @override
  String get retakeQuiz => '重新测试';

  @override
  String get notebookTitle => '我的生词本';

  @override
  String get notebookEmpty => '还没有收藏的单词';

  @override
  String get notebookEmptyHint => '在任意词汇卡片上点击书签图标即可收藏到这里';

  @override
  String get addNote => '添加笔记...';

  @override
  String get masteryLevel => '掌握程度';

  @override
  String savedOn(String date) {
    return '收藏于$date';
  }

  @override
  String get removeFromNotebook => '移除';

  @override
  String get aboutTitle => '关于';

  @override
  String aboutAppVersion(String version) {
    return '版本 $version';
  }

  @override
  String get dataSourcesTitle => '数据来源';

  @override
  String get dataSourcesBody =>
      '医学术语基于 NLM MeSH 医学主题词表（公共领域）。解剖学内容改编自 OpenStax《解剖学与生理学》（CC-BY 4.0）。词根词缀为语言学事实，不受版权限制。';

  @override
  String get openStaxCredit => 'OpenStax 解剖学与生理学（CC-BY 4.0）';

  @override
  String get meshCredit => 'NLM 医学主题词表（公共领域）';

  @override
  String get githubLink => '在 GitHub 上查看';

  @override
  String get search => '搜索';

  @override
  String get cancel => '取消';

  @override
  String get save => '保存';

  @override
  String get delete => '删除';

  @override
  String get back => '返回';

  @override
  String get loading => '加载中...';

  @override
  String get errorGeneric => '出错了，请稍后重试';

  @override
  String get noResults => '未找到相关内容';

  @override
  String get difficulty1 => '入门';

  @override
  String get difficulty2 => '初级';

  @override
  String get difficulty3 => '中级';

  @override
  String get difficulty4 => '高级';

  @override
  String get difficulty5 => '专家';
}
