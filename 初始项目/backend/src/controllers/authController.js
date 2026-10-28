const db = require('../config/database');
const { generateToken, comparePassword, hashPassword } = require('../utils/auth');

class AuthController {
  async login(req, res) {
    try {
      const { username, password, user_type } = req.body;

      const [users] = await db.query(
        'SELECT * FROM users WHERE username = ? AND user_type = ?',
        [username, user_type]
      );

      if (users.length === 0) {
        return res.status(401).json({ error: 'Invalid credentials' });
      }

      const user = users[0];
      const isValidPassword = await comparePassword(password, user.password);

      if (!isValidPassword) {
        return res.status(401).json({ error: 'Invalid credentials' });
      }

      // 更新最后登录时间
      await db.query(
        'UPDATE users SET last_login_time = NOW() WHERE user_id = ?',
        [user.user_id]
      );

      const token = generateToken(user);

      res.json({
        message: 'Login successful',
        token,
        user: {
          user_id: user.user_id,
          username: user.username,
          real_name: user.real_name,
          user_type: user.user_type,
          avatar: user.avatar
        }
      });
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  }

  async register(req, res) {
    try {
      const { username, password, real_name, phone, email, user_type } = req.body;

      // 检查用户名是否存在
      const [existingUsers] = await db.query(
        'SELECT user_id FROM users WHERE username = ?',
        [username]
      );

      if (existingUsers.length > 0) {
        return res.status(400).json({ error: 'Username already exists' });
      }

      const hashedPassword = await hashPassword(password);

      const [result] = await db.query(
        `INSERT INTO users (username, password, real_name, phone, email, user_type, status, created_at, updated_at)
         VALUES (?, ?, ?, ?, ?, ?, 'active', NOW(), NOW())`,
        [username, hashedPassword, real_name, phone, email, user_type]
      );

      const token = generateToken({
        user_id: result.insertId,
        username,
        user_type
      });

      res.status(201).json({
        message: 'Registration successful',
        token,
        user: {
          user_id: result.insertId,
          username,
          real_name,
          user_type
        }
      });
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  }

  async logout(req, res) {
    res.json({ message: 'Logout successful' });
  }
}

module.exports = new AuthController();