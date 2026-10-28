-- 创建存储过程
USE english_tutoring_system;

-- 1. 用户登录存储过程
DELIMITER //
CREATE PROCEDURE proc_user_login(
    IN p_username VARCHAR(50),
    IN p_password VARCHAR(255),
    IN p_user_type VARCHAR(20),
    OUT p_result INT,
    OUT p_message VARCHAR(255),
    OUT p_user_id INT
)
BEGIN
    DECLARE v_password VARCHAR(255);
    DECLARE v_status VARCHAR(20);
    DECLARE v_actual_type VARCHAR(20);
    
    SELECT password, status, user_type INTO v_password, v_status, v_actual_type
    FROM users
    WHERE username = p_username;
    
    IF v_password IS NULL THEN
        SET p_result = 0;
        SET p_message = '用户不存在';
        SET p_user_id = NULL;
    ELSEIF v_status != 'active' THEN
        SET p_result = 0;
        SET p_message = '账号已被禁用';
        SET p_user_id = NULL;
    ELSEIF v_actual_type != p_user_type THEN
        SET p_result = 0;
        SET p_message = '用户类型不匹配';
        SET p_user_id = NULL;
    ELSEIF v_password = p_password THEN
        UPDATE users SET last_login_time = NOW() WHERE username = p_username;
        SELECT user_id INTO p_user_id FROM users WHERE username = p_username;
        SET p_result = 1;
        SET p_message = '登录成功';
    ELSE
        SET p_result = 0;
        SET p_message = '密码错误';
        SET p_user_id = NULL;
    END IF;
END //
DELIMITER ;

-- 2. 用户注册存储过程
DELIMITER //
CREATE PROCEDURE proc_user_register(
    IN p_username VARCHAR(50),
    IN p_password VARCHAR(255),
    IN p_phone VARCHAR(20),
    IN p_email VARCHAR(100),
    IN p_real_name VARCHAR(50),
    IN p_user_type VARCHAR(20),
    OUT p_result INT,
    OUT p_message VARCHAR(255),
    OUT p_user_id INT
)
BEGIN
    DECLARE v_count INT;
    
    -- 检查用户名是否已存在
    SELECT COUNT(*) INTO v_count FROM users WHERE username = p_username;
    IF v_count > 0 THEN
        SET p_result = 0;
        SET p_message = '用户名已存在';
        SET p_user_id = NULL;
    ELSE
        -- 插入新用户
        INSERT INTO users (username, password, phone, email, real_name, user_type, status)
        VALUES (p_username, p_password, p_phone, p_email, p_real_name, p_user_type, 'active');
        
        SET p_user_id = LAST_INSERT_ID();
        SET p_result = 1;
        SET p_message = '注册成功';
        
        -- 如果是学生，创建学生记录
        IF p_user_type = 'student' THEN
            INSERT INTO students (user_id, english_level)
            VALUES (p_user_id, 'beginner');
        END IF;
    END IF;
END //
DELIMITER ;

-- 3. 更新学习记录存储过程
DELIMITER //
CREATE PROCEDURE proc_update_study_record(
    IN p_user_id INT,
    IN p_lesson_id INT,
    IN p_course_id INT,
    IN p_study_duration INT,
    IN p_progress INT,
    IN p_last_position INT
)
BEGIN
    DECLARE v_record_id INT;
    DECLARE v_is_completed BOOLEAN;
    
    -- 查找是否已有学习记录
    SELECT record_id, is_completed INTO v_record_id, v_is_completed
    FROM study_records
    WHERE user_id = p_user_id AND lesson_id = p_lesson_id;
    
    IF v_record_id IS NULL THEN
        -- 创建新的学习记录
        INSERT INTO study_records (
            user_id, lesson_id, course_id, study_duration, 
            progress, is_completed, last_position, study_count
        ) VALUES (
            p_user_id, p_lesson_id, p_course_id, p_study_duration,
            p_progress, (p_progress >= 100), p_last_position, 1
        );
    ELSE
        -- 更新现有学习记录
        UPDATE study_records SET
            study_duration = study_duration + p_study_duration,
            progress = p_progress,
            is_completed = (p_progress >= 100),
            last_position = p_last_position,
            study_count = study_count + 1,
            updated_at = NOW()
        WHERE record_id = v_record_id;
    END IF;
END //
DELIMITER ;

