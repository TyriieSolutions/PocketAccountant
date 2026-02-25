const { Pool } = require('pg');
const logger = require('../utils/logger');

// Database connection pool configuration
const poolConfig = {
  host: process.env.DB_HOST || 'localhost',
  port: process.env.DB_PORT || 5432,
  database: process.env.DB_NAME || 'pocketaccountant',
  user: process.env.DB_USER || 'pocketadmin',
  password: process.env.DB_PASSWORD || 'changeme123',
  max: 20, // Maximum number of clients in the pool
  idleTimeoutMillis: 30000, // How long a client is allowed to remain idle before being closed
  connectionTimeoutMillis: 2000, // How long to wait for a connection
};

// Create connection pool
const pool = new Pool(poolConfig);

// Test database connection
async function testConnection() {
  let client;
  try {
    client = await pool.connect();
    const result = await client.query('SELECT NOW() as current_time, version() as version');
    logger.info('Database connection test successful:', {
      currentTime: result.rows[0].current_time,
      version: result.rows[0].version.substring(0, 50) + '...',
    });
    return true;
  } catch (error) {
    logger.error('Database connection test failed:', error.message);
    return false;
  } finally {
    if (client) client.release();
  }
}

// Connect to database
async function connectToDatabase() {
  logger.info('Attempting to connect to database...', {
    host: poolConfig.host,
    port: poolConfig.port,
    database: poolConfig.database,
    user: poolConfig.user,
  });

  let retries = 5;
  while (retries > 0) {
    const connected = await testConnection();
    if (connected) {
      logger.info('Database connection established successfully');
      return;
    }
    
    retries--;
    if (retries > 0) {
      logger.warn(`Database connection failed. Retrying in 5 seconds... (${retries} retries left)`);
      await new Promise(resolve => setTimeout(resolve, 5000));
    }
  }
  
  throw new Error('Failed to connect to database after multiple attempts');
}

// Query helper function
async function query(text, params) {
  const start = Date.now();
  try {
    const result = await pool.query(text, params);
    const duration = Date.now() - start;
    
    logger.databaseLog(
      'query',
      extractTableFromQuery(text),
      text,
      duration
    );
    
    return result;
  } catch (error) {
    const duration = Date.now() - start;
    logger.error('Database query error:', {
      query: text,
      params,
      duration: `${duration}ms`,
      error: error.message,
    });
    throw error;
  }
}

// Transaction helper function
async function transaction(callback) {
  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    const result = await callback(client);
    await client.query('COMMIT');
    return result;
  } catch (error) {
    await client.query('ROLLBACK');
    throw error;
  } finally {
    client.release();
  }
}

// Extract table name from query for logging
function extractTableFromQuery(queryText) {
  const lowerQuery = queryText.toLowerCase().trim();
  
  if (lowerQuery.startsWith('insert into')) {
    const match = lowerQuery.match(/insert into\s+(\w+)/);
    return match ? match[1] : 'unknown';
  }
  
  if (lowerQuery.startsWith('update')) {
    const match = lowerQuery.match(/update\s+(\w+)/);
    return match ? match[1] : 'unknown';
  }
  
  if (lowerQuery.startsWith('delete from')) {
    const match = lowerQuery.match(/delete from\s+(\w+)/);
    return match ? match[1] : 'unknown';
  }
  
  if (lowerQuery.startsWith('select')) {
    const fromMatch = lowerQuery.match(/from\s+(\w+)/);
    return fromMatch ? fromMatch[1] : 'unknown';
  }
  
  return 'unknown';
}

// Health check function
async function healthCheck() {
  try {
    const result = await query('SELECT 1 as status');
    return {
      status: 'healthy',
      database: 'connected',
      timestamp: new Date().toISOString(),
    };
  } catch (error) {
    return {
      status: 'unhealthy',
      database: 'disconnected',
      error: error.message,
      timestamp: new Date().toISOString(),
    };
  }
}

// Event listeners for pool
pool.on('connect', (client) => {
  logger.debug('New client connected to database pool');
});

pool.on('acquire', (client) => {
  logger.debug('Client acquired from pool');
});

pool.on('release', (client) => {
  logger.debug('Client released back to pool');
});

pool.on('error', (err, client) => {
  logger.error('Unexpected error on idle client', err);
});

// Graceful shutdown
async function closePool() {
  logger.info('Closing database connection pool...');
  await pool.end();
  logger.info('Database connection pool closed');
}

// Export functions and pool
module.exports = {
  pool,
  query,
  transaction,
  connectToDatabase,
  testConnection,
  healthCheck,
  closePool,
};