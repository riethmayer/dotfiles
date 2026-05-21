import React, { useEffect, useState, useCallback } from 'react';
import { createRoot } from 'react-dom/client';
import { Tldraw } from 'tldraw';
import 'tldraw/tldraw.css';

// Storms bundled in ../assets. Order matches the way we want to walk them
// during iteration: Big Picture → Process → Software Design → Insurance.
const STORMS = [
  { id: 'ecommerce-bp',      title: '1. Shop · Big Picture'      },
  { id: 'ecommerce-process', title: '2. Shop · Process Modeling' },
  { id: 'ecommerce-sd',      title: '3. Shop · Software Design'  },
  { id: 'insurance-claims',  title: '4. Insurance · Process'     },
];

function App() {
  const [current, setCurrent] = useState(STORMS[0].id);
  const [editor, setEditor] = useState(null);
  const [status, setStatus] = useState('');

  const loadStorm = useCallback(async (id, ed) => {
    const e = ed ?? editor;
    if (!e) return;
    setStatus(`loading ${id}…`);
    try {
      const url = `/storms/${id}.tldr`;
      const res = await fetch(url);
      if (!res.ok) throw new Error(`fetch ${url}: ${res.status}`);
      const data = await res.json();

      // Don't replace the whole store via loadStoreSnapshot — that wipes
      // the editor's required instance/cameraId records and crashes.
      // Instead: clear existing user shapes on the current page, then
      // recreate from the .tldr's shape records.
      const currentPageId = e.getCurrentPageId();
      const existing = e.getCurrentPageShapes();
      if (existing.length) e.deleteShapes(existing.map((s) => s.id));

      const shapes = data.records
        .filter((r) => r.typeName === 'shape')
        .map((r) => ({
          // Re-parent every shape under the current page (the .tldr's page id
          // doesn't exist in this editor's store).
          ...r,
          parentId: currentPageId,
        }));
      e.createShapes(shapes);

      setTimeout(() => {
        try { e.zoomToFit({ animation: { duration: 0 } }); } catch {}
      }, 100);
      setStatus(`loaded · ${id} · ${shapes.length} shapes`);
    } catch (err) {
      console.error(err);
      setStatus(`error: ${err.message}`);
    }
  }, [editor]);

  useEffect(() => {
    if (editor) loadStorm(current, editor);
  }, [current, editor, loadStorm]);

  return (
    <div style={{ position: 'fixed', inset: 0, display: 'flex' }}>
      <aside style={{
        width: 220, padding: 14, borderRight: '1px solid #e2dccb',
        background: '#fbf7ee', color: '#1e1e1e', overflowY: 'auto',
        display: 'flex', flexDirection: 'column', gap: 6,
      }}>
        <h2 style={{ margin: '4px 0 12px', fontSize: 14, color: '#7a1a1a' }}>event-storms</h2>
        {STORMS.map((s) => (
          <button
            key={s.id}
            onClick={() => setCurrent(s.id)}
            style={{
              padding: '8px 10px', textAlign: 'left', border: '1px solid #d9d2c1',
              borderRadius: 6, background: current === s.id ? '#fff3b0' : '#fff',
              fontWeight: current === s.id ? 700 : 500, fontSize: 12,
              cursor: 'pointer',
            }}
          >{s.title}</button>
        ))}
        <button
          onClick={() => editor && loadStorm(current, editor)}
          style={{
            marginTop: 14, padding: '6px 10px', border: '1px solid #d9d2c1',
            borderRadius: 6, background: '#fff', fontSize: 11, cursor: 'pointer',
          }}
        >↻ reload</button>
        <div style={{
          marginTop: 'auto', fontSize: 11, color: '#6b6560', padding: '8px 0',
          borderTop: '1px solid #e2dccb',
        }}>{status}</div>
      </aside>
      <div style={{ flex: 1, position: 'relative' }}>
        <Tldraw onMount={setEditor} />
      </div>
    </div>
  );
}

createRoot(document.getElementById('root')).render(<App />);
