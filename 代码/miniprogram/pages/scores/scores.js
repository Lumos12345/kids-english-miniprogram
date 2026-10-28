const API = require('../../utils/api')
const { showLoading, hideLoading, showError, showSuccess, formatDate, isLoggedIn, goToLogin } = require('../../utils/util')

Page({
  data: {
    currentTab: 0,
    tabs: ['成绩列表', '统计分析', '学习排行'],
    scores: [],
    stats: null,
    leaderboard: [],
    trend: [],
    loading: false
  },

  onLoad() {
    if (!isLoggedIn()) {
      goToLogin()
      return
    }
    this.loadScoreData()
  },

  onShow() {
    if (isLoggedIn()) {
      this.loadScoreData()
    }
  },

  // 切换标签页
  switchTab(e) {
    const currentTab = e.currentTarget.dataset.tab
    this.setData({ currentTab })

    // 根据标签加载不同数据
    if (currentTab === 1) {
      this.loadScoreStats()
    } else if (currentTab === 2) {
      this.loadLeaderboard()
    }
  },

  // 加载成绩数据
  async loadScoreData() {
    this.setData({ loading: true })
    showLoading('加载中...')

    try {
      const res = await API.getScores()
      this.setData({
        scores: res.scores || [],
        loading: false
      })
      hideLoading()
    } catch (error) {
      console.error('加载成绩失败', error)
      this.setData({ loading: false })
      hideLoading()
      showError('加载成绩失败')
    }
  },

  // 加载成绩统计
  async loadScoreStats() {
    showLoading('加载统计中...')

    try {
      const [statsRes, trendRes] = await Promise.all([
        API.getScoreStats(),
        API.getScoreTrend()
      ])

      this.setData({
        stats: statsRes.stats,
        trend: trendRes.trend || [],
        loading: false
      })
      hideLoading()
    } catch (error) {
      console.error('加载统计失败', error)
      this.setData({ loading: false })
      hideLoading()
      showError('加载统计失败')
    }
  },

  // 加载排行榜
  async loadLeaderboard() {
    showLoading('加载排行中...')

    try {
      const res = await API.getLeaderboard()
      this.setData({
        leaderboard: res.leaderboard || [],
        loading: false
      })
      hideLoading()
    } catch (error) {
      console.error('加载排行榜失败', error)
      this.setData({ loading: false })
      hideLoading()
      showError('加载排行榜失败')
    }
  },

  // 查看成绩详情
  viewScoreDetail(e) {
    const scoreId = e.currentTarget.dataset.id
    wx.showModal({
      title: '成绩详情',
      content: '成绩详情功能开发中',
      showCancel: false
    })
  },

  // 分享成绩
  shareScore(e) {
    const score = e.currentTarget.dataset.score
    wx.showShareMenu({
      withShareTicket: true
    })

    return {
      title: '我的学习成绩',
      path: '/pages/scores/scores',
      imageUrl: ''
    }
  },

  // 下拉刷新
  onPullDownRefresh() {
    if (this.data.currentTab === 0) {
      this.loadScoreData()
    } else if (this.data.currentTab === 1) {
      this.loadScoreStats()
    } else if (this.data.currentTab === 2) {
      this.loadLeaderboard()
    }
    setTimeout(() => {
      wx.stopPullDownRefresh()
    }, 1000)
  }
})