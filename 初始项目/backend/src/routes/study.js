const express = require('express');
const router = express.Router();
const studyController = require('../controllers/studyController');
const { authMiddleware } = require('../middleware/auth');

router.get('/stats', authMiddleware, studyController.getStats);
router.get('/current', authMiddleware, studyController.getCurrentStudy);
router.post('/record', authMiddleware, studyController.recordStudy);
router.get('/progress/:courseId', authMiddleware, studyController.getProgress);

module.exports = router;