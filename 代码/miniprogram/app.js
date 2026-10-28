// app.js
App({
  globalData: {
    userInfo: null,
    token: null,
    baseUrl: 'http://127.0.0.1:3000',
    userId: null,
    userType: null // 'student', 'parent', 'teacher'
  },

  onLaunch() {
    // 检查登录状态
    const token = wx.getStorageSync('token')
    const userInfo = wx.getStorageSync('userInfo')
    
    if (token && userInfo) {
      this.globalData.token = token
      this.globalData.userInfo = userInfo
      this.globalData.userId = userInfo.user_id
      this.globalData.userType = userInfo.user_type
    }
  },

  // 网络请求封装
  request(options) {
    const { url, method = 'GET', data = {}, success, fail } = options
    
    wx.request({
      url: this.globalData.baseUrl + url,
      method: method,
      data: data,
      header: {
        'Content-Type': 'application/json',
        'Authorization': this.globalData.token ? `Bearer ${this.globalData.token}` : ''
      },
      success: (res) => {
        if (res.statusCode < 400) {
          success && success(res)
        } else {
          this.showToast('请求失败')
          fail && fail(res)
        }
      },
      fail: (err) => {
        this.showToast('网络请求失败')
        fail && fail(err)
      }
    })
  },

  // 显示Toast提示
  showToast(title, icon = 'none') {
    wx.showToast({
      title: title,
      icon: icon,
      duration: 2000
    })
  },

  // 显示加载
  showLoading(title = '加载中...') {
    wx.showLoading({
      title: title,
      mask: true
    })
  },

  // 隐藏加载
  hideLoading() {
    wx.hideLoading()
  }
})