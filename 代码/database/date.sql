-- 少儿英语辅导系统 - 数据初始化
USE english_tutoring_system;

-- 插入管理员用户
INSERT INTO users (username, password, phone, email, real_name, gender, user_type, status) VALUES
('admin', '$2b$10$XIXhV6Z5MZ5MvMZ5MZ5MZ5MZ5MZ5MZ5MZ5MZ5MZ5MZ5MZ5MZ5MZ5M', '13800138000', 'admin@english.com', '系统管理员', 'male', 'admin', 'active'),
('teacher1', '$2b$10$XIXhV6Z5MZ5MvMZ5MZ5MZ5MZ5MZ5MZ5MZ5MZ5MZ5MZ5MZ5MZ5MZ5M', '13800138001', 'teacher1@english.com', '王老师', 'female', 'teacher', 'active'),
('teacher2', '$2b$10$XIXhV6Z5MZ5MvMZ5MZ5MZ5MZ5MZ5MZ5MZ5MZ5MZ5MZ5MZ5MZ5MZ5M', '13800138002', 'teacher2@english.com', '李老师', 'male', 'teacher', 'active'),
('parent1', '$2b$10$XIXhV6Z5MZ5MvMZ5MZ5MZ5MZ5MZ5MZ5MZ5MZ5MZ5MZ5MZ5MZ5MZ5M', '13800138003', 'parent1@english.com', '张爸爸', 'male', 'parent', 'active'),
('parent2', '$2b$10$XIXhV6Z5MZ5MvMZ5MZ5MZ5MZ5MZ5MZ5MZ5MZ5MZ5MZ5MZ5MZ5MZ5M', '13800138004', 'parent2@english.com', '刘妈妈', 'female', 'parent', 'active'),
('student1', '$2b$10$XIXhV6Z5MZ5MvMZ5MZ5MZ5MZ5MZ5MZ5MZ5MZ5MZ5MZ5MZ5MZ5MZ5M', '13800138005', 'student1@english.com', '小明', 'male', 'student', 'active'),
('student2', '$2b$10$XIXhV6Z5MZ5MvMZ5MZ5MZ5MZ5MZ5MZ5MZ5MZ5MZ5MZ5MZ5MZ5MZ5M', '13800138006', 'student2@english.com', '小红', 'female', 'student', 'active'),
('student3', '$2b$10$XIXhV6Z5MZ5MvMZ5MZ5MZ5MZ5MZ5MZ5MZ5MZ5MZ5MZ5MZ5MZ5MZ5M', '13800138007', 'student3@english.com', '小华', 'male', 'student', 'active');

-- 插入教师信息
INSERT INTO teachers (user_id, qualification, experience_years, specialization, bio, rating, total_students) VALUES
(2, '英语专业八级，TESOL认证', 8, '少儿英语启蒙，自然拼读', '专注少儿英语教育8年，擅长用游戏化教学激发孩子学习兴趣', 4.8, 156),
(3, '英语专业硕士，CELTA认证', 5, '英语口语，阅读理解', '曾在国际学校任教，注重培养孩子的英语思维和表达能力', 4.9, 203);

-- 插入学生信息
INSERT INTO students (user_id, parent_id, grade_level, school_name, english_level, learning_goals) VALUES
(6, 4, '小学三年级', '阳光小学', 'beginner', '掌握基础词汇，能进行简单对话'),
(7, 5, '小学四年级', '明德小学', 'elementary', '提高听力理解，扩大词汇量'),
(8, 4, '小学五年级', '育才小学', 'intermediate', '准备PET考试，提高综合能力');

-- 插入课程分类
INSERT INTO course_categories (category_name, description, icon, sort_order, status) VALUES
('自然拼读', '学习英语字母发音规律，掌握拼读技巧', 'phonics.png', 1, 'active'),
('词汇积累', '系统学习常用词汇，扩大词汇量', 'vocabulary.png', 2, 'active'),
('口语对话', '日常口语练习，提高交流能力', 'speaking.png', 3, 'active'),
('听力训练', '提高英语听力理解能力', 'listening.png', 4, 'active'),
('阅读理解', '培养阅读兴趣，提高理解能力', 'reading.png', 5, 'active'),
('语法基础', '系统学习英语语法知识', 'grammar.png', 6, 'active'),
('写作入门', '基础写作训练', 'writing.png', 7, 'active');

