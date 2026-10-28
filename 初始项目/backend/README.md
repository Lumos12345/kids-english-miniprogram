# 少儿英语辅导小程序 - 后端服务

本项目后端基于 **Node.js + Express + MySQL**，提供完整的 API 接口。

> 完整项目文档请查看项目根目录 `README.md`

## 快速启动

```bash
# 启动 MySQL
sudo service mysql start

# 启动后端 (推荐从 /tmp/testserver 运行)
/tmp/testserver/start.sh
```

## 项目结构

```
backend/
├── server-full.js           # 完整服务（连接数据库）
├── server-mock.js           # 模拟服务（无需数据库）
├── src/
│   ├── config/database.js   # MySQL 连接池
│   ├── middleware/           # 认证、错误处理、验证
│   │   ├── auth.js
│   │   ├── errorHandler.js
│   │   └── validator.js
│   ├── routes/              # 路由定义
│   │   ├── auth.js          # 登录/注册
│   │   ├── users.js         # 用户信息
│   │   ├── courses.js       # 课程
│   │   ├── study.js         # 学习记录
│   │   ├── assignments.js   # 作业
│   │   ├── scores.js        # 成绩
│   │   └── vocabulary.js    # 词汇
│   ├── controllers/         # 业务逻辑
│   └── utils/auth.js        # JWT + bcrypt
├── .env                     # 环境变量
└── test-db.js               # 数据库连接测试
```

## API 清单

共 **28 个接口**，详见根目录 `README.md`。

## 测试账号

| 用户名 | 密码 | 角色 |
|--------|------|------|
| admin | 123456 | 管理员 |
| teacher1 | 123456 | 教师 |
| student1 | 123456 | 学生 |
| student2 | 123456 | 学生 |
| parent1 | 123456 | 家长 |
