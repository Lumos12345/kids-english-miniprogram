// pages/index/index.js
const app = getApp()

Page({
  data: {
    userInfo: null,
    userTypeText: '学生',
    currentTab: 'home',
    stats: {
      total_study_time: 0,
      completed_lessons: 0,
      learned_words: 0,
      current_streak: 0
    },
    recommendedCourses: [],
    avatarError: false,
    showReminder: false
  },

  onLoad(options) {
    this.checkLoginStatus()
    this.loadStudyStats()
    this.loadRecommendedCourses()
  },

  onShow() {
    this.checkLoginStatus()
  },

  // 检查登录状态
  checkLoginStatus() {
    const userInfo = wx.getStorageSync('userInfo')
    if (userInfo) {
      this.setData({
        userInfo: userInfo,
        userTypeText: this.getUserTypeText(userInfo.user_type)
      })
      // 更新全局数据
      app.globalData.userInfo = userInfo
      app.globalData.userId = userInfo.user_id
    }
  },

  // 获取用户类型文本
  getUserTypeText(type) {
    const typeMap = {
      'student': '学生',
      'parent': '家长',
      'teacher': '教师',
      'admin': '管理员'
    }
    return typeMap[type] || '学生'
  },

  // 头像加载错误处理
  onAvatarError() {
    console.log('Avatar load error, showing fallback')
    this.setData({ avatarError: true })
  },

  // 加载学习统计数据
  loadStudyStats() {
    const token = wx.getStorageSync('token')
    if (!token) return

    app.request({
      url: '/api/study/stats',
      method: 'GET',
      success: (res) => {
        console.log('Study stats response:', res)
        this.setData({
          stats: res.data.stats || {
            total_study_time: 0,
            completed_lessons: 0,
            learned_words: 0,
            current_streak: 0
          }
        })
      },
      fail: (err) => {
        console.error('加载学习统计失败', err)
      }
    })
  },

  // 加载推荐课程
  loadRecommendedCourses() {
    app.request({
      url: '/api/courses/recommended',
      method: 'GET',
      success: (res) => {
        console.log('Recommended courses response:', res)
        this.setData({
          recommendedCourses: res.data.courses || []
        })
      },
      fail: (err) => {
        console.error('加载推荐课程失败', err)
      }
    })
  },

  // 导航到登录页面
  navigateToLogin() {
    if (this.data.userInfo) {
      // 已登录：清除缓存，切换到登录页
      wx.removeStorageSync('token')
      wx.removeStorageSync('userInfo')
      wx.removeStorageSync('rememberData')
      app.globalData.token = null
      app.globalData.userInfo = null
      app.globalData.userId = null
    }
    wx.navigateTo({
      url: '/pages/login/login'
    })
  },

  // 导航到课程页面
  navigateToCourses() {
    wx.switchTab({
      url: '/pages/courses/courses'
    })
  },

  // 导航到作业页面
  navigateToAssignments() {
    wx.navigateTo({
      url: '/pages/assignments/assignments'
    })
  },

  // 导航到成绩页面
  navigateToScores() {
    wx.switchTab({
      url: '/pages/scores/scores'
    })
  },

  // 导航到学习资源页面
  navigateToResources() {
    wx.navigateTo({
      url: '/pages/resources/resources'
    })
  },

  // 导航到学习页面
  navigateToStudy() {
    wx.switchTab({
      url: '/pages/study/study'
    })
  },

  // 导航到课程详情
  navigateToCourseDetail(e) {
    const courseId = e.currentTarget.dataset.id
    wx.navigateTo({
      url: `/pages/courses/detail?id=${courseId}`
    })
  },

  // 关闭提醒
  dismissReminder() {
    this.setData({ showReminder: false })
  }
})