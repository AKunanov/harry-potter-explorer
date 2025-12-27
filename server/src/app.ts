import cors from "cors";
import express from "express";
import v1Router from "./routes/v1";

const app = express();

app.get("/health", (_req, res) => {
  res.json({ status: "ok" });
});

app.get("/", (_req, res) => {
  res.type("text/plain").send("Harry Potter Explorer BFF");
});

app.use(cors());
app.use(express.json());

app.use("/v1", v1Router);

export default app;
