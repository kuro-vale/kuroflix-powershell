function Get-UrlTitles {
    param (
        [Parameter(Mandatory=$true, Position=0)]
        [string]$url,
        [Parameter(Mandatory=$true, Position=1)]
        [string]$regex
    )
    # Get a url list of the media searched
    Clear-Host
    $search= (Read-Host -Prompt "What do you want to watch?: ") -replace " " , "+"
    $source_code= ( Invoke-RestMethod $url'?s='$search | Select-String $regex -AllMatches).Matches
    $media_links = New-Object Collections.Generic.List[string]
    foreach ($Media in $source_code)
    {
        $media_links.Add(($Media.Groups.Where{$_.Name -like 'media'}).Value)
    }
    if (!$media_links) {
        Write-Host "No search results for $search`nVerify that you didn't have errors like: 'Abatar' instead of 'Avatar', 'Ironman' instead of 'Iron Man'"
    }
    return $media_links
} 


function Watch-EnglishMedia {
    $url="https://gototub.com/"
    $regex= '.*<a href="https://gototub.com/(?<media>[^"]*)" data-url=.*'
    $media_links= Get-UrlTitles $url $regex
    Write-MediaTitles $media_links
}


function Write-MediaTitles {
    param(
        [Parameter(Mandatory=$true)]
        $media_links
    )
    $i=1
    foreach ($link in $media_links) {
        Write-Host "$i."$link
        $i++
    }
}
Watch-EnglishMedia
