# A simple data masking of CSV files

 param (
    [string]$csvFileIn = "",
    [string]$csvFileOut = "",
    [string]$inDelimiter = ',',
    [string]$outDelimiter = ',',
    [string]$profile = "",
    [string]$configFile = "$PSScriptRoot\MaskCSVData.config"
 )

 if (!(Test-Path $configFile) -or !(Test-Path $csvFileIn))
 {
    throw "Missing Configuration or Input files ($configFile, $csvFileIn)"
 }

 #####
 function MaskField
{
    param([string]$field, [string]$lookup)

    $fieldarray = [char[]]($field)
    $lookuparray = [char[]]($lookup)
    $randMax =  $lookup.Length - 1

    for($i=0; $i -lt $field.Length; $i++)
    {


        if ($lookup.indexof($fieldarray[$i]) -ne -1)
        {

            $rn = Get-Random -Minimum 0 -Maximum $randMax
                
            $fieldarray[$i] = $lookuparray[$rn]
        }
    }

    return [string]$fieldarray
}

#####

$csvData = Import-Csv -Path $csvFileIn -Delimiter $inDelimiter
if (!$csvData)
{
    throw "Can't import $csvFileIn (delimiter $inDelimiter)"
}

# Read configuration file
$xml = New-Object -TypeName XML
$xml.Load($configFile)
 
$config = $Xml.Profile | Where-Object { $_.Name -eq $profile }
if (!$config)
{
    throw "Missing profile $profile in $configFile"
}

# Create dictionary hashes
$dictionary = @{};
foreach ($maskfield in $config.MaskFields.Field)
{
    $dictionary[$maskfield] = @{};
}

foreach ($line in $csvData)
{

    foreach ($maskfield in $config.MaskFields.Field)
    {

        $mfield = $line.$maskfield

        if ($dictionary[$maskfield][$mfield])
        {
            $line.$maskfield = $dictionary[$maskfield][$mfield]
            "Dictionary hit $mfield ->" +  $line.$maskfield 

        } else {

            foreach ($mlookup in  "aeiou", "AIEOU","bcdfgjklmnpqrstvwxyz","BCDFGHJKLMNPQRSTVWXYZ","0123456789")
            {
                $mfield = MaskField -field $mfield -lookup $mlookup
            }

            $lstring = $mfield.Replace('                               ','')
            $dictionary[$maskfield][$line.$maskfield] = $lstring
            $line.$maskfield = $lstring
        }
    }
}

$csvData | Export-Csv -Path $csvFileOut -Delimiter $outDelimiter
