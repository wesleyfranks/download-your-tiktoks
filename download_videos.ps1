param (
    [string]$jsonFile = "user_data_tiktok.json"
)

Clear-Host
Set-Location -Path $PSScriptRoot

#
# --- SECTION 1: JSON-BASED FUNCTIONS ---
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

function Extract-Uploaded {
    param ([string]$jsonFile)
    $data = Get-Content -Path $jsonFile | ConvertFrom-Json
    $videoList = $data.Video.Videos.VideoList
    $links = @()
    foreach ($video in $videoList) {
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
    "uploaded_videos",
    "profile_scrape"          # for URLs scraped from a public profile
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
# --- SECTION 3: SCRAPE-BASED DOWNLOAD ---
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

    # Call the Python script (extract_urls.py) which prints each URL line by line
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

Write-Host "Please choose an option:"
Write-Host "  1) Use TikTok JSON data (Liked, Favorites, Shared, Uploaded)"
Write-Host "  2) Scrape from a public TikTok profile (e.g., @username)"
Write-Host ""

$mainChoice = Read-Host -Prompt "Enter your choice (1 or 2)"

switch ($mainChoice) {
    "1" {
        Write-Host "`nSelect which categories of videos you want to download."
        Write-Host "(Note: 'Liked' = heart icon, 'Favorite' = bookmark icon.)"
        Write-Host "Type 'all' to download everything, or enter numbers separated by commas:"
        Write-Host "  1) Liked (heart icon)... can take a VERY long time."
        Write-Host "  2) Favorites (bookmark icon)... might also be quite large."
        Write-Host "  3) Shared"
        Write-Host "  4) Uploaded"
        Write-Host ""

        $choice = Read-Host -Prompt "Enter selection (e.g., 'all' or '1,2,3,4')"

        if ($choice.ToLower() -eq 'all') {
            Write-Host "`nDownloading Liked (heart icon)..."
            $likedLinks = Extract-Liked -jsonFile $jsonFile
            Download-Videos -links $likedLinks -outputFolder "liked_videos"

            Write-Host "`nDownloading Favorites (bookmark icon)..."
            $favLinks = Extract-Favs -jsonFile $jsonFile
            Download-Videos -links $favLinks -outputFolder "fav_videos"

            Write-Host "`nDownloading Shared..."
            $sharedLinks = Extract-Shared -jsonFile $jsonFile
            Download-Videos -links $sharedLinks -outputFolder "shared_videos"

            Write-Host "`nDownloading Uploaded..."
            $uploadedLinks = Extract-Uploaded -jsonFile $jsonFile
            Download-Videos -links $uploadedLinks -outputFolder "uploaded_videos"

        } else {
            $selections = $choice -split ',' | ForEach-Object { $_.Trim() }

            foreach ($item in $selections) {
                switch ($item) {
                    "1" {
                        Write-Host "`nDownloading Liked (heart icon)..."
                        $likedLinks = Extract-Liked -jsonFile $jsonFile
                        Download-Videos -links $likedLinks -outputFolder "liked_videos"
                    }
                    "2" {
                        Write-Host "`nDownloading Favorites (bookmark icon)..."
                        $favLinks = Extract-Favs -jsonFile $jsonFile
                        Download-Videos -links $favLinks -outputFolder "fav_videos"
                    }
                    "3" {
                        Write-Host "`nDownloading Shared..."
                        $sharedLinks = Extract-Shared -jsonFile $jsonFile
                        Download-Videos -links $sharedLinks -outputFolder "shared_videos"
                    }
                    "4" {
                        Write-Host "`nDownloading Uploaded..."
                        $uploadedLinks = Extract-Uploaded -jsonFile $jsonFile
                        Download-Videos -links $uploadedLinks -outputFolder "uploaded_videos"
                    }
                    default {
                        Write-Host "`nInvalid selection: $item"
                    }
                }
            }
        }
        Write-Host "`nJSON-based download finished!"
    }
    "2" {
        # Scrape-based approach
        Scrape-TikTokProfile
    }
    default {
        Write-Host "`nInvalid choice. Exiting..."
    }
}

Write-Host "`nAll done!"
