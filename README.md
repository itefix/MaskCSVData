# MaskCSVData

NAME
    .\MarkCSVData.ps1
    
SYNOPSIS
    A simple script for data masking of CSV files
    
    
SYNTAX
    .\MarkCSVData.ps1 [[-csvFileIn] <String>] [[-csvFileOut] <String>] [[-inDelimiter] <String>] [[-outDelimiter] <String>] [[-profile] <String>] [[-configFile] <String>] [<CommonParameters>] 
    
DESCRIPTION
    Replaces characters in specified fields by using random lookup into predefined groups:
    lower and uppercase vocals, lower and uppercase consonants and digits by default.
    When a new pattern is generated, it will be reused again for occurences of the
    same value in the same field.
    

PARAMETERS

    -csvFileIn <String>        
    -csvFileOut <String>       
    -inDelimiter <String>      
    -outDelimiter <String>        
    -profile <String>       
    -configFile <String>
     
    -------------------------- EXAMPLE 1 --------------------------
    
    PS C:\>.\MarkCSVData.ps1 -profile Sample -csvFileIn .\MaskCSVData.sample.csv -csvFileOut .\MaskCSVData.out.csv
        
    
    -------------------------- EXAMPLE 2 --------------------------
    
    PS C:\>.\MarkCSVData.ps1 -profile Sample -csvFileIn .\in.csv -csvFileOut .\out.csv -inDelimiter '`t' -outDelimiter ';'
 
