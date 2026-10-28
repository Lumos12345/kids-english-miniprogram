const jwt = require('jsonwebtoken');
require('dotenv').config();

const authMiddleware = (req, res, next) => {
  try {
    const token = req.headers.authorization?.replace('Bearer ', '');

    if (!token) {
      return res.status(401).json({ error: 'No token provided' });
    }

    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    req.user = decoded;
    next();
  } catch (error) {
    res.status(401).json({ error: 'Invalid token' });
  }
};

const adminAuthMiddleware = (req, res, next) => {
  authMiddleware(req, res, () => {
    if (req.user.user_type !== 'admin') {
      return res.status(403).json({ error: 'Admin access required' });
    }
    next();
  });
};

const teacherAuthMiddleware = (req, res, next) => {
  authMiddleware(req, res, () => {
    if (req.user.user_type !== 'teacher' && req.user.user_type !== 'admin') {
      return res.status(403).json({ error: 'Teacher access required' });
    }
    next();
  });
};

module.exports = {
  authMiddleware,
  adminAuthMiddleware,
  teacherAuthMiddleware
};