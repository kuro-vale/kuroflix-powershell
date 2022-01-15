$BROWSER = "msedge"


function Get-UrlTitles {
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$url,
        [Parameter(Mandatory = $true, Position = 1)]
        [string]$regex
    )
    # Get a url list of the media searched
    Clear-Host
    $search = (Read-Host -Prompt "What do you want to watch?: ") -replace " " , "+"
    $source_code = ( Invoke-RestMethod $url'?s='$search | Select-String $regex -AllMatches).Matches
    $media_links = New-Object Collections.Generic.List[string]
    foreach ($Value in $source_code) {
        $media_links.Add(($Value.Groups.Where{ $_.Name -like 'media' }).Value)
    }
    if (!$media_links) {
        Write-Host "No search results for $search`nVerify that you didn't have errors like: 'Abatar' instead of 'Avatar', 'Ironman' instead of 'Iron Man'"
    }
    return $media_links
}


function Get-UserChoice {
    param (
        [Parameter(Mandatory = $true, Position=0)]
        $media_links
        # [Parameter(Mandatory = $false, Position=1)]
        # [bool]$save_choice
    )
    # Get the media url based on the user choice
    $choice = Read-Host -Prompt "Enter the prefix number of what do you want to watch: "
    $i = 1
    foreach ($link in $media_links) {
        if ($choice -eq $i) {
            $media = $link
        }
        $i++
    }
    return $media
}


function Select-Episodes {
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$url,
        [Parameter(Mandatory = $true, Position = 1)]
        [string]$regex_episodes,
        [Parameter(Mandatory = $true, Position = 2)]
        [string]$media
    )
    # Print a list of episodes, then user will choose which episode reproduce
    Clear-Host
    $source_code = ( Invoke-RestMethod $url$media | Select-String $regex_episodes -AllMatches).Matches
    $media_links = New-Object Collections.Generic.List[string]
    foreach ($Value in $source_code) {
        $media_links.Add(($Value.Groups.Where{ $_.Name -like 'media' }).Value)
    }
    Write-MediaTitles $media_links
    $media = Get-UserChoice $media_links
    return $media
}


function Start-EmbeddedLink {
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$url,
        [Parameter(Mandatory = $true, Position = 1)]
        [string]$regex_embed,
        [Parameter(Mandatory = $true, Position = 2)]
        [string]$media
    )
    Clear-Host
    Write-Host "Reproducing $media"
    $source_code = ( Invoke-RestMethod $url$media | Select-String $regex_embed -AllMatches).Matches
    $embedded_links = New-Object Collections.Generic.List[string]
    foreach ($Value in $source_code) {
        $embedded_links.Add(($Value.Groups.Where{ $_.Name -like 'media' }).Value)
    }
    foreach ($link in $embedded_links) {
        Start-Process $BROWSER $link
        $retry = Read-Host -Prompt "Want to try with another link? Y/N: "
        if ($retry.ToUpper() -eq "Y") {
            continue
        }
        else {
            Clear-Host
            Write-Host "Goodbye"
            Exit-PSHostProcess
        }
    }
    Clear-Host
    Write-Host "Sorry, can't find another link :(, Goodbye!"
    Exit-PSHostProcess
}


function Write-MediaTitles {
    param(
        [Parameter(Mandatory = $true)]
        $media_links
    )
    $i = 1
    foreach ($link in $media_links) {
        Write-Host "$i."$link
        $i++
    }
}


function Watch-EnglishMedia {
    # Scrape the url to find movies or series
    $choice
    $url = "https://gototub.com/"
    $regex = '\s*<a href="' + $url + '(?<media>[^"]*)" data-url=.*'
    $media_links = Get-UrlTitles $url $regex
    Write-MediaTitles $media_links
    $media = Get-UserChoice $media_links
    $regex_embed = '\s*<iframe src="(?<media>[^"]*)" frameborder=.*'
    if ($media -match "^series\/") {
        # When series selected, search episodes an change $media to the selected episode
        $url_episodes = "https://gototub.com/episode/"
        $regex_episodes = '\s*<a href="' + $url_episodes + '(?<media>[^"]*)">.*'
        $media = Select-Episodes $url $regex_episodes $media
        $url = $url_episodes
        #$choice-=1
        #Save-Cache
    }
    Start-EmbeddedLink $url $regex_embed $media
}


Watch-EnglishMedia
