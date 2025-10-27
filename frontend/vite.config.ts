/// <reference types="vitest" />

import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

// https://vitejs.dev/config/
export default defineConfig({
  // Use base path for GitHub Pages deployment
  // Set to '/' for local development or custom domain
  base: process.env.VITE_BASE_PATH || '/',
  plugins: [react()],
  test: {
    globals: true,
    environment: 'jsdom',
    setupFiles: ['src/setupTest.ts'],
    coverage: {
      reporter: ['text', 'json', 'html', 'cobertura'],
    },
  },
})