-- 4. 提交作业存储过程
DELIMITER //
CREATE PROCEDURE proc_submit_assignment(
    IN p_assignment_id INT,
    IN p_user_id INT,
    IN p_content TEXT,
    IN p_attachment_url VARCHAR(255),
    OUT p_result INT,
    OUT p_message VARCHAR(255)
)
BEGIN
    DECLARE v_due_date DATETIME;
    DECLARE v_status VARCHAR(20);
    
    -- 获取作业截止日期和状态
    SELECT due_date, status INTO v_due_date, v_status
    FROM assignments
    WHERE assignment_id = p_assignment_id;
    
    IF v_status != 'published' THEN
        SET p_result = 0;
        SET p_message = '作业已关闭，无法提交';
    ELSEIF v_due_date < NOW() THEN
        -- 逾期提交
        INSERT INTO assignment_submissions (
            assignment_id, user_id, content, attachment_url, status
        ) VALUES (
            p_assignment_id, p_user_id, p_content, p_attachment_url, 'late'
        );
        SET p_result = 1;
        SET p_message = '作业已逾期提交';
    ELSE
        -- 正常提交
        INSERT INTO assignment_submissions (
            assignment_id, user_id, content, attachment_url, status
        ) VALUES (
            p_assignment_id, p_user_id, p_content, p_attachment_url, 'submitted'
        );
        SET p_result = 1;
        SET p_message = '作业提交成功';
    END IF;
END //
DELIMITER ;

-- 5. 批改作业存储过程
DELIMITER //
CREATE PROCEDURE proc_grade_assignment(
    IN p_submission_id INT,
    IN p_score INT,
    IN p_feedback TEXT,
    OUT p_result INT,
    OUT p_message VARCHAR(255)
)
BEGIN
    DECLARE v_assignment_id INT;
    DECLARE v_user_id INT;
    DECLARE v_course_id INT;
    DECLARE v_total_score INT;
    
    -- 获取提交信息
    SELECT assignment_id, user_id INTO v_assignment_id, v_user_id
    FROM assignment_submissions
    WHERE submission_id = p_submission_id;
    
    -- 获取作业总分和课程ID
    SELECT total_score, course_id INTO v_total_score, v_course_id
    FROM assignments
    WHERE assignment_id = v_assignment_id;
    
    -- 验证分数
    IF p_score < 0 OR p_score > v_total_score THEN
        SET p_result = 0;
        SET p_message = '分数超出范围';
    ELSE
        -- 更新提交记录
        UPDATE assignment_submissions SET
            score = p_score,
            feedback = p_feedback,
            graded_at = NOW(),
            status = 'graded'
        WHERE submission_id = p_submission_id;
        
        -- 插入成绩记录
        INSERT INTO scores (
            user_id, course_id, assignment_id, score, 
            total_score, percentage
        ) VALUES (
            v_user_id, v_course_id, v_assignment_id, p_score,
            v_total_score, (p_score / v_total_score) * 100
        );
        
        SET p_result = 1;
        SET p_message = '批改完成';
    END IF;
END //
DELIMITER ;

-- 6. 更新词汇掌握程度存储过程
DELIMITER //
CREATE PROCEDURE proc_update_vocabulary_mastery(
    IN p_user_id INT,
    IN p_vocab_id INT,
    IN p_is_correct BOOLEAN,
    OUT p_result INT,
    OUT p_message VARCHAR(255)
)
BEGIN
    -- 所有变量统一在块最顶部声明，禁止中途DECLARE
    DECLARE v_mastery_level INT;
    DECLARE v_review_count INT;
    DECLARE v_next_review_days INT;
    
    -- 获取当前掌握程度
    SELECT mastery_level, review_count INTO v_mastery_level, v_review_count
    FROM user_vocabulary
    WHERE user_id = p_user_id AND vocab_id = p_vocab_id;
    
    IF v_mastery_level IS NULL THEN
        -- 首次学习
        INSERT INTO user_vocabulary (
            user_id, vocab_id, mastery_level, review_count,
            last_review_date, next_review_date
        ) VALUES (
            p_user_id, p_vocab_id, 
            IF(p_is_correct, 1, 0), 1,
            CURDATE(), DATE_ADD(CURDATE(), INTERVAL 1 DAY)
        );
        SET p_result = 1;
        SET p_message = '已添加新词汇';
    ELSE
        -- 更新掌握程度
        IF p_is_correct THEN
            -- 回答正确，提升掌握程度
            SET v_mastery_level = LEAST(v_mastery_level + 1, 5);
        ELSE
            -- 回答错误，降低掌握程度
            SET v_mastery_level = GREATEST(v_mastery_level - 1, 0);
        END IF;
        
        SET v_review_count = v_review_count + 1;
        
        -- 根据掌握程度计算下次复习时间（变量已提前声明，直接赋值）
        SET v_next_review_days = CASE v_mastery_level
            WHEN 0 THEN 1
            WHEN 1 THEN 2
            WHEN 2 THEN 4
            WHEN 3 THEN 7
            WHEN 4 THEN 14
            WHEN 5 THEN 30
            ELSE 1
        END;
        
        UPDATE user_vocabulary SET
            mastery_level = v_mastery_level,
            review_count = v_review_count,
            last_review_date = CURDATE(),
            next_review_date = DATE_ADD(CURDATE(), INTERVAL v_next_review_days DAY),
            updated_at = NOW()
        WHERE user_id = p_user_id AND vocab_id = p_vocab_id;
        
        SET p_result = 1;
        SET p_message = '词汇掌握程度已更新';
    END IF;
