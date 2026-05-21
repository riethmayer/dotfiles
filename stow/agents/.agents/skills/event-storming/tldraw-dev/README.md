# tldraw-dev

Local Vite + React + tldraw app for inspecting and iterating on the bundled event-storms. The sidebar switches between the four canonical storms (`ecommerce-bp`, `ecommerce-process`, `ecommerce-sd`, `insurance-claims`); the canvas is full tldraw — pan, zoom, drag, edit, draw your own arrows.

## Run

```sh
npm install     # once
npm run dev     # starts vite at http://localhost:5173
```

The dev server serves `public/storms/` which is symlinked to `../assets/`, so any `.tldr` file dropped in `assets/` shows up immediately.

## Add a new storm to the sidebar

Edit `src/main.jsx` and add to the `STORMS` array:

```js
const STORMS = [
  { id: 'ecommerce-bp',      title: '1. Shop · Big Picture' },
  ...
  { id: 'my-new-storm',      title: '5. My new storm' },
];
```

The `id` must match the filename (`assets/my-new-storm.tldr`).

## How it loads .tldr files

The `.tldr` file format includes a `schema` field with migration version numbers we can't easily generate from Python. To work around this, the dev app does NOT use `loadStoreSnapshot` directly:

1. Fetch the `.tldr` JSON.
2. Filter to just `shape` records.
3. Reparent them under the current page.
4. Call `editor.createShapes(shapes)` — same API the user uses interactively.

This sidesteps schema mismatches and lets the editor manage its own document/page/instance records.

## Iterate loop

1. Edit `../assets/<name>.storm.json`.
2. From the skill root: `python scripts/build_tldraw.py assets/<name>.storm.json --out assets/<name>.tldr`.
3. Click "↻ reload" in the sidebar (or switch storms and back).

Vite's file watcher picks up `.tldr` changes automatically — clicking reload re-fetches.
