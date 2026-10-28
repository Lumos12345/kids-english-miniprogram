// 工具函数集合

// 格式化日期
const formatDate = (date) => {
  if (!date) return ''

  const d = new Date(date)
  const year = d.getFullYear()
  const month = String(d.getMonth() + 1).padStart(2, '0')
  const day = String(d.getDate()).padStart(2, '0')
  const hour = String(d.getHours()).padStart(2, '0')
  const minute = String(d.getMinutes()).padStart(2, '0')

  return `${year}-${month}-${day} ${hour}:${minute}`
}

// 格式化日期（仅日期部分）
const formatDateOnly = (date) => {
  if (!date) return ''

  const d = new Date(date)
  const year = d.getFullYear()
  const month = String(d.getMonth() + 1).padStart(2, '0')
  const day = String(d.getDate()).padStart(2, '0')

  return `${year}-${month}-${day}`
}

// 格式化时间
const formatTime = (date) => {
  if (!date) return ''

  const d = new Date(date)
  const hour = String(d.getHours()).padStart(2, '0')
  const minute = String(d.getMinutes()).padStart(2, '0')
  const second = String(d.getSeconds()).padStart(2, '0')

  return `${hour}:${minute}:${second}`
}

// 格式化学习时长
const formatDuration = (seconds) => {
  if (!seconds) return '0分钟'

  const hours = Math.floor(seconds / 3600)
  const minutes = Math.floor((seconds % 3600) / 60)

  if (hours > 0) {
    return `${hours}小时${minutes}分钟`
  } else {
    return `${minutes}分钟`
  }
}

// 价格格式化
const formatPrice = (price) => {
  if (price === null || price === undefined) return '免费'
  if (price === 0) return '免费'
  return `¥${price.toFixed(2)}`
}

// 课程等级显示（与数据库中文值匹配）
const getLevelText = (level) => {
  const levelMap = {
    '初级': '初级',
    '中级': '中级',
    '高级': '高级',
    'beginner': '初级',
    'elementary': '中级',
    'intermediate': '高级',
    'advanced': '专家'
  }
  return levelMap[level] || level
}

// 课程等级颜色（支持中文和英文值）
const getLevelColor = (level) => {
  const colorMap = {
    '初级': '#4CAF50',
    '中级': '#2196F3',
    '高级': '#FF9800',
    '专家': '#F44336',
    'beginner': '#4CAF50',
    'elementary': '#2196F3',
    'intermediate': '#FF9800',
    'advanced': '#F44336'
  }
  return colorMap[level] || '#999'
}

// 用户类型显示
const getUserTypeText = (userType) => {
  const typeMap = {
    'student': '学生',
    'parent': '家长',
    'teacher': '教师',
    'admin': '管理员'
  }
  return typeMap[userType] || userType
}

// 显示加载提示
const showLoading = (title = '加载中...') => {
  wx.showLoading({
    title: title,
    mask: true
  })
}

// 隐藏加载提示
const hideLoading = () => {
  wx.hideLoading()
}

// 显示成功提示
const showSuccess = (title, duration = 2000) => {
  wx.showToast({
    title: title,
    icon: 'success',
    duration: duration
  })
}

// 显示错误提示
const showError = (title, duration = 2000) => {
  wx.showToast({
    title: title,
    icon: 'none',
    duration: duration
  })
}

// 显示普通提示
const showToast = (title, icon = 'none', duration = 2000) => {
  wx.showToast({
    title: title,
    icon: icon,
    duration: duration
  })
}

// 显示确认对话框
const showConfirm = (content, title = '提示') => {
  return new Promise((resolve) => {
    wx.showModal({
      title: title,
      content: content,
      success: (res) => {
        if (res.confirm) {
          resolve(true)
        } else {
          resolve(false)
        }
      }
    })
  })
}

// 获取用户信息
const getUserInfo = () => {
  return wx.getStorageSync('userInfo') || null
}

// 获取token
const getToken = () => {
  return wx.getStorageSync('token') || ''
}

// 设置用户信息
const setUserInfo = (userInfo) => {
  wx.setStorageSync('userInfo', userInfo)
}

// 设置token
const setToken = (token) => {
  wx.setStorageSync('token', token)
}

