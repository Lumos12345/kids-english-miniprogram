// pages/courses/courses.js
const app = getApp()

Page({
  data: {
    categories: [],
    courses: [],
    selectedCategory: 0,
    searchKeyword: '',
    filterLevel: '',
    filterPrice: '',
    showFilter: false,
    loading: false,
    hasMore: true,
    currentPage: 1,
    pageSize: 10
  },

  onLoad(options) {
    this.loadCategories()
    this.loadCourses()
  },

  onPullDownRefresh() {
    this.setData({
      currentPage: 1,
      courses: []
    })
    this.loadCourses()
  },

  onReachBottom() {
    if (this.data.hasMore && !this.data.loading) {
      this.loadMore()
    }
  },

  // 加载课程分类（从课程数据中提取不重复的分类）
  loadCategories() {
    // 分类数据随课程列表一起加载，无需单独请求
  },

  // 加载课程列表
  loadCourses(reset = false) {
    if (reset) {
      this.setData({
        currentPage: 1,
        courses: []
      })
    }

    this.setData({ loading: true })

    // 构建请求参数，过滤掉 undefined 的值
    const params = {
      page: this.data.currentPage,
      limit: this.data.pageSize
    }
    if (this.data.selectedCategory) params.category_id = this.data.selectedCategory
    if (this.data.searchKeyword) params.keyword = this.data.searchKeyword
    if (this.data.filterLevel) params.level = this.data.filterLevel
    if (this.data.filterPrice === 'free') params.is_free = true
    if (this.data.filterPrice === 'paid') params.is_free = false

    app.request({
      url: '/api/courses',
      method: 'GET',
      data: params,
      success: (res) => {
        const courseList = res.data.courses || res.data.list || []
        this.setData({
          courses: reset ? courseList : [...this.data.courses, ...courseList],
          hasMore: courseList.length >= this.data.pageSize,
          currentPage: this.data.currentPage + 1
        })
      },
      fail: (err) => {
        console.error('加载课程失败', err)
        app.showToast('加载课程失败')
      },
      complete: () => {
        this.setData({ loading: false })
        wx.stopPullDownRefresh()
      }
    })
  },

  // 加载更多
  loadMore() {
    this.loadCourses()
  },

  // 搜索输入
  onSearchInput(e) {
    this.setData({
      searchKeyword: e.detail.value
    })
  },

  // 搜索
  onSearch() {
    this.loadCourses(true)
  },

  // 选择分类
  selectCategory(e) {
    const categoryId = e.currentTarget.dataset.id
    this.setData({
      selectedCategory: categoryId
    })
    this.loadCourses(true)
  },

  // 显示筛选模态框
  showFilterModal() {
    this.setData({ showFilter: true })
  },

  // 隐藏筛选模态框
  hideFilterModal() {
    this.setData({ showFilter: false })
  },

  // 阻止事件冒泡
  stopPropagation() {
    // 阻止点击模态框内容时关闭模态框
  },

  // 选择难度级别
  selectLevel(e) {
    const level = e.currentTarget.dataset.level
    this.setData({ filterLevel: level })
  },

  // 选择价格类型
  selectPrice(e) {
    const price = e.currentTarget.dataset.price
    this.setData({ filterPrice: price })
  },

  // 重置筛选
  resetFilter() {
    this.setData({
      filterLevel: '',
      filterPrice: ''
    })
  },

  // 应用筛选
  applyFilter() {
    this.hideFilterModal()
    this.loadCourses(true)
  },

  // 导航到课程详情
  navigateToDetail(e) {
    const courseId = e.currentTarget.dataset.id
    wx.navigateTo({
      url: `/pages/courses/detail?id=${courseId}`
    })
  }
})