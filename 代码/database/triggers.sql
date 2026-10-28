-- 创建触发器
USE english_tutoring_system;

-- 1. 用户插入后触发器 - 自动创建学生/教师记录
DELIMITER //
CREATE TRIGGER trigger_after_user_insert
AFTER INSERT ON users
FOR EACH ROW
BEGIN
    IF NEW.user_type = 'student' THEN
        INSERT INTO students (user_id, english_level)
        VALUES (NEW.user_id, 'beginner');
    ELSEIF NEW.user_type = 'teacher' THEN
        INSERT INTO teachers (user_id, rating, total_students)
        VALUES (NEW.user_id, 5.00, 0);
    END IF;
END //
DELIMITER ;

-- 2. 用户删除前触发器 - 级联删除相关数据
DELIMITER //
CREATE TRIGGER trigger_before_user_delete
BEFORE DELETE ON users
FOR EACH ROW
BEGIN
    -- 删除学习记录
    DELETE FROM study_records WHERE user_id = OLD.user_id;
    
    -- 删除作业提交
    DELETE FROM assignment_submissions WHERE user_id = OLD.user_id;
    
    -- 删除成绩记录
    DELETE FROM scores WHERE user_id = OLD.user_id;
    
    -- 删除词汇学习记录
    DELETE FROM user_vocabulary WHERE user_id = OLD.user_id;
    
    -- 删除学习计划
    DELETE FROM study_plans WHERE user_id = OLD.user_id;
    
    -- 删除系统消息
    DELETE FROM system_messages WHERE user_id = OLD.user_id;
    
    -- 删除反馈
    DELETE FROM feedback WHERE user_id = OLD.user_id;
END //
DELIMITER ;

-- 3. 学习记录插入后触发器 - 更新课程浏览数
DELIMITER //
CREATE TRIGGER trigger_after_study_record_insert
AFTER INSERT ON study_records
FOR EACH ROW
BEGIN
    -- 更新课程浏览数
    UPDATE courses SET view_count = view_count + 1
    WHERE course_id = NEW.course_id;
END //
DELIMITER ;

-- 4. 学习记录更新触发器 - 检查课程完成情况
DELIMITER //
CREATE TRIGGER trigger_after_study_record_update
AFTER UPDATE ON study_records
FOR EACH ROW
BEGIN
    DECLARE v_total_lessons INT;
    DECLARE v_completed_lessons INT;
    
    -- 如果学习进度达到100%
    IF NEW.progress >= 100 AND OLD.progress < 100 THEN
        -- 更新完成状态
        UPDATE study_records SET is_completed = TRUE
        WHERE record_id = NEW.record_id;
        
        -- 检查是否完成整个课程
        SELECT COUNT(*) INTO v_total_lessons
        FROM lessons l
        JOIN course_chapters ch ON l.chapter_id = ch.chapter_id
        WHERE ch.course_id = NEW.course_id;
        
        SELECT COUNT(DISTINCT sr.lesson_id) INTO v_completed_lessons
        FROM study_records sr
        WHERE sr.user_id = NEW.user_id 
        AND sr.course_id = NEW.course_id 
        AND sr.is_completed = TRUE;
        
        -- 如果完成所有课时，发送完成消息
        IF v_completed_lessons >= v_total_lessons THEN
            INSERT INTO system_messages (user_id, title, content, message_type, related_id)
            VALUES (
                NEW.user_id, 
                '课程完成通知', 
                CONCAT('恭喜您完成了课程《', 
                    (SELECT course_name FROM courses WHERE course_id = NEW.course_id), 
                    '》！'),
                'course',
                NEW.course_id
            );
        END IF;
    END IF;
END //
DELIMITER ;

-- 5. 作业提交触发器 - 检查逾期情况
DELIMITER //
CREATE TRIGGER trigger_before_assignment_submit
BEFORE INSERT ON assignment_submissions
FOR EACH ROW
BEGIN
    DECLARE v_due_date DATETIME;
    
    -- 获取作业截止日期
    SELECT due_date INTO v_due_date
    FROM assignments
    WHERE assignment_id = NEW.assignment_id;
    
    -- 如果当前时间超过截止日期，设置为逾期状态
    IF NOW() > v_due_date THEN
        SET NEW.status = 'late';
    END IF;
END //
DELIMITER ;

-- 6. 作业批改触发器 - 更新学生平均分
DELIMITER //
CREATE TRIGGER trigger_after_assignment_grade
AFTER UPDATE ON assignment_submissions
FOR EACH ROW
BEGIN
    DECLARE v_avg_score DECIMAL(5,2);
    
    -- 计算学生平均分
    SELECT AVG(percentage) INTO v_avg_score
    FROM scores
    WHERE user_id = NEW.user_id;
    
    -- 发送成绩通知消息
    INSERT INTO system_messages (
        user_id, title, content, message_type, related_id
    ) VALUES (
        NEW.user_id,
        '作业批改完成',
        CONCAT('您的作业《', 
            (SELECT title FROM assignments WHERE assignment_id = NEW.assignment_id),
            '》已批改，得分：', NEW.score, '分'),
        'score',
        NEW.assignment_id
    );
