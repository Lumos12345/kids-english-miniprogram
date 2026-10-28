const express = require('express');
const router = express.Router();
const courseController = require('../controllers/courseController');
const { authMiddleware } = require('../middleware/auth');

router.get('/', courseController.getCourses);
router.get('/recommended', authMiddleware, courseController.getRecommendedCourses);
router.get('/my', authMiddleware, courseController.getMyCourses);
router.get('/:id', courseController.getCourseDetail);
router.post('/:id/enroll', authMiddleware, courseController.enrollCourse);

module.exports = router;