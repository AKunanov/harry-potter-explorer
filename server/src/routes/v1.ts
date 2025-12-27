import { createHash } from "crypto";
import express from "express";

const router = express.Router();

const HP_API_BASE = (process.env.HP_API_BASE ?? "https://hp-api.onrender.com").replace(
  /\/+$/,
  ""
);
const HP_API_TIMEOUT_MS = 8000;
const CACHE_TTL_MS = 10 * 60 * 1000;
const CACHE_KEY_CHARACTERS = "characters_all";
const ERROR_LOG_INTERVAL_MS = 60 * 1000;

type HpCharacter = {
  id?: string;
  name?: string;
  house?: string;
  patronus?: string;
  image?: string;
  species?: string;
  gender?: string;
  dateOfBirth?: string;
  yearOfBirth?: number;
  wizard?: boolean;
  ancestry?: string;
  eyeColour?: string;
  hairColour?: string;
  actor?: string;
  alive?: boolean;
  wand?: {
    wood?: string;
    core?: string;
    length?: number;
  };
};

type CharacterPreview = {
  id: string;
  name: string;
  house: string | null;
  patronus: string | null;
  image: string | null;
};

type CharacterDetails = {
  id: string;
  name: string;
  house: string | null;
  patronus: string | null;
  image: string | null;
  species: string | null;
  gender: string | null;
  dateOfBirth: string | null;
  yearOfBirth: number | null;
  wizard: boolean | null;
  ancestry: string | null;
  eyeColour: string | null;
  hairColour: string | null;
  actor: string | null;
  alive: boolean | null;
  wand: {
    wood: string | null;
    core: string | null;
    length: number | null;
  };
};

const houses = [
  {
    id: "gryffindor",
    name: "Gryffindor",
    colors: ["scarlet", "gold"],
    animal: "lion",
    founder: "Godric Gryffindor",
    description: "Bravery, nerve, and chivalry define this house.",
  },
  {
    id: "slytherin",
    name: "Slytherin",
    colors: ["green", "silver"],
    animal: "serpent",
    founder: "Salazar Slytherin",
    description: "Ambition, resourcefulness, and determination lead the way.",
  },
  {
    id: "hufflepuff",
    name: "Hufflepuff",
    colors: ["yellow", "black"],
    animal: "badger",
    founder: "Helga Hufflepuff",
    description: "Loyalty, patience, and fair play are most valued.",
  },
  {
    id: "ravenclaw",
    name: "Ravenclaw",
    colors: ["blue", "bronze"],
    animal: "eagle",
    founder: "Rowena Ravenclaw",
    description: "Wisdom, creativity, and learning are the core traits.",
  },
];

const cache = new Map<string, { data: HpCharacter[]; expiresAt: number }>();
let lastErrorLogAt = 0;

const logUpstreamError = (message: string, error: Error) => {
  const now = Date.now();
  if (now - lastErrorLogAt < ERROR_LOG_INTERVAL_MS) {
    return;
  }
  lastErrorLogAt = now;
  console.error(message, error);
};

const parsePositiveInt = (value: unknown, fallback: number): number => {
  const raw = Array.isArray(value) ? value[0] : value;
  const parsed = Number(raw);

  if (Number.isFinite(parsed) && parsed > 0) {
    return Math.floor(parsed);
  }

  return fallback;
};

const normalizeString = (value: unknown): string | null => {
  if (typeof value !== "string") {
    return null;
  }

  const trimmed = value.trim();
  return trimmed.length > 0 ? trimmed : null;
};

const normalizeNumber = (value: unknown): number | null => {
  if (typeof value === "number" && Number.isFinite(value)) {
    return value;
  }

  return null;
};

const normalizeBoolean = (value: unknown): boolean | null => {
  return typeof value === "boolean" ? value : null;
};

const buildCharacterId = (character: HpCharacter): string => {
  const existingId = normalizeString(character.id);
  if (existingId) {
    return existingId;
  }

  const name = normalizeString(character.name) ?? "";
  const actor = normalizeString(character.actor) ?? "";
  const source = `${name}|${actor}`;

  return createHash("sha1").update(source).digest("hex");
};

const toCharacterPreview = (character: HpCharacter): CharacterPreview => ({
  id: buildCharacterId(character),
  name: normalizeString(character.name) ?? "",
  house: normalizeString(character.house),
  patronus: normalizeString(character.patronus),
  image: normalizeString(character.image),
});

