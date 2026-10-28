USE english_tutoring_system;

-- 插入课程分类
INSERT INTO categories (category_name, description) VALUES
('基础英语', '适合英语初学者的基础课程'),
('口语训练', '提升英语口语能力的专门课程'),
('阅读理解', '培养英语阅读和理解能力的课程'),
('听力训练', '提高英语听力水平的课程'),
('写作技巧', '学习英语写作方法和技巧'),
('语法基础', '系统学习英语语法规则');

-- 插入用户
INSERT INTO users (username, password, real_name, phone, email, gender, birth_date, user_type, status, created_at) VALUES
('admin', '$2a$10$rqY3Y8p8Z8Y8Z8Y8Z8Y8Zu3qY3Y8p8Z8Y8Z8Y8Z8Y8Z8Y8Z8Y8Z8Y8', '系统管理员', '13800000001', 'admin@example.com', 'male', '1990-01-01', 'admin', 'active', NOW()),
('teacher1', '$2a$10$rqY3Y8p8Z8Y8Z8Y8Z8Y8Zu3qY3Y8p8Z8Y8Z8Y8Z8Y8Z8Y8Z8Y8Z8Y8', '张老师', '13800000002', 'teacher1@example.com', 'female', '1985-05-15', 'teacher', 'active', NOW()),
('student1', '$2a$10$rqY3Y8p8Z8Y8Z8Y8Z8Y8Zu3qY3Y8p8Z8Y8Z8Y8Z8Y8Z8Y8Z8Y8Z8Y8', '小明', '13800000003', 'student1@example.com', 'male', '2015-03-10', 'student', 'active', NOW()),
('student2', '$2a$10$rqY3Y8p8Z8Y8Z8Y8Z8Y8Zu3qY3Y8p8Z8Y8Z8Y8Z8Y8Z8Y8Z8Y8Z8Y8', '小红', '13800000004', 'student2@example.com', 'female', '2016-07-22', 'student', 'active', NOW()),
('parent1', '$2a$10$rqY3Y8p8Z8Y8Z8Y8Z8Y8Zu3qY3Y8p8Z8Y8Z8Y8Z8Y8Z8Y8Z8Y8Z8Y8', '王先生', '13800000005', 'parent1@example.com', 'male', '1980-08-01', 'parent', 'active', NOW());

-- 插入教师信息
INSERT INTO teachers (user_id, qualification, experience_years, specialization, bio, rating, total_students) VALUES
(2, '英语专业八级', 8, '少儿英语教学', '从事少儿英语教学8年，擅长趣味教学和互动教学', 4.8, 150);

-- 插入学生信息
INSERT INTO students (user_id, grade_level, school_name, english_level, learning_goals) VALUES
(4, '小学三年级', '阳光小学', '初级', '提高英语听说能力，培养学习兴趣'),
(5, '小学二年级', '希望小学', '初级', '掌握基础词汇，开始简单对话');

-- 插入家长信息
INSERT INTO parents (user_id, occupation, education) VALUES
(6, '工程师', '大学本科');

-- 更新学生的家长信息
UPDATE students SET parent_id = 6 WHERE user_id = 4;

-- 插入课程
INSERT INTO courses (course_name, category_id, teacher_id, description, level, target_age, duration, total_lessons, price, is_free, status, rating, enroll_count) VALUES
('趣味英语字母', 1, 1, '通过游戏和动画学习26个英文字母的发音和书写', '初级', '3-6岁', 1200, 26, 99.00, 0, 'published', 4.5, 45),
('日常会话基础', 1, 1, '学习日常生活中常用的英语表达和简单对话', '初级', '5-8岁', 1800, 30, 149.00, 0, 'published', 4.7, 32),
('英语绘本阅读', 3, 1, '通过绘本故事学习英语词汇和语法', '中级', '6-10岁', 2400, 20, 199.00, 0, 'published', 4.6, 28),
('英语儿歌学唱', 1, 1, '通过经典英语儿歌学习发音和词汇', '初级', '4-7岁', 1500, 15, 129.00, 0, 'published', 4.8, 55),
('英语语法入门', 6, 1, '系统学习英语基础语法知识', '中级', '8-12岁', 3000, 25, 249.00, 0, 'published', 4.4, 18);

-- 插入课时
INSERT INTO lessons (course_id, lesson_title, lesson_description, duration, order_index) VALUES
(1, '字母A', '学习字母A的发音和书写', 180, 1),
(1, '字母B', '学习字母B的发音和书写', 180, 2),
(1, '字母C', '学习字母C的发音和书写', 180, 3),
(1, '字母D', '学习字母D的发音和书写', 180, 4),
(1, '字母E', '学习字母E的发音和书写', 180, 5);

INSERT INTO lessons (course_id, lesson_title, lesson_description, duration, order_index) VALUES
(2, '打招呼', '学习如何用英语打招呼', 300, 1),
(2, '自我介绍', '学习如何用英语介绍自己', 300, 2),
(2, '数字1-10', '学习1到10的英语数字', 300, 3);

