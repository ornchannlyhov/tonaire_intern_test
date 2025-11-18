const ProductService = require("../services/product.service");
const { success, error } = require("../utils/response");

class ProductController {
  // Get all products
  static async getAll(req, res) {
    try {
      const products = await ProductService.getAll();
      return success(res, "Products fetched", products);
    } catch (err) {
      return error(res, err.message);
    }
  }

  // Get product by ID
  static async getById(req, res) {
    try {
      const id = req.params.id;
      const product = await ProductService.getById(id);

      if (!product) {
        return error(res, "Product not found", 404);
      }

      return success(res, "Product fetched", product);
    } catch (err) {
      return error(res, err.message);
    }
  }

  // Create a new product
  static async create(req, res) {
    try {
      const newProduct = await ProductService.create(req.body);
      return success(res, "Product created", newProduct, 201);
    } catch (err) {
      return error(res, err.message);
    }
  }

  // Update an existing product
  static async update(req, res) {
    try {
      const id = req.params.id;
      await ProductService.update(id, req.body);
      return success(res, "Product updated");
    } catch (err) {
      return error(res, err.message);
    }
  }

  // Delete a product
  static async delete(req, res) {
    try {
      const id = req.params.id;
      await ProductService.delete(id);
      return success(res, "Product deleted");
    } catch (err) {
      return error(res, err.message);
    }
  }
}

module.exports = ProductController;
