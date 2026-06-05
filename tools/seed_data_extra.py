# -*- coding: utf-8 -*-
"""New seed content (morphemes + articles) and the quiz generator.

Vocabulary lives in seed_vocab_extra.py. gen_seed.py assembles everything.
Inner Chinese quotation uses full-width 「」 to avoid clashing with the Python
ASCII double-quote string delimiters.
"""

# ── New morphemes (ids assigned sequentially starting after the existing 50) ──
# Tuple: (morpheme, type, meaning_zh, meaning_en, origin)
NEW_MORPHEMES = [
    ("arterio-", "root", "动脉", "artery", "Greek"),
    ("phlebo-/veno-", "root", "静脉", "vein", "Greek/Latin"),
    ("thrombo-", "root", "血栓、血凝块", "clot, thrombus", "Greek"),
    ("athero-", "root", "脂肪斑块", "fatty plaque", "Greek"),
    ("vaso-", "root", "血管", "vessel", "Latin"),
    ("aorto-", "root", "主动脉", "aorta", "Greek"),
    ("broncho-", "root", "支气管", "bronchus", "Greek"),
    ("laryngo-", "root", "喉", "larynx", "Greek"),
    ("pharyngo-", "root", "咽", "pharynx", "Greek"),
    ("rhino-", "root", "鼻", "nose", "Greek"),
    ("tracheo-", "root", "气管", "trachea", "Greek"),
    ("thoraco-", "root", "胸、胸腔", "chest, thorax", "Greek"),
    ("pleuro-", "root", "胸膜", "pleura", "Greek"),
    ("pulmo-/pulmono-", "root", "肺", "lung", "Latin"),
    ("oxy-", "root", "氧", "oxygen", "Greek"),
    ("-pnea", "suffix", "呼吸", "breathing", "Greek"),
    ("cerebro-", "root", "大脑", "cerebrum", "Latin"),
    ("cranio-", "root", "颅、头骨", "skull", "Greek"),
    ("myelo-", "root", "脊髓、骨髓", "spinal cord, marrow", "Greek"),
    ("meningo-", "root", "脑膜", "meninges", "Greek"),
    ("psycho-", "root", "精神、心理", "mind", "Greek"),
    ("-phasia", "suffix", "言语（能力）", "speech", "Greek"),
    ("-paresis", "suffix", "轻瘫", "slight paralysis", "Greek"),
    ("esthesi-", "root", "感觉", "sensation", "Greek"),
    ("colo-/colono-", "root", "结肠", "colon", "Greek"),
    ("procto-/recto-", "root", "直肠、肛门", "rectum, anus", "Greek/Latin"),
    ("chole-/cholecyst-", "root", "胆汁、胆囊", "bile, gallbladder", "Greek"),
    ("pancreat-", "root", "胰腺", "pancreas", "Greek"),
    ("esophag-", "root", "食管", "esophagus", "Greek"),
    ("glosso-", "root", "舌", "tongue", "Greek"),
    ("-emesis", "suffix", "呕吐", "vomiting", "Greek"),
    ("-phagia", "suffix", "吞咽、进食", "eating, swallowing", "Greek"),
    ("lapar-", "root", "腹部", "abdomen", "Greek"),
    ("chondro-", "root", "软骨", "cartilage", "Greek"),
    ("teno-/tendin-", "root", "肌腱", "tendon", "Greek/Latin"),
    ("spondylo-", "root", "椎骨", "vertebra", "Greek"),
    ("costo-", "root", "肋骨", "rib", "Latin"),
    ("kinesi-", "root", "运动", "movement", "Greek"),
    ("-malacia", "suffix", "软化", "softening", "Greek"),
    ("-desis", "suffix", "融合、固定", "fusion", "Greek"),
    ("thyro-", "root", "甲状腺", "thyroid", "Greek"),
    ("adreno-", "root", "肾上腺", "adrenal gland", "Latin"),
    ("glyco-/gluco-", "root", "糖、葡萄糖", "sugar, glucose", "Greek"),
    ("aden-", "root", "腺", "gland", "Greek"),
    ("-dipsia", "suffix", "渴", "thirst", "Greek"),
    ("reno-", "root", "肾", "kidney", "Latin"),
    ("cysto-", "root", "膀胱、囊", "bladder, sac", "Greek"),
    ("pyelo-", "root", "肾盂", "renal pelvis", "Greek"),
    ("uretero-", "root", "输尿管", "ureter", "Greek"),
    ("urethro-", "root", "尿道", "urethra", "Greek"),
    ("glomerulo-", "root", "肾小球", "glomerulus", "Latin"),
    ("litho-", "root", "结石", "stone", "Greek"),
    ("olig-", "root", "少", "scanty, few", "Greek"),
    ("kerato-", "root", "角质、角膜", "horny tissue, cornea", "Greek"),
    ("melano-", "root", "黑色", "black", "Greek"),
    ("onycho-", "root", "甲、指甲", "nail", "Greek"),
    ("tricho-", "root", "毛发", "hair", "Greek"),
    ("xero-", "root", "干燥", "dry", "Greek"),
    ("cyano-", "root", "蓝色、青紫", "blue", "Greek"),
    ("-penia", "suffix", "减少、缺乏", "deficiency", "Greek"),
    ("-lysis", "suffix", "分解、破坏", "breakdown, dissolution", "Greek"),
    ("-spasm", "suffix", "痉挛", "involuntary contraction", "Greek"),
    ("-ptosis", "suffix", "下垂", "drooping, prolapse", "Greek"),
    ("-rrhagia", "suffix", "出血、大量流出", "bursting forth, hemorrhage", "Greek"),
    ("-rrhaphy", "suffix", "缝合", "suture", "Greek"),
    ("-centesis", "suffix", "穿刺抽液", "surgical puncture", "Greek"),
    ("-stomy", "suffix", "造口、造瘘", "surgical opening", "Greek"),
    ("-pexy", "suffix", "固定术", "surgical fixation", "Greek"),
    ("-poiesis", "suffix", "生成", "formation, production", "Greek"),
    ("-cele", "suffix", "疝、膨出", "hernia, protrusion", "Greek"),
    ("-plasia", "suffix", "形成、发育", "formation, development", "Greek"),
    ("-sclerosis", "suffix", "硬化", "hardening", "Greek"),
    ("-stasis", "suffix", "停止、控制", "stopping, controlling", "Greek"),
    ("anti-", "prefix", "对抗、抗", "against", "Greek"),
    ("dys-", "prefix", "困难、异常", "difficult, abnormal", "Greek"),
    ("inter-", "prefix", "在……之间", "between", "Latin"),
    ("intra-", "prefix", "在……之内", "within", "Latin"),
    ("sub-", "prefix", "在……之下", "under, below", "Latin"),
    ("trans-", "prefix", "穿过、转移", "across, through", "Latin"),
    ("neo-", "prefix", "新", "new", "Greek"),
    ("post-", "prefix", "在……之后", "after, behind", "Latin"),
]

