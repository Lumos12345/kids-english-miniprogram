const db = require('../config/database');

class ScoreController {
  async getScores(req, res) {
    try {
      const userId = req.user.user_id;
      const { course_id, page = 1, limit = 10 } = req.query;
      const offset = (page - 1) * limit;

      let query = `
        SELECT s.*, c.course_name, a.title as assignment_title
        FROM scores s
        LEFT JOIN courses c ON s.course_id = c.course_id
        LEFT JOIN assignments a ON s.assignment_id = a.assignment_id
        WHERE s.user_id = ?
      `;
      const params = [userId];

      if (course_id) {
        query += ' AND s.course_id = ?';
        params.push(course_id);
      }

      query += ' ORDER BY s.test_date DESC LIMIT ? OFFSET ?';
      params.push(parseInt(limit), parseInt(offset));

      const [scores] = await db.query(query, params);

      res.json({ scores });
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  }

  async getStats(req, res) {
    try {
      const userId = req.user.user_id;

      const [stats] = await db.query(`
        SELECT 
          COUNT(*) as total_tests,
          AVG(percentage) as avg_percentage,
          MAX(percentage) as max_percentage,
          MIN(percentage) as min_percentage
        FROM scores
        WHERE user_id = ?
      `, [userId]);

      // 获取最近的5次成绩
      const [recentScores] = await db.query(`
        SELECT s.*, c.course_name
        FROM scores s
        LEFT JOIN courses c ON s.course_id = c.course_id
        WHERE s.user_id = ?
        ORDER BY s.test_date DESC
        LIMIT 5
      `, [userId]);

      res.json({
        stats: {
          total_tests: stats[0].total_tests || 0,
          avg_percentage: Math.round(stats[0].avg_percentage || 0),
          max_percentage: Math.round(stats[0].max_percentage || 0),
          min_percentage: Math.round(stats[0].min_percentage || 0)
        },
        recent_scores: recentScores
      });
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  }

  async getTrend(req, res) {
    try {
      const userId = req.user.user_id;
      const courseId = req.query.course_id;

      let query = `
        SELECT 
          DATE(test_date) as test_date,
          AVG(percentage) as avg_percentage
        FROM scores
        WHERE user_id = ?
      `;
      const params = [userId];

      if (courseId) {
        query += ' AND course_id = ?';
        params.push(courseId);
      }

      query += `
        GROUP BY DATE(test_date)
        ORDER BY test_date ASC
        LIMIT 30
      `;

      const [trend] = await db.query(query, params);

      res.json({ trend });
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  }

  async getLeaderboard(req, res) {
    try {
      const courseId = req.query.course_id;
      const limit = req.query.limit || 10;

      let query = `
        SELECT 
          u.user_id,
          u.real_name,
          u.avatar,
          AVG(s.percentage) as avg_percentage,
          COUNT(*) as test_count
        FROM scores s
        JOIN users u ON s.user_id = u.user_id
      `;
      const params = [];

      if (courseId) {
        query += ' WHERE s.course_id = ?';
        params.push(courseId);
      }

      query += `
        GROUP BY u.user_id, u.real_name, u.avatar
        ORDER BY avg_percentage DESC, test_count DESC
        LIMIT ?
      `;
      params.push(parseInt(limit));

      const [leaderboard] = await db.query(query, params);

      res.json({ leaderboard });
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  }
}

module.exports = new ScoreController();