// 项目配置文件
module.exports = {
  // 项目名称
  projectName: '少儿英语辅导',

  // 项目描述
  projectDescription: '基于微信小程序的少儿英语辅导系统，提供在线课程、作业管理、成绩查询等功能',

  // 开发环境配置
  development: {
    // API基础URL
    baseUrl: 'http://localhost:3000/api',
    // 调试模式
    debug: true,
    // 日志级别
    logLevel: 'debug'
  },

  // 生产环境配置
  production: {
    // API基础URL
    baseUrl: 'https://api.english-tutoring.com/api',
    // 调试模式
    debug: false,
    // 日志级别
    logLevel: 'error'
  },

  // 数据库配置
  database: {
    host: '127.0.0.1',
    port: 3306,
    user: 'root',
    password: 'root',
    database: 'english_tutoring_system',
    charset: 'utf8mb4',
    timezone: '+08:00'
  },

  // 小程序配置
  miniProgram: {
    appId: 'your_app_id',
    appSecret: 'your_app_secret',
    // 页面配置
    window: {
      navigationBarTitleText: '少儿英语辅导',
      navigationBarBackgroundColor: '#4A90E2',
      navigationBarTextStyle: 'white',
      backgroundColor: '#F5F5F5',
      backgroundTextStyle: 'light'
    },
    // TabBar配置
    tabBar: {
      color: '#666666',
      selectedColor: '#4A90E2',
      backgroundColor: '#ffffff',
      borderStyle: 'black',
      list: [
        {
          pagePath: 'pages/index/index',
          text: '首页',
          iconPath: 'images/home.png',
          selectedIconPath: 'images/home-active.png'
        },
        {
          pagePath: 'pages/courses/courses',
          text: '课程',
          iconPath: 'images/course.png',
          selectedIconPath: 'images/course-active.png'
        },
        {
          pagePath: 'pages/study/study',
          text: '学习',
          iconPath: 'images/study.png',
          selectedIconPath: 'images/study-active.png'
        },
        {
          pagePath: 'pages/scores/scores',
          text: '成绩',
          iconPath: 'images/score.png',
          selectedIconPath: 'images/score-active.png'
        }
      ]
    }
  },

  // 功能配置
  features: {
    // 是否启用语音识别
    voiceRecognition: true,
    // 是否启用摄像头拍照
    camera: true,
    // 是否启用地理位置
    location: false,
    // 是否启用蓝牙
    bluetooth: false,
    // 是否启用NFC
    nfc: false
  },

  // 存储配置
  storage: {
    // Token存储key
    tokenKey: 'token',
    // 用户信息存储key
    userInfoKey: 'userInfo',
    // 记住密码存储key
    rememberKey: 'rememberData',
    // 学习进度存储key
    progressKey: 'studyProgress'
  },

  // 缓存配置
  cache: {
    // 课程缓存时间（秒）
    courseCacheTime: 3600,
    // 用户信息缓存时间（秒）
    userCacheTime: 1800,
    // 词汇缓存时间（秒）
    vocabCacheTime: 7200
  },

  // 分页配置
  pagination: {
    // 默认页大小
    pageSize: 10,
    // 最大页大小
    maxPageSize: 50,
    // 课程列表页大小
    coursePageSize: 12,
    // 作业列表页大小
    assignmentPageSize: 8
  },

  // 文件上传配置
  upload: {
    // 最大文件大小（字节）
    maxSize: 10 * 1024 * 1024, // 10MB
    // 允许的图片类型
    imageTypes: ['jpg', 'jpeg', 'png', 'gif'],
    // 允许的视频类型
    videoTypes: ['mp4', 'mov', 'avi'],
    // 允许的音频类型
    audioTypes: ['mp3', 'wav', 'aac'],
    // 允许的文档类型
    documentTypes: ['pdf', 'doc', 'docx', 'txt']
  },

  // 消息推送配置
  notification: {
    // 是否启用推送
    enabled: true,
    // 推送模板ID
    templateIds: {
      assignment: 'your_assignment_template_id',
      score: 'your_score_template_id',
      course: 'your_course_template_id'
    }
  },

  // 第三方服务配置
  thirdParty: {
    // 微信支付
    wechatPay: {
      appId: 'your_app_id',
      mchId: 'your_mch_id',
      apiKey: 'your_api_key'
    },
    // 阿里云OSS
    aliOSS: {
      region: 'oss-cn-hangzhou',
      accessKeyId: 'your_access_key_id',
      accessKeySecret: 'your_access_key_secret',
      bucket: 'your_bucket_name'
    },
    // 腾讯云COS
    tencentCOS: {
      secretId: 'your_secret_id',
      secretKey: 'your_secret_key',
      bucket: 'your_bucket_name',
      region: 'ap-guangzhou'
    }
  },

  // 安全配置
  security: {
    // Token过期时间（秒）
    tokenExpireTime: 7 * 24 * 3600, // 7天
    // 刷新Token过期时间（秒）
    refreshTokenExpireTime: 30 * 24 * 3600, // 30天
    // 密码最小长度
    passwordMinLength: 6,
    // 密码最大长度
    passwordMaxLength: 20
  },

  // 性能配置
  performance: {
    // 是否启用预加载
    preload: true,
    // 是否启用图片懒加载
    lazyLoad: true,
    // 是否启用缓存
    cache: true,
    // 最大并发请求数
    maxConcurrentRequests: 5
  }
}