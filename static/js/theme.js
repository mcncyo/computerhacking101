// Theme Toggle Functionality
document.addEventListener('DOMContentLoaded', function() {
  // Check for saved user preference, if any, on load
  const savedTheme = localStorage.getItem('theme') || 
                    (window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light');
  
  // Apply the saved theme
  setTheme(savedTheme);
  
  // Theme toggle button event listeners
  const themeToggleBtns = document.querySelectorAll('[id^="themeToggle"]');
  themeToggleBtns.forEach(btn => {
    btn.addEventListener('click', toggleTheme);
  });
  
  // Listen for theme changes from other components
  document.addEventListener('themeChanged', (e) => {
    setTheme(e.detail.theme);
  });
});

// Toggle between light and dark theme
function toggleTheme() {
  const currentTheme = document.documentElement.getAttribute('data-theme') || 'light';
  const newTheme = currentTheme === 'dark' ? 'light' : 'dark';
  setTheme(newTheme);
  
  // Dispatch event for other components
  document.dispatchEvent(new CustomEvent('themeChanged', { detail: { theme: newTheme } }));
}

// Set the theme
function setTheme(theme) {
  // Update the HTML attribute
  document.documentElement.setAttribute('data-theme', theme);
  
  // Save to localStorage
  localStorage.setItem('theme', theme);
  
  // Update UI elements
  updateThemeIcons(theme);
  
  // Dispatch a custom event for any components that need to react to theme changes
  document.dispatchEvent(new CustomEvent('themeChange', { detail: { theme } }));
}

// Update theme toggle icons
function updateThemeIcons(theme) {
  const icons = document.querySelectorAll('[id^="themeToggle"] svg');
  icons.forEach(icon => {
    if (theme === 'dark') {
      // Show moon icon (dark mode active)
      icon.classList.toggle('hidden', !icon.getAttribute('data-dark'));
      icon.classList.toggle('block', icon.getAttribute('data-dark'));
    } else {
      // Show sun icon (light mode active)
      icon.classList.toggle('hidden', !icon.getAttribute('data-light'));
      icon.classList.toggle('block', icon.getAttribute('data-light'));
    }
  });
  
  // Update text labels if any
  const darkLabels = document.querySelectorAll('.dark-label');
  const lightLabels = document.querySelectorAll('.light-label');
  
  if (theme === 'dark') {
    darkLabels.forEach(el => el.classList.add('hidden'));
    lightLabels.forEach(el => el.classList.remove('hidden'));
  } else {
    darkLabels.forEach(el => el.classList.remove('hidden'));
    lightLabels.forEach(el => el.classList.add('hidden'));
  }
}

// Listen for system theme changes
window.matchMedia('(prefers-color-scheme: dark)').addEventListener('change', e => {
  // Only apply system theme if user hasn't set a preference
  if (!localStorage.getItem('theme')) {
    const newTheme = e.matches ? 'dark' : 'light';
    setTheme(newTheme);
  }
});
