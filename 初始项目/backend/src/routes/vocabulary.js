const express = require('express');
const router = express.Router();
const vocabularyController = require('../controllers/vocabularyController');
const { authMiddleware } = require('../middleware/auth');

router.get('/', vocabularyController.getVocabulary);
router.get('/stats', authMiddleware, vocabularyController.getStats);
router.post('/learn/:vocab_id', authMiddleware, vocabularyController.learn);
router.post('/review', authMiddleware, vocabularyController.review);

module.exports = router;