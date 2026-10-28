const db = require('../config/database');

class AssignmentController {
  async getAssignments(req, res) {
    try {
      const userId = req.user.user_id;
      const { status, page = 1, limit = 8 } = req.query;
      const offset = (page - 1) * limit;

      let query = `
        SELECT a.*, c.course_name, u.real_name as teacher_name,
               sa.submission_id, sa.submission_date, sa.score, sa.status as submission_status
        FROM assignments a
        JOIN courses c ON a.course_id = c.course_id
        LEFT JOIN teachers t ON a.teacher_id = t.teacher_id
        LEFT JOIN users u ON t.user_id = u.user_id
        LEFT JOIN submissions sa ON a.assignment_id = sa.assignment_id AND sa.user_id = ?
        WHERE a.status = 'published'
      `;
      const params = [userId];

      if (status) {
        query += ' AND sa.status = ?';
        params.push(status);
      }

      query += ' ORDER BY a.created_at DESC LIMIT ? OFFSET ?';
      params.push(parseInt(limit), parseInt(offset));

      const [assignments] = await db.query(query, params);

      res.json({ assignments });
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  }

  async getAssignmentDetail(req, res) {
    try {
      const assignmentId = req.params.id;

      const [assignments] = await db.query(`
        SELECT a.*, c.course_name, u.real_name as teacher_name
        FROM assignments a
        JOIN courses c ON a.course_id = c.course_id
        LEFT JOIN teachers t ON a.teacher_id = t.teacher_id
        LEFT JOIN users u ON t.user_id = u.user_id
        WHERE a.assignment_id = ?
      `, [assignmentId]);

      if (assignments.length === 0) {
        return res.status(404).json({ error: 'Assignment not found' });
      }

      res.json({ assignment: assignments[0] });
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  }

  async submitAssignment(req, res) {
    try {
      const userId = req.user.user_id;
      const assignmentId = req.params.id;
      const { content, attachments } = req.body;

      // 检查作业是否存在
      const [assignments] = await db.query(
        'SELECT due_date FROM assignments WHERE assignment_id = ?',
        [assignmentId]
      );

      if (assignments.length === 0) {
        return res.status(404).json({ error: 'Assignment not found' });
      }

      const isLate = new Date() > new Date(assignments[0].due_date) ? 1 : 0;

      // 检查是否已提交
      const [existing] = await db.query(
        'SELECT submission_id FROM submissions WHERE user_id = ? AND assignment_id = ?',
        [userId, assignmentId]
      );

      if (existing.length > 0) {
        return res.status(400).json({ error: 'Already submitted' });
      }

      // 提交作业
      await db.query(
        `INSERT INTO submissions (user_id, assignment_id, content, attachments, submission_date, is_late, status)
         VALUES (?, ?, ?, ?, NOW(), ?, 'submitted')`,
        [userId, assignmentId, content, JSON.stringify(attachments), isLate]
      );

      res.status(201).json({ message: 'Assignment submitted successfully' });
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  }

  async getPendingAssignments(req, res) {
    try {
      const userId = req.user.user_id;

      const [assignments] = await db.query(`
        SELECT a.*, c.course_name, u.real_name as teacher_name
        FROM assignments a
        JOIN courses c ON a.course_id = c.course_id
        LEFT JOIN teachers t ON a.teacher_id = t.teacher_id
        LEFT JOIN users u ON t.user_id = u.user_id
        LEFT JOIN submissions s ON a.assignment_id = s.assignment_id AND s.user_id = ?
        WHERE a.status = 'published' 
        AND s.submission_id IS NULL
        AND a.due_date >= NOW()
        ORDER BY a.due_date ASC
        LIMIT 10
      `, [userId]);

      res.json({ assignments });
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  }
}

module.exports = new AssignmentController();