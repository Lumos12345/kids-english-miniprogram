const mysql = require('mysql2/promise');

async function testConnection() {
  console.log('Testing MySQL connection...');

  const configs = [
    {
      name: 'localhost connection',
      config: {
        host: 'localhost',
        port: 3306,
        user: 'root',
        password: 'root',
        database: 'english_tutoring_system'
      }
    },
    {
      name: '127.0.0.1 connection',
      config: {
        host: '127.0.0.1',
        port: 3306,
        user: 'root',
        password: 'root',
        database: 'english_tutoring_system'
      }
    },
    {
      name: 'Windows IP connection',
      config: {
        host: '172.19.225.1',
        port: 3306,
        user: 'root',
        password: 'root',
        database: 'english_tutoring_system'
      }
    }
  ];

  for (const test of configs) {
    console.log(`\nTesting ${test.name}...`);
    try {
      const connection = await mysql.createConnection(test.config);
      console.log(`✓ ${test.name} successful!`);

      // 测试查询
      const [rows] = await connection.execute('SELECT COUNT(*) as count FROM users');
      console.log(`✓ Query successful! Found ${rows[0].count} users`);

      await connection.end();
    } catch (error) {
      console.log(`✗ ${test.name} failed:`, error.message);
    }
  }
}

testConnection();