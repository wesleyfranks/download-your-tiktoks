import sys
import requests
from bs4 import BeautifulSoup

def extract_video_urls(page_url):
    """
    Returns a Python list of video URLs found in
    <a class="css-1mdo0pl-AVideoContainer e19c29qe4"> elements.
    """
    response = requests.get(page_url, timeout=10)
    response.raise_for_status()

    soup = BeautifulSoup(response.text, 'html.parser')
    anchors = soup.find_all('a', class_='css-1mdo0pl-AVideoContainer e19c29qe4')

    video_urls = []
    for a in anchors: 
        href = a.get('href')
        if href:
            video_urls.append(href)

    return video_urls

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python extract_urls.py <page_url>")
        sys.exit(1)

    page_url = sys.argv[1]
    urls = extract_video_urls(page_url)

    for url in urls:
        print(url)

