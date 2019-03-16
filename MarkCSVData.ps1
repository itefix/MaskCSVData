<#
.Synopsis
   A simple script for data masking of CSV files
.DESCRIPTION
   Replaces characters in specified fields by using random lookup into predefined groups:
   lower and uppercase vocals, lower and uppercase consonants and digits by default.
   When a new pattern is generated, it will be reused again for occurences of the
   same value in the same field.
.EXAMPLE
   .\MarkCSVData.ps1 -profile Sample -csvFileIn .\MaskCSVData.sample.csv -csvFileOut .\MaskCSVData.out.csv
.EXAMPLE
    .\MarkCSVData.ps1 -profile Sample -csvFileIn .\in.csv -csvFileOut .\out.csv -inDelimiter '`t' -outDelimiter ';'
#>

 param (
    [string]$csvFileIn = "",
    [string]$csvFileOut = "",
    [string]$inDelimiter = ",",
    [string]$outDelimiter = ",",
    [string]$profile = "",
    [string]$configFile = "$PSScriptRoot\MaskCSVData.config"
 )

 if (!(Test-Path $configFile) -or !(Test-Path $csvFileIn))
 {
    throw "Missing Configuration or Input files ($configFile, $csvFileIn)"
 }

 ##### Functions #####
 function MaskField
{
    param(
        [string]$field, # field to mask
        [string]$lookup # each field char in that group will be replaced by an other char in the same group
    )

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

##### Main #####

$csvData = Import-Csv -Path $csvFileIn -Delimiter $inDelimiter
if (!$csvData)
{
    throw "Can't import $csvFileIn (delimiter $inDelimiter)"
}

# Read configuration file
$xml = New-Object -TypeName XML
$xml.Load($configFile)

# check if the profile is defined in the configuration file
$config = $Xml.Profile | Where-Object { $_.Name -eq $profile }
if (!$config)
{
    throw "Missing profile $profile in $configFile"
}

# Create dictionary hashes for reuse of pattern
$dictionary = @{};
foreach ($maskfield in $config.MaskFields.Field)
{
    $dictionary[$maskfield] = @{};
}

foreach ($line in $csvData)
{
    # Process only fields specified in the configuration
    foreach ($maskfield in $config.MaskFields.Field)
    {
        $mfield = $line.$maskfield

        # No need to generate a new mask if done already
        if ($dictionary[$maskfield][$mfield])
        {
            $line.$maskfield = $dictionary[$maskfield][$mfield]
            # "Dictionary hit $mfield ->" +  $line.$maskfield 

        } else {

            # We use five lookup groups - lower/upper-case vocals, lower/-uppercase consonants and digits
            # Extend/update according to your needs
            foreach ($mlookup in  "aeiou", "AIEOU","bcdfgjklmnpqrstvwxyz","BCDFGHJKLMNPQRSTVWXYZ","0123456789")
            {
                $mfield = MaskField -field $mfield -lookup $mlookup
            }

            # removing debris spaces, created during conversion from string to char array
            # almost sure that this can be done better :-)
            $lstring = $mfield.Replace('                               ','')
            $dictionary[$maskfield][$line.$maskfield] = $lstring
            $line.$maskfield = $lstring
        }
    }
}

$csvData | Export-Csv -Path $csvFileOut -Delimiter $outDelimiter -NoTypeInformation
