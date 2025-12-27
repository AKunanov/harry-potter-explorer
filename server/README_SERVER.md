# Server

## Local run
1. `cd server`
2. `npm install`
3. `npm run dev`
4. `curl http://localhost:3000/health`

## Environment variables
- `PORT`: HTTP port for the server. Default: `3000`.
- `HP_API_BASE`: base URL for the upstream HP API. Default: `https://hp-api.onrender.com`.

## curl examples
- Health check:
  `curl http://localhost:3000/health`
- List houses:
  `curl http://localhost:3000/v1/houses`
- List characters (paging + search):
  `curl "http://localhost:3000/v1/characters?page=1&limit=5&q=harry"`
- Character details (use an `id` from the list response):
  `curl http://localhost:3000/v1/characters/<id>`

## Note
Free hosting can go to sleep. The first request after idle may be slow.
