$Directory = "C:\Users\cdonohue\Desktop\TestFolderArchive"
$FilesToKeep =@("ImageTest","ProcessHistory")
$FileExtension = ".zip"
$MaxDepth=3
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

function delete-files
{
	Param (
		$DeleteDirectory=""
	)
	[Reflection.Assembly]::LoadWithPartialName("System.Windows.forms") | out-null
	write-host "Archiving folder $SourceDir ..." -foregroundcolor Yellow
	$FileList = Get-ChildItem $DeleteDirectory -recurse

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
}
Function Get-FoldersToDepth
{
  Param(
  [String]$Path=$PWD,
  [Byte]$ToDepth=255,
  [Byte]$CurrentDepth=0
  )
  
  #The function Get-FoldersToDepth inventory all subfolders until it reach a maximum Depth
  $CurrentDepth++
  $Childs=Get-ChildItem $Path
  LogDisplay ("Get Folders in $Path") "Information"
  $Tab=@()
  ForEach ($Child in  $Childs)
  {
    If (($Child.PsIsContainer) -AND ($CurrentDepth -le $ToDepth))
	{
	  $Tab+=$Child.FullName
	  $TabTemp=Get-FoldersToDepth -Path $Child.FullName -ToDepth $ToDepth -CurrentDepth $CurrentDepth
	  If ($TabTemp -ne $Null) {$Tab+=$TabTemp}
	}
  }
  Return $Tab
}

[Reflection.Assembly]::LoadWithPartialName("System.Windows.forms") | out-null
$SourceFolders=@()
$SourceFolders+=$Directory
$TempSourceFoldersDepth=Get-FoldersToDepth -Path $Directory -ToDepth $MaxDepth
If ($TempSourceFoldersDepth -ne $Null) 
{
  $SourceFolders+=$TempSourceFoldersDepth
}
#We start by the end to be sure to treat the deepest folder (less files per archive session)
for($i=($SourceFolders.count-1); $i -ge 0; $i--)
{
  $Folder=$SourceFolders[$i]
  $TempArchiveDir=$Folder.Replace($SourceDir,$ArchiveDir)
  delete-files $Folder
}

