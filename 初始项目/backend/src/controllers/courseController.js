const db = require('../config/database');

class CourseController {
  async getCourses(req, res) {
    try {
      const { category_id, level, page = 1, limit = 12 } = req.query;
      const offset = (page - 1) * limit;

      let query = `
        SELECT c.*, u.real_name as teacher_name, cat.category_name
        FROM courses c
        LEFT JOIN teachers t ON c.teacher_id = t.teacher_id
        LEFT JOIN users u ON t.user_id = u.user_id
        LEFT JOIN categories cat ON c.category_id = cat.category_id
        WHERE c.status = 'published'
      `;
      const params = [];

      if (category_id) {
        query += ' AND c.category_id = ?';
        params.push(category_id);
      }

      if (level) {
        query += ' AND c.level = ?';
        params.push(level);
      }

      query += ' ORDER BY c.created_at DESC LIMIT ? OFFSET ?';
      params.push(parseInt(limit), parseInt(offset));

      const [courses] = await db.query(query, params);

      // 获取总数
      let countQuery = 'SELECT COUNT(*) as total FROM courses WHERE status = "published"';
      const countParams = [];

      if (category_id) {
        countQuery += ' AND category_id = ?';
        countParams.push(category_id);
      }

      if (level) {
        countQuery += ' AND level = ?';
        countParams.push(level);
      }

      const [countResult] = await db.query(countQuery, countParams);

      res.json({
        courses,
        pagination: {
          current_page: parseInt(page),
          total_pages: Math.ceil(countResult[0].total / limit),
          total_items: countResult[0].total,
          items_per_page: parseInt(limit)
        }
      });
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  }

  async getCourseDetail(req, res) {
    try {
      const courseId = req.params.id;

      const [courses] = await db.query(
        `SELECT c.*, u.real_name as teacher_name, t.bio as teacher_bio,
                cat.category_name
         FROM courses c
         LEFT JOIN teachers t ON c.teacher_id = t.teacher_id
         LEFT JOIN users u ON t.user_id = u.user_id
         LEFT JOIN categories cat ON c.category_id = cat.category_id
         WHERE c.course_id = ?`,
        [courseId]
      );

      if (courses.length === 0) {
        return res.status(404).json({ error: 'Course not found' });
      }

      // 增加浏览次数
      await db.query(
        'UPDATE courses SET view_count = view_count + 1 WHERE course_id = ?',
        [courseId]
      );

      res.json({ course: courses[0] });
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  }

  async getRecommendedCourses(req, res) {
    try {
      const userId = req.user.user_id;
      const limit = req.query.limit || 6;

      // 根据学生英语水平推荐课程
      const [studentLevel] = await db.query(
        'SELECT english_level FROM students WHERE user_id = ?',
        [userId]
      );

      let levelFilter = '';
      const params = [parseInt(limit)];

      if (studentLevel.length > 0) {
        levelFilter = 'AND level = ?';
        params.unshift(studentLevel[0].english_level);
      }

      const [courses] = await db.query(
        `SELECT c.*, u.real_name as teacher_name
         FROM courses c
         LEFT JOIN teachers t ON c.teacher_id = t.teacher_id
         LEFT JOIN users u ON t.user_id = u.user_id
         WHERE c.status = 'published' AND c.rating >= 4.0 ${levelFilter}
         ORDER BY c.rating DESC, c.enroll_count DESC
         LIMIT ?`,
        params
      );

      res.json({ courses });
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  }

  async getMyCourses(req, res) {
    try {
      const userId = req.user.user_id;

      const [courses] = await db.query(
        `SELECT c.*, sr.progress, sr.is_completed, sr.last_study_date
         FROM enrollments e
         JOIN courses c ON e.course_id = c.course_id
         LEFT JOIN study_records sr ON e.course_id = sr.course_id AND sr.user_id = e.user_id
         WHERE e.user_id = ?
         ORDER BY e.enrolled_at DESC`,
        [userId]
      );

      res.json({ courses });
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  }

  async enrollCourse(req, res) {
    try {
      const userId = req.user.user_id;
      const courseId = req.params.id;

      // 检查是否已报名
      const [existing] = await db.query(
        'SELECT enrollment_id FROM enrollments WHERE user_id = ? AND course_id = ?',
        [userId, courseId]
      );

      if (existing.length > 0) {
        return res.status(400).json({ error: 'Already enrolled' });
      }

      // 报名课程
      await db.query(
        'INSERT INTO enrollments (user_id, course_id, enrolled_at) VALUES (?, ?, NOW())',
        [userId, courseId]
      );

      // 增加课程报名人数
      await db.query(
        'UPDATE courses SET enroll_count = enroll_count + 1 WHERE course_id = ?',
        [courseId]
      );

      res.status(201).json({ message: 'Enrolled successfully' });
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  }
}

module.exports = new CourseController();