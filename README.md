# kuroflix-PowerShell

A bash script to browse and watch movies or series on Windows

This script is a port of [kuroflix](https://github.com/kuro-vale/kuroflix)

This script also have an [android version](https://github.com/kuro-vale/kuroflix/tree/termux), please read carefully to make it work

For english media this script scrapes [gototub](https://www.gototub.com/)

For spanish media this script scrapes [pelisplus](https://pelisplushd.net/)

## Download

Download code as zip and extract 

or git clone if you have git bash:

```bash
git clone https://github.com/kuro-vale/kuroflix-powershell.git
```

## How to use
### Getting Started
There is a policy which restricts script execution, you have to run the following code as administrator in powershell

```bash
Set-executionpolicy unrestricted
```

##### Set an internet browser

Change the first line of the script with your favorite browser, example:
```$BROWSER= "chrome"```

### Initialize script

```bash
cd kuroflix-powershell
.\kuroflix.ps1
```

Then follow the instructions

If you enter an empty space when the script prompts you anything, an error will appear

## Dependencies

* Powershell
* Internet Browser

## Disclaimer

I do not own any of the media this script show.

This script was made for educational purposes only.

What users do with this is not my responsibility.

## Explaining video

[![kuroflix](https://img.youtube.com/vi/kdTxGzryaeo/0.jpg)](https://youtu.be/kdTxGzryaeo "kuroflix")
