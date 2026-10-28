const { showLoading, hideLoading, showError, formatDate } = require('../../utils/util')

Page({
  data: {
    categories: [
      { id: 1, name: '绘本资源', icon: '📚', count: 0 },
      { id: 2, name: '听力材料', icon: '🎧', count: 0 },
      { id: 3, name: '练习题库', icon: '✏️', count: 0 },
      { id: 4, name: '视频课程', icon: '🎬', count: 0 },
      { id: 5, name: '音频材料', icon: '🎵', count: 0 },
      { id: 6, name: '学习工具', icon: '🛠️', count: 0 }
    ],
    resources: [],
    currentCategory: null,
    loading: false,
    searchKeyword: ''
  },

  onLoad() {
    this.loadResources()
  },

  // 选择分类
  selectCategory(e) {
    const categoryId = e.currentTarget.dataset.id
    this.setData({
      currentCategory: categoryId,
      resources: []
    })
    this.loadResources(categoryId)
  },

  // 搜索资源
  onSearchInput(e) {
    this.setData({
      searchKeyword: e.detail.value
    })
  },

  onSearch() {
    this.loadResources(this.data.currentCategory, this.data.searchKeyword)
  },

  // 加载资源列表
  async loadResources(categoryId = null, keyword = '') {
    this.setData({ loading: true })
    showLoading('加载中...')

    // 模拟数据 - 实际应该从API获取
    const mockResources = [
      {
        id: 1,
        title: '英语启蒙绘本系列',
        description: '适合3-6岁儿童的基础英语绘本',
        category: '绘本资源',
        cover: '../../images/placeholder.svg',
        downloadCount: 1280,
        fileSize: '15.2MB',
        uploadTime: '2026-06-20'
      },
      {
        id: 2,
        title: '自然拼读音频全集',
        description: '完整的自然拼读发音教程',
        category: '音频材料',
        cover: '../../images/placeholder.svg',
        downloadCount: 890,
        fileSize: '45.8MB',
        uploadTime: '2026-06-18'
      },
      {
        id: 3,
        title: '日常对话练习视频',
        description: '生活中常用的英语对话场景',
        category: '视频课程',
        cover: '../../images/placeholder.svg',
        downloadCount: 2100,
        fileSize: '320MB',
        uploadTime: '2026-06-15'
      },
      {
        id: 4,
        title: '基础语法练习题',
        description: '适合小学生的英语语法练习',
        category: '练习题库',
        cover: '../../images/placeholder.svg',
        downloadCount: 1560,
        fileSize: '8.5MB',
        uploadTime: '2026-06-12'
      },
      {
        id: 5,
        title: '英语儿歌合集',
        description: '经典英语儿歌，培养语感',
        category: '音频材料',
        cover: '../../images/placeholder.svg',
        downloadCount: 3250,
        fileSize: '68.5MB',
        uploadTime: '2026-06-10'
      }
    ]

    // 过滤资源
    let filteredResources = mockResources
    if (categoryId) {
      const categoryName = this.data.categories.find(c => c.id === categoryId).name
      filteredResources = mockResources.filter(r => r.category === categoryName)
    }
    if (keyword) {
      filteredResources = filteredResources.filter(r =>
        r.title.includes(keyword) || r.description.includes(keyword)
      )
    }

    setTimeout(() => {
      this.setData({
        resources: filteredResources,
        loading: false
      })
      hideLoading()
    }, 500)
  },

  // 下载资源
  downloadResource(e) {
    const resourceId = e.currentTarget.dataset.id
    const resource = this.data.resources.find(r => r.id === resourceId)

    wx.showModal({
      title: '下载资源',
      content: `确定要下载"${resource.title}"吗？`,
      success: (res) => {
        if (res.confirm) {
          wx.showLoading({ title: '下载中...' })
          // 模拟下载过程
          setTimeout(() => {
            wx.hideLoading()
            wx.showToast({
              title: '下载成功',
              icon: 'success'
            })
          }, 2000)
        }
      }
    })
  },

  // 预览资源
  previewResource(e) {
    const resourceId = e.currentTarget.dataset.id
    const resource = this.data.resources.find(r => r.id === resourceId)

    if (resource.category === '视频课程') {
      wx.showToast({
        title: '视频预览功能开发中',
        icon: 'none'
      })
    } else if (resource.category === '音频材料') {
      wx.showToast({
        title: '音频预览功能开发中',
        icon: 'none'
      })
    } else {
      wx.showToast({
        title: '预览功能开发中',
        icon: 'none'
      })
    }
  },

  // 分享资源
  shareResource(e) {
    const resourceId = e.currentTarget.dataset.id
    const resource = this.data.resources.find(r => r.id === resourceId)

    wx.showShareMenu({
      withShareTicket: true
    })

    return {
      title: resource.title,
      path: '/pages/resources/resources',
      imageUrl: resource.cover
    }
  },

  // 下拉刷新
  onPullDownRefresh() {
    this.loadResources(this.data.currentCategory, this.data.searchKeyword)
    setTimeout(() => {
      wx.stopPullDownRefresh()
    }, 1000)
  }
})