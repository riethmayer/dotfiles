import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';
import { fileURLToPath } from 'node:url';
import path from 'node:path';

const __dirname = path.dirname(fileURLToPath(import.meta.url));

export default defineConfig({
  plugins: [react()],
  server: {
    fs: {
      // allow serving files from ../assets so the app can fetch storm.tldr
      allow: [path.resolve(__dirname, '..')],
    },
  },
});