# ── New knowledge articles ───────────────────────────────────────────────────
# Tuple: (system_id, title_en, title_zh, difficulty, content_en, content_zh)
NEW_ARTICLES = [
    # ---- System 1: Cardiovascular ----
    (1, "Blood Pressure and Its Regulation", "血压及其调节", 2,
     "Blood pressure is the force exerted by circulating blood on the walls of arteries. It is recorded as two numbers: systolic pressure (when the ventricles contract) over diastolic pressure (when the heart relaxes). A typical healthy value is around 120/80 mmHg. The body regulates blood pressure through the autonomic nervous system, which adjusts heart rate and vessel diameter, and through hormones such as those of the renin-angiotensin-aldosterone system, which control blood volume. Sustained high blood pressure, or hypertension, forces the heart to work harder and damages arteries over time, raising the risk of stroke, heart attack, and kidney disease.",
     "血压是循环血液对动脉壁施加的压力，记录为两个数值：收缩压（心室收缩时）/舒张压（心脏舒张时），健康成人通常约为 120/80 mmHg。机体通过自主神经系统调节心率和血管口径，并通过肾素-血管紧张素-醛固酮系统等激素调控血容量来维持血压。长期高血压会迫使心脏负荷加重并逐渐损伤动脉，增加卒中、心肌梗死和肾病的风险。"),
    (1, "Atherosclerosis and Coronary Artery Disease", "动脉粥样硬化与冠心病", 3,
     "Atherosclerosis is the gradual buildup of fatty plaques within the walls of arteries. Plaques narrow the vessel lumen and reduce blood flow, and they may rupture, triggering a clot. When this happens in the coronary arteries that supply the heart muscle, the result is coronary artery disease. Reduced flow causes chest pain known as angina, while complete blockage causes a myocardial infarction (heart attack), in which heart muscle dies from lack of oxygen. Major risk factors include high cholesterol, smoking, diabetes, and hypertension.",
     "动脉粥样硬化是动脉壁内脂质斑块逐渐堆积的过程。斑块使管腔狭窄、血流减少，并可能破裂诱发血栓。当其发生在供应心肌的冠状动脉时即为冠心病：血流减少引起称为心绞痛的胸痛，完全阻塞则导致心肌梗死，心肌因缺氧而坏死。主要危险因素包括高胆固醇、吸烟、糖尿病和高血压。"),
    (1, "The Cardiac Conduction System", "心脏传导系统", 3,
     "Each heartbeat begins as an electrical impulse in the sinoatrial (SA) node, the heart's natural pacemaker located in the right atrium. The impulse spreads across both atria, causing them to contract, then reaches the atrioventricular (AV) node, which briefly delays the signal before passing it down the bundle of His and Purkinje fibers to the ventricles. This orderly sequence ensures the atria empty into the ventricles before the ventricles contract. Disruptions in conduction produce arrhythmias, which an electrocardiogram (ECG) can detect by recording the heart's electrical activity.",
     "每次心跳都始于位于右心房的窦房结（SA 结）发出的电冲动，它是心脏的天然起搏点。冲动传遍两个心房使其收缩，随后到达房室结（AV 结）短暂延搁，再经希氏束和浦肯野纤维传向心室。这一有序过程确保心房先将血液排入心室、心室再收缩。传导异常会产生心律失常，心电图（ECG）可通过记录心脏电活动来检测。"),
    # ---- System 2: Respiratory ----
    (2, "Mechanics of Breathing", "呼吸的力学", 2,
     "Breathing moves air in and out of the lungs through changes in chest cavity volume. During inhalation, the diaphragm contracts and flattens while the external intercostal muscles lift the ribs, enlarging the thorax and lowering the pressure inside the lungs so that air rushes in. During quiet exhalation these muscles relax, the elastic lungs recoil, and air flows out passively. The pleural membranes and the fluid between them keep the lungs adhered to the chest wall, so that the lungs follow its movements.",
     "呼吸通过改变胸腔容积使空气进出肺部。吸气时膈肌收缩变平、肋间外肌上提肋骨，使胸腔扩大、肺内压下降，空气随即涌入；平静呼气时这些肌肉松弛，富有弹性的肺回缩，空气被动排出。胸膜及其间的胸膜液使肺紧贴胸壁，从而随胸壁运动。"),
    (2, "Gas Exchange in the Alveoli", "肺泡气体交换", 3,
     "Gas exchange occurs across the thin walls of the alveoli, the tiny air sacs that give the lungs an enormous surface area. Oxygen from inhaled air diffuses across the alveolar wall and the surrounding capillary into the blood, where it binds to hemoglobin in red blood cells. At the same time, carbon dioxide diffuses from the blood into the alveoli to be exhaled. This exchange is driven by differences in partial pressure between air and blood. Conditions such as emphysema or pneumonia impair gas exchange and cause shortness of breath.",
     "气体交换发生在肺泡的薄壁上——这些微小气囊赋予肺巨大的表面积。吸入空气中的氧气经肺泡壁和周围毛细血管扩散入血，与红细胞中的血红蛋白结合；同时二氧化碳从血液扩散入肺泡随呼气排出。该交换由空气与血液间的分压差驱动。肺气肿、肺炎等疾病会损害气体交换并引起呼吸困难。"),
    (2, "Asthma and Airway Obstruction", "哮喘与气道阻塞", 2,
     "Asthma is a chronic inflammatory disease of the airways. In susceptible people, triggers such as allergens, cold air, or exercise cause the smooth muscle around the bronchi to contract (bronchospasm), the airway lining to swell, and mucus production to increase. The airways narrow, producing wheezing, coughing, chest tightness, and difficulty breathing. Treatment combines long-term anti-inflammatory inhalers that control the underlying inflammation with fast-acting bronchodilators that relax airway muscle during an attack.",
     "哮喘是一种气道慢性炎症性疾病。在易感人群中，过敏原、冷空气或运动等诱因会使支气管周围平滑肌收缩（支气管痉挛）、气道黏膜肿胀、黏液分泌增多，导致气道狭窄，出现喘鸣、咳嗽、胸闷和呼吸困难。治疗将控制基础炎症的长期抗炎吸入剂与发作时松弛气道肌肉的速效支气管扩张剂相结合。"),
    # ---- System 3: Nervous ----
    (3, "Neurons and the Nerve Impulse", "神经元与神经冲动", 3,
     "Neurons are the basic signaling cells of the nervous system. A typical neuron has dendrites that receive signals, a cell body, and a long axon that carries impulses to other cells. Information travels along the axon as an action potential, a brief reversal of electrical charge across the membrane that moves like a wave. Where one neuron meets another, at the synapse, the impulse triggers the release of chemical neurotransmitters that cross the gap and influence the next cell. Many axons are wrapped in a myelin sheath that greatly speeds conduction.",
     "神经元是神经系统的基本信号细胞。典型神经元由接收信号的树突、胞体和将冲动传向其他细胞的长轴突组成。信息以动作电位的形式沿轴突传播——这是一种跨膜电荷的短暂逆转，像波一样推进。在神经元相接的突触处，冲动触发化学神经递质释放，递质跨越间隙影响下一个细胞。许多轴突外包髓鞘，可极大加快传导速度。"),
    (3, "The Central and Peripheral Nervous Systems", "中枢与周围神经系统", 2,
     "The nervous system is divided into two parts. The central nervous system (CNS) consists of the brain and spinal cord, where information is processed and decisions are made. The peripheral nervous system (PNS) consists of the nerves that connect the CNS to the rest of the body. The PNS includes the somatic division, which controls voluntary muscles, and the autonomic division, which regulates involuntary functions such as heart rate and digestion. The autonomic system is further split into the sympathetic ('fight-or-flight') and parasympathetic ('rest-and-digest') branches.",
     "神经系统分为两部分。中枢神经系统（CNS）由脑和脊髓组成，负责处理信息和做出决策；周围神经系统（PNS）由连接中枢与全身的神经组成。PNS 包括控制随意肌的躯体部分和调节心率、消化等不随意功能的自主部分。自主神经系统又分为交感（「战或逃」）和副交感（「休息与消化」）两支。"),
    (3, "Stroke: When Blood Flow to the Brain Fails", "卒中：脑供血中断", 3,
     "A stroke occurs when blood flow to part of the brain is interrupted, depriving neurons of oxygen. In an ischemic stroke, the most common type, a clot blocks a cerebral artery. In a hemorrhagic stroke, a vessel ruptures and bleeds into brain tissue. Because brain cells die quickly without oxygen, a stroke is a medical emergency. Symptoms appear suddenly and may include weakness or paralysis on one side of the body (hemiplegia), difficulty speaking (aphasia), facial drooping, and loss of coordination. Rapid treatment can limit permanent damage.",
     "卒中（中风）发生在脑某部分血流中断、神经元缺氧时。最常见的缺血性卒中由血栓阻塞脑动脉所致；出血性卒中则因血管破裂出血进入脑组织。由于脑细胞缺氧后迅速死亡，卒中属于急症。症状突然出现，可包括一侧肢体无力或偏瘫、言语困难（失语）、面部下垂和协调障碍。及时治疗可减少永久性损伤。"),
    # ---- System 4: Digestive ----
    (4, "The Journey of Food Through the Digestive Tract", "食物在消化道中的旅程", 2,
     "Digestion begins in the mouth, where teeth grind food and saliva starts breaking down starch. Swallowed food passes down the esophagus by waves of muscle contraction called peristalsis into the stomach, where acid and enzymes turn it into a semi-liquid. Most nutrient absorption happens in the small intestine, whose lining is folded into tiny villi to maximize surface area. The large intestine then reabsorbs water and forms waste into stool. The liver, gallbladder, and pancreas add bile and enzymes that aid digestion.",
     "消化始于口腔，牙齿研磨食物、唾液开始分解淀粉。吞下的食物经食管的蠕动（节律性肌肉收缩）进入胃，被胃酸和酶转化为半液态。大部分营养在小肠吸收——其内壁折叠成微小绒毛以最大化表面积；随后大肠重吸收水分并将残渣形成粪便。肝、胆囊和胰腺则分泌胆汁和酶以辅助消化。"),
    (4, "The Liver: The Body's Chemical Factory", "肝脏：人体的化工厂", 3,
     "The liver is the largest internal organ and performs hundreds of functions. It processes nutrients absorbed from the intestine, stores glucose as glycogen, and releases it when blood sugar falls. It produces bile to help digest fats, makes proteins needed for blood clotting, and detoxifies drugs and waste products such as ammonia. Because blood from the digestive tract passes through the liver first, it acts as a filter and gatekeeper. Chronic injury from infection or alcohol can lead to cirrhosis, in which scar tissue replaces healthy liver.",
     "肝脏是最大的内脏器官，承担数百种功能：处理从肠道吸收的营养、以糖原形式储存葡萄糖并在血糖下降时释放；生成帮助消化脂肪的胆汁、制造凝血所需蛋白，并对药物和氨等废物进行解毒。由于来自消化道的血液先经过肝脏，肝脏起到过滤器和「守门人」的作用。感染或酒精导致的慢性损伤可引起肝硬化，瘢痕组织取代健康肝组织。"),
    (4, "Peptic Ulcers and Helicobacter pylori", "消化性溃疡与幽门螺杆菌", 3,
     "A peptic ulcer is an open sore in the lining of the stomach or the first part of the small intestine, where digestive acid has eroded the protective mucous layer. For many years ulcers were blamed on stress and spicy food, but most are actually caused by infection with the bacterium Helicobacter pylori or by long-term use of NSAID painkillers. Typical symptoms include burning upper-abdominal pain. Treatment combines antibiotics to clear the infection with acid-suppressing drugs that allow the lining to heal.",
     "消化性溃疡是胃或小肠起始部黏膜上的开放性溃烂，因消化酸侵蚀了保护性黏液层所致。多年来溃疡曾被归咎于压力和辛辣食物，但实际上多由幽门螺杆菌感染或长期服用非甾体抗炎止痛药引起。典型症状为上腹部烧灼样疼痛。治疗将清除感染的抗生素与抑酸药物相结合，使黏膜得以愈合。"),
    # ---- System 5: Musculoskeletal ----
    (5, "Bone Structure and Remodeling", "骨的结构与重塑", 2,
     "Bone is living tissue that constantly renews itself. The hard outer layer, compact bone, surrounds a spongy inner region and, in long bones, a central marrow cavity where blood cells are made. Two cell types keep bone in balance: osteoblasts build new bone matrix, while osteoclasts break old bone down. This continual remodeling repairs micro-damage and releases calcium into the blood when needed. When breakdown outpaces formation, bones lose density and become fragile, a condition called osteoporosis that increases the risk of fractures.",
     "骨是不断自我更新的活组织。坚硬的外层为密质骨，包绕内部的松质骨，长骨中央还有制造血细胞的骨髓腔。两类细胞维持骨的平衡：成骨细胞构建新的骨基质，破骨细胞分解旧骨。这种持续重塑可修复微损伤并在需要时向血中释放钙。当分解超过形成时，骨密度下降、变得脆弱，即骨质疏松症，会增加骨折风险。"),
    (5, "How Skeletal Muscle Contracts", "骨骼肌如何收缩", 3,
     "Skeletal muscles move the body by contracting. Each muscle is made of bundles of fibers, and each fiber contains thread-like myofibrils built from overlapping filaments of the proteins actin and myosin. When a nerve signal arrives, calcium is released inside the fiber, allowing myosin heads to grab the actin filaments and pull them past one another. This sliding shortens the muscle. The process requires energy in the form of ATP, which is why muscles fatigue and why oxygen and nutrients delivered by the blood are essential for sustained activity.",
     "骨骼肌通过收缩使身体运动。每块肌肉由成束的肌纤维构成，每条纤维内含线状肌原纤维，由肌动蛋白和肌球蛋白丝交叠组成。神经信号到达时，纤维内释放钙离子，使肌球蛋白头部抓住肌动蛋白丝并相互滑过，这种滑动使肌肉缩短。该过程需要 ATP 形式的能量，这也是肌肉会疲劳、以及血液输送的氧和养分对持续活动至关重要的原因。"),
    (5, "Arthritis: Inflammation of the Joints", "关节炎：关节的炎症", 2,
     "Arthritis refers to inflammation of one or more joints, causing pain and stiffness. The two most common forms differ in cause. Osteoarthritis is a 'wear-and-tear' disease in which the cartilage cushioning the ends of bones gradually breaks down, most often in weight-bearing joints of older adults. Rheumatoid arthritis, by contrast, is an autoimmune disease in which the body's immune system attacks the joint lining, leading to swelling, deformity, and damage that can affect many joints at once. Management aims to reduce inflammation and preserve mobility.",
     "关节炎指一个或多个关节的炎症，引起疼痛和僵硬。最常见的两种类型病因不同：骨关节炎是一种「磨损性」疾病，缓冲骨端的软骨逐渐破坏，多见于老年人的承重关节；类风湿关节炎则是自身免疫病，免疫系统攻击关节滑膜，导致肿胀、畸形和损害，常同时累及多个关节。治疗目标是减轻炎症、保持活动能力。"),
    # ---- System 6: Endocrine ----
    (6, "Hormones and the Endocrine System", "激素与内分泌系统", 2,
     "The endocrine system is a network of glands that release chemical messengers called hormones directly into the bloodstream. Hormones travel to distant target organs, where they regulate processes such as growth, metabolism, reproduction, and the body's response to stress. Major glands include the pituitary, which coordinates many others; the thyroid, which sets metabolic rate; the adrenal glands, which release stress hormones; and the pancreas, which controls blood sugar. Because hormones act in tiny amounts, even small imbalances can have widespread effects.",
     "内分泌系统是一组将称为激素的化学信使直接释放入血的腺体网络。激素运行至远处的靶器官，调节生长、代谢、生殖以及机体对应激的反应等过程。主要腺体包括协调众多腺体的垂体、设定代谢率的甲状腺、释放应激激素的肾上腺，以及调控血糖的胰腺。由于激素以极微量起作用，即使轻微失衡也可能产生广泛影响。"),
    (6, "Diabetes Mellitus", "糖尿病", 3,
     "Diabetes mellitus is a group of disorders marked by chronically high blood glucose. Normally the pancreas releases insulin, a hormone that lets cells take up glucose from the blood. In type 1 diabetes, the immune system destroys the insulin-producing cells, so little or no insulin is made. In the far more common type 2 diabetes, the body becomes resistant to insulin and cannot keep up with demand. Over years, high glucose damages blood vessels and nerves, raising the risk of heart disease, kidney failure, blindness, and poor wound healing.",
     "糖尿病是一组以血糖长期升高为特征的疾病。正常情况下胰腺释放胰岛素，使细胞从血液中摄取葡萄糖。1 型糖尿病中，免疫系统破坏产生胰岛素的细胞，胰岛素极少或缺失；在更为常见的 2 型糖尿病中，机体对胰岛素产生抵抗、难以满足需求。多年累积下，高血糖损伤血管和神经，增加心脏病、肾衰竭、失明和伤口难愈的风险。"),
    (6, "The Thyroid Gland and Metabolism", "甲状腺与代谢", 2,
     "The thyroid is a butterfly-shaped gland in the neck that sets the body's metabolic rate by releasing thyroid hormones. When the gland is overactive (hyperthyroidism), metabolism speeds up, producing weight loss, a fast heartbeat, heat intolerance, and anxiety. When it is underactive (hypothyroidism), metabolism slows, causing fatigue, weight gain, cold intolerance, and dry skin. The pituitary gland monitors hormone levels and releases thyroid-stimulating hormone (TSH) to keep them in balance, which is why TSH is measured to assess thyroid function.",
     "甲状腺是颈部一个蝶形腺体，通过释放甲状腺激素设定机体的代谢率。腺体功能亢进（甲亢）时代谢加快，出现体重下降、心跳加快、怕热和焦虑；功能减退（甲减）时代谢减慢，导致乏力、体重增加、怕冷和皮肤干燥。垂体监测激素水平并释放促甲状腺激素（TSH）以维持平衡，这也是临床通过检测 TSH 评估甲状腺功能的原因。"),
    # ---- System 7: Urinary ----
    (7, "How the Kidneys Filter Blood", "肾脏如何过滤血液", 3,
     "The kidneys are a pair of bean-shaped organs that filter waste from the blood and balance the body's water and salts. Each kidney contains about a million tiny filtering units called nephrons. In each nephron, blood is first filtered through a tuft of capillaries known as the glomerulus, producing a fluid that passes through a series of tubules. There, useful substances such as water, glucose, and salts are reabsorbed back into the blood, while waste products remain to form urine. The result is precise control of blood composition and volume.",
     "肾脏是一对蚕豆形器官，负责从血液中过滤废物并平衡机体的水和盐。每个肾脏约含一百万个称为肾单位的微小过滤单元。在每个肾单位中，血液先经称为肾小球的毛细血管丛过滤，生成的滤液流经一系列肾小管；其中水、葡萄糖、盐等有用物质被重吸收回血液，而废物则留下形成尿液。由此实现对血液成分和容量的精确调控。"),
    (7, "Urinary Tract Infections", "尿路感染", 2,
     "A urinary tract infection (UTI) occurs when bacteria, most often from the bowel, enter and multiply in the urinary tract. Infections of the bladder (cystitis) cause a burning sensation when urinating, a frequent urge to go, and cloudy or strong-smelling urine. If bacteria travel up the ureters to the kidneys, a more serious infection called pyelonephritis can develop, often with fever and back pain. UTIs are more common in women because of the shorter urethra, and they are usually treated effectively with antibiotics.",
     "尿路感染（UTI）发生在细菌（多来自肠道）进入并在尿路中繁殖时。膀胱感染（膀胱炎）引起排尿灼痛、尿频和尿液混浊或异味。若细菌沿输尿管上行至肾脏，可发展为更严重的肾盂肾炎，常伴发热和腰背痛。由于尿道较短，女性更易患尿路感染，通常用抗生素可有效治疗。"),
    (7, "Kidney Stones", "肾结石", 2,
     "Kidney stones are hard deposits of minerals and salts that form inside the kidneys when urine becomes concentrated. A small stone may pass unnoticed, but a larger one can lodge in the ureter and block the flow of urine, causing sudden, severe pain in the side and back that may radiate to the lower abdomen, often with blood in the urine and nausea. Drinking plenty of fluids helps prevent stones, and many pass on their own; larger stones may require procedures that break them up or remove them.",
     "肾结石是当尿液浓缩时在肾脏内形成的矿物质和盐类硬性沉积。小结石可能无症状排出，而较大结石可嵌顿于输尿管阻塞尿流，引起腰侧和背部突发剧痛并可向下腹放射，常伴血尿和恶心。多饮水有助于预防结石，许多可自行排出；较大结石可能需要碎石或取石等处理。"),
    # ---- System 8: Integumentary ----
    (8, "The Skin: Structure and Function", "皮肤：结构与功能", 2,
     "The skin is the body's largest organ and its first line of defense. It has three layers: the epidermis, a tough outer barrier that constantly sheds and renews; the dermis, which contains blood vessels, nerves, hair follicles, and sweat and oil glands; and the deeper subcutaneous layer of fat that cushions and insulates. The skin protects against injury and microbes, helps regulate body temperature through sweating and blood-flow changes, senses touch and pain, and produces vitamin D when exposed to sunlight.",
     "皮肤是人体最大的器官，也是第一道防线。它由三层组成：表皮——坚韧的外屏障，不断脱落更新；真皮——含血管、神经、毛囊以及汗腺和皮脂腺；以及更深的皮下脂肪层，起缓冲和保温作用。皮肤抵御损伤和微生物，通过出汗和血流变化帮助调节体温，感知触觉和痛觉，并在阳光照射下生成维生素 D。"),
    (8, "Wound Healing", "伤口愈合", 3,
     "Wound healing is an orderly process that restores damaged skin. It begins with hemostasis, in which blood clots to stop bleeding. Next comes inflammation, when immune cells clear debris and bacteria, producing redness and swelling. During the proliferation phase, new tissue and tiny blood vessels fill the wound and the edges draw together. Finally, in the remodeling phase, collagen is reorganized to strengthen the area, sometimes leaving a scar. Poor circulation, infection, and conditions such as diabetes can slow each of these steps.",
     "伤口愈合是恢复受损皮肤的有序过程。它始于止血——血液凝固以止血；随后是炎症期，免疫细胞清除碎屑和细菌，出现红肿；在增生期，新组织和微小血管填充伤口、创缘相互靠拢；最后在重塑期，胶原重新排列以增强强度，有时留下瘢痕。血液循环不良、感染以及糖尿病等情况会减慢上述各步骤。"),
    (8, "Common Skin Infections", "常见皮肤感染", 2,
     "Because the skin is constantly exposed, it is prone to infection by bacteria, fungi, and viruses. Cellulitis is a bacterial infection of the deeper skin that causes a spreading area of redness, warmth, and tenderness and can become serious if untreated. Fungal infections such as athlete's foot thrive in warm, moist areas and cause itching and scaling. Viral infections include warts and cold sores. Keeping skin clean and dry, and treating breaks in the surface promptly, helps prevent these infections from taking hold.",
     "由于皮肤持续暴露，易受细菌、真菌和病毒感染。蜂窝织炎是较深部皮肤的细菌感染，引起逐渐扩大的红、热、压痛区域，若不治疗可变得严重；足癣等真菌感染好发于温暖潮湿处，引起瘙痒和脱屑；病毒感染包括疣和唇疱疹。保持皮肤清洁干燥、及时处理皮肤破损有助于防止这些感染发生。"),
]


