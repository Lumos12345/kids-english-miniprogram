const db = require('../config/database');

class StudyController {
  async getStats(req, res) {
    try {
      const userId = req.user.user_id;

      // 获取学习统计
      const [stats] = await db.query(`
        SELECT 
          COUNT(DISTINCT sr.course_id) as courses_studied,
          SUM(sr.study_duration) as total_study_duration,
          AVG(sr.progress) as avg_progress,
          COUNT(CASE WHEN sr.is_completed = 1 THEN 1 END) as completed_lessons
        FROM study_records sr
        WHERE sr.user_id = ?
      `, [userId]);

      // 获取本周学习时间
      const [weekStats] = await db.query(`
        SELECT SUM(study_duration) as week_study_duration
        FROM study_records
        WHERE user_id = ? 
        AND last_study_date >= DATE_SUB(NOW(), INTERVAL 7 DAY)
      `, [userId]);

      // 获取学习连续天数
      const [streak] = await db.query(`
        SELECT COUNT(DISTINCT DATE(last_study_date)) as streak
        FROM study_records
        WHERE user_id = ?
        AND last_study_date >= DATE_SUB(NOW(), INTERVAL 30 DAY)
      `, [userId]);

      res.json({
        stats: {
          courses_studied: stats[0].courses_studied || 0,
          total_study_duration: stats[0].total_study_duration || 0,
          avg_progress: Math.round(stats[0].avg_progress || 0),
          completed_lessons: stats[0].completed_lessons || 0,
          week_study_duration: weekStats[0].week_study_duration || 0,
          streak: streak[0].streak || 0
        }
      });
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  }

  async getCurrentStudy(req, res) {
    try {
      const userId = req.user.user_id;

      // 获取最近学习的课程
      const [currentStudy] = await db.query(`
        SELECT sr.*, c.course_name, c.cover_image, u.real_name as teacher_name
        FROM study_records sr
        JOIN courses c ON sr.course_id = c.course_id
        LEFT JOIN teachers t ON c.teacher_id = t.teacher_id
        LEFT JOIN users u ON t.user_id = u.user_id
        WHERE sr.user_id = ?
        ORDER BY sr.last_study_date DESC
        LIMIT 1
      `, [userId]);

      if (currentStudy.length === 0) {
        return res.json({ current_study: null });
      }

      res.json({ current_study: currentStudy[0] });
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  }

  async recordStudy(req, res) {
    try {
      const userId = req.user.user_id;
      const { lesson_id, course_id, study_duration, progress, last_position } = req.body;

      // 检查是否已有学习记录
      const [existing] = await db.query(
        'SELECT record_id, study_count, progress FROM study_records WHERE user_id = ? AND lesson_id = ?',
        [userId, lesson_id]
      );

      if (existing.length > 0) {
        // 更新现有记录
        const is_completed = progress >= 100 ? 1 : existing[0].is_completed;

        await db.query(
          `UPDATE study_records 
           SET study_duration = study_duration + ?, 
               progress = ?,
               last_position = ?,
               last_study_date = NOW(),
               study_count = study_count + 1,
               is_completed = ?
           WHERE record_id = ?`,
          [study_duration, progress, last_position, is_completed, existing[0].record_id]
        );
      } else {
        // 创建新记录
        const is_completed = progress >= 100 ? 1 : 0;

        await db.query(
          `INSERT INTO study_records 
           (user_id, lesson_id, course_id, study_duration, progress, last_position, last_study_date, study_count, is_completed)
           VALUES (?, ?, ?, ?, ?, ?, NOW(), 1, ?)`,
          [userId, lesson_id, course_id, study_duration, progress, last_position, is_completed]
        );
      }

      res.json({ message: 'Study recorded successfully' });
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  }

  async getProgress(req, res) {
    try {
      const userId = req.user.user_id;
      const courseId = req.params.courseId;

      const [progress] = await db.query(`
        SELECT 
          COUNT(*) as total_lessons,
          SUM(CASE WHEN is_completed = 1 THEN 1 ELSE 0 END) as completed_lessons,
          AVG(progress) as avg_progress
        FROM study_records
        WHERE user_id = ? AND course_id = ?
      `, [userId, courseId]);

      res.json({
        progress: {
          total_lessons: progress[0].total_lessons || 0,
          completed_lessons: progress[0].completed_lessons || 0,
          avg_progress: Math.round(progress[0].avg_progress || 0)
        }
      });
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  }
}

module.exports = new StudyController();