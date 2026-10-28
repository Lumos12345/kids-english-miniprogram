-- 创建函数
USE english_tutoring_system;

-- 1. 计算学生平均分函数
DELIMITER //
CREATE FUNCTION func_calculate_avg_score(p_user_id INT) 
RETURNS DECIMAL(5,2)
DETERMINISTIC
BEGIN
    DECLARE v_avg_score DECIMAL(5,2);
    
    SELECT AVG(percentage) INTO v_avg_score
    FROM scores
    WHERE user_id = p_user_id;
    
    RETURN IFNULL(v_avg_score, 0);
END //
DELIMITER ;

-- 2. 计算课程完成率函数
DELIMITER //
CREATE FUNCTION func_calculate_course_completion(p_user_id INT, p_course_id INT) 
RETURNS DECIMAL(5,2)
DETERMINISTIC
BEGIN
    DECLARE v_total_lessons INT;
    DECLARE v_completed_lessons INT;
    DECLARE v_completion_rate DECIMAL(5,2);
    
    -- 获取课程总课时数
    SELECT COUNT(*) INTO v_total_lessons
    FROM lessons l
    JOIN course_chapters ch ON l.chapter_id = ch.chapter_id
    WHERE ch.course_id = p_course_id;
    
    -- 获取已完成课时数
    SELECT COUNT(DISTINCT sr.lesson_id) INTO v_completed_lessons
    FROM study_records sr
    WHERE sr.user_id = p_user_id 
    AND sr.course_id = p_course_id 
    AND sr.is_completed = TRUE;
    
    -- 计算完成率
    IF v_total_lessons > 0 THEN
        SET v_completion_rate = (v_completed_lessons / v_total_lessons) * 100;
    ELSE
        SET v_completion_rate = 0;
    END IF;
    
    RETURN v_completion_rate;
END //
DELIMITER ;

-- 3. 计算学习时长函数
DELIMITER //
CREATE FUNCTION func_calculate_study_hours(p_user_id INT) 
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE v_total_seconds INT;
    
    SELECT SUM(study_duration) INTO v_total_seconds
    FROM study_records
    WHERE user_id = p_user_id;
    
    RETURN IFNULL(ROUND(v_total_seconds / 3600, 2), 0);
END //
DELIMITER ;

-- 4. 获取词汇掌握数量函数
DELIMITER //
CREATE FUNCTION func_get_mastered_vocab_count(p_user_id INT, p_min_level INT) 
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE v_count INT;
    
    SELECT COUNT(*) INTO v_count
    FROM user_vocabulary
    WHERE user_id = p_user_id AND mastery_level >= p_min_level;
    
    RETURN IFNULL(v_count, 0);
END //
DELIMITER ;

-- 5. 计算下次复习日期函数
DELIMITER //
CREATE FUNCTION func_calculate_next_review(p_mastery_level INT) 
RETURNS DATE
DETERMINISTIC
BEGIN
    DECLARE v_days INT;
    
    SET v_days = CASE p_mastery_level
        WHEN 0 THEN 1
        WHEN 1 THEN 2
        WHEN 2 THEN 4
        WHEN 3 THEN 7
        WHEN 4 THEN 14
        WHEN 5 THEN 30
        ELSE 1
    END;
    
    RETURN DATE_ADD(CURDATE(), INTERVAL v_days DAY);
END //
DELIMITER ;

-- 6. 检查作业是否逾期函数
DELIMITER //
CREATE FUNCTION func_is_assignment_late(p_assignment_id INT) 
RETURNS BOOLEAN
DETERMINISTIC
BEGIN
    DECLARE v_due_date DATETIME;
    
    SELECT due_date INTO v_due_date
    FROM assignments
    WHERE assignment_id = p_assignment_id;
    
    RETURN NOW() > v_due_date;
END //
DELIMITER ;

-- 7. 计算课程评分函数
DELIMITER //
CREATE FUNCTION func_calculate_course_rating(p_course_id INT) 
RETURNS DECIMAL(3,2)
DETERMINISTIC
BEGIN
    DECLARE v_avg_rating DECIMAL(3,2);
    
    SELECT AVG(rating) INTO v_avg_rating
    FROM courses
    WHERE course_id = p_course_id;
    
    RETURN IFNULL(v_avg_rating, 0);
END //
DELIMITER ;

-- 8. 获取待处理作业数量函数
DELIMITER //
CREATE FUNCTION func_get_pending_assignments(p_user_id INT) 
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE v_count INT;
    
    SELECT COUNT(DISTINCT a.assignment_id) INTO v_count
    FROM assignments a
    LEFT JOIN assignment_submissions asub ON a.assignment_id = asub.assignment_id AND asub.user_id = p_user_id
    JOIN course_chapters ch ON a.course_id IN (
        SELECT DISTINCT course_id FROM study_records WHERE user_id = p_user_id
    )
    WHERE a.status = 'published'
    AND a.due_date >= CURDATE()
    AND asub.submission_id IS NULL;
    
    RETURN IFNULL(v_count, 0);
