-- 创建视图
USE english_tutoring_system;

-- 1. 用户详细信息视图
CREATE OR REPLACE VIEW view_user_details AS
SELECT 
    u.user_id,
    u.username,
    u.real_name,
    u.phone,
    u.email,
    u.avatar,
    u.gender,
    u.birth_date,
    u.user_type,
    u.status,
    u.last_login_time,
    s.student_id,
    s.parent_id,
    s.grade_level,
    s.school_name,
    s.english_level,
    t.teacher_id,
    t.qualification,
    t.experience_years,
    t.specialization,
    t.rating AS teacher_rating
FROM users u
LEFT JOIN students s ON u.user_id = s.user_id
LEFT JOIN teachers t ON u.user_id = t.user_id;

-- 2. 课程详细信息视图
CREATE OR REPLACE VIEW view_course_details AS
SELECT 
    c.course_id,
    c.course_name,
    c.description,
    c.cover_image,
    c.level,
    c.target_age,
    c.duration,
    c.total_lessons,
    c.price,
    c.is_free,
    c.status,
    c.view_count,
    c.enroll_count,
    c.rating,
    c.created_at,
    cat.category_name,
    cat.description AS category_description,
    u.real_name AS teacher_name,
    u.avatar AS teacher_avatar,
    t.rating AS teacher_rating,
    t.experience_years,
    COUNT(DISTINCT ch.chapter_id) AS chapter_count
FROM courses c
LEFT JOIN course_categories cat ON c.category_id = cat.category_id
LEFT JOIN users u ON c.teacher_id = u.user_id
LEFT JOIN teachers t ON u.user_id = t.user_id
LEFT JOIN course_chapters ch ON c.course_id = ch.course_id
GROUP BY c.course_id;

-- 3. 学生学习进度视图
CREATE OR REPLACE VIEW view_student_progress AS
SELECT 
    u.user_id,
    u.real_name AS student_name,
    u.avatar AS student_avatar,
    c.course_id,
    c.course_name,
    c.level,
    c.total_lessons,
    COUNT(DISTINCT sr.lesson_id) AS completed_lessons,
    SUM(sr.study_duration) AS total_study_duration,
    AVG(sr.progress) AS avg_progress,
    MAX(sr.updated_at) AS last_study_time
FROM users u
JOIN students s ON u.user_id = s.user_id
JOIN study_records sr ON u.user_id = sr.user_id
JOIN courses c ON sr.course_id = c.course_id
WHERE u.user_type = 'student'
GROUP BY u.user_id, c.course_id;

-- 4. 课程作业统计视图
CREATE OR REPLACE VIEW view_assignment_stats AS
SELECT 
    c.course_id,
    c.course_name,
    COUNT(a.assignment_id) AS total_assignments,
    COUNT(CASE WHEN a.status = 'published' THEN 1 END) AS published_assignments,
    COUNT(DISTINCT asub.user_id) AS student_submissions,
    AVG(asub.score) AS avg_score,
    MAX(asub.score) AS max_score,
    MIN(asub.score) AS min_score
FROM courses c
LEFT JOIN assignments a ON c.course_id = a.course_id
LEFT JOIN assignment_submissions asub ON a.assignment_id = asub.assignment_id
GROUP BY c.course_id;

-- 5. 学生成绩统计视图
CREATE OR REPLACE VIEW view_student_scores AS
SELECT 
    u.user_id,
    u.real_name AS student_name,
    c.course_id,
    c.course_name,
    COUNT(sc.score_id) AS test_count,
    AVG(sc.percentage) AS avg_percentage,
    MAX(sc.percentage) AS max_percentage,
    MIN(sc.percentage) AS min_percentage,
    SUM(sc.score) AS total_score,
    SUM(sc.total_score) AS total_possible_score
FROM users u
JOIN students s ON u.user_id = s.user_id
JOIN scores sc ON u.user_id = sc.user_id
JOIN courses c ON sc.course_id = c.course_id
WHERE u.user_type = 'student'
GROUP BY u.user_id, c.course_id;

-- 6. 教师教学统计视图
CREATE OR REPLACE VIEW view_teacher_stats AS
SELECT 
    u.user_id,
    u.real_name AS teacher_name,
    t.qualification,
    t.rating AS teacher_rating,
    COUNT(DISTINCT c.course_id) AS total_courses,
    SUM(c.enroll_count) AS total_students,
    AVG(c.rating) AS avg_course_rating,
    COUNT(DISTINCT a.assignment_id) AS total_assignments,
    COUNT(DISTINCT asub.submission_id) AS total_submissions