-- 插入报名记录
INSERT INTO enrollments (user_id, course_id, progress) VALUES
(4, 1, 20),
(4, 2, 10),
(5, 1, 5);

-- 插入学习记录
INSERT INTO study_records (user_id, lesson_id, course_id, study_duration, progress, is_completed, study_count) VALUES
(4, 1, 1, 180, 100, 1, 1),
(4, 2, 1, 150, 80, 0, 2),
(4, 3, 1, 120, 60, 0, 1);

-- 插入作业
INSERT INTO assignments (course_id, lesson_id, teacher_id, title, description, requirements, due_date, total_score, status) VALUES
(1, 1, 1, '字母A练习', '练习字母A的书写和发音', '请手写字母A10遍，并录制发音视频', DATE_ADD(NOW(), INTERVAL 3 DAY), 100, 'published'),
(1, 2, 1, '字母B练习', '练习字母B的书写和发音', '请手写字母B10遍，并录制发音视频', DATE_ADD(NOW(), INTERVAL 3 DAY), 100, 'published'),
(2, 1, 1, '打招呼练习', '练习用英语打招呼', '请录制自己打招呼的视频', DATE_ADD(NOW(), INTERVAL 2 DAY), 100, 'published');

-- 插入词汇
INSERT INTO vocabulary (word, phonetic, part_of_speech, chinese_meaning, english_definition, example_sentence, example_translation, difficulty_level, category, frequency) VALUES
('hello', '/həˈloʊ/', interjection, '你好', 'Used as a greeting', 'Hello, how are you?', '你好，你好吗？', '初级', '问候', 95),
('apple', '/ˈæpəl/', noun, '苹果', 'A round fruit with red or green skin', 'I like to eat apples.', '我喜欢吃苹果。', '初级', '食物', 90),
('cat', '/kæt/', noun, '猫', 'A small domesticated carnivorous mammal', 'The cat is sleeping.', '猫正在睡觉。', '初级', '动物', 85),
('dog', '/dɔːɡ/', noun, '狗', 'A domesticated carnivorous mammal', 'My dog likes to play.', '我的狗喜欢玩耍。', '初级', '动物', 88),
('book', '/bʊk/', noun, '书', 'A written or printed work', 'I am reading a book.', '我正在读一本书。', '初级', '物品', 80),
('pencil', '/ˈpensəl/', noun, '铅笔', 'A thin cylindrical instrument used for writing', 'I use a pencil to write.', '我用铅笔写字。', '初级', '物品', 75),
('school', '/skuːl/', noun, '学校', 'An educational institution', 'I go to school every day.', '我每天都去学校。', '初级', '场所', 85),
('teacher', '/ˈtiːtʃər/', noun, '老师', 'A person who teaches', 'Our teacher is very kind.', '我们的老师很和蔼。', '初级', '人物', 82),
('student', '/ˈstjuːdənt/', noun, '学生', 'A person who is studying at a school', 'I am a student.', '我是一个学生。', '初级', '人物', 88),
('friend', '/frend/', noun, '朋友', 'A person with whom one has a bond of mutual affection', 'She is my best friend.', '她是我最好的朋友。', '初级', '人物', 78);

-- 插入用户词汇学习记录
INSERT INTO user_vocabulary (user_id, vocab_id, mastery_level, review_count, last_review_date, next_review_date) VALUES
(4, 1, 3, 5, NOW(), DATE_ADD(NOW(), INTERVAL 3 DAY)),
(4, 2, 4, 8, NOW(), DATE_ADD(NOW(), INTERVAL 7 DAY)),
(4, 3, 2, 3, NOW(), DATE_ADD(NOW(), INTERVAL 1 DAY)),
(5, 1, 2, 2, NOW(), DATE_ADD(NOW(), INTERVAL 2 DAY)),
(5, 2, 1, 1, NOW(), DATE_ADD(NOW(), INTERVAL 1 DAY));

-- 插入成绩
INSERT INTO scores (user_id, course_id, assignment_id, score, total_score, percentage, test_date, remarks) VALUES
(4, 1, 1, 95, 100, 95.00, DATE_SUB(NOW(), INTERVAL 1 DAY), '表现优秀'),
(4, 1, 2, 88, 100, 88.00, DATE_SUB(NOW(), INTERVAL 2 DAY), '继续努力'),
(5, 1, 1, 92, 100, 92.00, DATE_SUB(NOW(), INTERVAL 1 DAY), '很好');

-- 插入消息
INSERT INTO messages (user_id, title, content, message_type, is_read) VALUES
(4, '作业提醒', '您有新的作业需要提交，请及时完成。', 'assignment', 0),
(4, '成绩通知', '您的作业"字母A练习"已批改，得分95分。', 'score', 0),
(5, '作业提醒', '您有新的作业需要提交，请及时完成。', 'assignment', 0);