class Product {
  constructor({ productid, productname, price, stock }) {
    this.id = productid;
    this.name = productname;
    this.price = price;
    this.stock = stock;
  }
}

module.exports = Product;