FROM users u
JOIN teachers t ON u.user_id = t.user_id
LEFT JOIN courses c ON u.user_id = c.teacher_id
LEFT JOIN assignments a ON u.user_id = a.teacher_id
LEFT JOIN assignment_submissions asub ON a.assignment_id = asub.assignment_id
WHERE u.user_type = 'teacher'
GROUP BY u.user_id;

-- 7. 热门课程视图
CREATE OR REPLACE VIEW view_popular_courses AS
SELECT 
    c.course_id,
    c.course_name,
    c.cover_image,
    c.level,
    c.target_age,
    c.price,
    c.is_free,
    c.rating,
    c.enroll_count,
    c.view_count,
    cat.category_name,
    u.real_name AS teacher_name,
    (c.enroll_count * 0.4 + c.view_count * 0.3 + c.rating * 10 * 0.3) AS popularity_score
FROM courses c
LEFT JOIN course_categories cat ON c.category_id = cat.category_id
LEFT JOIN users u ON c.teacher_id = u.user_id
WHERE c.status = 'published'
ORDER BY popularity_score DESC;

-- 8. 用户词汇掌握情况视图
CREATE OR REPLACE VIEW view_user_vocabulary_mastery AS
SELECT 
    u.user_id,
    u.real_name,
    uv.vocab_id,
    v.word,
    v.phonetic,
    v.chinese_meaning,
    v.difficulty_level,
    uv.mastery_level,
    uv.review_count,
    uv.last_review_date,
    uv.next_review_date,
    uv.is_favorited
FROM users u
JOIN user_vocabulary uv ON u.user_id = uv.user_id
JOIN vocabulary v ON uv.vocab_id = v.vocab_id
WHERE u.user_type = 'student'
ORDER BY uv.mastery_level DESC, uv.next_review_date ASC;

-- 9. 待办作业视图
CREATE OR REPLACE VIEW view_pending_assignments AS
SELECT 
    u.user_id,
    u.real_name AS student_name,
    a.assignment_id,
    a.title,
    a.description,
    a.due_date,
    a.total_score,
    c.course_name,
    ch.chapter_name,
    l.lesson_name,
    CASE 
        WHEN asub.submission_id IS NULL THEN '未提交'
        ELSE '已提交'
    END AS submission_status,
    DATEDIFF(a.due_date, CURRENT_DATE) AS days_remaining
FROM users u
JOIN students s ON u.user_id = s.user_id
JOIN courses c ON c.course_id = c.course_id
JOIN assignments a ON c.course_id = a.course_id
LEFT JOIN course_chapters ch ON a.lesson_id IN (
    SELECT chapter_id FROM lessons WHERE lesson_id = a.lesson_id
)
LEFT JOIN lessons l ON a.lesson_id = l.lesson_id
LEFT JOIN assignment_submissions asub ON a.assignment_id = asub.assignment_id AND asub.user_id = u.user_id
WHERE u.user_type = 'student'
AND a.status = 'published'
AND a.due_date >= CURRENT_DATE
AND asub.submission_id IS NULL
ORDER BY a.due_date ASC;

-- 10. 学习排行榜视图
CREATE OR REPLACE VIEW view_study_leaderboard AS 
SELECT
    u.user_id,
    u.real_name AS student_name,
    u.avatar,
    s.grade_level,
    COUNT(DISTINCT sr.course_id) AS courses_enrolled,
    COUNT(DISTINCT CASE WHEN sr.is_completed = TRUE THEN sr.lesson_id END) AS lesson_finished,
    SUM(sr.study_duration) AS total_study_seconds,
    ROUND(SUM(sr.study_duration) / 3600, 2) AS total_study_hours,
    AVG(sr.progress) AS avg_progress,
    ROW_NUMBER() OVER (ORDER BY SUM(sr.study_duration) DESC) AS stu_rank
FROM users u
JOIN students s ON u.user_id = s.user_id
JOIN study_records sr ON u.user_id = sr.user_id
WHERE u.user_type = 'student'
GROUP BY u.user_id
ORDER BY total_study_seconds DESC;