<#
This script was written to find the resource utilization in a Hyper-V cluster.
It collects information on a list of hosts provided in the ClusterHosts.txt file,
such as total RAM and logical CPUs on the host. It also gets a list of how many
VMs are on each host, and how many CPU cores and how much RAM each VM is assigned.
It adds these all together and prints out a report of usage on each host, as well
as a total of how many CPUs are available across the cluster versus how many are
in use, as well as the same breakdown for memory.
#>

#This provides the total installed memory of the specified host server.
function Get-Memory
{
    Param($serverName)
    $totalRAM = (Get-CimInstance Win32_ComputerSystem -ComputerName $serverName).TotalPhysicalMemory
    return ($totalRAM / 1GB)
}

#This provides the total number of logical CPU cores present on the specified host.
function Get-Processors
{
    param($serverName)
    $numberCPUs = (Get-CimInstance Win32_ComputerSystem -ComputerName $serverName).NumberOfLogicalProcessors
    return $numberCPUs
}

cls
#This is where we specify the input list of host servers to check
$hostList = Get-Content C:\scripts\ClusterHosts.txt
#These will be filled in as the script runs to keep track of the various resource values
$availableCores = 0
$availableMemory = 0
$allocatedCPUs = 0
$allocatedMemory = 0

#The loop that goes through each host in the provided list and collects information from it
foreach ($server in $hostList)
{
    #These will keep track of how many VM resources are actually assigned out across the cluster
    $hostCoresUsed = 0
    $hostMemoryUsed = 0
    $guests = Get-VM -ComputerName $server
    $numberGuests = $guests.count
    #Collecting resource assignment numbers for each hosted VM
    foreach ($guest in $guests)
    {
        $name = $guest.name
        $guestCores = $guest.ProcessorCount
        $guestMemory = ($guest.MemoryAssigned) / 1GB
        #These add the resources used by each VM to the running totals for what's being used on each host in the cluster
        $hostCoresUsed += $guestCores
        $hostMemoryUsed += $guestMemory
    }
    #collect the host CPU and memory info
    $hostRAM = Get-Memory -serverName $server
    $hostCores = Get-Processors -serverName $server
    #Add the resources on each host to the running totals for the entire cluster
    $availableCores +=$hostCores
    $availableMemory += $hostRAM
    #Add the used resources on each host to the running totals for the entire cluster
    $allocatedCPUs += $hostCoresUsed
    $allocatedMemory += $hostMemoryUsed
    #Print out a report for each host as it runs through the list
    Write-Host "$server is hosting $numberGuests VMs. It is using $hostCoresUsed / $hostCores CPUs, and $hostMemoryUsed / $hostRAM GB RAM."
}
#Print out the reports for CPU and memory usage versus availability across the cluster
Write-Host "There are $availableCores cores available in the cluster and we are using $allocatedCPUs of them."
Write-Host "There is $availableMemory GB of memory available in the cluster and we are using $allocatedMemory of it."