# MaskCSVData
A simple approach to mask fields in CSV files for use in test environments. What we do is simply replacing characters in five predefined groups: lower and uppercase vocals, lower and uppercase consonants and digits. When a new pattern is created in the script, it will be reused again for the same original values.

Usage:

- Edit the configuration file and specify the fields you want to mask in the CSV file

- Run the script:

.\MaskCSVData.ps1 -profile MySystem -csvFileIn .\csvfile.in -csvFileOut csvfile.out [-config .\MaskCSVData.config] [ -indelimiter char] [-outdelimiter char]