-- 插入课程
INSERT INTO courses (course_name, category_id, teacher_id, description, cover_image, level, target_age, duration, total_lessons, price, is_free, status) VALUES
('少儿英语自然拼读入门', 1, 2, '通过有趣的动画和游戏，帮助孩子掌握26个字母的发音规律，学会拼读简单单词', 'phonics_course.jpg', 'beginner', '4-7岁', 1200, 12, 199.00, FALSE, 'published'),
('日常口语100句', 3, 3, '涵盖日常生活、学校、家庭等场景的100句常用口语，让孩子轻松开口说英语', 'speaking_course.jpg', 'beginner', '5-10岁', 900, 10, 149.00, FALSE, 'published'),
('小学英语词汇训练营', 2, 2, '系统学习小学阶段必备词汇，通过记忆宫殿法快速记忆', 'vocabulary_course.jpg', 'elementary', '7-12岁', 1500, 15, 249.00, FALSE, 'published'),
('英语绘本阅读', 5, 3, '精选经典英文绘本，培养阅读兴趣，提高理解能力', 'reading_course.jpg', 'beginner', '5-9岁', 1000, 10, 179.00, FALSE, 'published'),
('基础语法入门', 6, 2, '用通俗易懂的方式讲解基础语法知识', 'grammar_course.jpg', 'intermediate', '8-12岁', 1300, 13, 219.00, FALSE, 'published');

-- 插入课程章节 (以自然拼读课程为例)
INSERT INTO course_chapters (course_id, chapter_name, chapter_order, description, duration, is_free) VALUES
(1, '第一章：字母A-E的发音', 1, '学习字母A、B、C、D、E的发音规律', 100, TRUE),
(1, '第二章：字母F-J的发音', 2, '学习字母F、G、H、I、J的发音规律', 100, FALSE),
(1, '第三章：字母K-O的发音', 3, '学习字母K、L、M、N、O的发音规律', 100, FALSE),
(1, '第四章：字母P-T的发音', 4, '学习字母P、Q、R、S、T的发音规律', 100, FALSE),
(1, '第五章：字母U-Z的发音', 5, '学习字母U、V、W、X、Y、Z的发音规律', 120, FALSE),
(1, '第六章：CVC单词拼读', 6, '练习拼读CVC结构单词', 150, FALSE),
(1, '第七章：长元音发音规则', 7, '学习长元音的发音规则', 120, FALSE),
(1, '第八章：辅音组合发音', 8, '学习常见辅音组合的发音', 130, FALSE),
(1, '第九章：综合练习', 9, '综合运用所学知识进行拼读练习', 180, FALSE),
(1, '第十章：总结与拓展', 10, '总结学习内容，拓展更多拼读技巧', 100, FALSE);

-- 插入课时
INSERT INTO lessons (chapter_id, lesson_name, lesson_order, content, video_url, audio_url, duration, is_free) VALUES
(1, '1.1 字母A的发音', 1, '学习字母A的短音发音/a/，认识以A开头的单词', 'lesson_1_1.mp4', 'lesson_1_1.mp3', 10, TRUE),
(1, '1.2 字母B的发音', 2, '学习字母B的发音/b/，认识以B开头的单词', 'lesson_1_2.mp4', 'lesson_1_2.mp3', 10, FALSE),
(1, '1.3 字母C的发音', 3, '学习字母C的发音/k/，认识以C开头的单词', 'lesson_1_3.mp4', 'lesson_1_3.mp3', 10, FALSE),
(1, '1.4 字母D的发音', 4, '学习字母D的发音/d/，认识以D开头的单词', 'lesson_1_4.mp4', 'lesson_1_4.mp3', 10, FALSE),
(1, '1.5 字母E的发音', 5, '学习字母E的短音发音/e/，认识以E开头的单词', 'lesson_1_5.mp4', 'lesson_1_5.mp3', 10, FALSE),
(2, '2.1 字母F的发音', 1, '学习字母F的发音/f/，认识以F开头的单词', 'lesson_2_1.mp4', 'lesson_2_1.mp3', 10, FALSE),
(2, '2.2 字母G的发音', 2, '学习字母G的发音/g/，认识以G开头的单词', 'lesson_2_2.mp4', 'lesson_2_2.mp3', 10, FALSE);