END //
DELIMITER ;

-- 7. 课程发布触发器 - 通知相关学生
DELIMITER //
CREATE TRIGGER trigger_after_course_publish
AFTER UPDATE ON courses
FOR EACH ROW
BEGIN
    -- 如果课程从未发布变为已发布
    IF OLD.status != 'published' AND NEW.status = 'published' THEN
        -- 向所有学生发送新课程通知
        INSERT INTO system_messages (user_id, title, content, message_type, related_id)
        SELECT 
            u.user_id,
            '新课程发布',
            CONCAT('新课程《', NEW.course_name, '》已上线，快来学习吧！'),
            'course',
            NEW.course_id
        FROM users u
        WHERE u.user_type = 'student'
        AND u.status = 'active';
    END IF;
END //
DELIMITER ;

-- 8. 词汇学习触发器 - 更新复习计划
DELIMITER //
CREATE TRIGGER trigger_after_vocabulary_learn
AFTER INSERT ON user_vocabulary
FOR EACH ROW
BEGIN
    -- 设置初始复习时间为1天后
    UPDATE user_vocabulary
    SET next_review_date = DATE_ADD(CURDATE(), INTERVAL 1 DAY)
    WHERE id = NEW.id;
END //
DELIMITER ;

-- 9. 反馈提交触发器 - 通知管理员
DELIMITER //
CREATE TRIGGER trigger_after_feedback_submit
AFTER INSERT ON feedback
FOR EACH ROW
BEGIN
    -- 向管理员发送新反馈通知
    INSERT INTO system_messages (user_id, title, content, message_type, related_id)
    SELECT 
        user_id,
        CONCAT('新反馈：', NEW.title),
        CONCAT('用户', NEW.user_id, '提交了新反馈，请及时处理。'),
        'system',
        NEW.feedback_id
    FROM users
    WHERE user_type = 'admin'
    LIMIT 1;
END //
DELIMITER ;

-- 10. 学习计划完成触发器 - 发送完成通知
DELIMITER //
CREATE TRIGGER trigger_after_study_plan_complete
AFTER UPDATE ON study_plans
FOR EACH ROW
BEGIN
    -- 如果学习计划从未完成变为已完成
    IF OLD.status != 'completed' AND NEW.status = 'completed' THEN
        INSERT INTO system_messages (
            user_id, title, content, message_type, related_id
        ) VALUES (
            NEW.user_id,
            '学习计划完成',
            CONCAT('恭喜您完成了学习计划《', NEW.plan_name, '》！'),
            'system',
            NEW.plan_id
        );
    END IF;
END //
DELIMITER ;

-- 11. 测验答案提交触发器 - 计算得分
DELIMITER //
CREATE TRIGGER trigger_after_quiz_answer
AFTER INSERT ON quiz_answers
FOR EACH ROW
BEGIN
    DECLARE v_total_points INT;
    DECLARE v_earned_points INT;
    
    -- 获取测验总分
    SELECT SUM(points) INTO v_total_points
    FROM quiz_questions
    WHERE quiz_id = NEW.quiz_id;
    
    -- 获取已获得分数
    SELECT SUM(points_earned) INTO v_earned_points
    FROM quiz_answers
    WHERE quiz_id = NEW.quiz_id AND user_id = NEW.user_id;
    
    -- 如果所有题目都已回答，创建成绩记录
    IF (SELECT COUNT(*) FROM quiz_questions WHERE quiz_id = NEW.quiz_id) = 
       (SELECT COUNT(DISTINCT question_id) FROM quiz_answers WHERE quiz_id = NEW.quiz_id AND user_id = NEW.user_id) THEN
        INSERT INTO scores (
            user_id, course_id, quiz_id, score, total_score, percentage
        ) VALUES (
            NEW.user_id,
            (SELECT course_id FROM quizzes WHERE quiz_id = NEW.quiz_id),
            NEW.quiz_id,
            v_earned_points,
            v_total_points,
            (v_earned_points / v_total_points) * 100
        );
    END IF;
END //
DELIMITER ;

-- 12. 学习资源下载触发器 - 更新下载计数
DELIMITER //
CREATE TRIGGER trigger_after_resource_download
AFTER UPDATE ON study_resources
FOR EACH ROW
BEGIN
    -- 如果下载计数增加，更新最后下载时间
    IF NEW.download_count > OLD.download_count THEN
        UPDATE study_resources
        SET updated_at = NOW()
        WHERE resource_id = NEW.resource_id;
    END IF;
END //
DELIMITER ;