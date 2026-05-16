# Mermaid — Earlybird theme

Drop-in initialization snippet that makes [Mermaid](https://mermaid.js.org) diagrams look on-brand (Earlybird red + Untitled Sans, light/dark aware) inside any HTML artifact. Pairs with the `mermaid-diagrams` (authoring) and `beautiful-mermaid` (server-side rendering) skills.

## Why this exists

The third-party Mermaid skills ship neutral themes (GitHub Dark/Light, Tokyo Night, Catppuccin…). None are Earlybird. Rather than fork those skills and drift from upstream, this snippet **layers Earlybird's brand vars on top of Mermaid's `base` theme** via `themeVariables`. Re-themes work without touching the upstream skills.

## When to use Mermaid (vs inline SVG)

Mermaid is the right tool for **diagrams whose structure follows a known type**: flowcharts, sequence, state, class, ERD, C4 architecture, gantt, git-graph. The text source is short, version-controllable, and renders correctly in the browser without overlap fixes.

Use **inline SVG** (deterministic Python builder or hand-authored) when:
- The diagram is a `/shape` USM + event storm (`shape` skill's canonical use — fixed sticky sizes, slice swimlanes, Brandolini colors)
- You need pixel-precise control over positions (architecture maps with custom layouts, posters)
- The artifact must be 100% offline-ready as a static file without any JS

Use **Mermaid** otherwise. It's the default for "diagram this lifecycle / sequence / state machine / data model / system architecture."

## Browser-rendered (the 90% case)

For HTML artifacts that will be opened in a modern browser. Mermaid renders client-side; the user sees diagrams immediately, no separate app, no build step.

Drop this `<script type="module">` block in the page `<head>` (or before `</body>`) — anywhere after the Earlybird brand CSS so font names match:

```html
<script type="module">
  import mermaid from 'https://cdn.jsdelivr.net/npm/mermaid@11/dist/mermaid.esm.min.mjs';

  const lightVars = {
    background:        '#F8FCFF',  // --bg
    primaryColor:      '#FD1A1B',  // --red
    primaryTextColor:  '#F8FCFF',
    primaryBorderColor:'#2D1A16',  // --eb-dark
    secondaryColor:    '#FFE066',
    tertiaryColor:     '#B2F2BB',
    lineColor:         '#2D1A16',
    textColor:         '#2D1A16',
    mainBkg:           '#FBF7EE',
    nodeBorder:        '#2D1A16',
    clusterBkg:        '#fff7e6',
    clusterBorder:     '#7a3b09',
    edgeLabelBackground:'#ffffff',
    labelBackground:   '#ffffff',
    labelTextColor:    '#2D1A16',
    // Sequence
    actorBkg:          '#FBF7EE',
    actorBorder:       '#2D1A16',
    actorTextColor:    '#2D1A16',
    actorLineColor:    '#6b6560',
    activationBkgColor:'#FD1A1B',
    activationBorderColor: '#2D1A16',
    sequenceNumberColor:'#F8FCFF',
    signalColor:       '#2D1A16',
    signalTextColor:   '#2D1A16',
    // Notes
    noteBkgColor:      '#FFEC99',
    noteTextColor:     '#3d2c0d',
    noteBorderColor:   '#ca8a04',
    // State
    altBackground:     '#f0f4f7',
    fontFamily:        '"Untitled Sans", Inter, -apple-system, sans-serif',
    fontSize:          '14px',
  };

  const darkVars = {
    ...lightVars,
    background:        '#1a0f0d',
    primaryColor:      '#FD1A1B',
    primaryTextColor:  '#F8FCFF',
    primaryBorderColor:'#F8FCFF',
    lineColor:         '#F8FCFF',
    textColor:         '#F8FCFF',
    mainBkg:           '#251c17',
    nodeBorder:        '#F8FCFF',
    clusterBkg:        '#2f241d',
    clusterBorder:     '#FFB86B',
    edgeLabelBackground:'#251c17',
    labelBackground:   '#251c17',
    labelTextColor:    '#F8FCFF',
    actorBkg:          '#251c17',
    actorBorder:       '#F8FCFF',
    actorTextColor:    '#F8FCFF',
    signalColor:       '#F8FCFF',
    signalTextColor:   '#F8FCFF',
    noteBkgColor:      '#3d2c0d',
    noteTextColor:     '#FFEC99',
    noteBorderColor:   '#ca8a04',
    altBackground:     '#2f241d',
  };

  function applyTheme() {
    const isDark = document.documentElement.classList.contains('dark');
    mermaid.initialize({
      startOnLoad: false,
      theme: 'base',
      themeVariables: isDark ? darkVars : lightVars,
      fontFamily: '"Untitled Sans", Inter, sans-serif',
      flowchart: { curve: 'basis', useMaxWidth: true, htmlLabels: true },
      sequence: { actorMargin: 50, useMaxWidth: true },
    });
    // Re-render every .mermaid block
    document.querySelectorAll('.mermaid').forEach((el) => {
      // Restore original source if we've already rendered once
      if (el.dataset.source) el.textContent = el.dataset.source;
      else el.dataset.source = el.textContent;
      el.removeAttribute('data-processed');
    });
    mermaid.run({ nodes: document.querySelectorAll('.mermaid') });
  }

  applyTheme();
  // Reapply on theme toggle — html-output's `d` keybind toggles html.dark
  new MutationObserver(applyTheme).observe(document.documentElement, { attributes: true, attributeFilter: ['class'] });
</script>
```

Then write Mermaid sources inline:

```html
<pre class="mermaid">
sequenceDiagram
  participant U as User
  participant CLI as ebsk CLI
  participant API as Registry
  U->>CLI: ebsk sync
  CLI->>API: GET /api/skills/workspace/eng
  API-->>CLI: index + signed URLs
  CLI->>CLI: install/uninstall to match
  CLI-->>U: "12 installed, 1 removed"
</pre>
```

The block re-renders automatically when the user presses `d` to toggle light/dark.

## Server-side rendered (the 10% case)

When the artifact must be 100% static — no client JS, no Mermaid runtime — use the `beautiful-mermaid` skill to render Mermaid source to SVG **before** embedding. The Earlybird theme isn't a `beautiful-mermaid` preset, so render with `default` and then post-process the SVG with these find-replace passes (or inject a `<style>` block at the top of the SVG to recolor):

```css
/* Earlybird overrides for beautiful-mermaid SVG output */
.mermaid svg .node rect, .mermaid svg .node polygon {
  fill: #FBF7EE !important;
  stroke: #2D1A16 !important;
}
.mermaid svg .node text { font-family: 'Untitled Sans', Inter, sans-serif !important; fill: #2D1A16 !important; }
.mermaid svg .edgePath path { stroke: #2D1A16 !important; }
.mermaid svg .cluster rect { fill: #fff7e6 !important; stroke: #7a3b09 !important; }
.mermaid svg .actor { fill: #FBF7EE !important; stroke: #2D1A16 !important; }
.mermaid svg text.actor { fill: #2D1A16 !important; }
```

Server-side is heavier — prefer the browser-rendered path unless the artifact must work without network access (offline distribution, archival snapshots).

## Headlines on diagrams

Mermaid renders all text in a single font. Headlines and labels stay in Untitled Sans for legibility. If you need to break in Condensed Sans No10 for a specific diagram-level title, do it in the *surrounding HTML* (e.g. `<h2 class="section-title">Lifecycle</h2>` above the `<pre class="mermaid">` block) rather than inside the diagram. Mermaid handles content; the brand chrome handles framing.

## See also

- [`mermaid-diagrams`](../../../mermaid-diagrams/SKILL.md) — Mermaid syntax authoring guide (the diagram types and their grammars).
- [`beautiful-mermaid`](../../../beautiful-mermaid/SKILL.md) — server-side SVG rendering (when you need pre-rendered output).
- `feedback_shape_inline_svg_canvas` — why `/shape` USM + event storm stays as deterministic inline SVG, not Mermaid.
