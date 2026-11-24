// Retired service worker (2026-11-23). The old cache-first worker precached the previous theme's
// CSS and JS. Browsers that still have it installed fetch this file on their next visit; it clears
// every cache, unregisters itself and reloads open tabs so they get the current site.
self.addEventListener('install', () => self.skipWaiting());
self.addEventListener('activate', (event) => {
  event.waitUntil((async () => {
    const keys = await caches.keys();
    await Promise.all(keys.map((k) => caches.delete(k)));
    await self.registration.unregister();
    const clientList = await self.clients.matchAll({ type: 'window' });
    clientList.forEach((c) => c.navigate(c.url));
  })());
});
