#加载winapi 
trap [exception]
{
 '在trap中捕获到脚本异常'
 $_.Exception.Message
 continue
} 
try
{


$ini = Add-Type -memberDefinition @"  
[DllImport("Kernel32")]  
public static extern int GetPrivateProfileString (  
string section ,    
string key ,   
string def ,   
StringBuilder retVal ,    
int size ,   
string filePath );   
"@ -passthru -name MyPrivateProfileString -UsingNamespace System.Text  
$retVal=New-Object System.Text.StringBuilder(256) 
$filePath=$env:__ROOTDIR__ + '\config.ini'
$null=$ini::GetPrivateProfileString("MinGW","location","",$retVal,256,$filePath)  


$MINGW_URL=$retVal.tostring()  
#
#
$dlpath=$env:__ROOTDIR__ + "\~tmp\MinGW.zip"
$client=new-object System.Net.WebClient
$client.DownloadFile( $MINGW_URL, $dlpath )


$Source = $dlpath
$Destination = $env:__ROOTDIR__

 
if ((Test-Path $Destination) -eq $false)
{
  $null = mkdir $Destination
}
 
$shell = New-Object -ComObject Shell.Application
$sourceFolder = $shell.NameSpace($Source)
$destinationFolder = $shell.NameSpace($Destination)
$DestinationFolder.CopyHere($sourceFolder.Items())

}
catch
{
   echo $_.Exception.Message
   exit 1
 
}
