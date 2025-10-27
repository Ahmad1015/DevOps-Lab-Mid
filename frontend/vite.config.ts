/// <reference types="vitest" />

import { defineConfig, loadEnv } from 'vite'
import react from '@vitejs/plugin-react'

// https://vitejs.dev/config/
export default defineConfig(({ mode }) => {
  const env = loadEnv(mode, process.cwd(), '')
  
  return {
    // Use base path for GitHub Pages deployment
    // Set to '/' for local development or custom domain
    base: env.VITE_BASE_PATH || '/',
    plugins: [react()],
    test: {
      globals: true,
      environment: 'jsdom',
      setupFiles: ['src/setupTest.ts'],
      coverage: {
        reporter: ['text', 'json', 'html', 'cobertura'],
      },
    },
  }
})
