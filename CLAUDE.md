# CLAUDE.md

This file provides general guidance to Claude Code (claude.ai/code).

## General Instructions for Claude

### Token Discipline

- Be concise by default.
- No explanations unless explicitly requested.
- No restating the question.
- No summaries at the end.
- Use bullet points only when clarity improves.
- Prefer short sentences.
- Assume reader is expert.

### Output Rules

- Answer the question directly.
- Do not add context, background, or alternatives unless asked.
- If uncertain, say "unknown" or ask one clarifying question.

### Code

- Output code only, no commentary.
- Prefer minimal, idiomatic solutions.
- Limit comments to very brief descriptions of what the code does. Do not describe why changes were made.

### Interaction

- Ask at most one clarifying question.
- Never suggest next steps unless requested.

## Project: Not A Clue

Assistant for playing the board game Clue.

### Tech Stack

- React 18 with MUI 6 (Material UI)
- Vite for build/dev
- Vitest for testing
- CoffeeScript source files

### Project Structure

```
cs/              # CoffeeScript source files (edit these)
src/             # Generated JavaScript (do not edit directly)
public/          # Static assets (favicon, manifest, icons)
index.html       # Vite entry point
vite.config.js   # Vite configuration
```

### Build Workflow

CoffeeScript files in `cs/` are compiled to JavaScript in `src/`. The `src/*.js` files are gitignored as generated artifacts.

### Commands

| Command | Description |
|---------|-------------|
| `pnpm dev` | Start dev server on port 3000 |
| `pnpm build` | Production build to `dist/` |
| `pnpm preview` | Preview production build |
| `pnpm test` | Run tests with Vitest |
| `pnpm compile` | Compile CoffeeScript to JavaScript |
| `pnpm watch` | Watch and compile CoffeeScript |

### Key Files

- `cs/App.coffee` - Main application component
- `cs/Solver.coffee` - Core game logic/solver
- `src/registerServiceWorker.js` - PWA service worker (plain JS, not from CoffeeScript)

### Notes

- JSX is used in `.js` files (generated from CoffeeScript)
- Vite configured to handle JSX in `.js` files via `esbuild.loader`
- Uses `import.meta.env.PROD` instead of `process.env.NODE_ENV`

### Bumping Minor Version

1. Create release branch, update version in `package.json` and `cs/version.coffee`, commit:

   ```bash
   git checkout -b release/<version>
   # edit package.json and cs/version.coffee
   git add package.json cs/version.coffee && git commit -m "Bumped version to <version>"
   ```

2. Merge to master, tag, and push:

   ```bash
   git checkout master && git merge --no-ff release/<version>
   git tag v<version> && git push origin master v<version>
   ```

3. Merge to develop and clean up:

   ```bash
   git checkout develop && git merge --no-ff master && git push origin develop
   git branch -d release/<version>
   ```
