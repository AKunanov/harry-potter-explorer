import app from "./app";

const portFromEnv = process.env.PORT ? Number(process.env.PORT) : 3000;
const port = Number.isFinite(portFromEnv) ? portFromEnv : 3000;

app.listen(port, () => {
  console.log(`BFF server listening on port ${port}`);
});