-- 插入词汇数据
INSERT INTO vocabulary (word, phonetic, part_of_speech, chinese_meaning, english_definition, example_sentence, example_translation, audio_url, difficulty_level, category, frequency) VALUES
('apple', '/ˈæpl/', 'n.', '苹果', 'A round fruit with red or green skin', 'I like to eat apples.', '我喜欢吃苹果。', 'apple.mp3', 'beginner', '水果', 95),
('banana', '/bəˈnænə/', 'n.', '香蕉', 'A long yellow fruit', 'Monkeys like bananas.', '猴子喜欢香蕉。', 'banana.mp3', 'beginner', '水果', 90),
('cat', '/kæt/', 'n.', '猫', 'A small domesticated carnivorous mammal', 'The cat is sleeping.', '猫在睡觉。', 'cat.mp3', 'beginner', '动物', 92),
('dog', '/dɒɡ/', 'n.', '狗', 'A domesticated carnivorous mammal', 'I have a dog.', '我有一只狗。', 'dog.mp3', 'beginner', '动物', 94),
('book', '/bʊk/', 'n.', '书', 'A written or printed work', 'This is a good book.', '这是一本好书。', 'book.mp3', 'beginner', '学习用品', 88),
('pencil', '/ˈpensl/', 'n.', '铅笔', 'An instrument for writing or drawing', 'Use a pencil to write.', '用铅笔写字。', 'pencil.mp3', 'beginner', '学习用品', 85),
('teacher', '/ˈtiːtʃə/', 'n.', '老师', 'A person who teaches', 'She is a teacher.', '她是一名老师。', 'teacher.mp3', 'beginner', '人物', 87),
('student', '/ˈstjuːdnt/', 'n.', '学生', 'A person who is studying at a school', 'He is a student.', '他是一名学生。', 'student.mp3', 'beginner', '人物', 89),
('school', '/skuːl/', 'n.', '学校', 'An institution for educating children', 'I go to school every day.', '我每天去学校。', 'school.mp3', 'beginner', '场所', 91),
('family', '/ˈfæməli/', 'n.', '家庭', 'A group of parents and children', 'I love my family.', '我爱我的家庭。', 'family.mp3', 'beginner', '人物', 86),
('happy', '/ˈhæpi/', 'adj.', '快乐的', 'Feeling or showing pleasure', 'I am very happy.', '我很快乐。', 'happy.mp3', 'beginner', '情感', 93),
('sad', '/sæd/', 'adj.', '悲伤的', 'Feeling or showing sorrow', 'He looks sad.', '他看起来很伤心。', 'sad.mp3', 'beginner', '情感', 84),
('big', '/bɪɡ/', 'adj.', '大的', 'Of considerable size', 'The elephant is big.', '大象很大。', 'big.mp3', 'beginner', '形容词', 90),
('small', '/smɔːl/', 'adj.', '小的', 'Of a size that is less than normal', 'The bird is small.', '鸟很小。', 'small.mp3', 'beginner', '形容词', 88),
('good', '/ɡʊd/', 'adj.', '好的', 'Of a high quality or standard', 'This is a good book.', '这是一本好书。', 'good.mp3', 'beginner', '形容词', 95),
('bad', '/bæd/', 'adj.', '坏的', 'Of poor quality or a low standard', 'The weather is bad.', '天气很糟糕。', 'bad.mp3', 'beginner', '形容词', 82),
('eat', '/iːt/', 'v.', '吃', 'Put food into the mouth and chew it', 'I eat breakfast at 7 o\'clock.', '我7点吃早饭。', 'eat.mp3', 'beginner', '动词', 91),
('drink', '/drɪŋk/', 'v.', '喝', 'Take liquid into the mouth and swallow', 'Drink some water.', '喝点水。', 'drink.mp3', 'beginner', '动词', 87),
('play', '/pleɪ/', 'v.', '玩', 'Engage in activity for enjoyment', 'Children like to play.', '孩子们喜欢玩。', 'play.mp3', 'beginner', '动词', 94),
('learn', '/lɜːn/', 'v.', '学习', 'Gain knowledge or skill', 'I learn English every day.', '我每天学英语。', 'learn.mp3', 'beginner', '动词', 89);

