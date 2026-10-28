-- 少儿英语辅导系统数据库设计
-- 创建数据库
CREATE DATABASE IF NOT EXISTS english_tutoring_system 
CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE english_tutoring_system;

-- 1. 用户表
CREATE TABLE users (
    user_id INT PRIMARY KEY AUTO_INCREMENT COMMENT '用户ID',
    username VARCHAR(50) UNIQUE NOT NULL COMMENT '用户名',
    password VARCHAR(255) NOT NULL COMMENT '密码(加密)',
    phone VARCHAR(20) UNIQUE COMMENT '手机号',
    email VARCHAR(100) UNIQUE COMMENT '邮箱',
    real_name VARCHAR(50) COMMENT '真实姓名',
    avatar VARCHAR(255) COMMENT '头像URL',
    gender ENUM('male', 'female', 'other') DEFAULT 'other' COMMENT '性别',
    birth_date DATE COMMENT '出生日期',
    user_type ENUM('student', 'parent', 'teacher', 'admin') NOT NULL DEFAULT 'student' COMMENT '用户类型',
    status ENUM('active', 'inactive', 'banned') DEFAULT 'active' COMMENT '状态',
    last_login_time DATETIME COMMENT '最后登录时间',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    CHECK (user_type IN ('student', 'parent', 'teacher', 'admin')),
    CHECK (status IN ('active', 'inactive', 'banned'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户表';

-- 2. 学生信息表
CREATE TABLE students (
    student_id INT PRIMARY KEY AUTO_INCREMENT COMMENT '学生ID',
    user_id INT UNIQUE NOT NULL COMMENT '用户ID',
    parent_id INT COMMENT '家长ID',
    grade_level VARCHAR(20) COMMENT '年级',
    school_name VARCHAR(100) COMMENT '学校名称',
    english_level VARCHAR(20) DEFAULT 'beginner' COMMENT '英语水平',
    learning_goals TEXT COMMENT '学习目标',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (parent_id) REFERENCES users(user_id) ON DELETE SET NULL,
    CHECK (english_level IN ('beginner', 'elementary', 'intermediate', 'advanced'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='学生信息表';

-- 3. 教师信息表
CREATE TABLE teachers (
    teacher_id INT PRIMARY KEY AUTO_INCREMENT COMMENT '教师ID',
    user_id INT UNIQUE NOT NULL COMMENT '用户ID',
    qualification VARCHAR(100) COMMENT '资质证书',
    experience_years INT DEFAULT 0 COMMENT '教学年限',
    specialization VARCHAR(100) COMMENT '专业领域',
    bio TEXT COMMENT '个人简介',
    rating DECIMAL(3,2) DEFAULT 5.00 COMMENT '评分',
    total_students INT DEFAULT 0 COMMENT '学生总数',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    CHECK (rating >= 0 AND rating <= 5),
    CHECK (experience_years >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='教师信息表';

-- 4. 课程分类表
CREATE TABLE course_categories (
    category_id INT PRIMARY KEY AUTO_INCREMENT COMMENT '分类ID',
    category_name VARCHAR(50) UNIQUE NOT NULL COMMENT '分类名称',
    description TEXT COMMENT '分类描述',
    icon VARCHAR(255) COMMENT '图标URL',
    sort_order INT DEFAULT 0 COMMENT '排序',
    status ENUM('active', 'inactive') DEFAULT 'active' COMMENT '状态',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='课程分类表';

-- 5. 课程表
CREATE TABLE courses (
    course_id INT PRIMARY KEY AUTO_INCREMENT COMMENT '课程ID',
    course_name VARCHAR(100) NOT NULL COMMENT '课程名称',
    category_id INT COMMENT '分类ID',
    teacher_id INT COMMENT '教师ID',
    description TEXT COMMENT '课程描述',
    cover_image VARCHAR(255) COMMENT '封面图片URL',
    level VARCHAR(20) DEFAULT 'beginner' COMMENT '难度级别',
    target_age VARCHAR(50) COMMENT '适用年龄',
    duration INT COMMENT '课程时长(分钟)',
    total_lessons INT DEFAULT 0 COMMENT '总课时数',
    price DECIMAL(10,2) DEFAULT 0.00 COMMENT '价格',
    is_free BOOLEAN DEFAULT FALSE COMMENT '是否免费',
    status ENUM('draft', 'published', 'archived') DEFAULT 'draft' COMMENT '状态',
    view_count INT DEFAULT 0 COMMENT '浏览次数',
    enroll_count INT DEFAULT 0 COMMENT '报名人数',
    rating DECIMAL(3,2) DEFAULT 0.00 COMMENT '评分',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    FOREIGN KEY (category_id) REFERENCES course_categories(category_id) ON DELETE SET NULL,
    FOREIGN KEY (teacher_id) REFERENCES users(user_id) ON DELETE SET NULL,
    CHECK (level IN ('beginner', 'elementary', 'intermediate', 'advanced')),
    CHECK (status IN ('draft', 'published', 'archived')),
    CHECK (price >= 0),
    CHECK (rating >= 0 AND rating <= 5)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='课程表';

-- 6. 课程章节表
CREATE TABLE course_chapters (
    chapter_id INT PRIMARY KEY AUTO_INCREMENT COMMENT '章节ID',
    course_id INT NOT NULL COMMENT '课程ID',
    chapter_name VARCHAR(100) NOT NULL COMMENT '章节名称',
    chapter_order INT NOT NULL COMMENT '章节顺序',
    description TEXT COMMENT '章节描述',
    duration INT COMMENT '章节时长(分钟)',
    is_free BOOLEAN DEFAULT FALSE COMMENT '是否免费试看',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    FOREIGN KEY (course_id) REFERENCES courses(course_id) ON DELETE CASCADE,
    UNIQUE KEY unique_chapter_order (course_id, chapter_order)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='课程章节表';

-- 7. 课时表
CREATE TABLE lessons (
    lesson_id INT PRIMARY KEY AUTO_INCREMENT COMMENT '课时ID',
    chapter_id INT NOT NULL COMMENT '章节ID',
    lesson_name VARCHAR(100) NOT NULL COMMENT '课时名称',
    lesson_order INT NOT NULL COMMENT '课时顺序',
    content TEXT COMMENT '课时内容',
    video_url VARCHAR(255) COMMENT '视频URL',
    audio_url VARCHAR(255) COMMENT '音频URL',
    duration INT COMMENT '时长(分钟)',
    resources JSON COMMENT '学习资源(JSON格式)',
    is_free BOOLEAN DEFAULT FALSE COMMENT '是否免费',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    FOREIGN KEY (chapter_id) REFERENCES course_chapters(chapter_id) ON DELETE CASCADE,
    UNIQUE KEY unique_lesson_order (chapter_id, lesson_order)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='课时表';

-- 8. 学习记录表
CREATE TABLE study_records (
    record_id INT PRIMARY KEY AUTO_INCREMENT COMMENT '记录ID',
    user_id INT NOT NULL COMMENT '用户ID',
    lesson_id INT NOT NULL COMMENT '课时ID',
    course_id INT NOT NULL COMMENT '课程ID',
    study_duration INT DEFAULT 0 COMMENT '学习时长(秒)',
    progress INT DEFAULT 0 COMMENT '学习进度(%)',
    is_completed BOOLEAN DEFAULT FALSE COMMENT '是否完成',
    last_position INT DEFAULT 0 COMMENT '最后播放位置(秒)',
    study_count INT DEFAULT 0 COMMENT '学习次数',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (lesson_id) REFERENCES lessons(lesson_id) ON DELETE CASCADE,
    FOREIGN KEY (course_id) REFERENCES courses(course_id) ON DELETE CASCADE,
    CHECK (progress >= 0 AND progress <= 100),
    CHECK (study_duration >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='学习记录表';

-- 9. 作业表
CREATE TABLE assignments (
    assignment_id INT PRIMARY KEY AUTO_INCREMENT COMMENT '作业ID',
    course_id INT NOT NULL COMMENT '课程ID',
    lesson_id INT COMMENT '课时ID',
    teacher_id INT NOT NULL COMMENT '教师ID',
    title VARCHAR(100) NOT NULL COMMENT '作业标题',
    description TEXT COMMENT '作业描述',
    requirements TEXT COMMENT '作业要求',
    due_date DATETIME COMMENT '截止日期',
    total_score INT DEFAULT 100 COMMENT '总分',
    attachment_url VARCHAR(255) COMMENT '附件URL',
    status ENUM('draft', 'published', 'closed') DEFAULT 'draft' COMMENT '状态',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    FOREIGN KEY (course_id) REFERENCES courses(course_id) ON DELETE CASCADE,
    FOREIGN KEY (lesson_id) REFERENCES lessons(lesson_id) ON DELETE SET NULL,
    FOREIGN KEY (teacher_id) REFERENCES users(user_id) ON DELETE CASCADE,
    CHECK (status IN ('draft', 'published', 'closed')),
    CHECK (total_score > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='作业表';

-- 10. 作业提交表
CREATE TABLE assignment_submissions (
    submission_id INT PRIMARY KEY AUTO_INCREMENT COMMENT '提交ID',
    assignment_id INT NOT NULL COMMENT '作业ID',
    user_id INT NOT NULL COMMENT '学生用户ID',
    content TEXT COMMENT '提交内容',
    attachment_url VARCHAR(255) COMMENT '附件URL',
    score INT COMMENT '得分',
    feedback TEXT COMMENT '教师反馈',
    submitted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '提交时间',
    graded_at DATETIME COMMENT '批改时间',
    status ENUM('submitted', 'graded', 'late') DEFAULT 'submitted' COMMENT '状态',
    FOREIGN KEY (assignment_id) REFERENCES assignments(assignment_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    CHECK (status IN ('submitted', 'graded', 'late')),
    CHECK (score >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='作业提交表';

-- 11. 成绩表
CREATE TABLE scores (
    score_id INT PRIMARY KEY AUTO_INCREMENT COMMENT '成绩ID',
    user_id INT NOT NULL COMMENT '用户ID',
    course_id INT NOT NULL COMMENT '课程ID',
    assignment_id INT COMMENT '作业ID',
    quiz_id INT COMMENT '测验ID',
    score INT NOT NULL COMMENT '得分',
    total_score INT NOT NULL COMMENT '总分',
    percentage DECIMAL(5,2) COMMENT '百分比',
    test_date DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '考试日期',
    remarks TEXT COMMENT '备注',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (course_id) REFERENCES courses(course_id) ON DELETE CASCADE,
    CHECK (score >= 0 AND score <= total_score),
    CHECK (percentage >= 0 AND percentage <= 100)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='成绩表';

-- 12. 测验表
CREATE TABLE quizzes (
    quiz_id INT PRIMARY KEY AUTO_INCREMENT COMMENT '测验ID',
    course_id INT NOT NULL COMMENT '课程ID',
    lesson_id INT COMMENT '课时ID',
    title VARCHAR(100) NOT NULL COMMENT '测验标题',
    description TEXT COMMENT '测验描述',
    duration INT COMMENT '测验时长(分钟)',
    total_score INT DEFAULT 100 COMMENT '总分',
    pass_score INT DEFAULT 60 COMMENT '及格分数',
    attempt_limit INT DEFAULT 3 COMMENT '尝试次数限制',
    random_questions BOOLEAN DEFAULT FALSE COMMENT '是否随机题目',
    status ENUM('draft', 'published', 'archived') DEFAULT 'draft' COMMENT '状态',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    FOREIGN KEY (course_id) REFERENCES courses(course_id) ON DELETE CASCADE,
    FOREIGN KEY (lesson_id) REFERENCES lessons(lesson_id) ON DELETE SET NULL,
    CHECK (status IN ('draft', 'published', 'archived')),
    CHECK (total_score > 0),
    CHECK (pass_score >= 0 && pass_score <= total_score),
    CHECK (attempt_limit > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='测验表';

-- 13. 测验题目表
CREATE TABLE quiz_questions (
    question_id INT PRIMARY KEY AUTO_INCREMENT COMMENT '题目ID',
    quiz_id INT NOT NULL COMMENT '测验ID',
    question_text TEXT NOT NULL COMMENT '题目内容',
    question_type ENUM('choice', 'multiple_choice', 'fill_blank', 'essay') NOT NULL COMMENT '题目类型',
    options JSON COMMENT '选项(JSON格式)',
    correct_answer TEXT NOT NULL COMMENT '正确答案',
    explanation TEXT COMMENT '解析',
    points INT DEFAULT 1 COMMENT '分值',
    order_num INT DEFAULT 0 COMMENT '排序',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    FOREIGN KEY (quiz_id) REFERENCES quizzes(quiz_id) ON DELETE CASCADE,
    CHECK (question_type IN ('choice', 'multiple_choice', 'fill_blank', 'essay')),
    CHECK (points > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='测验题目表';

-- 14. 测验答案表
CREATE TABLE quiz_answers (
    answer_id INT PRIMARY KEY AUTO_INCREMENT COMMENT '答案ID',
    quiz_id INT NOT NULL COMMENT '测验ID',
    user_id INT NOT NULL COMMENT '用户ID',
    question_id INT NOT NULL COMMENT '题目ID',
    user_answer TEXT COMMENT '用户答案',
    is_correct BOOLEAN COMMENT '是否正确',
    points_earned INT DEFAULT 0 COMMENT '获得分数',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    FOREIGN KEY (quiz_id) REFERENCES quizzes(quiz_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (question_id) REFERENCES quiz_questions(question_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='测验答案表';

-- 15. 学习资源表
CREATE TABLE study_resources (
    resource_id INT PRIMARY KEY AUTO_INCREMENT COMMENT '资源ID',
    resource_name VARCHAR(100) NOT NULL COMMENT '资源名称',
    resource_type ENUM('video', 'audio', 'document', 'image', 'link') NOT NULL COMMENT '资源类型',
    description TEXT COMMENT '资源描述',
    file_url VARCHAR(255) NOT NULL COMMENT '文件URL',
    file_size BIGINT COMMENT '文件大小(字节)',
    duration INT COMMENT '时长(秒)',
    category VARCHAR(50) COMMENT '资源分类',
    tags VARCHAR(255) COMMENT '标签',
    download_count INT DEFAULT 0 COMMENT '下载次数',
    view_count INT DEFAULT 0 COMMENT '查看次数',
    uploader_id INT COMMENT '上传者ID',
    status ENUM('draft', 'published', 'archived') DEFAULT 'draft' COMMENT '状态',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    FOREIGN KEY (uploader_id) REFERENCES users(user_id) ON DELETE SET NULL,
    CHECK (resource_type IN ('video', 'audio', 'document', 'image', 'link')),
    CHECK (status IN ('draft', 'published', 'archived')),
    CHECK (file_size >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='学习资源表';

-- 16. 学习计划表
CREATE TABLE study_plans (
    plan_id INT PRIMARY KEY AUTO_INCREMENT COMMENT '计划ID',
    user_id INT NOT NULL COMMENT '用户ID',
    plan_name VARCHAR(100) NOT NULL COMMENT '计划名称',
    description TEXT COMMENT '计划描述',
    start_date DATE NOT NULL COMMENT '开始日期',
    end_date DATE NOT NULL COMMENT '结束日期',
    daily_study_time INT COMMENT '每日学习时长(分钟)',
    total_study_time INT COMMENT '总学习时长(小时)',
    goals TEXT COMMENT '学习目标',
    status ENUM('active', 'completed', 'paused') DEFAULT 'active' COMMENT '状态',
    progress INT DEFAULT 0 COMMENT '进度(%)',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    CHECK (status IN ('active', 'completed', 'paused')),
    CHECK (progress >= 0 AND progress <= 100),
    CHECK (daily_study_time > 0),
    CHECK (total_study_time >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='学习计划表';

-- 17. 系统消息表
CREATE TABLE system_messages (
    message_id INT PRIMARY KEY AUTO_INCREMENT COMMENT '消息ID',
    user_id INT COMMENT '接收用户ID(NULL表示全体用户)',
    title VARCHAR(100) NOT NULL COMMENT '消息标题',
    content TEXT NOT NULL COMMENT '消息内容',
    message_type ENUM('system', 'course', 'assignment', 'score', 'other') NOT NULL COMMENT '消息类型',
    is_read BOOLEAN DEFAULT FALSE COMMENT '是否已读',
    related_id INT COMMENT '关联ID',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    CHECK (message_type IN ('system', 'course', 'assignment', 'score', 'other'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='系统消息表';

-- 18. 反馈表
CREATE TABLE feedback (
    feedback_id INT PRIMARY KEY AUTO_INCREMENT COMMENT '反馈ID',
    user_id INT NOT NULL COMMENT '用户ID',
    feedback_type ENUM('bug', 'suggestion', 'complaint', 'other') NOT NULL COMMENT '反馈类型',
    title VARCHAR(100) NOT NULL COMMENT '反馈标题',
    content TEXT NOT NULL COMMENT '反馈内容',
    contact_info VARCHAR(100) COMMENT '联系方式',
    status ENUM('pending', 'processing', 'resolved', 'closed') DEFAULT 'pending' COMMENT '处理状态',
    reply TEXT COMMENT '回复内容',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    CHECK (feedback_type IN ('bug', 'suggestion', 'complaint', 'other')),
    CHECK (status IN ('pending', 'processing', 'resolved', 'closed'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='反馈表';

-- 19. 词汇表
CREATE TABLE vocabulary (
    vocab_id INT PRIMARY KEY AUTO_INCREMENT COMMENT '词汇ID',
    word VARCHAR(50) UNIQUE NOT NULL COMMENT '单词',
    phonetic VARCHAR(50) COMMENT '音标',
    part_of_speech VARCHAR(20) COMMENT '词性',
    chinese_meaning TEXT NOT NULL COMMENT '中文意思',
    english_definition TEXT COMMENT '英文定义',
    example_sentence TEXT COMMENT '例句',
    example_translation TEXT COMMENT '例句翻译',
    audio_url VARCHAR(255) COMMENT '发音音频URL',
    image_url VARCHAR(255) COMMENT '图片URL',
    difficulty_level VARCHAR(20) DEFAULT 'beginner' COMMENT '难度级别',
    category VARCHAR(50) COMMENT '分类',
    frequency INT DEFAULT 0 COMMENT '频率',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    CHECK (difficulty_level IN ('beginner', 'elementary', 'intermediate', 'advanced')),
    CHECK (frequency >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='词汇表';

-- 20. 用户词汇学习记录表
CREATE TABLE user_vocabulary (
    id INT PRIMARY KEY AUTO_INCREMENT COMMENT '记录ID',
    user_id INT NOT NULL COMMENT '用户ID',
    vocab_id INT NOT NULL COMMENT '词汇ID',
    mastery_level INT DEFAULT 0 COMMENT '掌握程度(0-5)',
    review_count INT DEFAULT 0 COMMENT '复习次数',
    last_review_date DATE COMMENT '最后复习日期',
    next_review_date DATE COMMENT '下次复习日期',
    is_favorited BOOLEAN DEFAULT FALSE COMMENT '是否收藏',
    notes TEXT COMMENT '笔记',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (vocab_id) REFERENCES vocabulary(vocab_id) ON DELETE CASCADE,
    CHECK (mastery_level >= 0 AND mastery_level <= 5),
    CHECK (review_count >= 0),
    UNIQUE KEY unique_user_vocab (user_id, vocab_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户词汇学习记录表';