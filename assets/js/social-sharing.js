document.addEventListener('DOMContentLoaded', function() {
  // Copy link functionality
  const copyButtons = document.querySelectorAll('.copy-link');
  
  copyButtons.forEach(button => {
    button.addEventListener('click', async function() {
      const url = this.getAttribute('data-url');
      const feedback = this.closest('.social-sharing').querySelector('.copy-feedback');
      
      try {
        await navigator.clipboard.writeText(url);
        
        // Show feedback
        feedback.classList.remove('hidden');
        setTimeout(() => {
          feedback.classList.add('hidden');
        }, 3000);
        
        // Change icon to checkmark temporarily
        const icon = this.querySelector('svg');
        const originalIcon = icon.outerHTML;
        icon.outerHTML = `
          <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path>
          </svg>
        `;
        
        setTimeout(() => {
          icon.outerHTML = originalIcon;
        }, 2000);
        
      } catch (err) {
        console.error('Failed to copy URL: ', err);
        alert('Failed to copy URL to clipboard');
      }
    });
  });
  
  // Open share dialog on mobile devices
  if (navigator.share) {
    const shareButtons = document.querySelectorAll('.social-sharing');
    
    shareButtons.forEach(container => {
      const shareButton = document.createElement('button');
      shareButton.className = 'inline-flex items-center justify-center w-8 h-8 rounded-full bg-purple-50 hover:bg-purple-100 dark:bg-purple-900/30 dark:hover:bg-purple-800/50 text-purple-500 dark:text-purple-400 transition-colors';
      shareButton.innerHTML = `
        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8.684 13.342C8.886 12.938 9 12.482 9 12c0-.482-.114-.938-.316-1.342m0 2.684a3 3 0 110-2.684m0 2.684l6.632 3.316m-6.632-6l6.632-3.316m0 0a3 3 0 105.367-2.684 3 3 0 00-5.367 2.684zm0 9.316a3 3 0 105.368 2.684 3 3 0 00-5.368-2.684z"></path>
        </svg>
      `;
      shareButton.setAttribute('aria-label', 'Share this page');
      
      shareButton.addEventListener('click', async () => {
        try {
          await navigator.share({
            title: document.title,
            text: document.querySelector('meta[name="description"]')?.content || '',
            url: window.location.href
          });
        } catch (err) {
          console.log('Share was cancelled or failed', err);
        }
      });
      
      // Insert share button at the beginning on mobile
      const shareContainer = container.querySelector('.flex');
      if (shareContainer) {
        shareContainer.insertBefore(shareButton, shareContainer.firstChild);
      }
    });
  }
});
