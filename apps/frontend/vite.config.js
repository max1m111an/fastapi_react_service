import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

export default defineConfig({
  plugins: [react()],
  server: {
    host: true,
    port: 3000,
    proxy: {
      '/api': 'http://localhost:8080',
      '/docs': 'http://localhost:8080',
      '/openapi.json': 'http://localhost:8080',
      '/hello': 'http://localhost:8080',
    },
  },
});
