-- 创建数据库
CREATE DATABASE IF NOT EXISTS english_tutoring_system CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE english_tutoring_system;

-- 创建课程分类表
CREATE TABLE IF NOT EXISTS categories (
  category_id INT PRIMARY KEY AUTO_INCREMENT,
  category_name VARCHAR(100) NOT NULL,
  description TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- 创建教师表
CREATE TABLE IF NOT EXISTS teachers (
  teacher_id INT PRIMARY KEY AUTO_INCREMENT,
  user_id INT NOT NULL,
  qualification VARCHAR(200),
  experience_years INT DEFAULT 0,
  specialization VARCHAR(200),
  bio TEXT,
  rating DECIMAL(3,2) DEFAULT 4.50,
  total_students INT DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- 创建课程表
CREATE TABLE IF NOT EXISTS courses (
  course_id INT PRIMARY KEY AUTO_INCREMENT,
  course_name VARCHAR(200) NOT NULL,
  category_id INT,
  teacher_id INT,
  description TEXT,
  cover_image VARCHAR(500),
  level VARCHAR(50),
  target_age VARCHAR(50),
  duration INT,
  total_lessons INT DEFAULT 0,
  price DECIMAL(10,2),
  is_free TINYINT DEFAULT 0,
  status VARCHAR(20) DEFAULT 'draft',
  view_count INT DEFAULT 0,
  enroll_count INT DEFAULT 0,
  rating DECIMAL(3,2) DEFAULT 0.00,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (category_id) REFERENCES categories(category_id) ON DELETE SET NULL,
  FOREIGN KEY (teacher_id) REFERENCES teachers(teacher_id) ON DELETE SET NULL
);

-- 创建课时表
CREATE TABLE IF NOT EXISTS lessons (
  lesson_id INT PRIMARY KEY AUTO_INCREMENT,
  course_id INT NOT NULL,
  lesson_title VARCHAR(200) NOT NULL,
  lesson_description TEXT,
  video_url VARCHAR(500),
  audio_url VARCHAR(500),
  duration INT,
  order_index INT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (course_id) REFERENCES courses(course_id) ON DELETE CASCADE
);

-- 创建学生表
CREATE TABLE IF NOT EXISTS students (
  student_id INT PRIMARY KEY AUTO_INCREMENT,
  user_id INT NOT NULL,
  parent_id INT,
  grade_level VARCHAR(50),
  school_name VARCHAR(200),
  english_level VARCHAR(50),
  learning_goals TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
  FOREIGN KEY (parent_id) REFERENCES users(user_id) ON DELETE SET NULL
);

-- 创建家长表
CREATE TABLE IF NOT EXISTS parents (
  parent_id INT PRIMARY KEY AUTO_INCREMENT,
  user_id INT NOT NULL,
  occupation VARCHAR(100),
  education VARCHAR(100),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- 创建报名表
CREATE TABLE IF NOT EXISTS enrollments (
  enrollment_id INT PRIMARY KEY AUTO_INCREMENT,
  user_id INT NOT NULL,
  course_id INT NOT NULL,
  enrolled_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  progress INT DEFAULT 0,
  FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
  FOREIGN KEY (course_id) REFERENCES courses(course_id) ON DELETE CASCADE,
  UNIQUE KEY unique_enrollment (user_id, course_id)
);

-- 创建学习记录表
CREATE TABLE IF NOT EXISTS study_records (
  record_id INT PRIMARY KEY AUTO_INCREMENT,
  user_id INT NOT NULL,
  lesson_id INT,
  course_id INT,
  study_duration INT DEFAULT 0,
  progress INT DEFAULT 0,
  is_completed TINYINT DEFAULT 0,
  last_position INT DEFAULT 0,
  study_count INT DEFAULT 0,
  last_study_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
  FOREIGN KEY (lesson_id) REFERENCES lessons(lesson_id) ON DELETE CASCADE,
  FOREIGN KEY (course_id) REFERENCES courses(course_id) ON DELETE CASCADE
);

-- 创建作业表
CREATE TABLE IF NOT EXISTS assignments (
  assignment_id INT PRIMARY KEY AUTO_INCREMENT,
  course_id INT,
  lesson_id INT,
  teacher_id INT,
  title VARCHAR(200) NOT NULL,
  description TEXT,
  requirements TEXT,
  due_date TIMESTAMP,
  total_score INT DEFAULT 100,
  status VARCHAR(20) DEFAULT 'draft',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (course_id) REFERENCES courses(course_id) ON DELETE CASCADE,
  FOREIGN KEY (lesson_id) REFERENCES lessons(lesson_id) ON DELETE CASCADE,
  FOREIGN KEY (teacher_id) REFERENCES teachers(teacher_id) ON DELETE SET NULL
);

-- 创建作业提交表
CREATE TABLE IF NOT EXISTS submissions (
  submission_id INT PRIMARY KEY AUTO_INCREMENT,
  user_id INT NOT NULL,
  assignment_id INT NOT NULL,
  content TEXT,
  attachments TEXT,
  submission_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  is_late TINYINT DEFAULT 0,
  score INT,
  feedback TEXT,
  status VARCHAR(20) DEFAULT 'submitted',
  graded_at TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
  FOREIGN KEY (assignment_id) REFERENCES assignments(assignment_id) ON DELETE CASCADE,
  UNIQUE KEY unique_submission (user_id, assignment_id)
);

-- 创建成绩表
CREATE TABLE IF NOT EXISTS scores (
  score_id INT PRIMARY KEY AUTO_INCREMENT,
  user_id INT NOT NULL,
  course_id INT,
  assignment_id INT,
  quiz_id INT,
  score INT NOT NULL,
  total_score INT NOT NULL,
  percentage DECIMAL(5,2),
  test_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  remarks TEXT,
  FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
  FOREIGN KEY (course_id) REFERENCES courses(course_id) ON DELETE SET NULL,
  FOREIGN KEY (assignment_id) REFERENCES assignments(assignment_id) ON DELETE SET NULL
);

-- 创建词汇表
CREATE TABLE IF NOT EXISTS vocabulary (
  vocab_id INT PRIMARY KEY AUTO_INCREMENT,
  word VARCHAR(100) NOT NULL,
  phonetic VARCHAR(200),
  part_of_speech VARCHAR(50),
  chinese_meaning VARCHAR(500),
  english_definition TEXT,
  example_sentence TEXT,
  example_translation TEXT,
  audio_url VARCHAR(500),
  image_url VARCHAR(500),
  difficulty_level VARCHAR(20),
  category VARCHAR(100),
  frequency INT DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- 创建用户词汇学习记录表
CREATE TABLE IF NOT EXISTS user_vocabulary (
  id INT PRIMARY KEY AUTO_INCREMENT,
  user_id INT NOT NULL,
  vocab_id INT NOT NULL,
  mastery_level INT DEFAULT 0 COMMENT '0-5',
  review_count INT DEFAULT 0,
  last_review_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  next_review_date TIMESTAMP,
  is_favorited TINYINT DEFAULT 0,
  notes TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
  FOREIGN KEY (vocab_id) REFERENCES vocabulary(vocab_id) ON DELETE CASCADE,
  UNIQUE KEY unique_user_vocab (user_id, vocab_id)
);

-- 创建消息表
CREATE TABLE IF NOT EXISTS messages (
  message_id INT PRIMARY KEY AUTO_INCREMENT,
  user_id INT NOT NULL,
  title VARCHAR(200) NOT NULL,
  content TEXT,
  message_type VARCHAR(50),
  is_read TINYINT DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);