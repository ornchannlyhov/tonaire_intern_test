module.exports = (req, res, next) => {
  const { productName, price, stock } = req.body;

  if (!productName || productName.trim() === "")
    return res.status(400).json({ message: "Product name is required" });

  if (price <= 0 || isNaN(price))
    return res.status(400).json({ message: "Price must be positive" });

  if (stock < 0 || isNaN(stock))
    return res.status(400).json({ message: "Stock must be >= 0" });

  next();
};
