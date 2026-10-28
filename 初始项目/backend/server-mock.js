// 简化版服务器文件 - 用于测试
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const bodyParser = require('body-parser');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

// 中间件
app.use(helmet());
app.use(cors());
app.use(morgan('dev'));
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

// 静态文件服务
app.use('/public', express.static('public'));

// 健康检查
app.get('/health', (req, res) => {
  res.json({
    status: 'ok',
    timestamp: new Date().toISOString(),
    message: 'Backend service is running',
    database: 'Mock data mode (database connection unavailable)'
  });
});

// 模拟数据
const mockUsers = [
  { user_id: 1, username: 'admin', real_name: '系统管理员', user_type: 'admin', status: 'active' },
  { user_id: 2, username: 'teacher1', real_name: '王老师', user_type: 'teacher', status: 'active' },
  { user_id: 6, username: 'student1', real_name: '小明', user_type: 'student', status: 'active' },
  { user_id: 7, username: 'student2', real_name: '小红', user_type: 'student', status: 'active' }
];

const mockCourses = [
  { course_id: 1, course_name: '少儿英语自然拼读入门', level: 'beginner', price: 199.00, enroll_count: 0, rating: 4.5, status: 'published', description: '适合3-6岁儿童的英语启蒙课程' },
  { course_id: 2, course_name: '日常口语100句', level: 'beginner', price: 149.00, enroll_count: 0, rating: 4.7, status: 'published', description: '掌握日常对话的核心表达' },
  { course_id: 3, course_name: '小学英语词汇训练营', level: 'elementary', price: 249.00, enroll_count: 0, rating: 4.6, status: 'published', description: '系统学习小学阶段核心词汇' },
  { course_id: 4, course_name: '英语绘本阅读', level: 'beginner', price: 179.00, enroll_count: 0, rating: 4.8, status: 'published', description: '培养英语阅读兴趣和能力' },
  { course_id: 5, course_name: '基础语法入门', level: 'intermediate', price: 219.00, enroll_count: 0, rating: 4.4, status: 'published', description: '轻松掌握英语基础语法' }
];

const mockVocabulary = [
  { vocab_id: 1, word: 'hello', chinese_meaning: '你好', difficulty_level: '初级', category: '问候' },
  { vocab_id: 2, word: 'apple', chinese_meaning: '苹果', difficulty_level: '初级', category: '食物' },
  { vocab_id: 3, word: 'cat', chinese_meaning: '猫', difficulty_level: '初级', category: '动物' },
  { vocab_id: 4, word: 'dog', chinese_meaning: '狗', difficulty_level: '初级', category: '动物' },
  { vocab_id: 5, word: 'book', chinese_meaning: '书', difficulty_level: '初级', category: '物品' }
];

// 模拟认证接口
app.post('/api/auth/login', (req, res) => {
  const { username, password, user_type } = req.body;
  console.log('Login request:', { username, user_type });

  const user = mockUsers.find(u => u.username === username && u.user_type === user_type);

  if (!user) {
    console.log('User not found:', username);
    return res.status(401).json({ error: 'Invalid credentials' });
  }

  // 模拟生成token（实际应该使用JWT）
  const token = 'mock_token_' + Date.now();

  console.log('Login successful:', user.username);

  res.json({
    message: 'Login successful',
    token,
    user: user
  });
});

app.post('/api/auth/register', (req, res) => {
  const { username, password, real_name, phone, email, user_type } = req.body;
  const newUser = {
    user_id: mockUsers.length + 1,
    username,
    real_name,
    user_type,
    status: 'active'
  };
  mockUsers.push(newUser);

  const token = 'mock_token_' + Date.now();

  res.status(201).json({
    message: 'Registration successful',
    token,
    user: newUser
  });
});

// 模拟用户接口
app.get('/api/users/profile', (req, res) => {
  res.json({ user: mockUsers[0] });
});

// 模拟课程接口 - 特殊路由必须在前面
app.get('/api/courses/recommended', (req, res) => {
  console.log('Getting recommended courses');
  const recommended = mockCourses.slice(0, 3);
  console.log('Recommended courses:', recommended);
  res.json({ courses: recommended });
});

app.get('/api/courses/my', (req, res) => {
  res.json({ courses: [] });
});

