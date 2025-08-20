document.addEventListener('DOMContentLoaded', function() {
  // Elements
  const searchModal = document.getElementById('search-modal');
  const searchInput = document.getElementById('search-input');
  const searchResults = document.getElementById('search-hits');
  const searchStatus = document.getElementById('search-status');
  const searchClear = document.getElementById('search-clear');
  let fuse;
  let searchIndex = [];
  let searchDebounce;

  // Fetch search index
  async function loadSearchIndex() {
    try {
      showLoading(true);
      const response = await fetch('/index.json');
      const data = await response.json();
      searchIndex = data;
      
      // Initialize Fuse.js
      const options = {
        keys: [
          { name: 'title', weight: 0.8 },
          { name: 'content', weight: 0.5 },
          { name: 'tags', weight: 0.3 },
          { name: 'description', weight: 0.4 }
        ],
        includeScore: true,
        threshold: 0.4,
        ignoreLocation: true,
        minMatchCharLength: 2,
        useExtendedSearch: true
      };
      
      fuse = new Fuse(searchIndex, options);
      showLoading(false);
    } catch (error) {
      console.error('Error loading search index:', error);
      showError('Error loading search. Please try again later.');
    }
  }

  // Show loading state
  function showLoading(show) {
    if (show) {
      searchResults.innerHTML = '<div class="search-loading"></div>';
    } else if (searchResults.querySelector('.search-loading')) {
      searchResults.innerHTML = '';
    }
  }

  // Show error message
  function showError(message) {
    searchStatus.innerHTML = `<p class="text-red-500 text-sm mt-2">${message}</p>`;
    setTimeout(() => {
      searchStatus.innerHTML = '';
    }, 5000);
  }

  // Toggle search modal
  function toggleSearchModal() {
    searchModal.classList.toggle('hidden');
    document.body.classList.toggle('overflow-hidden');
    
    if (!searchModal.classList.contains('hidden')) {
      // Show modal with animation
      setTimeout(() => {
        searchInput.focus();
        document.getElementById('search-container').classList.add('opacity-100');
      }, 50);
      
      // Load search index when modal is opened
      if (!fuse) {
        loadSearchIndex();
      }
      
      // Load search index if not already loaded
      if (!fuse) {
        loadSearchIndex();
      }
    } else {
      document.getElementById('search-container').classList.remove('opacity-100');
      searchInput.value = '';
      searchResults.innerHTML = '';
      searchStatus.innerHTML = '<p>Type to search...</p>';
      searchStatus.classList.remove('hidden');
      searchClear.classList.add('hidden');
    }
  }

  // Perform search with debounce
  function performSearch(query) {
    if (!fuse) return;
    
    // Clear previous debounce
    clearTimeout(searchDebounce);
    
    // Set loading state
    showLoading(true);
    
    // Debounce search to avoid too many requests
    searchDebounce = setTimeout(() => {
      query = query.trim();
      
      if (query.length < 2) {
        searchResults.innerHTML = `
          <div class="no-results">
            <p>Type at least 2 characters to search</p>
            <p class="text-sm mt-2 text-gray-500">Try searching for tutorials, guides, or blog posts</p>
          </div>
        `;
        return;
      }
      
      // Show searching indicator
      searchResults.innerHTML = `
        <div class="search-loading"></div>
        <div class="text-center text-sm text-gray-500 mb-4">Searching for "${query}"...</div>
      `;
      
      // Perform search
      const results = fuse.search(query);
      
      // Show results
      if (results.length === 0) {
        searchResults.innerHTML = `
          <div class="no-results">
            <p>No results found for "${query}"</p>
            <p class="text-sm mt-2 text-gray-500">Try different keywords or check your spelling</p>
          </div>
        `;
        return;
      }
      
      let resultsHTML = '';
      
      results.slice(0, 8).forEach((result, index) => {
        const item = result.item;
        const url = new URL(item.permalink, window.location.origin);
        
        // Highlight matching text in title and description
        const title = highlightMatches(item.title, query);
        const description = item.description ? highlightMatches(item.description, query, 150) : '';
        
        resultsHTML += `
          <a href="${url}" class="search-result-item block transition-all duration-200 hover:shadow-md">
            <h3 class="text-lg font-semibold">${title}</h3>
            ${description ? `<p class="mt-1">${description}</p>` : ''}
            <span class="url text-sm">${url.pathname}</span>
          </a>
        `;
      });
      
      searchResults.innerHTML = resultsHTML;
      
    }, 300); // 300ms debounce
  }
  
  // Highlight matching text in search results
  function highlightMatches(text, query, maxLength = 0) {
    if (!text) return '';
    
    let result = text;
    const queryTerms = query.split(' ').filter(term => term.length > 1);
    
    // Highlight each term
    queryTerms.forEach(term => {
      const regex = new RegExp(`(${escapeRegExp(term)})`, 'gi');
      result = result.replace(regex, '<span class="bg-yellow-100 dark:bg-yellow-900 text-yellow-800 dark:text-yellow-200 px-1 rounded">$1</span>');
    });
    
    // Truncate if needed
    if (maxLength > 0 && result.length > maxLength) {
      result = result.substring(0, maxLength) + '...';
    }
    
    return result;
  }
  
  // Escape special regex characters
  function escapeRegExp(string) {
    return string.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
  }

  // Event Listeners
  document.querySelectorAll('[data-target="search-modal"], [data-search-trigger]').forEach(button => {
    button.addEventListener('click', (e) => {
      e.preventDefault();
      toggleSearchModal();
    });
  });

  // Close button
  const closeButton = document.getElementById('search-close');
  if (closeButton) {
    closeButton.addEventListener('click', (e) => {
      e.preventDefault();
      toggleSearchModal();
    });
  }
  
  // Search input handler with debounce
  let searchTimeout;
  searchInput.addEventListener('input', (e) => {
    clearTimeout(searchTimeout);
    searchTimeout = setTimeout(() => {
      performSearch(e.target.value);
    }, 200);
  });
  
  // Clear search
  if (searchClear) {
    searchClear.addEventListener('click', (e) => {
      e.preventDefault();
      searchInput.value = '';
      searchResults.innerHTML = '';
      searchStatus.textContent = '';
      searchInput.focus();
      performSearch('');
    });
  }
  
  // Close modal when clicking outside
  searchModal.addEventListener('click', (e) => {
    if (e.target === searchModal) {
      toggleSearchModal();
    }
  });
  
  // Keyboard navigation
  document.addEventListener('keydown', (e) => {
    // Close with Escape
    if (e.key === 'Escape' && !searchModal.classList.contains('hidden')) {
      e.preventDefault();
      toggleSearchModal();
    }
    
    // Navigate results with arrow keys
    if (!searchModal.classList.contains('hidden') && searchResults.children.length > 0) {
      const results = searchResults.querySelectorAll('.search-result-item');
      const focused = document.activeElement;
      let currentIndex = Array.from(results).indexOf(focused);
      
      if (e.key === 'ArrowDown') {
        e.preventDefault();
        const nextIndex = currentIndex < results.length - 1 ? currentIndex + 1 : 0;
        results[nextIndex].focus();
      } else if (e.key === 'ArrowUp') {
        e.preventDefault();
        const prevIndex = currentIndex > 0 ? currentIndex - 1 : results.length - 1;
        results[prevIndex].focus();
      } else if (e.key === 'Enter' && focused === searchInput && searchInput.value.trim().length >= 2) {
        e.preventDefault();
        const firstResult = searchResults.querySelector('.search-result-item');
        if (firstResult) firstResult.click();
      }
    }
  });
  
  // Load search index on page load
  if (searchModal) {
    // Preload search index when search button is hovered
    const searchButtons = document.querySelectorAll('[data-search-trigger]');
    searchButtons.forEach(button => {
      button.addEventListener('mouseenter', () => {
        if (!fuse) loadSearchIndex();
      }, { once: true });
    });
  }
});
