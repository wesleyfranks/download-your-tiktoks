# Download Your TikToks

This PowerShell-based project downloads your TikTok videos in two ways:

1. **Exported JSON** (Liked, Favorites, Shared, Uploaded)  
2. **Scraping a Public Profile** (via `extract_urls.py` + Python)

> **Note**: The original repo included handling for “Uploaded” videos in the JSON, but TikTok’s provided URLs are too long and can break downloads. 

---

## Getting Your TikTok Data (JSON Approach)

1. **Open TikTok on Your Phone**  
   - Go to your **Profile**.  
   - Tap the **menu** (top-right) → **Settings and privacy** → **Account** → **Download your data**.  
   - Select **JSON**.  
   - Request your data; wait for it to be ready.  
   - Tap **Download** (once available).

2. **Transfer the Zip File**  
   - The file will save to your phone.  
   - Move the `.zip` to your computer (iCloud, USB cable, email, etc.).  
   - **Extract** the `.zip`. Inside, find `user_data_tiktok.json`.

3. **Place `user_data_tiktok.json`**  
   - Put it in the **same folder** as `download_videos.ps1`.

---

## Project Structure

```
download_videos_project
├── download_videos.ps1       # PowerShell script (menu-driven)
├── extract_urls.py           # Python script for scraping public profiles
└── README.md                 # Documentation
```

---

## Prerequisites

### Homebrew (Windows or macOS)

1. **Install Homebrew**  
   - **macOS**: [brew.sh](https://brew.sh/)  
   - **Windows**: [Homebrew for Windows](https://github.com/Homebrew-Install/homebrew-windows)

2. **Install PowerShell & yt-dlp**  
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

---

## Usage

1. **Place Scripts**  
   - Put `download_videos.ps1` and `extract_urls.py` together in one folder.

2. **Open PowerShell**  
   - Change directory to the folder:
     ```powershell
     cd "C:\Users\MyUserName\Desktop\TikTok-Video-Dl"
     ```

3. **Run the Script**  
   ```powershell
   .\download_videos.ps1
   ```

4. **Choose an Option**:
   - **Use TikTok JSON**  
     - Make sure `user_data_tiktok.json` is in the same folder.  
     - Select which categories (Liked, Favorites, Shared, Uploaded) you want.  
     - Videos download into `liked_videos`, `fav_videos`, `shared_videos`, `uploaded_videos`.
   - **Scrape a Public TikTok Profile**  
     - Enter your username (e.g., `@wesleyfranks` without the “@”).  
     - The script uses `extract_urls.py` to parse the profile.  
     - Downloads land in the `profile_scrape` folder.

---

## Video Format

All downloaded files follow:
```
YYYY-MM-DD HH-mm - videoid.ext

Example:
2025-01-01 12-42 - 32937297237293.mp4
```

---

## License

MIT
