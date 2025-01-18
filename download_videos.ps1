param (
    [string]$jsonFile = "user_data_tiktok.json"
)

Clear-Host
Set-Location -Path $PSScriptRoot

#
# --- SECTION 1: JSON-BASED FUNCTIONS (Liked, Favorites, Shared) ---
#

function Extract-Liked {
    param ([string]$jsonFile)
    $data = Get-Content -Path $jsonFile | ConvertFrom-Json
    $links = @()

    foreach ($video in $data.Activity.'Like List'.ItemFavoriteList) {
        $linkKey = $video.PSObject.Properties.Name | Where-Object { $_ -match 'link' }
        $dateKey = $video.PSObject.Properties.Name | Where-Object { $_ -match 'date' }
        if ($linkKey -and $dateKey) {
            $dateFormatted = $video.$dateKey -replace ":", "-"
            $dateFormatted = $dateFormatted.Substring(0, 16)
            $links += [PSCustomObject]@{
                Link = $video.$linkKey
                Date = $dateFormatted
            }
        }
    }
    return $links
}

function Extract-Favs {
    param ([string]$jsonFile)
    $data = Get-Content -Path $jsonFile | ConvertFrom-Json
    $links = @()

    foreach ($video in $data.Activity.'Favorite Videos'.FavoriteVideoList) {
        $linkKey = $video.PSObject.Properties.Name | Where-Object { $_ -match 'link' }
        $dateKey = $video.PSObject.Properties.Name | Where-Object { $_ -match 'date' }
        if ($linkKey -and $dateKey) {
            $dateFormatted = $video.$dateKey -replace ":", "-"
            $dateFormatted = $dateFormatted.Substring(0, 16)
            $links += [PSCustomObject]@{
                Link = $video.$linkKey
                Date = $dateFormatted
            }
        }
    }
    return $links
}

function Extract-Shared {
    param ([string]$jsonFile)
    $data = Get-Content -Path $jsonFile | ConvertFrom-Json
    $links = @()

    foreach ($video in $data.Activity.'Share History'.ShareHistoryList) {
        $linkKey = $video.PSObject.Properties.Name | Where-Object { $_ -match 'link' }
        $dateKey = $video.PSObject.Properties.Name | Where-Object { $_ -match 'date' }
        if ($linkKey -and $dateKey) {
            $dateFormatted = $video.$dateKey -replace ":", "-"
            $dateFormatted = $dateFormatted.Substring(0, 16)
            $links += [PSCustomObject]@{
                Link = $video.$linkKey
                Date = $dateFormatted
            }
        }
    }
    return $links
}

#
# --- SECTION 2: FOLDER CREATION & DOWNLOAD FUNCTION ---
#

# Create directories if they do not exist
$folders = @(
    "liked_videos",
    "fav_videos",
    "shared_videos",
    "profile_scrape"
)
foreach ($folder in $folders) {
    if (-not (Test-Path $folder)) {
        New-Item -ItemType Directory -Path $folder | Out-Null
    }
}

function Download-Videos {
    param (
        [array]$links,
        [string]$outputFolder
    )

    foreach ($linkObj in $links) {
        $link = $linkObj.Link
        $date = $linkObj.Date
        # Example filename: 2024-10-04 05-29 - %(id)s.%(ext)s
        $arguments = "-o `"$outputFolder/$date - %(id)s.%(ext)s`" $link"
        Start-Process -FilePath "yt-dlp" -ArgumentList $arguments -NoNewWindow -Wait
    }
}

#
# --- SECTION 3: SCRAPE-BASED DOWNLOAD (Option 4) ---
#

function Scrape-TikTokProfile {
    Write-Host "`nEnter your TikTok username (e.g., wesleyfranks):"
    $username = Read-Host
    if (-not $username) {
        Write-Host "No username entered. Returning..."
        return
    }

    $profileUrl = "https://www.tiktok.com/@$username"
    Write-Host "`nScraping URLs from: $profileUrl"

    # Call the Python script (extract_urls.py) which prints each URL
    $scrapedUrls = python .\extract_urls.py $profileUrl
    if (-not $scrapedUrls) {
        Write-Host "No URLs found or scrape failed."
        return
    }

    Write-Host "`nFound $($scrapedUrls.Count) video URL(s). Downloading into 'profile_scrape' folder..."

    foreach ($url in $scrapedUrls) {
        # We'll timestamp each file in profile_scrape
        $timestamp = (Get-Date -Format 'yyyy-MM-dd HH-mm')
        $arguments = "-o `"profile_scrape/$timestamp - %(id)s.%(ext)s`" $url"
        Start-Process -FilePath "yt-dlp" -ArgumentList $arguments -NoNewWindow -Wait
    }

    Write-Host "`nProfile scrape done!"
}

#
# --- SECTION 4: MAIN MENU ---
#

Write-Host ""
Write-Host "Choose which TikTok videos to download:"
Write-Host "  1) Liked (heart icon) - JSON data"
Write-Host "  2) Favorites (bookmark icon) - JSON data"
Write-Host "  3) Shared - JSON data"
Write-Host "  4) Profile Scrape (uploaded videos/public feed) - uses Python"
Write-Host ""

$choice = Read-Host -Prompt "Enter your selection (1,2,3,4)"

switch ($choice) {
    "1" {
        Write-Host "`nDownloading Liked..."
        $likedLinks = Extract-Liked -jsonFile $jsonFile
        Download-Videos -links $likedLinks -outputFolder "liked_videos"
    }
    "2" {
        Write-Host "`nDownloading Favorites..."
        $favLinks = Extract-Favs -jsonFile $jsonFile
        Download-Videos -links $favLinks -outputFolder "fav_videos"
    }
    "3" {
        Write-Host "`nDownloading Shared..."
        $sharedLinks = Extract-Shared -jsonFile $jsonFile
        Download-Videos -links $sharedLinks -outputFolder "shared_videos"
    }
    "4" {
        Write-Host "`nScraping Public Profile (uploaded videos / user feed)..."
        Scrape-TikTokProfile
    }
    default {
        Write-Host "`nInvalid choice. Exiting..."
    }
}

Write-Host "`nAll done!"