app.get('/api/courses', (req, res) => {
  const { level, category } = req.query;
  let courses = [...mockCourses];

  if (level) {
    courses = courses.filter(c => c.level === level);
  }

  res.json({
    courses,
    pagination: {
      current_page: 1,
      total_pages: 1,
      total_items: courses.length,
      items_per_page: courses.length
    }
  });
});

app.get('/api/courses/:id', (req, res) => {
  const course = mockCourses.find(c => c.course_id === parseInt(req.params.id));
  if (!course) {
    return res.status(404).json({ error: 'Course not found' });
  }
  res.json({ course });
});

app.post('/api/courses/:id/enroll', (req, res) => {
  res.json({ message: 'Enrolled successfully' });
});

// 模拟词汇接口
app.get('/api/vocabulary', (req, res) => {
  const { difficulty_level } = req.query;
  let vocab = [...mockVocabulary];

  if (difficulty_level) {
    vocab = vocab.filter(v => v.difficulty_level === difficulty_level);
  }

  res.json({ vocabulary: vocab });
});

// 模拟学习统计接口
app.get('/api/study/stats', (req, res) => {
  res.json({
    stats: {
      total_study_time: 1250, // 分钟
      completed_lessons: 15,
      learned_words: 120,
      current_streak: 7
    }
  });
});

app.get('/api/study/progress', (req, res) => {
  res.json({
    progress: [
      { course_id: 1, course_name: '少儿英语自然拼读入门', progress: 75, completed_lessons: 15 },
      { course_id: 2, course_name: '日常口语100句', progress: 40, completed_lessons: 20 }
    ]
  });
});

// 模拟作业接口
app.get('/api/assignments', (req, res) => {
  const mockAssignments = [
    {
      assignment_id: 1,
      title: '第一单元测试',
      course_id: 1,
      course_name: '少儿英语自然拼读入门',
      due_date: '2026-07-01',
      total_score: 100,
      submission_id: null
    },
    {
      assignment_id: 2,
      title: '词汇记忆测试',
      course_id: 2,
      course_name: '日常口语100句',
      due_date: '2026-07-05',
      total_score: 100,
      submission_id: null
    }
  ];

  res.json({ assignments: mockAssignments });
});

app.get('/api/assignments/pending', (req, res) => {
  const mockAssignments = [
    {
      assignment_id: 1,
      title: '第一单元测试',
      course_id: 1,
      course_name: '少儿英语自然拼读入门',
      due_date: '2026-07-01',
      total_score: 100
    }
  ];

  res.json({ assignments: mockAssignments });
});

// 模拟成绩接口
app.get('/api/scores', (req, res) => {
  const mockScores = [
    {
      score_id: 1,
      assignment_id: 1,
      assignment_title: '第一单元测试',
      course_name: '少儿英语自然拼读入门',
      score: 85,
      total_score: 100,
      created_at: '2026-06-20'
    },
    {
      score_id: 2,
      assignment_id: 2,
      assignment_title: '词汇记忆测试',
      course_name: '日常口语100句',
      score: 92,
      total_score: 100,
      created_at: '2026-06-18'
    }
  ];

  res.json({ scores: mockScores });
});

// 模拟资源接口
app.get('/api/resources', (req, res) => {
  res.json({
    resources: [
      {
        id: 1,
        title: '英语启蒙绘本系列',
        description: '适合3-6岁儿童的基础英语绘本',
        category: '绘本资源',
        cover: 'https://via.placeholder.com/200x280',
        downloadCount: 1280,
        fileSize: '15.2MB',
        uploadTime: '2026-06-20'
      }
    ]
  });
});

// 404处理
app.use((req, res) => {
  console.log('404 - Route not found:', req.method, req.path);
  res.status(404).json({ error: 'Route not found' });
});

// 错误处理
app.use((err, req, res, next) => {
  console.error('Error:', err);
  res.status(500).json({ error: 'Internal server error' });
});

// 启动服务器
app.listen(PORT, () => {
  console.log('🚀 Server running on port', PORT);
  console.log('🌍 Environment:', process.env.NODE_ENV || 'development');
  console.log('🏥 Health check: http://localhost:' + PORT + '/health');
  console.log('📝 API Base URL: http://localhost:' + PORT + '/api');
  console.log('⚠️  Database: Mock data mode (database connection unavailable)');
});

module.exports = app;