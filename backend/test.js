import sql from './db/db.js';
import 'dotenv/config'

async function testConnection() {
  try {
    // Simple query to check connection
    const result = await sql`SELECT NOW() AS current_time`;

    console.log('✅ Connected to database!');
    console.log('Current time from DB:', result[0].current_time);

    process.exit(0); // Exit after success
  } catch (err) {
    console.error('❌ Database connection failed:', err);
    process.exit(1);
  }
}

testConnection();
