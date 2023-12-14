function Format-Json([Parameter(Mandatory, ValueFromPipeline)][String] $json) {
  $indent = 0;
  ($json -Split '\n' |
    % {
      if ($_ -match '[\}\]]') {
        # This line contains  ] or }, decrement the indentation level
        $indent--
      }
      $line = (' ' * $indent * 2) + $_.TrimStart().Replace(':  ', ': ')
      if ($_ -match '[\{\[]') {
        # This line contains [ or {, increment the indentation level
        $indent++
      }
      $line
  }) -Join "`n"
}

function get_root_path()
{
	$root_path = (Get-ChildItem -Path Env:KIS_ROOT).Value
	$root_path = $root_path.Substring(0, $root_path.length - 1)
	
	return $root_path
}


function patch_IOBoardManagerConf()
{	
	echo " => Run patch_IOBoardManagerConf ..."

	$root_path = get_root_path
	$file_source = "$root_path\app\services\super-io\Configuration\IOBoardManagerConf.json"
	$file_destination  = "$root_path\app\services\super-io\Configuration\IOBoardManagerConf.json"
	
	$json = Get-Content $file_source | Out-String | ConvertFrom-Json

	$json.IoBoardManagerConf.FakeBoard = $false
	$json.IoBoardManagerConf.FakeCF330 = $false
	$json.IoBoardManagerConf.FakeWynide = $false

	$json | ConvertTo-Json -depth 32 | Format-Json | set-content $file_destination

	echo " => Finish patch_IOBoardManagerConf"
}

function patch_AutoDiscoveryOptions()
{
	echo " => Run patch_AutoDiscoveryOptions ..."

	$root_path = get_root_path
	$file_source = "$root_path\app\services\hardware\Configuration\AutoDiscoveryOptions.json"
	$file_destination  = "$root_path\app\services\hardware\Configuration\AutoDiscoveryOptions.json"

	$json = Get-Content $file_source | Out-String | ConvertFrom-Json
	$json.AutoDiscoveryOptions.ListDisabledDevices = $json.AutoDiscoveryOptions.ListDisabledDevices |
		Where-Object {
			$_ -ne 'Fake'
		}
	
	$json | ConvertTo-Json -depth 32 | Format-Json | set-content $file_destination

	echo " => Finish patch_AutoDiscoveryOptions"
}

function patch_appsettings()
{	
	echo " => Run patch_appsettings ..."

	$root_path = get_root_path
	$file_source = "$root_path\app\services\ui\appsettings.json"
	$file_destination  = "$root_path\app\services\ui\appsettings.json"
	
	$json = Get-Content $file_source | Out-String | ConvertFrom-Json

	$json.SystemSettings.Cursor = "none"

	$json | ConvertTo-Json -depth 32 | Format-Json | set-content $file_destination

	echo " => Finish patch_appsettings"
}

function patch_configuration()
{	
	echo " => Run patch_configuration ..."

	$root_path = get_root_path
	$file_source = "$root_path\static\configuration\services\payment\configuration.json"
	$file_destination  = "$root_path\static\configuration\services\payment\configuration.json"
	
	$json = Get-Content $file_source | Out-String | ConvertFrom-Json

	# SET DEVICES
	$json.Devices | % {
		if($_.Type -eq 'Free'){
			$_.Active = $false
		} elseif($_.Type -eq 'Coin'){
			$_.Active = $true
		} else {
			$_.Active = $false
		}
	}

	# SET DisablePrinter
	$json.DisablePrinter = $false

	$json | ConvertTo-Json -depth 32 | Format-Json | set-content $file_destination

	echo " => Finish patch_configuration"
}

function patch_staticConfiguration()
{	
	echo " => Run patch_staticConfiguration ..."

	$root_path = get_root_path
	$file_source = "$root_path\static\configuration\services\receipt\staticConfiguration.json"
	$file_destination  = "$root_path\static\configuration\services\receipt\staticConfiguration.json"
	
	$json = Get-Content $file_source | Out-String | ConvertFrom-Json

	$json.DisabledPlugins = $json.DisabledPlugins |
		Where-Object {
			$_ -ne 'Printer'
		}
		
	if ($json.DisabledPlugins -eq $null) {
		$json.DisabledPlugins = @()
	}

	$json | ConvertTo-Json -depth 32 | Format-Json | set-content $file_destination

	echo " => Finish patch_staticConfiguration"
}

function patch_UiConfiguration()
{	
	echo " => Run patch_UiConfiguration ..."

	$root_path = get_root_path
	$file_source = "$root_path\app\services\ui\Configuration\UiConfiguration\UiConfiguration.json"
	$file_destination  = "$root_path\app\services\ui\Configuration\UiConfiguration\UiConfiguration.json"
	
	$json = Get-Content $file_source | Out-String | ConvertFrom-Json

	$json.UiConfiguration.DisplayPrintTicket = $true

	$json | ConvertTo-Json -depth 32 | Format-Json | set-content $file_destination

	echo " => Finish patch_UiConfiguration"
}

patch_IOBoardManagerConf
patch_AutoDiscoveryOptions
patch_appsettings
patch_configuration
patch_staticConfiguration
patch_UiConfiguration
