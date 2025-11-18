const sql = require("mssql");

const dbConfig = {
  user: process.env.DB_USER,
  password: process.env.DB_PASS,
  server: process.env.DB_HOST,
  database: process.env.DB_NAME,
  options: {
    encrypt: false,
    trustServerCertificate: true,
  },
};

const poolPromise = new sql.ConnectionPool(dbConfig)
  .connect()
  .then((pool) => {
    console.log("SQL Server connected");
    return pool;
  })
  .catch((err) => console.log(" DB Connection failed:", err));

module.exports = { sql, poolPromise };