END //
DELIMITER ;

-- 9. 检查用户权限函数
DELIMITER //
CREATE FUNCTION func_check_user_permission(p_user_id INT, p_permission VARCHAR(50)) 
RETURNS BOOLEAN
DETERMINISTIC
BEGIN
    DECLARE v_user_type VARCHAR(20);
    DECLARE v_has_permission BOOLEAN;
    
    SELECT user_type INTO v_user_type
    FROM users
    WHERE user_id = p_user_id;
    
    SET v_has_permission = FALSE;
    
    -- 管理员拥有所有权限
    IF v_user_type = 'admin' THEN
        SET v_has_permission = TRUE;
    -- 教师权限
    ELSEIF v_user_type = 'teacher' THEN
        IF p_permission IN ('view_course', 'create_course', 'grade_assignment', 'view_student_progress') THEN
            SET v_has_permission = TRUE;
        END IF;
    -- 家长权限
    ELSEIF v_user_type = 'parent' THEN
        IF p_permission IN ('view_child_progress', 'view_child_scores') THEN
            SET v_has_permission = TRUE;
        END IF;
    -- 学生权限
    ELSEIF v_user_type = 'student' THEN
        IF p_permission IN ('view_course', 'study_lesson', 'submit_assignment', 'view_scores') THEN
            SET v_has_permission = TRUE;
        END IF;
    END IF;
    
    RETURN v_has_permission;
END //
DELIMITER ;

-- 10. 生成唯一订单号函数
DELIMITER //
CREATE FUNCTION func_generate_order_id() 
RETURNS VARCHAR(32)
DETERMINISTIC
BEGIN
    RETURN CONCAT('ORD', DATE_FORMAT(NOW(), '%Y%m%d'), LPAD(FLOOR(RAND() * 1000000), 6, '0'));
END //
DELIMITER ;

-- 11. 计算学生排名函数
DELIMITER //
CREATE FUNCTION func_calculate_student_rank(p_user_id INT) 
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE v_rank INT;
    DECLARE v_total_hours DECIMAL(10,2);
    
    -- 获取学生总学习时长
    SELECT func_calculate_study_hours(p_user_id) INTO v_total_hours;
    
    -- 计算排名
    SELECT COUNT(*) + 1 INTO v_rank
    FROM users u
    JOIN students s ON u.user_id = s.user_id
    WHERE u.user_type = 'student'
    AND func_calculate_study_hours(u.user_id) > v_total_hours;
    
    RETURN v_rank;
END //
DELIMITER ;

-- 12. 检查是否完成课程函数
DELIMITER //
CREATE FUNCTION func_is_course_completed(p_user_id INT, p_course_id INT) 
RETURNS BOOLEAN
DETERMINISTIC
BEGIN
    DECLARE v_completion_rate DECIMAL(5,2);
    
    SELECT func_calculate_course_completion(p_user_id, p_course_id) INTO v_completion_rate;
    
    RETURN v_completion_rate >= 100;
END //
DELIMITER ;

-- 13. 获取今日学习时长函数
DELIMITER //
CREATE FUNCTION func_get_today_study_hours(p_user_id INT) 
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE v_total_seconds INT;
    
    SELECT SUM(study_duration) INTO v_total_seconds
    FROM study_records
    WHERE user_id = p_user_id
    AND DATE(updated_at) = CURDATE();
    
    RETURN IFNULL(ROUND(v_total_seconds / 3600, 2), 0);
END //
DELIMITER ;

-- 14. 计算本周学习时长函数
DELIMITER //
CREATE FUNCTION func_get_weekly_study_hours(p_user_id INT) 
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE v_total_seconds INT;
    
    SELECT SUM(study_duration) INTO v_total_seconds
    FROM study_records
    WHERE user_id = p_user_id
    AND YEARWEEK(updated_at, 1) = YEARWEEK(CURDATE(), 1);
    
    RETURN IFNULL(ROUND(v_total_seconds / 3600, 2), 0);
END //
DELIMITER ;

-- 15. 获取推荐词汇函数
DELIMITER //
CREATE FUNCTION func_get_recommended_vocab(p_user_id INT, p_limit INT) 
RETURNS VARCHAR(1000)
DETERMINISTIC
BEGIN
    DECLARE v_result VARCHAR(1000);
    
    SELECT GROUP_CONCAT(word ORDER BY frequency DESC SEPARATOR ',') INTO v_result
    FROM vocabulary v
    WHERE v.vocab_id NOT IN (
        SELECT vocab_id FROM user_vocabulary WHERE user_id = p_user_id
    )
    ORDER BY v.frequency DESC
    LIMIT p_limit;
    
    RETURN IFNULL(v_result, '');
END //
DELIMITER ;