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

<#
Time-Killer introduces some unpredictability into the process by pulling Unix Timestamps and checking to see if they are
divisible by a given prime number. The function runs until it finds 'n' Timestamps meeting this criteria. Changing the prime
to a larger value increases runtime and makes the results even less predictable.

The idea here is, even knowing the exact moment the script starts running, it's very difficult to predict how long this function
will take to ocmplete because it's dependent on the processor speed as well as the load. So theoretically, if you ran this script
on two different machines but at the exact same time, you should still get different outputs because of this function.
#>
function Time-Killer
{
    param($length)
    $counter = 0
    while ($counter -lt $length)
    {
        [decimal]$source = ((New-TimeSpan -Start (Get-Date "01/01/1970") -End (Get-Date)).TotalSeconds) * 100000
        if (($source % 7) -eq 0)
        {
            $counter++
        }
    } 
}

<#
Here is where most of the work is done. We get an initial Timestamp value, then run the Time-Killer function to add a variable
length buffer before pulling a second Timestamp value. Next we add the two Timestamps together, then convert all three values
to strings for manipulation. We repeat this again, running Time-Killer once more to get a third Timestamp.
We combine the last several digits of each number to create a new number of 20 digits (this can be
changed in the $comboString settings if you want to generate even larger numbers, but be wary of this as PowerShell natively
doesn't handle super big numbers well). After creating the $comboString number we reverse the order of the digits with the Reverse-Value
function, and finally extract the last few digits to create a number that is the same length as the difference between the input
boundary values given by the user. This number is returned to the Get-Randoms function that called for it.

NOTE: Increasing the number of digits extracted from each source value for creating $comboString is NOT recommended.
Doing so results in issues generating numbers with only a couple of digits. If larger numbers aare needed, the best way
to achieve this is to add another .Substring() into the chain (add in a Time-Killer runtime above, grab the Timestamp
in a new vaariable, convert that to a string, and pull the last 4 from that).
#>
function Generate-Number
{
    param($length)
    [decimal]$num1 = ((New-TimeSpan -Start (Get-Date "01/01/1970") -End (Get-Date)).TotalSeconds) * 100000
    Time-Killer -length $length
    [decimal]$num2 = ((New-TimeSpan -Start (Get-Date "01/01/1970") -End (Get-Date)).TotalSeconds) * 100000
    [decimal]$sum1 = $num1 + $num2
    Time-Killer -length $length
    [decimal]$num3 = ((New-TimeSpan -Start (Get-Date "01/01/1970") -End (Get-Date)).TotalSeconds) * 100000
    [decimal]$bigNum = $num1 + $num2 + $num3 + $sum1
    [string]$string1 = $num1
    [string]$string2 = $num2
    [string]$string3 = $sum1
    [string]$string4 = $num3
    [string]$string5 = $bigNum
    [string]$comboString = $string1.Substring($string1.get_Length()-4) + $string2.Substring($string2.get_Length()-4) + $string5.Substring($string5.get_Length()-4) + $string3.Substring($string3.get_Length()-4) + $string4.Substring($string4.get_Length()-4)
    [string]$sumString = Reverse-Value -original $comboString
    [string]$sameLength = $sumString.Substring($sumString.get_Length()-$length)
    $sameLength
}

<#
Very simple function, it reverses the order of the digits of a given input. I didn't make this myself, I found the regex command via Google:
https://learn-powershell.net/2012/08/12/reversing-a-string-using-powershell/
#>
function Reverse-Value
{
    param($original)
    $inputString = [string]$original
    $reversed = ([regex]::Matches($inputString,'.','RightToLeft') | ForEach {$_.value}) -join ''
    $reversed
}

<#
This function takes the given lower and upper bounds supplied by the user, passes them to Generate-Number to get an output semi-random number
the same length as the difference between the bound values, checks to verify the returned value isn't larger than the difference and then adds
the value to the lower bound. This is how we get a number between any two given values, positive or negative. If the returned number is larger
than the difference between the bounds, it's thrown out and the function reruns everything to get a new number. This will continue indefinitely
if need be, though in practice it rarely has to reject more than a couple numbers to get a usable result. Once we have a good returned value,
it gets added to the lower bound and the total is reversed if it is divisible by 2. Currently there is a bug with this that causes the entire 
string to be reversed, including the negative sign at the beginning (if there is one). The reversal is done to help randomize the result
for larger numbers, otherwise they tend to group together with similar beginning digits.
#>
function Get-Randoms
{
    param([decimal]$lowerBound, [decimal]$upperBound)
    [decimal]$boundRange = $upperBound - $lowerBound
    [decimal]$diffLength = $boundRange | measure-object -character | select -ExpandProperty characters
    [string]$number = Generate-Number -length $diffLength
    while ($number -gt $boundRange)
    {
        [string]$number = Generate-Number -length $diffLength
    }
    $randResult = $lowerBound + $number
    if ($randResult % 2)
    {
        $randResult = Reverse-Value -original $randResult
        if ($randResult -gt $upperBound)
        {
            $randResult = Reverse-Value -original $randResult
        }
    }
    Write-Host "The randomly selected result is $randResult."
}

<#
Ask the user for a minimum and maximum boundary on the range of numbers to select from, and how many numbers (n) to generate.
The 'for' loop will run the Get-Randoms function n number of times
#>
[decimal]$rangeMin = Read-Host "Please enter the minimum number for generating a random number: "
[decimal]$rangeMax = Read-Host "Please enter the maximum number for generating a random number: "
[decimal]$runtime = Read-Host "How many numbers would you like to generate within this range?"
for ($i = 0; $i -lt $runtime; $i++)
{
    Get-Randoms -lowerBound $rangeMin -upperBound $rangeMax
}
