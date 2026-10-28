const db = require('../config/database');

class UserController {
  async getProfile(req, res) {
    try {
      const userId = req.user.user_id;

      const [users] = await db.query(
        'SELECT user_id, username, real_name, phone, email, avatar, gender, birth_date, user_type, status, created_at FROM users WHERE user_id = ?',
        [userId]
      );

      if (users.length === 0) {
        return res.status(404).json({ error: 'User not found' });
      }

      res.json({ user: users[0] });
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  }

  async updateProfile(req, res) {
    try {
      const userId = req.user.user_id;
      const { real_name, phone, email, gender, birth_date } = req.body;

      await db.query(
        `UPDATE users SET real_name = ?, phone = ?, email = ?, gender = ?, birth_date = ?, updated_at = NOW()
         WHERE user_id = ?`,
        [real_name, phone, email, gender, birth_date, userId]
      );

      res.json({ message: 'Profile updated successfully' });
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  }

  async uploadAvatar(req, res) {
    try {
      const userId = req.user.user_id;
      const avatarUrl = `/public/uploads/${req.file.filename}`;

      await db.query(
        'UPDATE users SET avatar = ?, updated_at = NOW() WHERE user_id = ?',
        [avatarUrl, userId]
      );

      res.json({ message: 'Avatar uploaded successfully', avatar_url: avatarUrl });
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  }
}

module.exports = new UserController();