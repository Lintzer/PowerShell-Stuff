<#

This program is designed to create random numbers within a given range, of size up to 12 digits long.
After prompting the user to input the boundaries (min and max), as well as how many times the user wants
to generate a number, the program goes to the Get-Randoms function. The overall idea is to get the Unix Timestamp
at the beginning of the Generate-Number function, then run the Time-Killer function to introduce some unpredictability
before grabbing a second Unix Timestamp, adding the two timestamp values together, creating a new value based on the
last 4 digits of each of those 3 numbers, reversing the order of the digits, and finally pulling out the last few
digits based on the number of digits in the difference between the lower and upper bounds. Lastly, we add that extracted
number to the lower bound and check to ensure it's not larger than the upper bound. If it is, we go through the process
Once more. If not, the number is acceptable and returned to the user.

#>
clear

function Time-Killer
{
    param($length)
    $counter = 0
    while ($counter -lt $length)
    {
        [double]$source = ((New-TimeSpan -Start (Get-Date "01/01/1970") -End (Get-Date)).TotalSeconds) * 100000
        if (($source % 7) -eq 0)
        {
            $counter++
        }
    } 
}

function Generate-Number
{
    param($length)
    [double]$num1 = ((New-TimeSpan -Start (Get-Date "01/01/1970") -End (Get-Date)).TotalSeconds) * 100000
    Time-Killer -length $length
    [double]$num2 = ((New-TimeSpan -Start (Get-Date "01/01/1970") -End (Get-Date)).TotalSeconds) * 100000
    [double]$sum1 = $num1 + $num2
    [string]$string1 = $num1
    [string]$string2 = $num2
    [string]$string3 = $sum1
    [string]$comboString = $string1.Substring($string1.get_Length()-4) + $string2.Substring($string2.get_Length()-4) + $string3.Substring($string3.get_Length()-4)
    [string]$sumString = Reverse-Value -original $comboString
    [string]$sameLength = $sumString.Substring($sumString.get_Length()-$length)
    $sameLength
}

function Reverse-Value
{
    param($original)
    $inputString = [string]$original
    $reversed = ([regex]::Matches($inputString,'.','RightToLeft') | ForEach {$_.value}) -join ''
    $reversed
}

function Get-Randoms
{
    param([int]$lowerBound, [int]$upperBound)
    [int]$boundRange = $upperBound - $lowerBound
    [int]$diffLength = $boundRange | measure-object -character | select -ExpandProperty characters
    [string]$number = Generate-Number -length $diffLength
    while ($number -gt $boundRange)
    {
        [string]$number = Generate-Number -length $diffLength
    }
    $randResult = $lowerBound + $number
    if ($randResult % 2)
    {
        $randResult = Reverse-Value -original $randResult
    }
    Write-Host "The randomly selected result is $randResult."
}

<#
Ask the user for a minimum and maximum boundary on the range of numbers to select from, and how many numbers (n) to generate.
The 'for' loop will run the Get-Randoms function n number of times
#>
[int]$rangeMin = Read-Host "Please enter the minimum number for generating a random number: "
[int]$rangeMax = Read-Host "Please enter the maximum number for generating a random number: "
[int]$runtime = Read-Host "How many numbers would you like to generate within this range?"
for ($i = 0; $i -lt $runtime; $i++)
{
    Get-Randoms -lowerBound $rangeMin -upperBound $rangeMax
}


