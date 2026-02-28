const express = require("express");
const axios = require("axios");

const app = express();
const PORT = 3000;

// IMPORTANT: This will be replaced in Kubernetes
const BACKEND_URL = process.env.BACKEND_URL || "http://localhost:8000";

app.get("/", async (req, res) => {
  try {
    const response = await axios.get(`${BACKEND_URL}/api/message`);
    res.send(`
      <h1>Frontend Service 🚀</h1>
      <p>Backend says: ${response.data.message}</p>
    `);
  } catch (error) {
    res.send("<h1>Error connecting to backend 😅</h1>");
  }
});

app.listen(PORT, () => {
  console.log(`Frontend running on port ${PORT}`);
});
