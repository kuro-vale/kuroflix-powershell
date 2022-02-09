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
        exit
    }
    return $media_links
}


function Get-UserChoice {
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        $media_links
    )
    # Get the media url based on the user choice
    $global:choice = Read-Host -Prompt "Enter the prefix number of what do you want to watch: "
    $i = 1
    foreach ($link in $media_links) {
        if ($global:choice -eq $i) {
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
    $global:media_links = $media_links
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
        if ( $retry.ToUpper() -eq "Y" ) {
            continue
        }
        else {
            Clear-Host
            Write-Host "Goodbye"
            exit
        }
    }
    Clear-Host
    Write-Host "Sorry, can't find another link :(, Goodbye!"
    exit
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


function Save-Cache {
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$url,
        [Parameter(Mandatory = $true, Position = 1)]
        [string]$regex_embed,
        [Parameter(Mandatory = $true, Position = 2)]
        $media_links,
        [Parameter(Mandatory = $false, Position = 3)]
        $pelisplus
    )
    # Save the variables needed to reproduce media in cache.ps1, cache_media save the url of the next episode
    $global:choice += 1
    $i = 1
    foreach ($link in $media_links) {
        if ($global:choice -eq $i) {
            $global:cache_media = $link
        }
        $i++
    }
    if ($pelisplus -eq $true) {
        Write-Output "`$global:pelisplus=`$true`n`$global:choice=$global:choice`n`$url='$url'`n`$regex_embed=`"$regex_embed`"`n`$global:cache_media='$global:cache_media'`n`$media_links=" > cache.ps1        
    }
    else {
        Write-Output "`$global:pelisplus=`$false`n`$global:choice=$global:choice`n`$url='$url'`n`$regex_embed='$regex_embed'`n`$global:cache_media='$global:cache_media'`n`$media_links=" > cache.ps1
    }
    foreach ($link in $media_links) {
        Write-Output "'$link'," >> cache.ps1
    }
    Write-Output "'That Was the last chapter :('" >> .\cache.ps1
}


function Start-Cache {
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$url,
        [Parameter(Mandatory = $true, Position = 1)]
        [string]$regex_embed,
        [Parameter(Mandatory = $true, Position = 2)]
        $media_links
    )
    Remove-Item cache.ps1
    Save-Cache $url $regex_embed $media_links $pelisplus
    $media = $global:cache_media
    Start-EmbeddedLink $url $regex_embed $media
}


function Watch-EnglishMedia {
    # Scrape the url to find movies or series
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
        # Prevent add 2 to choice when saving cache
        $global:choice -= 1 
        Save-Cache $url $regex_embed $global:media_links
    }
    Start-EmbeddedLink $url $regex_embed $media
}


function Watch-SpanishMedia {
    # Scrape spanish media
    # Since regex_embed of pelisplus have single quotes, this is useful to save the file without affect regex_embed of gototub 
    $pelisplus = $true
    $url = "https://pelisplushd.net/search"
    $regex = '\s*<a href="https:\/\/pelisplushd.net\/(?<media>[^"]*)" class=.*'
    $media_links = Get-UrlTitles $url $regex
    $url = "https://pelisplushd.net/"
    Write-MediaTitles $media_links
    $media = Get-UserChoice $media_links
    $regex_embed = "\s*video\[\d\] = '(?<media>[^']*)'.*"
    # Distinguis between movie or series
    if ($media -match "^serie\/.*") {
        # When series selected, search episodes an change $media to the selected episode
        $url_episodes = "https://pelisplushd.net/serie/"
        $regex_episodes = '\s*<a href="' + $url_episodes + '(?<media>[^"]*)" class=.*'
        $media = Select-Episodes $url $regex_episodes $media
        $url = $url_episodes
        # Prevent add 2 to choice when saving cache
        $global:choice -= 1
        Save-Cache $url $regex_embed $global:media_links $pelisplus
    }
    Start-EmbeddedLink $url $regex_embed $media
}


function Menu {
    Clear-Host
    # If cache found, ask user if want to reproduce next episode
    if (Test-Path cache.ps1) {
        . .\cache.ps1
        $ans = Read-Host -Prompt "In your last visit you were watching $global:cache_media, Do you want to see the next episode? Y/N: "
        if ($ans.ToUpper() -eq "Y") {
            Start-Cache $url $regex_embed $media_links
        }
        else {
            Remove-Item cache.ps1
        }
    }
    Clear-Host
    Write-Host "Menu`n`n1. Watch movies or series in english`n2. Watch movies or series in spanish`n3. Exit"
    $selected_option = Read-Host
    switch ($selected_option) {
        1 { Watch-EnglishMedia }
        2 { Watch-SpanishMedia }
        3 {
            Clear-Host
            Write-Host "Goodbye"
            Exit-PSHostProcess 
        }
        Default { Write-Host -ForegroundColor red -BackgroundColor white "Invalid option. Please select another option"; pause; Menu }
    }
}


Menu # This start the menu
