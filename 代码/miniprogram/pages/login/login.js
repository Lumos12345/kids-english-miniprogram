// pages/login/login.js
const API = require('../../utils/api')
const { showLoading, hideLoading, showError, showSuccess } = require('../../utils/util')

Page({
  data: {
    userType: 'student',
    username: '',
    password: '',
    showPassword: false,
    rememberMe: false,
    loading: false
  },

  onLoad(options) {
    // 检查是否记住密码
    this.checkRememberPassword()
  },

  // 检查记住的密码
  checkRememberPassword() {
    const rememberData = wx.getStorageSync('rememberData')
    if (rememberData) {
      this.setData({
        username: rememberData.username,
        password: rememberData.password,
        rememberMe: true
      })
    }
  },

  // 选择用户类型
  selectUserType(e) {
    const type = e.currentTarget.dataset.type
    this.setData({ userType: type })
  },

  // 用户名输入
  onUsernameInput(e) {
    this.setData({ username: e.detail.value })
  },

  // 密码输入
  onPasswordInput(e) {
    this.setData({ password: e.detail.value })
  },

  // 切换密码显示
  togglePassword() {
    this.setData({
      showPassword: !this.data.showPassword
    })
  },

  // 切换记住密码
  toggleRemember() {
    this.setData({
      rememberMe: !this.data.rememberMe
    })
  },

  // 忘记密码
  forgotPassword() {
    wx.showModal({
      title: '忘记密码',
      content: '请联系管理员重置密码',
      showCancel: false,
      confirmText: '知道了'
    })
  },

  // 处理登录
  async handleLogin() {
    const { username, password, userType, rememberMe } = this.data

    // 表单验证
    if (!username.trim()) {
      showError('请输入用户名或手机号')
      return
    }

    if (!password.trim()) {
      showError('请输入密码')
      return
    }

    this.setData({ loading: true })
    showLoading('登录中...')

    try {
      const res = await API.login({
        username: username.trim(),
        password: password.trim(),
        user_type: userType
      })

      // 保存登录信息
      wx.setStorageSync('token', res.token)
      wx.setStorageSync('userInfo', res.user)

      // 记住密码
      if (rememberMe) {
        wx.setStorageSync('rememberData', {
          username: username,
          password: password
        })
      } else {
        wx.removeStorageSync('rememberData')
      }

      hideLoading()
      showSuccess('登录成功')

      // 延迟跳转到首页
      setTimeout(() => {
        wx.switchTab({
          url: '/pages/index/index'
        })
      }, 1000)

    } catch (error) {
      console.error('登录失败', error)
      hideLoading()
      this.setData({ loading: false })
      showError(error.message || '登录失败，请检查用户名和密码')
    }
  },

  // 微信登录
  wechatLogin() {
    showLoading('授权中...')

    wx.login({
      success: (res) => {
        if (res.code) {
          // 发送code到服务器
          // API.wechatLogin({ code: res.code })
          hideLoading()
          showSuccess('授权成功，请完善信息')
          setTimeout(() => {
            wx.switchTab({
              url: '/pages/index/index'
            })
          }, 1000)
        }
      },
      fail: (err) => {
        hideLoading()
        console.error('获取微信code失败', err)
        showError('授权失败，请重试')
      }
    })
  },

  // 跳转到注册页面
  goToRegister() {
    wx.navigateTo({
      url: '/pages/register/register'
    })
  }
})