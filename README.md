# TikTok DL

This project is designed to download videos using `yt-dlp` from multiple text files. The videos are categorized into three folders based on their status: liked, favorites, shared, uploaded. I created this in PowerShell to be more compatible with people with less technical knowledge.

## Project Structure

```
download_videos_project
├── download_videos.ps1       # PowerShell script for downloading videos
└── README.md                 # Documentation for the project
```

## Prerequisites

- Ensure you have `python` installed on your system. You can download and install from:
  ```
  https://www.python.org/ftp/python/3.13.1/python-3.13.1-amd64.exe
  ```
- PowerShell should be available on your system to run the script.

## Usage

1. Download your TikTok data as a json and copy the user_data_tiktok.json from the TikTok_Data_xxxxxxxxxx.zip to the same directory as the download_videos.ps1 script.

2. Open PowerShell from the start menu and change the directory to the script directory.
   ```ex command: cd C:\Users\MyUserName\Desktop\TikTok-Video-Dl)  ```

3. Run the PowerShell script:
   ```
   .\download_videos.ps1
   ```

4. The videos will be downloaded into their respective folders:
   - Liked videos will be saved in the `liked_videos` folder.
   - Favorite videos will be saved in the `fav_videos` folder.
   - Shared videos will be saved in the `shared_videos` folder.
   - Uploaded videos will be saved in the `uploaded_videos` folder.

## Video Format

All downloaded videos will be saved using the example format:
```
date - video id.ext

2025-01-01 12-42 - 32937297237293.mp4
```

## License

MIT