END //
DELIMITER ;S

-- 7. 获取学生学习统计存储过程
DELIMITER //
CREATE PROCEDURE proc_get_student_stats(
    IN p_user_id INT,
    OUT p_total_hours DECIMAL(10,2),
    OUT p_completed_lessons INT,
    OUT p_avg_score DECIMAL(5,2),
    OUT p_total_words INT,
    OUT p_mastered_words INT
)
BEGIN
    -- 总学习时长
    SELECT ROUND(SUM(study_duration) / 3600, 2) INTO p_total_hours
    FROM study_records
    WHERE user_id = p_user_id;
    
    -- 完成的课时数
    SELECT COUNT(DISTINCT lesson_id) INTO p_completed_lessons
    FROM study_records
    WHERE user_id = p_user_id AND is_completed = TRUE;
    
    -- 平均分数
    SELECT AVG(percentage) INTO p_avg_score
    FROM scores
    WHERE user_id = p_user_id;
    
    -- 总词汇数
    SELECT COUNT(*) INTO p_total_words
    FROM user_vocabulary
    WHERE user_id = p_user_id;
    
    -- 掌握的词汇数（掌握程度>=3）
    SELECT COUNT(*) INTO p_mastered_words
    FROM user_vocabulary
    WHERE user_id = p_user_id AND mastery_level >= 3;
END //
DELIMITER ;

-- 8. 课程报名存储过程
DELIMITER //
CREATE PROCEDURE proc_enroll_course(
    IN p_user_id INT,
    IN p_course_id INT,
    OUT p_result INT,
    OUT p_message VARCHAR(255)
)
BEGIN
    DECLARE v_enroll_count INT;
    DECLARE v_is_free BOOLEAN;
    DECLARE v_status VARCHAR(20);
    
    -- 获取课程信息
    SELECT enroll_count, is_free, status INTO v_enroll_count, v_is_free, v_status
    FROM courses
    WHERE course_id = p_course_id;
    
    IF v_status != 'published' THEN
        SET p_result = 0;
        SET p_message = '课程未发布';
    ELSEIF v_is_free = FALSE AND v_enroll_count >= 100 THEN
        SET p_result = 0;
        SET p_message = '课程已满员';
    ELSE
        -- 增加报名人数
        UPDATE courses SET enroll_count = enroll_count + 1
        WHERE course_id = p_course_id;
        
        SET p_result = 1;
        SET p_message = '报名成功';
    END IF;
END //
DELIMITER ;

-- 9. 发送系统消息存储过程
DELIMITER //
CREATE PROCEDURE proc_send_system_message(
    IN p_user_id INT,
    IN p_title VARCHAR(100),
    IN p_content TEXT,
    IN p_message_type VARCHAR(20),
    IN p_related_id INT
)
BEGIN
    INSERT INTO system_messages (
        user_id, title, content, message_type, related_id
    ) VALUES (
        p_user_id, p_title, p_content, p_message_type, p_related_id
    );
END //
DELIMITER ;

-- 10. 获取推荐课程存储过程
DELIMITER //
CREATE PROCEDURE proc_get_recommended_courses(
    IN p_user_id INT,
    IN p_limit INT
)
BEGIN
    DECLARE v_english_level VARCHAR(20);
    
    -- 获取学生英语水平
    SELECT english_level INTO v_english_level
    FROM students
    WHERE user_id = p_user_id;
    
    -- 返回推荐课程
    SELECT c.*
    FROM courses c
    WHERE c.status = 'published'
    AND (c.level = v_english_level OR c.level = 'beginner')
    ORDER BY c.rating DESC, c.enroll_count DESC
    LIMIT p_limit;
END //
DELIMITER ;