
#init theme
oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\atomic.omp.json" | Invoke-Expression

#Alias
Set-Alias  grep  findstr
Set-Alias  vim  nvim
Set-Alias  ls  lsd
function  la  { lsd -la }
function  ll { lsd  -l }
function  l  { lsd -l }

