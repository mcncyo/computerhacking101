// Register Service Worker
if ('serviceWorker' in navigator) {
  window.addEventListener('load', () => {
    navigator.serviceWorker.register('/sw.js')
      .then(registration => {
        console.log('ServiceWorker registration successful');
        
        // Check for updates
        registration.addEventListener('updatefound', () => {
          const newWorker = registration.installing;
          newWorker.addEventListener('statechange', () => {
            if (newWorker.state === 'installed' && navigator.serviceWorker.controller) {
              // New update available
              showUpdateNotification();
            }
          });
        });
      })
      .catch(err => console.log('ServiceWorker registration failed: ', err));
  });
}

// Show update notification
function showUpdateNotification() {
  if (window.confirm('A new version of this app is available. Update now?')) {
    window.location.reload();
  }
}

// Handle install prompt
let deferredPrompt;
const addToHomeBtn = document.getElementById('add-to-home');

window.addEventListener('beforeinstallprompt', (e) => {
  // Prevent Chrome 67 and earlier from automatically showing the prompt
  e.preventDefault();
  // Stash the event so it can be triggered later
  deferredPrompt = e;
  
  // Show the install button if it exists
  if (addToHomeBtn) {
    addToHomeBtn.style.display = 'block';
    
    addToHomeBtn.addEventListener('click', () => {
      // Hide the button - it won't trigger again if shown
      addToHomeBtn.style.display = 'none';
      
      // Show the prompt
      deferredPrompt.prompt();
      
      // Wait for the user to respond to the prompt
      deferredPrompt.userChoice.then((choiceResult) => {
        if (choiceResult.outcome === 'accepted') {
          console.log('User accepted the A2HS prompt');
        } else {
          console.log('User dismissed the A2HS prompt');
        }
        deferredPrompt = null;
      });
    });
  }
});

// Track web app installs
window.addEventListener('appinstalled', (evt) => {
  console.log('App was installed');
  // You can track the installation here
  if (window.gtag) {
    window.gtag('event', 'pwa_install');
  }
});

// Check if the page is being displayed as a PWA
if (window.matchMedia('(display-mode: standalone)').matches || window.navigator.standalone === true) {
  document.documentElement.setAttribute('data-pwa', 'true');
}

// Track PWA usage
if (window.gtag && (window.matchMedia('(display-mode: standalone)').matches || window.navigator.standalone === true)) {
  window.gtag('event', 'pwa_launch');
}

// Handle offline status
function updateOnlineStatus() {
  if (!navigator.onLine) {
    // Show offline UI
    document.documentElement.classList.add('offline');
    
    // Show offline notification
    const notification = document.createElement('div');
    notification.className = 'offline-notification';
    notification.textContent = 'You are currently offline. Some features may not be available.';
    document.body.prepend(notification);
    
    // Remove notification when back online
    window.addEventListener('online', () => {
      document.documentElement.classList.remove('offline');
      if (notification) notification.remove();
    });
  }
}

// Initial check
updateOnlineStatus();

// Listen for online/offline events
window.addEventListener('online', updateOnlineStatus);
window.addEventListener('offline', updateOnlineStatus);
