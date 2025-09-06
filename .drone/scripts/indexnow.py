#!/usr/bin/env python3

import os
import sys
import re
import time
import requests
import logging
from urllib.parse import urlparse, urljoin
from typing import List, Set, Optional

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[logging.StreamHandler()]
)
logger = logging.getLogger(__name__)

class SitemapProcessor:
    def __init__(self, host: str, key: str):
        self.host = host
        self.key = key
        self.key_url = f"https://{host}/{key}.txt"
        self.sitemap_url = f"https://{host}/sitemap.xml"
        self.indexnow_endpoint = "https://api.indexnow.org/indexnow"
        self.max_batch = 10_000
        self.session = requests.Session()
        self.session.headers.update({
            'User-Agent': 'ComputerHacking101/1.0',
            'Content-Type': 'application/json'
        })

    def fetch(self, url: str, max_retries: int = 3, timeout: int = 30) -> Optional[str]:
        """Fetch URL content with retries and error handling."""
        for attempt in range(max_retries):
            try:
                response = self.session.get(url, timeout=timeout)
                if response.status_code == 200:
                    return response.text
                logger.warning(f"Fetch attempt {attempt + 1} failed for {url}: HTTP {response.status_code}")
            except Exception as e:
                logger.warning(f"Fetch error for {url} (attempt {attempt + 1}): {str(e)}")
            
            if attempt < max_retries - 1:
                wait_time = (2 ** attempt) * 5  # Exponential backoff
                logger.info(f"Retrying in {wait_time} seconds...")
                time.sleep(wait_time)
        
        logger.error(f"Failed to fetch {url} after {max_retries} attempts")
        return None

    def extract_urls(self, xml_content: str) -> List[str]:
        """Extract URLs from sitemap XML content."""
        try:
            # Try to use defusedxml for safer XML parsing
            from defusedxml import ElementTree as ET
            root = ET.fromstring(xml_content)
            namespaces = {'ns': 'http://www.sitemaps.org/schemas/sitemap/0.9'}
            return [loc.text for loc in root.findall('.//ns:loc', namespaces) if loc.text]
        except ImportError:
            # Fallback to regex if defusedxml is not available
            logger.warning("defusedxml not found, using regex for XML parsing (less reliable)")
            return re.findall(r'<loc>\s*([^<\s]+)\s*</loc>', xml_content, flags=re.IGNORECASE)

    def normalize_url(self, url: str) -> Optional[str]:
        """Normalize URL and ensure it belongs to the target host."""
        if not url or not isinstance(url, str):
            return None
            
        try:
            parsed = urlparse(url.strip())
            if not parsed.scheme or not parsed.netloc:
                return None
                
            # Ensure we're only processing URLs for our host
            if not parsed.netloc.endswith(self.host):
                return None
                
            # Rebuild URL with consistent scheme and host
            normalized = f"https://{self.host}{parsed.path or '/'}"
            if parsed.query:
                normalized += f"?{parsed.query}"
                
            return normalized
        except Exception as e:
            logger.warning(f"Error normalizing URL {url}: {str(e)}")
            return None

    def process_sitemap(self, url: str) -> Set[str]:
        """Process a sitemap URL and return all unique, normalized URLs."""
        logger.info(f"Processing sitemap: {url}")
        content = self.fetch(url)
        if not content:
            return set()
            
        urls = set()
        
        # Check if this is a sitemap index
        if "<sitemapindex" in content.lower():
            sitemap_urls = self.extract_urls(content)
            logger.info(f"Found sitemap index with {len(sitemap_urls)} child sitemaps")
            
            for sm_url in sitemap_urls:
                if sm_url:
                    urls.update(self.process_sitemap(sm_url))
        else:
            # Process regular sitemap
            extracted = self.extract_urls(content)
            logger.info(f"Found {len(extracted)} URLs in sitemap")
            
            for url in extracted:
                normalized = self.normalize_url(url)
                if normalized:
                    urls.add(normalized)
        
        return urls

    def submit_to_indexnow(self, urls: List[str]) -> int:
        """Submit URLs to IndexNow in batches."""
        if not urls:
            logger.warning("No URLs to submit to IndexNow")
            return 0
            
        total_sent = 0
        batch_size = min(10000, self.max_batch)  # IndexNow limit is 10,000 URLs per batch
        
        for i in range(0, len(urls), batch_size):
            batch = urls[i:i + batch_size]
            success = self._submit_batch(batch)
            if success:
                total_sent += len(batch)
                logger.info(f"Submitted batch of {len(batch)} URLs ({total_sent}/{len(urls)} total)")
            else:
                logger.error(f"Failed to submit batch of {len(batch)} URLs")
                
        return total_sent

    def _submit_batch(self, urls: List[str], max_retries: int = 3) -> bool:
        """Submit a single batch of URLs to IndexNow."""
        payload = {
            "host": self.host,
            "key": self.key,
            "keyLocation": self.key_url,
            "urlList": urls
        }
        
        for attempt in range(max_retries):
            try:
                response = self.session.post(
                    self.indexnow_endpoint,
                    json=payload,
                    timeout=30
                )
                
                if response.status_code in (200, 202):
                    return True
                    
                if response.status_code == 429:  # Rate limited
                    retry_after = int(response.headers.get('Retry-After', 60))
                    logger.warning(f"Rate limited. Waiting {retry_after} seconds...")
                    time.sleep(retry_after)
                    continue
                    
                logger.error(
                    f"IndexNow API error (attempt {attempt + 1}): "
                    f"HTTP {response.status_code} - {response.text[:200]}"
                )
                
            except Exception as e:
                logger.error(f"Request error (attempt {attempt + 1}): {str(e)}")
            
            # Exponential backoff
            wait_time = (2 ** attempt) * 5
            logger.info(f"Retrying in {wait_time} seconds...")
            time.sleep(wait_time)
        
        return False

def main():
    # Get configuration from environment
    host = os.environ.get('SITE_HOST', 'computerhacking101.com')
    key = os.environ.get('INDEXNOW_KEY', '')
    
    if not key:
        logger.error("ERROR: INDEXNOW_KEY environment variable is required")
        sys.exit(1)
    
    logger.info(f"Starting IndexNow submission for {host}")
    
    try:
        # Initialize processor
        processor = SitemapProcessor(host, key)
        
        # Process sitemap
        logger.info(f"Fetching sitemap from {processor.sitemap_url}")
        urls = processor.process_sitemap(processor.sitemap_url)
        
        if not urls:
            logger.error("No URLs found in sitemap")
            sys.exit(1)
            
        urls = sorted(urls)  # Sort for consistent ordering
        logger.info(f"Found {len(urls)} unique URLs to submit")
        
        # Submit to IndexNow
        logger.info("Starting submission to IndexNow...")
        sent = processor.submit_to_indexnow(list(urls))
        
        logger.info(f"Successfully submitted {sent}/{len(urls)} URLs to IndexNow")
        
    except KeyboardInterrupt:
        logger.info("Operation cancelled by user")
        sys.exit(1)
    except Exception as e:
        logger.exception("Fatal error during IndexNow submission")
        sys.exit(1)

if __name__ == "__main__":
    main()