-- 插入学习记录
INSERT INTO study_records (user_id, lesson_id, course_id, study_duration, progress, is_completed, last_position, study_count) VALUES
(6, 1, 1, 600, 100, TRUE, 600, 3),
(6, 2, 1, 420, 70, FALSE, 420, 2),
(6, 3, 1, 300, 50, FALSE, 300, 1),
(7, 1, 2, 540, 90, FALSE, 540, 2),
(8, 1, 3, 720, 100, TRUE, 720, 4);

-- 插入作业
INSERT INTO assignments (course_id, lesson_id, teacher_id, title, description, requirements, due_date, total_score, status) VALUES
(1, 1, 2, '字母A发音练习', '练习字母A的发音，录制视频上传', '1. 正确发音字母A\n2. 说出3个以A开头的单词\n3. 视频时长不少于1分钟', DATE_ADD(CURRENT_DATE, INTERVAL 7 DAY), 100, 'published'),
(1, 2, 2, '字母B-E复习作业', '复习字母B到E的发音', '完成练习册第5-8页', DATE_ADD(CURRENT_DATE, INTERVAL 7 DAY), 100, 'published'),
(2, 1, 3, '自我介绍练习', '用英语进行简单的自我介绍', '包括姓名、年龄、爱好等信息，视频时长2-3分钟', DATE_ADD(CURRENT_DATE, INTERVAL 10 DAY), 100, 'published');

-- 插入作业提交
INSERT INTO assignment_submissions (assignment_id, user_id, content, attachment_url, score, feedback, status) VALUES
(1, 6, '我已经完成了字母A的发音练习，请老师批改', 'video_001.mp4', 95, '发音很标准，继续加油！', 'graded'),
(2, 6, '练习册已完成', 'homework_001.pdf', 88, '完成情况很好，注意B和D的区分', 'graded'),
(3, 7, '这是我的自我介绍视频', 'video_002.mp4', NULL, NULL, 'submitted');

-- 插入成绩
INSERT INTO scores (user_id, course_id, assignment_id, score, total_score, percentage, remarks) VALUES
(6, 1, 1, 95, 100, 95.00, '优秀'),
(6, 1, 2, 88, 100, 88.00, '良好'),
(7, 2, 3, 92, 100, 92.00, '优秀'),
(8, 3, NULL, 85, 100, 85.00, '良好');

-- 插入测验
INSERT INTO quizzes (course_id, lesson_id, title, description, duration, total_score, pass_score, attempt_limit, status) VALUES
(1, 1, '字母A-E发音测验', '测试字母A到E的发音掌握情况', 15, 100, 60, 3, 'published'),
(1, 6, 'CVC单词拼读测验', '测试CVC结构单词的拼读能力', 20, 100, 60, 3, 'published'),
(2, 5, '日常口语测验', '测试日常口语的掌握情况', 30, 100, 60, 3, 'published');

-- 插入测验题目
INSERT INTO quiz_questions (quiz_id, question_text, question_type, options, correct_answer, explanation, points, order_num) VALUES
(1, '字母A的发音是什么？', 'choice', '["/æ/", "/e/", "/i/", "/o/"]', '/æ/', '字母A的短音发音是/æ/', 10, 1),
(1, '下面哪个单词以字母A开头？', 'choice', '["Banana", "Apple", "Cat", "Dog"]', 'Apple', 'Apple以字母A开头', 10, 2),
(1, '字母B的发音是什么？', 'choice', '["/b/", "/p/", "/d/", "/t/"]', '/b/', '字母B的发音是/b/', 10, 3),
(1, 'cat这个单词怎么读？', 'choice', '["/kæt/", "/kɑːt/", "/keɪt/", "/kɒt/"]', '/kæt/', 'cat读作/kæt/', 10, 4);

