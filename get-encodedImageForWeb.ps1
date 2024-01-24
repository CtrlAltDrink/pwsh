# This script takes an image file path as a parameter and returns a base 64 encoded string
Param ([String]$imagePath)
# Read the image file as a byte array
$bytes = Get-Content -Path $imagePath -Encoding Byte
# Convert the byte array to a base 64 string
$base64 = [Convert]::ToBase64String($bytes)
# Return the base 64 string
return $base64
'<img src="data:image/png;base64, $base64" alt="Image">' | set-clipboard