// 清除用户信息
const clearUserInfo = () => {
  wx.removeStorageSync('userInfo')
  wx.removeStorageSync('token')
}

// 检查是否登录
const isLoggedIn = () => {
  const token = wx.getStorageSync('token')
  const userInfo = wx.getStorageSync('userInfo')
  return !!(token && userInfo)
}

// 跳转到登录页
const goToLogin = () => {
  wx.redirectTo({
    url: '/pages/login/login'
  })
}

// 页面跳转（检查登录状态）
const navigateTo = (url, needLogin = false) => {
  if (needLogin && !isLoggedIn()) {
    goToLogin()
    return
  }

  wx.navigateTo({
    url: url,
    fail: (err) => {
      console.error('页面跳转失败', err)
    }
  })
}

// 返回上一页
const navigateBack = (delta = 1) => {
  wx.navigateBack({
    delta: delta
  })
}

// 重定向到指定页面
const redirectTo = (url) => {
  wx.redirectTo({
    url: url,
    fail: (err) => {
      console.error('页面重定向失败', err)
    }
  })
}

// 切换到指定页面
const switchTab = (url) => {
  wx.switchTab({
    url: url,
    fail: (err) => {
      console.error('切换页面失败', err)
    }
  })
}

// 复制到剪贴板
const copyToClipboard = (data) => {
  return new Promise((resolve, reject) => {
    wx.setClipboardData({
      data: data,
      success: () => {
        showToast('已复制到剪贴板')
        resolve()
      },
      fail: (err) => {
        showToast('复制失败')
        reject(err)
      }
    })
  })
}

// 保存图片到相册
const saveImageToPhotosAlbum = (filePath) => {
  return new Promise((resolve, reject) => {
    wx.saveImageToPhotosAlbum({
      filePath: filePath,
      success: () => {
        showSuccess('已保存到相册')
        resolve()
      },
      fail: (err) => {
        showError('保存失败')
        reject(err)
      }
    })
  })
}

// 预览图片
const previewImage = (urls, current = 0) => {
  wx.previewImage({
    urls: urls,
    current: current
  })
}

// 选择图片
const chooseImage = (count = 1, sizeType = ['original', 'compressed'], sourceType = ['album', 'camera']) => {
  return new Promise((resolve, reject) => {
    wx.chooseImage({
      count: count,
      sizeType: sizeType,
      sourceType: sourceType,
      success: (res) => {
        resolve(res.tempFilePaths)
      },
      fail: (err) => {
        reject(err)
      }
    })
  })
}

// 上传图片
const uploadImage = (filePath) => {
  return new Promise((resolve, reject) => {
    wx.uploadFile({
      url: 'http://127.0.0.1:3000/api/users/avatar',
      filePath: filePath,
      name: 'avatar',
      header: {
        'Authorization': getToken()
      },
      success: (res) => {
        const data = JSON.parse(res.data)
        if (res.statusCode === 200) {
          resolve(data)
        } else {
          reject(new Error(data.error || '上传失败'))
        }
      },
      fail: (err) => {
        reject(err)
      }
    })
  })
}

// 防抖函数
const debounce = (func, delay = 300) => {
  let timer = null
  return function(...args) {
    if (timer) clearTimeout(timer)
    timer = setTimeout(() => {
      func.apply(this, args)
    }, delay)
  }
}

// 节流函数
const throttle = (func, delay = 300) => {
  let last = 0
  return function(...args) {
    const now = Date.now()
    if (now - last >= delay) {
      func.apply(this, args)
      last = now
    }
  }
}

module.exports = {
  formatDate,
  formatDateOnly,
  formatTime,
  formatDuration,
  formatPrice,
  getLevelText,
  getLevelColor,
  getUserTypeText,
  showLoading,
  hideLoading,
  showSuccess,
  showError,
  showToast,
  showConfirm,
  getUserInfo,
  getToken,
  setUserInfo,
  setToken,
  clearUserInfo,
  isLoggedIn,
  goToLogin,
  navigateTo,
  navigateBack,
  redirectTo,
  switchTab,
  copyToClipboard,
  saveImageToPhotosAlbum,
  previewImage,
  chooseImage,
  uploadImage,
  debounce,
  throttle
}