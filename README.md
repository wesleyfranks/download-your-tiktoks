# TikTok DL

A PowerShell-based project to download TikTok videos by either:
1. **Exported JSON** (Liked, Favorites, Shared, Uploaded)  
2. **Scraping a Public Profile** (via `extract_urls.py` + Python)

## Project Structure

```
download_videos_project
├── download_videos.ps1       # PowerShell script (menu-driven)
├── extract_urls.py           # Python script for scraping public profiles
└── README.md                 # Documentation
```

## Prerequisites

### Homebrew (Windows or macOS)

1. **Install Homebrew**  
   - **macOS**: [brew.sh](https://brew.sh/)  
   - **Windows**: [Homebrew for Windows](https://github.com/Homebrew-Install/homebrew-windows)  

2. **Install PowerShell & yt-dlp via Homebrew**  
   ```bash
   brew install --cask powershell
   brew install yt-dlp
   ```

3. **Install Python**  
   - [python.org](https://www.python.org/downloads)  
   - Or via Homebrew:
     ```bash
     brew install python
     ```

## Usage

1. **Place Scripts**  
   - `download_videos.ps1` and `extract_urls.py` in the **same folder**.
2. **Open PowerShell**  
   - Change directory to this project folder:
     ```powershell
     cd "C:\Users\MyUserName\Desktop\TikTok-Video-Dl"
     ```
3. **Run the Script**  
   ```powershell
   .\download_videos.ps1
   ```
4. **Choose an Option**:
   1. **Use TikTok JSON**  
      - Copy `user_data_tiktok.json` into the project folder.  
      - Pick which categories (Liked, Favorites, Shared, Uploaded).  
      - Videos download into `liked_videos`, `fav_videos`, `shared_videos`, `uploaded_videos`.
   2. **Scrape a Public TikTok Profile**  
      - Enter your username (e.g., `wesleyfranks`).  
      - The script calls `extract_urls.py` to find video URLs.  
      - Videos download into the `profile_scrape` folder.

## Video Format

Files are named:
```
YYYY-MM-DD HH-mm - videoid.ext

Example:
2025-01-01 12-42 - 32937297237293.mp4
```

## License

MIT
