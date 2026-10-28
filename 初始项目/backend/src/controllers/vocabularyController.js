const db = require('../config/database');

class VocabularyController {
  async getVocabulary(req, res) {
    try {
      const { category, difficulty_level, page = 1, limit = 20 } = req.query;
      const offset = (page - 1) * limit;

      let query = 'SELECT * FROM vocabulary WHERE 1=1';
      const params = [];

      if (category) {
        query += ' AND category = ?';
        params.push(category);
      }

      if (difficulty_level) {
        query += ' AND difficulty_level = ?';
        params.push(difficulty_level);
      }

      query += ' ORDER BY frequency DESC LIMIT ? OFFSET ?';
      params.push(parseInt(limit), parseInt(offset));

      const [vocabulary] = await db.query(query, params);

      res.json({ vocabulary });
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  }

  async getStats(req, res) {
    try {
      const userId = req.user.user_id;

      const [stats] = await db.query(`
        SELECT 
          COUNT(*) as total_vocabulary,
          COUNT(CASE WHEN mastery_level >= 3 THEN 1 END) as mastered,
          COUNT(CASE WHEN is_favorited = 1 THEN 1 END) as favorited,
          SUM(review_count) as total_reviews
        FROM user_vocabulary
        WHERE user_id = ?
      `, [userId]);

      // 获取需要复习的词汇数量
      const [dueForReview] = await db.query(`
        SELECT COUNT(*) as count
        FROM user_vocabulary
        WHERE user_id = ? AND next_review_date <= NOW()
      `, [userId]);

      res.json({
        stats: {
          total_vocabulary: stats[0].total_vocabulary || 0,
          mastered: stats[0].mastered || 0,
          favorited: stats[0].favorited || 0,
          total_reviews: stats[0].total_reviews || 0,
          due_for_review: dueForReview[0].count || 0
        }
      });
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  }

  async learn(req, res) {
    try {
      const userId = req.user.user_id;
      const { vocab_id } = req.params;

      // 检查是否已经学习过
      const [existing] = await db.query(
        'SELECT id FROM user_vocabulary WHERE user_id = ? AND vocab_id = ?',
        [userId, vocab_id]
      );

      if (existing.length > 0) {
        // 更新掌握程度
        await db.query(
          `UPDATE user_vocabulary 
           SET mastery_level = mastery_level + 1,
               review_count = review_count + 1,
               last_review_date = NOW(),
               next_review_date = DATE_ADD(NOW(), INTERVAL 1 DAY)
           WHERE user_id = ? AND vocab_id = ?`,
          [userId, vocab_id]
        );
      } else {
        // 创建新学习记录
        await db.query(
          `INSERT INTO user_vocabulary 
           (user_id, vocab_id, mastery_level, review_count, last_review_date, next_review_date)
           VALUES (?, ?, 1, 1, NOW(), DATE_ADD(NOW(), INTERVAL 1 DAY))`,
          [userId, vocab_id]
        );
      }

      res.json({ message: 'Vocabulary learned successfully' });
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  }

  async review(req, res) {
    try {
      const userId = req.user.user_id;
      const { vocab_id, result } = req.body; // result: 'correct' or 'incorrect'

      let intervalDays;
      let masteryChange;

      if (result === 'correct') {
        masteryChange = 1;
        intervalDays = Math.pow(2, 3); // 下次复习间隔根据掌握程度
      } else {
        masteryChange = -1;
        intervalDays = 1; // 错误的话明天复习
      }

      await db.query(
        `UPDATE user_vocabulary 
         SET mastery_level = GREATEST(0, LEAST(5, mastery_level + ?)),
             review_count = review_count + 1,
             last_review_date = NOW(),
             next_review_date = DATE_ADD(NOW(), INTERVAL ? DAY)
         WHERE user_id = ? AND vocab_id = ?`,
        [masteryChange, intervalDays, userId, vocab_id]
      );

      res.json({ message: 'Vocabulary reviewed successfully' });
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  }
}

module.exports = new VocabularyController();