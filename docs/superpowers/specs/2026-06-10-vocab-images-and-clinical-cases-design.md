# 设计：单词配图 + 病例推理（Clinical Cases）

日期：2026-06-10
状态：已批准

## 背景与目标

两个新功能，让医学英语学习更直观、更有趣：

1. **单词配图**：为可视化的医学词汇（解剖结构、器官、可见症状等约 100–150 个词）添加图片，帮助直观理解。混合来源：解剖类用 OpenStax CC-BY 4.0 插图（与知识库同源），症状/操作类用统一风格 2D 插画。
2. **病例推理（Clinical Cases）**：受《豪斯医生》启发的鉴别诊断思维游戏。玩**预制虚构病例**：给出患者主诉 → 列出鉴别假设 → 用户选择问诊/检查 → 逐步排除 → 揭晓答案并关联词汇学习。**纯离线**，内容引擎用预制病例库；通过 repository 接口预留未来接入 LLM API 的扩展点。

**合规红线**（见 CLAUDE.md）：App 是教育类，绝不出现诊断建议。病例推理全程使用虚构病例、不接受用户输入真实症状、入口处展示免责声明、UI 文案定位为"医学英语学习游戏"。功能名避免使用"诊断/diagnosis"。

## Feature 1：单词配图

### 数据层

- `VocabularyWords` 表加两个 nullable 列：
  - `imagePath` — 资产路径，如 `assets/images/vocab/myocardium.webp`
  - `imageCredit` — 授权署名（CC-BY 要求，如 "OpenStax A&P, CC-BY 4.0"）
- drift `schemaVersion` 2→3，`onUpgrade` 按 v1→v2 先例 `addColumn`
- 域实体 `Vocabulary` 加对应字段，repository impl 映射同步
- seeder 读取 `vocabulary.json` 新增的可选 `image` / `image_credit` 字段
- `kSeedVersion` 3→4 触发重播种（用户笔记本不受影响）

### 资产与内容

- 新目录 `assets/images/vocab/`（pubspec 注册），图片统一 WebP，每张 ≤50KB
- 内容分批：首批 15–20 张试点（每系统 2–3 个代表词），跑通管线后批量补充
- 抽象词（prognosis、etiology 等）不配图

### UI

- 词汇详情页两种模式（滑动 `_VocabPageContent` / 单词 `_SingleWordScaffold`）在标题/IPA 下方插入圆角图片卡片，下方小字署名；无图不渲染占位
- 闪卡背面（释义面）有图则展示小图

## Feature 2：病例推理（Clinical Cases）

### 数据模型

病例少（首批 6–8 个）、只读、无用户数据挂接 → **不进 drift**，直接从打包 JSON 资产加载；通关状态存 SharedPreferences。

`assets/data/clinical_cases.json` 单病例结构（全双语）：

```json
{
  "id": 1,
  "title_en": "…", "title_zh": "…",
  "difficulty": 2,
  "system_id": 1,
  "presentation_en": "虚构患者主诉", "presentation_zh": "…",
  "differentials": [
    { "id": "dx_a", "name_en": "…", "name_zh": "…",
      "rationale_en": "为何合理", "rationale_zh": "…",
      "vocab_ids": [12, 45] }
  ],
  "rounds": [
    { "tests": [
        { "id": "t1", "name_en": "问诊/检查名", "name_zh": "…",
          "finding_en": "结果描述", "finding_zh": "…",
          "rules_out": ["dx_a"] }
    ] }
  ],
  "answer_id": "dx_b",
  "epilogue_en": "揭晓解析", "epilogue_zh": "…",
  "vocab_ids": [12, 45, 78]
}
```

病例内容基于 OpenStax / MeSH 教科书级经典场景改编为虚构故事，每例 3–4 个鉴别假设、2–3 轮检查。

### 架构

- 实体：`ClinicalCase`、`Differential`、`CaseRound`、`CaseTest`（`lib/domain/entities/clinical_case.dart`）
- 接口：`IClinicalCaseRepository`（`getAllCases()` / `getCaseById(id)`）——未来 LLM 版只需新增 impl 替换注入
- 实现：`ClinicalCaseRepositoryImpl` 从 `rootBundle` 加载 JSON
- 通关状态：SharedPreferences 持久化的 provider

### 玩法流程

1. **Hub**（`/cases`）：病例卡片列表（标题、难度、系统、是否通关），顶部常驻免责声明条，首次进入弹免责声明
2. **Session**（`/cases/session/:caseId`）：
   - 展示患者主诉（虚构标识明显）
   - 亮出鉴别假设卡片（白板风格）
   - 每轮从检查中选一项 → 揭示结果 → 被排除假设红叉划掉
   - 最终在剩余假设中做选择 → 揭晓
3. **Result**（`/cases/result`）：答对/答错、解析、"本案词汇"列表（跳转现有词汇详情页）

路由仿 `/quiz` 系列：shell 外全屏路由。首页加第 5 张 `_ModuleCard` 入口。

### 测试策略

- 内容完整性单测：所有 `rules_out` / `answer_id` 必须引用存在的 differential id；`vocab_ids` 必须存在于 `vocabulary.json`；每个病例至少 2 个鉴别假设且答案不能在中途被全部排除逻辑矛盾
- repository 解析单测
- 模拟器手工走查：升级路径（迁移+重播种不丢笔记本）、详情页有图/无图渲染、完整玩通一个病例

## 不做什么（YAGNI）

- 不做用户自由输入症状的查询（合规红线）
- 不做联网/LLM 实时生成（预留接口，后续按需接入）
- 不做病例进度中途存档（病例短，一次玩完）
- 不为抽象词强行配图
