const API = require('../../utils/api')
const { showLoading, hideLoading, showError, showSuccess, formatDate, isLoggedIn, goToLogin } = require('../../utils/util')

Page({
  data: {
    assignments: [],
    pendingAssignments: [],
    currentTab: 0,
    tabs: ['全部作业', '待完成'],
    loading: false
  },

  onLoad() {
    if (!isLoggedIn()) {
      goToLogin()
      return
    }
    this.loadAssignments()
    this.loadPendingAssignments()
  },

  onShow() {
    if (isLoggedIn()) {
      this.loadPendingAssignments()
    }
  },

  // 切换标签页
  switchTab(e) {
    const currentTab = e.currentTarget.dataset.tab
    this.setData({ currentTab })
  },

  // 加载作业列表
  async loadAssignments() {
    this.setData({ loading: true })
    showLoading('加载中...')

    try {
      const res = await API.getAssignments()
      this.setData({
        assignments: res.assignments || [],
        loading: false
      })
      hideLoading()
    } catch (error) {
      console.error('加载作业列表失败', error)
      this.setData({ loading: false })
      hideLoading()
      showError('加载作业列表失败')
    }
  },

  // 加载待完成作业
  async loadPendingAssignments() {
    try {
      const res = await API.getPendingAssignments()
      this.setData({
        pendingAssignments: res.assignments || []
      })
    } catch (error) {
      console.error('加载待完成作业失败', error)
    }
  },

  // 查看作业详情
  viewAssignment(e) {
    const assignmentId = e.currentTarget.dataset.id
    wx.navigateTo({
      url: `/pages/assignments/detail?id=${assignmentId}`
    })
  },

  // 提交作业
  submitAssignment(e) {
    const assignmentId = e.currentTarget.dataset.id
    wx.navigateTo({
      url: `/pages/assignments/submit?id=${assignmentId}`
    })
  },

  // 下拉刷新
  onPullDownRefresh() {
    this.loadAssignments()
    this.loadPendingAssignments()
    setTimeout(() => {
      wx.stopPullDownRefresh()
    }, 1000)
  },

  // 上拉加载更多
  onReachBottom() {
    if (this.data.loading) return
    this.loadAssignments()
  }
})