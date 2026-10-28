const express = require('express');
const router = express.Router();
const scoreController = require('../controllers/scoreController');
const { authMiddleware } = require('../middleware/auth');

router.get('/', authMiddleware, scoreController.getScores);
router.get('/stats', authMiddleware, scoreController.getStats);
router.get('/trend', authMiddleware, scoreController.getTrend);
router.get('/leaderboard', authMiddleware, scoreController.getLeaderboard);

module.exports = router;