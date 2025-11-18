const express = require("express");
const router = express.Router();
const { success } = require("../utils/response");

router.get("/", (req, res) => {
  return success(res, "API is healthy", {
    uptime: process.uptime(),
    timestamp: new Date(),
  });
});

module.exports = router;