-- 插入系统消息
INSERT INTO system_messages (user_id, title, content, message_type, related_id) VALUES
(NULL, '欢迎使用少儿英语辅导系统', '欢迎来到少儿英语辅导系统，开始你的英语学习之旅吧！', 'system', NULL),
(6, '新课程发布', '《日常口语100句》课程已上线，快来学习吧！', 'course', 2),
(6, '作业提醒', '您有新的作业需要完成，请及时提交', 'assignment', 2),
(6, '成绩通知', '您的作业《字母A发音练习》已批改，得分95分', 'score', 1);

-- 插入学习资源
INSERT INTO study_resources (resource_name, resource_type, description, file_url, file_size, category, tags, uploader_id, status) VALUES
('英语字母发音表', 'document', '26个英文字母的发音对照表', 'alphabet_chart.pdf', 1024000, '发音', '字母,发音,基础', 2, 'published'),
('自然拼读口诀', 'document', '自然拼读学习口诀和技巧', 'phonics_rhymes.pdf', 512000, '拼读', '自然拼读,口诀', 2, 'published'),
('英文儿歌合集', 'audio', '20首经典英文儿歌', 'english_songs.mp3', 25600000, '音乐', '儿歌,音乐,听力', 3, 'published'),
('常用词汇卡片', 'image', '100个常用英语词汇卡片', 'vocab_cards.jpg', 2048000, '词汇', '词汇,卡片', 2, 'published'),
('英语动画视频', 'video', '适合儿童观看的英语教学动画', 'english_cartoon.mp4', 52428800, '视频', '动画,视频,娱乐', 3, 'published');

-- 插入学习计划
INSERT INTO study_plans (user_id, plan_name, description, start_date, end_date, daily_study_time, total_study_time, goals, status, progress) VALUES
(6, '暑假英语提升计划', '利用暑假时间提高英语水平', '2024-07-01', '2024-08-31', 60, 60, '掌握自然拼读基础，学会100个常用单词', 'active', 35),
(7, '新学期英语学习计划', '制定新学期的英语学习目标', '2024-09-01', '2025-01-31', 45, 90, '提高口语表达能力，扩大词汇量到500个', 'active', 15);

-- 插入用户词汇学习记录
INSERT INTO user_vocabulary (user_id, vocab_id, mastery_level, review_count, last_review_date, next_review_date, is_favorited) VALUES
(6, 1, 4, 5, CURRENT_DATE, DATE_ADD(CURRENT_DATE, INTERVAL 3 DAY), TRUE),
(6, 2, 3, 3, CURRENT_DATE, DATE_ADD(CURRENT_DATE, INTERVAL 2 DAY), FALSE),
(6, 3, 5, 8, CURRENT_DATE, DATE_ADD(CURRENT_DATE, INTERVAL 7 DAY), TRUE),
(6, 4, 4, 6, CURRENT_DATE, DATE_ADD(CURRENT_DATE, INTERVAL 4 DAY), FALSE),
(7, 5, 3, 4, CURRENT_DATE, DATE_ADD(CURRENT_DATE, INTERVAL 2 DAY), FALSE),
(7, 6, 2, 2, CURRENT_DATE, DATE_ADD(CURRENT_DATE, INTERVAL 1 DAY), FALSE),
(8, 7, 4, 5, CURRENT_DATE, DATE_ADD(CURRENT_DATE, INTERVAL 3 DAY), TRUE),
(8, 8, 5, 7, CURRENT_DATE, DATE_ADD(CURRENT_DATE, INTERVAL 5 DAY), FALSE);

-- 插入反馈
INSERT INTO feedback (user_id, feedback_type, title, content, contact_info, status) VALUES
(6, 'suggestion', '增加更多游戏化学习内容', '希望能增加更多英语学习游戏，让学习更有趣', '13800138005', 'resolved'),
(7, 'bug', '视频播放卡顿', '在观看课程视频时经常出现卡顿现象', '13800138006', 'processing'),
(8, 'suggestion', '增加家长监督功能', '希望能让家长看到孩子的学习进度和情况', '13800138007', 'pending');