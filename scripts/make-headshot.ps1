<#
  Crops a square, face-centred headshot from a profile photo for the People page cards.

  Usage (from the project root):
    powershell -File scripts/make-headshot.ps1 images/profiles/jane_doe.jpg -CenterX 0.5 -CenterY 0.25 -Zoom 2

  CenterX / CenterY : position of the face as a fraction of image width / height (0 = left/top)
  Zoom              : 1 = largest possible square; 2 = square half as wide (tighter on the face)
  Output            : images/profiles/thumbs/<same name>.jpg, Size x Size pixels
#>
param(
  [Parameter(Mandatory = $true)][string]$Path,
  [double]$CenterX = 0.5,
  [double]$CenterY = 0.5,
  [double]$Zoom = 1.0,
  [int]$Size = 400
)

Add-Type -AssemblyName System.Drawing

$src = [System.Drawing.Image]::FromFile((Resolve-Path $Path))

# Respect EXIF orientation so phone photos are not sideways
$orientationId = 0x0112
if ($src.PropertyIdList -contains $orientationId) {
  switch ($src.GetPropertyItem($orientationId).Value[0]) {
    3 { $src.RotateFlip([System.Drawing.RotateFlipType]::Rotate180FlipNone) }
    6 { $src.RotateFlip([System.Drawing.RotateFlipType]::Rotate90FlipNone) }
    8 { $src.RotateFlip([System.Drawing.RotateFlipType]::Rotate270FlipNone) }
  }
}

$side = [Math]::Min($src.Width, $src.Height) / [Math]::Max($Zoom, 1.0)
$left = [Math]::Min([Math]::Max($CenterX * $src.Width - $side / 2, 0), $src.Width - $side)
$top  = [Math]::Min([Math]::Max($CenterY * $src.Height - $side / 2, 0), $src.Height - $side)

$dst = New-Object System.Drawing.Bitmap $Size, $Size
$g = [System.Drawing.Graphics]::FromImage($dst)
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
$g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
$g.DrawImage($src,
  (New-Object System.Drawing.RectangleF 0, 0, $Size, $Size),
  (New-Object System.Drawing.RectangleF $left, $top, $side, $side),
  [System.Drawing.GraphicsUnit]::Pixel)

$outDir = Join-Path (Split-Path (Resolve-Path $Path)) 'thumbs'
New-Item -ItemType Directory -Force $outDir | Out-Null
$out = Join-Path $outDir ([IO.Path]::GetFileNameWithoutExtension($Path) + '.jpg')

$codec = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object { $_.MimeType -eq 'image/jpeg' }
$params = New-Object System.Drawing.Imaging.EncoderParameters 1
$params.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter ([System.Drawing.Imaging.Encoder]::Quality), 90L
$dst.Save($out, $codec, $params)

$g.Dispose(); $dst.Dispose(); $src.Dispose()
Write-Output "Wrote $out"
