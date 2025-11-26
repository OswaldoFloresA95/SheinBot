import dotenv from "dotenv";
dotenv.config();

export const config = {
  PORT: process.env.PORT || 3000,

  DATABASE_URL: process.env.DATABASE_URL,

  EMBEDDINGS_API_KEY: process.env.EMBEDDINGS_API_KEY,
  LLM_API_KEY: process.env.LLM_API_KEY,
  EMBEDDINGS_DIM: process.env.EMBEDDINGS_DIM,
  API_PROVIDER: process.env.API_PROVIDER
};
