param (
    [string]$jsonFile = "user_data_tiktok.json"
)

Clear-Host

Set-Location -Path $PSScriptRoot

function Extract-Liked {
    param (
        [string]$jsonFile
    )

    $data = Get-Content -Path $jsonFile | ConvertFrom-Json
    $links = @()

    foreach ($video in $data.Activity.'Like List'.ItemFavoriteList) {
        $linkKey = $video.PSObject.Properties.Name | Where-Object { $_ -match 'link' }
        $date = $video.PSObject.Properties.Name | Where-Object { $_ -match 'date' }
        if ($linkKey -and $date) {
            $dateFormatted = $video.$date -replace ":", "-"
            $dateFormatted = $dateFormatted.Substring(0, 16)
            $links += [PSCustomObject]@{ Link = $video.$linkKey; Date = $dateFormatted }
        }
    }

    return $links
}

function Extract-Favs {
    param (
        [string]$jsonFile
    )

    $data = Get-Content -Path $jsonFile | ConvertFrom-Json
    $links = @()

    foreach ($video in $data.Activity.'Favorite Videos'.FavoriteVideoList) {
        $linkKey = $video.PSObject.Properties.Name | Where-Object { $_ -match 'link' }
        $date = $video.PSObject.Properties.Name | Where-Object { $_ -match 'date' }
        if ($linkKey -and $date) {
            $dateFormatted = $video.$date -replace ":", "-"
            $dateFormatted = $dateFormatted.Substring(0, 16)
            $links += [PSCustomObject]@{ Link = $video.$linkKey; Date = $dateFormatted }
        }
    }

    return $links
}

function Extract-Shared {
    param (
        [string]$jsonFile
    )

    $data = Get-Content -Path $jsonFile | ConvertFrom-Json
    $links = @()

    foreach ($video in $data.Activity.'Share History'.ShareHistoryList) {
        $linkKey = $video.PSObject.Properties.Name | Where-Object { $_ -match 'link' }
        $date = $video.PSObject.Properties.Name | Where-Object { $_ -match 'date' }
        if ($linkKey -and $date) {
            $dateFormatted = $video.$date -replace ":", "-"
            $dateFormatted = $dateFormatted.Substring(0, 16)
            $links += [PSCustomObject]@{ Link = $video.$linkKey; Date = $dateFormatted }
        }
    }

    return $links
}

function Extract-Uploaded {
    param (
        [string]$jsonFile
    )

    $data = Get-Content -Path $jsonFile | ConvertFrom-Json
    $videoList = $data.Video.Videos.VideoList

    $links = @()

    foreach ($video in $videoList) {
        $linkKey = $video.PSObject.Properties.Name | Where-Object { $_ -match 'link' }
        $date = $video.PSObject.Properties.Name | Where-Object { $_ -match 'date' }
        if ($linkKey -and $date) {
            $dateFormatted = $video.$date -replace ":", "-"
            $dateFormatted = $dateFormatted.Substring(0, 16)
            $links += [PSCustomObject]@{ Link = $video.$linkKey; Date = $dateFormatted }
        }
    }

    return $links
}

# Create directories if they do not exist
$folders = @("liked_videos", "fav_videos", "shared_videos", "uploaded_videos")
foreach ($folder in $folders) {
    if (-not (Test-Path $folder)) {
        New-Item -ItemType Directory -Path $folder
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
        $arguments = "-o `"$outputFolder/$date - %(id)s.%(ext)s`" $link"
        Start-Process -FilePath "yt-dlp" -ArgumentList $arguments -NoNewWindow -Wait
    }
}

$likedLinks = Extract-Liked -jsonFile $jsonFile
Download-Videos -links $likedLinks -outputFolder "liked_videos"

$favLinks = Extract-Favs -jsonFile $jsonFile
Download-Videos -links $favLinks -outputFolder "fav_videos"

$sharedLinks = Extract-Shared -jsonFile $jsonFile
Download-Videos -links $sharedLinks -outputFolder "shared_videos"

$sharedLinks = Extract-Uploaded -jsonFile $jsonFile
Download-Videos -links $sharedLinks -outputFolder "uploaded_videos"
