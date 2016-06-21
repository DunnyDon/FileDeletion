$Directory = "C:\Users\cdonohue\Desktop\TestFolderArchive"
$FilesToKeep =@("ImageTest","ProcessHistory")
$FileExtension = ".zip"

function LogExe
{
  param([string]$Message="")
  write "$Date | $Message" | out-file -filepath $LogsExe -append 
}
function LogDisplay
{
  param([string]$Message="", [string]$TypeMess="")
  If ($TypeMess -eq "Error") {Write-Host $Message -foregroundcolor Red}
  If ($TypeMess -eq "Information") {Write-Host $Message -foregroundcolor Yellow}
  If ($TypeMess -eq "Success") {Write-Host $Message -foregroundcolor Green}
  $Message | Out-File 'C:\Users\cdonohue\Desktop\DeletionLog.log' -Append
  }

[Reflection.Assembly]::LoadWithPartialName("System.Windows.forms") | out-null
write-host "Archiving folder $SourceDir ..." -foregroundcolor Yellow
$FileList = Get-ChildItem $Directory -recurse

If ($FileList -ne $Null)
{
Foreach ($File in $FileList)
	{
		if($FileExtension -contains $File.Extension.ToLower()){
			$check = 0
			Foreach ($nameoffile in $FilesToKeep){
				$containsWord = $file | %{$_ -match $nameoffile}
				If($containsWord -eq "True"){
					$check = 1 
				}
			}
			if ($check -ne 1){
				Remove-item $File.FullName
				LogDisplay ($File.FullName+" Removed") "Success"
			}
		}
	}
}