const toCharacterDetails = (character: HpCharacter): CharacterDetails => ({
  id: buildCharacterId(character),
  name: normalizeString(character.name) ?? "",
  house: normalizeString(character.house),
  patronus: normalizeString(character.patronus),
  image: normalizeString(character.image),
  species: normalizeString(character.species),
  gender: normalizeString(character.gender),
  dateOfBirth: normalizeString(character.dateOfBirth),
  yearOfBirth: normalizeNumber(character.yearOfBirth),
  wizard: normalizeBoolean(character.wizard),
  ancestry: normalizeString(character.ancestry),
  eyeColour: normalizeString(character.eyeColour),
  hairColour: normalizeString(character.hairColour),
  actor: normalizeString(character.actor),
  alive: normalizeBoolean(character.alive),
  wand: {
    wood: normalizeString(character.wand?.wood),
    core: normalizeString(character.wand?.core),
    length: normalizeNumber(character.wand?.length),
  },
});

const fetchWithTimeout = async (
  url: string,
  init: RequestInit = {}
): Promise<Response> => {
  const controller = new AbortController();
  const timer = setTimeout(() => controller.abort(), HP_API_TIMEOUT_MS);

  try {
    return await fetch(url, { ...init, signal: controller.signal });
  } finally {
    clearTimeout(timer);
  }
};

const fetchJson = async <T>(
  url: string
): Promise<
  { ok: true; status: number; data: T } | { ok: false; status: number; error: Error }
> => {
  try {
    const response = await fetchWithTimeout(url);
    if (!response.ok) {
      return {
        ok: false,
        status: response.status,
        error: new Error(`HP API responded with ${response.status}`),
      };
    }

    const data = (await response.json()) as T;
    return { ok: true, status: response.status, data };
  } catch (error) {
    const err = error instanceof Error ? error : new Error("Unknown error");
    return { ok: false, status: 0, error: err };
  }
};

const getCachedCharacters = (): HpCharacter[] | null => {
  const entry = cache.get(CACHE_KEY_CHARACTERS);
  if (!entry) {
    return null;
  }

  if (entry.expiresAt <= Date.now()) {
    cache.delete(CACHE_KEY_CHARACTERS);
    return null;
  }

  return entry.data;
};

const setCachedCharacters = (data: HpCharacter[]): void => {
  cache.set(CACHE_KEY_CHARACTERS, {
    data,
    expiresAt: Date.now() + CACHE_TTL_MS,
  });
};

const loadCharactersAll = async (): Promise<
  { ok: true; data: HpCharacter[] } | { ok: false; status: number; error: Error }
> => {
  const cached = getCachedCharacters();
  if (cached) {
    return { ok: true, data: cached };
  }

  const url = `${HP_API_BASE}/api/characters`;
  const result = await fetchJson<HpCharacter[]>(url);
  if (!result.ok) {
    return result;
  }

  if (!Array.isArray(result.data)) {
    return {
      ok: false,
      status: 502,
      error: new Error("HP API returned invalid characters payload"),
    };
  }

  setCachedCharacters(result.data);
  return { ok: true, data: result.data };
};

const sendUpstreamError = (res: express.Response, error: Error) => {
  logUpstreamError("HP API unavailable", error);
  res.status(502).json({
    error: "upstream_unavailable",
    message: "HP API is unavailable",
  });
};

router.get("/health", (_req, res) => {
  res.json({ status: "ok" });
});

router.get("/houses", (_req, res) => {
  res.json(houses);
});

router.get("/characters", async (req, res) => {
  const page = parsePositiveInt(req.query.page, 1);
  const limit = parsePositiveInt(req.query.limit, 20);
  const q = typeof req.query.q === "string" ? req.query.q.trim().toLowerCase() : "";

  const result = await loadCharactersAll();
  if (!result.ok) {
    sendUpstreamError(res, result.error);
    return;
  }

  const filtered = q
    ? result.data.filter((character) => {
        const name = normalizeString(character.name) ?? "";
        return name.toLowerCase().includes(q);
      })
    : result.data;

  const total = filtered.length;
  const start = (page - 1) * limit;
  const items = filtered.slice(start, start + limit).map(toCharacterPreview);

  res.json({
    page,
    limit,
    total,
    items,
  });
});

router.get("/characters/:id", async (req, res) => {
  const { id } = req.params;
  const url = `${HP_API_BASE}/api/character/${id}`;
  const result = await fetchJson<HpCharacter | HpCharacter[]>(url);

  if (result.ok) {
    const data = Array.isArray(result.data) ? result.data[0] : result.data;
    if (!data) {
      res.status(404).json({ error: "not_found", message: "Character not found" });
      return;
    }
    res.json(toCharacterDetails(data));
    return;
  }

  const isNotFound = result.status === 404 || result.status === 400;
  if (!isNotFound) {
    sendUpstreamError(res, result.error);
    return;
  }

  const allResult = await loadCharactersAll();
  if (!allResult.ok) {
    sendUpstreamError(res, allResult.error);
    return;
  }

  const match = allResult.data.find((character) => buildCharacterId(character) === id);
  if (!match) {
    res.status(404).json({ error: "not_found", message: "Character not found" });
    return;
  }

  res.json(toCharacterDetails(match));
});

export default router;
