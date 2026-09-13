/* coi-serviceworker — adds Cross-Origin-Isolation headers via a service worker
   so that SharedArrayBuffer / WASM threads work on static hosts (GitHub Pages).
   Based on https://github.com/gzuidhof/coi-serviceworker (MIT licence). */

if (typeof window === 'undefined') {
  /* ── Service-worker side ── */
  self.addEventListener('install', () => self.skipWaiting());
  self.addEventListener('activate', (e) => e.waitUntil(self.clients.claim()));

  self.addEventListener('fetch', (e) => {
    const req = e.request;
    // Skip opaque / only-if-cached requests that can't be re-fetched
    if (req.cache === 'only-if-cached' && req.mode !== 'same-origin') return;

    e.respondWith(
      fetch(req)
        .then((res) => {
          if (res.status === 0) return res;           // opaque — pass through
          const h = new Headers(res.headers);
          h.set('Cross-Origin-Opener-Policy',   'same-origin');
          h.set('Cross-Origin-Embedder-Policy', 'require-corp');
          return new Response(res.body, {
            status: res.status, statusText: res.statusText, headers: h,
          });
        })
        .catch(() => fetch(req))                      // network error fallback
    );
  });
} else {
  /* ── Main-thread side — register this script as a SW ── */
  (() => {
    if (window.crossOriginIsolated) return;           // already isolated, done

    const reloaded = sessionStorage.getItem('coiReload');
    sessionStorage.removeItem('coiReload');

    navigator.serviceWorker
      .register(document.currentScript.src)
      .then((reg) => {
        const reload = () => {
          sessionStorage.setItem('coiReload', '1');
          location.reload();
        };
        if (reloaded) return;                         // avoid reload loop
        if (reg.installing) {
          reg.installing.addEventListener('statechange', (ev) => {
            if (ev.target.state === 'activated') reload();
          });
        } else if (reg.active) {
          reload();
        }
      })
      .catch((err) => console.warn('COI service worker failed:', err));
  })();
}
