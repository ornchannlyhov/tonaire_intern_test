const { poolPromise, sql } = require("../config/db");
const Product = require("../models/product.model");

class ProductService {
  // Get all products
  static async getAll() {
    const pool = await poolPromise;
    const result = await pool.request().query("SELECT * FROM PRODUCTS");

    // Map SQL rows to Product model objects
    return result.recordset.map((row) => new Product(row));
  }

  // Get product by ID
  static async getById(id) {
    const pool = await poolPromise;
    const result = await pool
      .request()
      .input("id", sql.Int, id)
      .query("SELECT * FROM PRODUCTS WHERE PRODUCTID = @id");

    const record = result.recordset[0];

    return record ? new Product(record) : null;
  }

  // Create product
  static async create(data) {
    const { productName, price, stock } = data;
    const pool = await poolPromise;

    const result = await pool
      .request()
      .input("productName", sql.NVarChar, productName)
      .input("price", sql.Decimal(10, 2), price)
      .input("stock", sql.Int, stock).query(`
        INSERT INTO PRODUCTS (PRODUCTNAME, PRICE, STOCK)
        OUTPUT INSERTED.*
        VALUES (@productName, @price, @stock)
      `);

    return new Product(result.recordset[0]);
  }

  // Update product
  static async update(id, data) {
    const { productName, price, stock } = data;
    const pool = await poolPromise;

    const result = await pool
      .request()
      .input("id", sql.Int, id)
      .input("productName", sql.NVarChar, productName)
      .input("price", sql.Decimal(10, 2), price)
      .input("stock", sql.Int, stock).query(`
        UPDATE PRODUCTS
        SET PRODUCTNAME = @productName,
            PRICE = @price,
            STOCK = @stock
        OUTPUT INSERTED.*
        WHERE PRODUCTID = @id
      `);

    const record = result.recordset[0];
    return record ? new Product(record) : null;
  }

  // Delete product
  static async delete(id) {
    const pool = await poolPromise;

    const result = await pool.request().input("id", sql.Int, id).query(`
        DELETE FROM PRODUCTS
        OUTPUT DELETED.*
        WHERE PRODUCTID = @id
      `);

    const record = result.recordset[0];
    return record ? new Product(record) : null;
  }
}

module.exports = ProductService;
