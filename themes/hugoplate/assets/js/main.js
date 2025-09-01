// main script
(function () {
  "use strict";

  // Dropdown Menu Toggler For Mobile
  // ----------------------------------------
  const dropdownMenuToggler = document.querySelectorAll(
    ".nav-dropdown > .nav-link",
  );

  dropdownMenuToggler.forEach((toggler) => {
    toggler?.addEventListener("click", (e) => {
      e.target.closest(".nav-item").classList.toggle("active");
    });
  });

  // Testimonial Slider
  // ----------------------------------------
  new Swiper(".testimonial-slider", {
    spaceBetween: 24,
    loop: true,
    pagination: {
      el: ".testimonial-slider-pagination",
      type: "bullets",
      clickable: true,
    },
    breakpoints: {
      768: {
        slidesPerView: 2,
      },
      992: {
        slidesPerView: 3,
      },
    },
  });

  // Code Block Copy Button
  // ----------------------------------------
  function initCodeCopyButtons() {
    // Find all code blocks
    const codeBlocks = document.querySelectorAll('pre > code');
    
    codeBlocks.forEach((codeBlock) => {
      // Create container if it doesn't exist
      if (!codeBlock.closest('.codeblock-container')) {
        const container = document.createElement('div');
        container.className = 'codeblock-container';
        codeBlock.parentNode.insertBefore(container, codeBlock);
        container.appendChild(codeBlock);
      }
      
      // Add copy button if it doesn't exist
      const container = codeBlock.closest('.codeblock-container');
      if (container && !container.querySelector('.codeblock-copy')) {
        const copyButton = document.createElement('button');
        copyButton.className = 'codeblock-copy';
        copyButton.setAttribute('aria-label', 'Copy code');
        copyButton.setAttribute('title', 'Copy');
        copyButton.innerHTML = '📋';
        
        copyButton.addEventListener('click', async () => {
          try {
            const code = codeBlock.textContent;
            await navigator.clipboard.writeText(code);
            
            // Visual feedback
            const originalText = copyButton.innerHTML;
            copyButton.innerHTML = '✅';
            copyButton.classList.add('copied');
            
            // Reset after 2 seconds
            setTimeout(() => {
              copyButton.innerHTML = originalText;
              copyButton.classList.remove('copied');
            }, 2000);
          } catch (err) {
            console.error('Failed to copy text: ', err);
          }
        });
        
        container.appendChild(copyButton);
      }
    });
  }

  // Initialize copy buttons when DOM is loaded
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initCodeCopyButtons);
  } else {
    initCodeCopyButtons();
  }
})();
