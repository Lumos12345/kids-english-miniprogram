const express = require('express');
const router = express.Router();
const assignmentController = require('../controllers/assignmentController');
const { authMiddleware } = require('../middleware/auth');

router.get('/', authMiddleware, assignmentController.getAssignments);
router.get('/pending', authMiddleware, assignmentController.getPendingAssignments);
router.get('/:id', authMiddleware, assignmentController.getAssignmentDetail);
router.post('/:id/submit', authMiddleware, assignmentController.submitAssignment);

module.exports = router;