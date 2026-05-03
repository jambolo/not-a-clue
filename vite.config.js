import { defineConfig, transformWithOxc } from 'vite'
import react from '@vitejs/plugin-react'

const jsxInJs = {
  name: 'jsx-in-js',
  enforce: 'pre',
  async transform(code, id) {
    if (/src\/.*\.js$/.test(id)) {
      return transformWithOxc(code, id, { lang: 'jsx' })
    }
  }
}

export default defineConfig({
  plugins: [jsxInJs, react()],
  optimizeDeps: {
    rolldownOptions: {
      moduleTypes: {
        '.js': 'jsx'
      }
    }
  },
  server: {
    port: 3000,
    open: true
  },
  build: {
    outDir: 'dist',
    emptyOutDir: true,
    sourcemap: false
  },
  publicDir: 'public'
})
