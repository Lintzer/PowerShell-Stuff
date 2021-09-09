cls

#This line sets the cutoff date for a system to be considered inactive. You can change this to 60 or 90 days if you wish, rather than 30 days
$inactiveDate = (Get-Date).AddDays(-30).Date

#Get a list of every computer account in the domain and sort it alphabetically
$allServers = Get-ADComputer -Filter * -Properties *
$allServers = $allServers | Sort

#Creatign the arrays to split the accounts into based on whether they are considered active or inactive
$activeServers = @()
$inactiveServers = @()

#Go through the list of computer accounts found, get their last logon date, compare it to the cutoff date defined above,
#and add them to the list of active or inactive systems based on the results of the comparison. This part also lists
#out each computer name that is found to be inactive
foreach ($server in $allServers)
{
    $serverName = $server.Name
    $logonDate = $server.lastLogonDate
    if ($logonDate -lt $inactiveDate)
    {
        Write-Host "$serverName hasn't connected to AD in longer than 30 days; the last connection date was $logonDate"
        $inactiveServers += $serverName
    }
    else
    {
        $activeServers += $serverName
    }
}

#Get counts for the three lists. Active and inactive counts should add up to the count for all systems
$serverCount = $allServers.count
$activeCount = $activeServers.count
$inactiveServers = $inactiveServers.count

Write-Host "There are $serverCount servers in the domain: $activeCount are active and $inactiveCount are inactive."