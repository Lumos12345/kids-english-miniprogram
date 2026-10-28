// pages/study/study.js
const app = getApp()

Page({
  data: {
    studyStats: {
      totalHours: 0,
      completedLessons: 0,
      learnedWords: 0,
      progress: 0
    },
    currentCourse: null,
    currentChapter: null,
    currentLesson: null,
    currentProgress: 0,
    myCourses: [],
    pendingAssignments: [],
    vocabStats: {
      due_count: 0,
      new_count: 0,
      mastered_count: 0
    },
    studyPlan: null
  },

  onLoad(options) {
    this.loadStudyStats()
    this.loadCurrentCourse()
    this.loadMyCourses()
    this.loadPendingAssignments()
    this.loadVocabStats()
  },

  onShow() {
    // 每次显示页面时刷新数据
    this.loadStudyStats()
    this.loadPendingAssignments()
  },

  // 加载学习统计
  loadStudyStats() {
    if (!app.globalData.userId) return

    app.request({
      url: '/api/study/stats',
      method: 'GET',
      data: {
        userId: app.globalData.userId,
        period: 'week'
      },
      success: (res) => {
        this.setData({
          studyStats: res.data || {
            totalHours: 0,
            completedLessons: 0,
            learnedWords: 0,
            progress: 0
          }
        })
      }
    })
  },

  // 加载当前学习的课程
  loadCurrentCourse() {
    if (!app.globalData.userId) return

    app.request({
      url: '/api/study/current',
      method: 'GET',
      data: {
        userId: app.globalData.userId
      },
      success: (res) => {
        const data = res.data
        if (data) {
          this.setData({
            currentCourse: data.course,
            currentChapter: data.chapter,
            currentLesson: data.lesson,
            currentProgress: data.progress || 0
          })
        }
      }
    })
  },

  // 加载我的课程
  loadMyCourses() {
    if (!app.globalData.userId) return

    app.request({
      url: '/api/courses/my',
      method: 'GET',
      data: {
        userId: app.globalData.userId,
        limit: 5
      },
      success: (res) => {
        this.setData({
          myCourses: res.data || []
        })
      }
    })
  },

  // 加载待完成作业
  loadPendingAssignments() {
    if (!app.globalData.userId) return

    app.request({
      url: '/api/assignments/pending',
      method: 'GET',
      data: {
        userId: app.globalData.userId,
        limit: 3
      },
      success: (res) => {
        const assignments = res.data && res.data.assignments ? res.data.assignments : (Array.isArray(res.data) ? res.data : [])
        // 处理作业数据，添加紧急标识和截止日期文本
        const processedAssignments = assignments.map(item => {
          const dueDate = new Date(item.due_date)
          const now = new Date()
          const daysLeft = Math.ceil((dueDate - now) / (1000 * 60 * 60 * 24))
          
          return {
            ...item,
            is_urgent: daysLeft <= 2,
            deadline_text: daysLeft <= 0 ? '已逾期' : (daysLeft === 1 ? '明天截止' : `${daysLeft}天后截止`)
          }
        })
        
        this.setData({
          pendingAssignments: processedAssignments
        })
      }
    })
  },

  // 加载词汇统计
  loadVocabStats() {
    if (!app.globalData.userId) return

    app.request({
      url: '/api/vocabulary/stats',
      method: 'GET',
      data: {
        userId: app.globalData.userId
      },
      success: (res) => {
        this.setData({
          vocabStats: res.data || {
            due_count: 0,
            new_count: 0,
            mastered_count: 0
          }
        })
      }
    })
  },

  // 加载学习计划
  loadStudyPlan() {
    if (!app.globalData.userId) return

    app.request({
      url: '/plans/current',
      method: 'GET',
      data: {
        userId: app.globalData.userId
      },
      success: (res) => {
        const plan = res.data
        if (plan) {
          // 处理计划数据
          const endDate = new Date(plan.end_date)
          const now = new Date()
          const daysLeft = Math.ceil((endDate - now) / (1000 * 60 * 60 * 24))
          
          this.setData({
            studyPlan: {
              ...plan,
              status_text: this.getStatusText(plan.status),
              daily_time: plan.daily_study_time,
              days_left: Math.max(0, daysLeft)
            }
          })
        }
      },
      fail: () => {} // 计划功能暂未实现，静默忽略
    })
  },

  // 获取状态文本
  getStatusText(status) {
    const statusMap = {
      'active': '进行中',
      'completed': '已完成',
      'paused': '已暂停'
    }
    return statusMap[status] || status
  },

  // 继续学习
  continueLearning(e) {
    const lessonId = e.currentTarget.dataset.id
    wx.navigateTo({
      url: `/pages/study/lesson?id=${lessonId}`
    })
  },

  // 导航到课程详情
  navigateToCourseDetail(e) {
    const courseId = e.currentTarget.dataset.id
    wx.navigateTo({
      url: `/pages/courses/detail?id=${courseId}`
    })
  },

  // 导航到所有课程
  navigateToAllCourses() {
    wx.navigateTo({
      url: '/pages/courses/my-courses'
    })
  },

  // 导航到课程中心
  navigateToCourses() {
    wx.switchTab({
      url: '/pages/courses/courses'
    })
  },

  // 导航到作业详情
  navigateToAssignmentDetail(e) {
    const assignmentId = e.currentTarget.dataset.id
    wx.navigateTo({
      url: `/pages/assignments/detail?id=${assignmentId}`
    })
  },

  // 导航到作业列表
  navigateToAssignments() {
    wx.navigateTo({
      url: '/pages/assignments/assignments'
    })
  },

  // 开始词汇复习
  startVocabReview(e) {
    const type = e.currentTarget.dataset.type
    wx.navigateTo({
      url: `/pages/vocab/review?type=${type}`
    })
  },

  // 导航到词汇页面
  navigateToVocab() {
    wx.navigateTo({
      url: '/pages/vocab/vocab'
    })
  },

  // 导航到学习计划
  navigateToPlan() {
    wx.navigateTo({
      url: `/pages/study/plan`
    })
  }
})