const express = require("express");
const cors = require("cors");
require("dotenv").config();

const productRoutes = require("./routes/product.routes");
const apiHealthRoutes = require("./routes/apiHealth.routes");

const app = express();
app.use(cors());
app.use(express.json());

app.use("/api/health", apiHealthRoutes);
app.use("/products", productRoutes);

app.listen(process.env.PORT, () =>
  console.log(`Server running on port ${process.env.PORT}`)
);
