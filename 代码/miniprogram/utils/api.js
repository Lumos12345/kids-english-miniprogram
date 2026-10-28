// API 工具类
const API_BASE_URL = 'http://127.0.0.1:3000/api'

class API {
  static request(options) {
    const {
      url,
      method = 'GET',
      data = {},
      header = {},
      success,
      fail,
      complete
    } = options

    // 获取存储的token
    const token = wx.getStorageSync('token') || ''

    // 合并请求头
    const headers = {
      'Content-Type': 'application/json',
      'Authorization': token,
      ...header
    }

    return new Promise((resolve, reject) => {
      wx.request({
        url: API_BASE_URL + url,
        method: method,
        data: data,
        header: headers,
        success: (res) => {
          if (res.statusCode === 200) {
            resolve(res.data)
          } else if (res.statusCode === 401) {
            // token过期，清除存储并跳转登录
            wx.removeStorageSync('token')
            wx.removeStorageSync('userInfo')
            wx.showToast({
              title: '请重新登录',
              icon: 'none'
            })
            setTimeout(() => {
              wx.redirectTo({
                url: '/pages/login/login'
              })
            }, 1500)
            reject(new Error('Unauthorized'))
          } else {
            reject(new Error(res.data.error || '请求失败'))
          }
        },
        fail: (err) => {
          wx.showToast({
            title: '网络错误',
            icon: 'none'
          })
          reject(err)
        },
        complete: complete
      })
    })
  }

  // 认证相关
  static login(data) {
    return this.request({
      url: '/auth/login',
      method: 'POST',
      data: data
    })
  }

  static register(data) {
    return this.request({
      url: '/auth/register',
      method: 'POST',
      data: data
    })
  }

  // 用户相关
  static getProfile() {
    return this.request({
      url: '/users/profile',
      method: 'GET'
    })
  }

  static updateProfile(data) {
    return this.request({
      url: '/users/profile',
      method: 'PUT',
      data: data
    })
  }

  // 课程相关
  static getCourses(params = {}) {
    return this.request({
      url: '/courses',
      method: 'GET',
      data: params
    })
  }

  static getCourseDetail(id) {
    return this.request({
      url: `/courses/${id}`,
      method: 'GET'
    })
  }

  static getRecommendedCourses() {
    return this.request({
      url: '/courses/recommended',
      method: 'GET'
    })
  }

  static getMyCourses() {
    return this.request({
      url: '/courses/my',
      method: 'GET'
    })
  }

  static enrollCourse(id) {
    return this.request({
      url: `/courses/${id}/enroll`,
      method: 'POST'
    })
  }

  // 学习相关
  static getStudyStats() {
    return this.request({
      url: '/study/stats',
      method: 'GET'
    })
  }

  static getCurrentStudy() {
    return this.request({
      url: '/study/current',
      method: 'GET'
    })
  }

  static recordStudy(data) {
    return this.request({
      url: '/study/record',
      method: 'POST',
      data: data
    })
  }

  static getStudyProgress(courseId) {
    return this.request({
      url: `/study/progress/${courseId}`,
      method: 'GET'
    })
  }

  // 作业相关
  static getAssignments(params = {}) {
    return this.request({
      url: '/assignments',
      method: 'GET',
      data: params
    })
  }

  static getPendingAssignments() {
    return this.request({
      url: '/assignments/pending',
      method: 'GET'
    })
  }

  static getAssignmentDetail(id) {
    return this.request({
      url: `/assignments/${id}`,
      method: 'GET'
    })
  }

  static submitAssignment(id, data) {
    return this.request({
      url: `/assignments/${id}/submit`,
      method: 'POST',
      data: data
    })
  }

  // 成绩相关
  static getScores(params = {}) {
    return this.request({
      url: '/scores',
      method: 'GET',
      data: params
    })
  }

  static getScoreStats() {
    return this.request({
      url: '/scores/stats',
      method: 'GET'
    })
  }

  static getScoreTrend(params = {}) {
    return this.request({
      url: '/scores/trend',
      method: 'GET',
      data: params
    })
  }

  static getLeaderboard(params = {}) {
    return this.request({
      url: '/scores/leaderboard',
      method: 'GET',
      data: params
    })
  }

  // 词汇相关
  static getVocabulary(params = {}) {
    return this.request({
      url: '/vocabulary',
      method: 'GET',
      data: params
    })
  }

  static getVocabularyStats() {
    return this.request({
      url: '/vocabulary/stats',
      method: 'GET'
    })
  }

  static learnVocabulary(vocabId) {
    return this.request({
      url: `/vocabulary/learn/${vocabId}`,
      method: 'POST'
    })
  }

  static reviewVocabulary(data) {
    return this.request({
      url: '/vocabulary/review',
      method: 'POST',
      data: data
    })
  }
}

module.exports = API