# ── Quiz generation ──────────────────────────────────────────────────────────
import random


def build_quiz(vocab, morphemes, seed=42):
    """Generate a quiz pool from vocab (definition-match) and morphemes
    (meaning-match). Answers and distractors come straight from the data, so
    every question is guaranteed correct."""
    rng = random.Random(seed)
    questions = []
    qid = 1

    by_system = {}
    for v in vocab:
        by_system.setdefault(v.get("system_id"), []).append(v)

    # Vocab: "Which term matches this definition?" (options are words)
    for v in vocab:
        pool = [w for w in by_system.get(v.get("system_id"), []) if w["id"] != v["id"]]
        if len(pool) < 3:
            pool = [w for w in vocab if w["id"] != v["id"]]
        distractors = rng.sample(pool, 3)
        options = [v] + distractors
        rng.shuffle(options)
        words = [o["word"] for o in options]
        correct_index = words.index(v["word"])
        questions.append({
            "id": qid,
            "type": "multiple_choice",
            "question_en": f'Which term matches this definition: "{v["def_en"]}"',
            "question_zh": f'下列哪个术语符合该释义：「{v["def_zh"]}」',
            "options_en": words,
            "options_zh": words,
            "correct_index": correct_index,
            "explanation_en": f'{v["word"]} — {v["def_en"]}',
            "explanation_zh": f'{v["word"]}——{v["def_zh"]}',
            "vocab_id": v["id"],
            "morpheme_id": None,
        })
        qid += 1

    # Morphemes: "What does this root/affix mean?"
    label_en = {"prefix": "prefix", "suffix": "suffix", "root": "root"}
    label_zh = {"prefix": "前缀", "suffix": "后缀", "root": "词根"}
    for m in morphemes:
        pool = [x for x in morphemes if x["id"] != m["id"]]
        distractors = rng.sample(pool, 3)
        chosen = [m] + distractors
        rng.shuffle(chosen)
        en_opts = [c["meaning_en"] for c in chosen]
        zh_opts = [c["meaning_zh"] for c in chosen]
        correct_index = chosen.index(m)
        questions.append({
            "id": qid,
            "type": "multiple_choice",
            "question_en": f'What does the {label_en[m["type"]]} "{m["morpheme"]}" mean?',
            "question_zh": f'{label_zh[m["type"]]}「{m["morpheme"]}」的含义是？',
            "options_en": en_opts,
            "options_zh": zh_opts,
            "correct_index": correct_index,
            "explanation_en": f'{m["morpheme"]} means "{m["meaning_en"]}".',
            "explanation_zh": f'{m["morpheme"]} 意为「{m["meaning_zh"]}」。',
            "vocab_id": None,
            "morpheme_id": m["id"],
        })
        qid += 1

    return questions
