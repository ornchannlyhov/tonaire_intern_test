const express = require("express");
const router = express.Router();
const ProductController = require("../controllers/product.controller");
const validateProduct = require("../middlewares/validateProduct");

// Get all products
router.get("/", ProductController.getAll);

// Get product by ID
router.get("/:id", ProductController.getById);

// Create a new product
router.post("/", validateProduct, ProductController.create);

// Update an existing product
router.put("/:id", validateProduct, ProductController.update);

// Delete a product
router.delete("/:id", ProductController.delete);

module.exports = router;
