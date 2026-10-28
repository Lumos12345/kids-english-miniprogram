-- 创建索引
USE english_tutoring_system;

-- 用户表索引
CREATE INDEX idx_users_username ON users(username);
CREATE INDEX idx_users_phone ON users(phone);
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_type ON users(user_type);
CREATE INDEX idx_users_status ON users(status);

-- 学生信息表索引
CREATE INDEX idx_students_user_id ON students(user_id);
CREATE INDEX idx_students_parent_id ON students(parent_id);
CREATE INDEX idx_students_level ON students(english_level);

-- 教师信息表索引
CREATE INDEX idx_teachers_user_id ON teachers(user_id);
CREATE INDEX idx_teachers_rating ON teachers(rating);

-- 课程表索引
CREATE INDEX idx_courses_category ON courses(category_id);
CREATE INDEX idx_courses_teacher ON courses(teacher_id);
CREATE INDEX idx_courses_level ON courses(level);
CREATE INDEX idx_courses_status ON courses(status);
CREATE INDEX idx_courses_rating ON courses(rating);

-- 课程章节表索引
CREATE INDEX idx_chapters_course ON course_chapters(course_id);

-- 课时表索引
CREATE INDEX idx_lessons_chapter ON lessons(chapter_id);

-- 学习记录表索引
CREATE INDEX idx_records_user ON study_records(user_id);
CREATE INDEX idx_records_lesson ON study_records(lesson_id);
CREATE INDEX idx_records_course ON study_records(course_id);
CREATE INDEX idx_records_completed ON study_records(is_completed);

-- 作业表索引
CREATE INDEX idx_assignments_course ON assignments(course_id);
CREATE INDEX idx_assignments_lesson ON assignments(lesson_id);
CREATE INDEX idx_assignments_teacher ON assignments(teacher_id);
CREATE INDEX idx_assignments_status ON assignments(status);

-- 作业提交表索引
CREATE INDEX idx_submissions_assignment ON assignment_submissions(assignment_id);
CREATE INDEX idx_submissions_user ON assignment_submissions(user_id);
CREATE INDEX idx_submissions_status ON assignment_submissions(status);

-- 成绩表索引
CREATE INDEX idx_scores_user ON scores(user_id);
CREATE INDEX idx_scores_course ON scores(course_id);

-- 测验表索引
CREATE INDEX idx_quizzes_course ON quizzes(course_id);
CREATE INDEX idx_quizzes_status ON quizzes(status);

-- 测验题目表索引
CREATE INDEX idx_questions_quiz ON quiz_questions(quiz_id);

-- 测验答案表索引
CREATE INDEX idx_answers_quiz ON quiz_answers(quiz_id);
CREATE INDEX idx_answers_user ON quiz_answers(user_id);
CREATE INDEX idx_answers_question ON quiz_answers(question_id);

-- 学习资源表索引
CREATE INDEX idx_resources_type ON study_resources(resource_type);
CREATE INDEX idx_resources_category ON study_resources(category);
CREATE INDEX idx_resources_uploader ON study_resources(uploader_id);
CREATE INDEX idx_resources_status ON study_resources(status);

-- 学习计划表索引
CREATE INDEX idx_plans_user ON study_plans(user_id);
CREATE INDEX idx_plans_status ON study_plans(status);

-- 系统消息表索引
CREATE INDEX idx_messages_user ON system_messages(user_id);
CREATE INDEX idx_messages_type ON system_messages(message_type);
CREATE INDEX idx_messages_read ON system_messages(is_read);

-- 反馈表索引
CREATE INDEX idx_feedback_user ON feedback(user_id);
CREATE INDEX idx_feedback_type ON feedback(feedback_type);
CREATE INDEX idx_feedback_status ON feedback(status);

-- 词汇表索引
CREATE INDEX idx_vocabulary_word ON vocabulary(word);
CREATE INDEX idx_vocabulary_level ON vocabulary(difficulty_level);
CREATE INDEX idx_vocabulary_category ON vocabulary(category);
CREATE INDEX idx_vocabulary_frequency ON vocabulary(frequency);

-- 用户词汇学习记录表索引
CREATE INDEX idx_user_vocab_user ON user_vocabulary(user_id);
CREATE INDEX idx_user_vocab_vocab ON user_vocabulary(vocab_id);
CREATE INDEX idx_user_vocab_mastery ON user_vocabulary(mastery_level);
CREATE INDEX idx_user_vocab_next_review ON user_vocabulary(next_review_date);