<#
This script is designed to remediate an odd issue sometimes found with VMs on Hyper-V hosts.
After a VM reboots, there is a chance of the NIC (or one of the NICs if the VM has several) getting an IP
address of 169.254.X.X and not being able to connect to the intended network. The easiest way to fix this
is to disconnect and reconnect the NIC, and this script does so automatically for any VM on the host that
has an IP address starting with 169.254.

Set up a repeating scheduled task on the host and you can run this every few minutes forever, so any
system that has the IP conflict bug will be fixed automatically after no more than 5 minutes once
it has finished rebooting.
#>
$serverList = Get-VM | Select-Object Name   #creates a list of every VM running on the host
foreach ($server in $serverList)
{
    $name = $server.Name
    $adapters = Get-VMNetworkAdapter -VMName $name   #gets a list of info for each adapter on the VM, if there's more than one
    foreach ($adapter in $adapters)
    {
        if ($adapter.IPAddresses -match "169.254")   #checks if the IP contains 169.254, which indicates the NIC needs to be reset
        {
            $adapterName = $adapter.SwitchName   #This is the name of the network the NIC is connected to
            Disconnect-VMNetworkAdapter -VMName $name
            Connect-VMNetworkAdapter -VMName $name -SwitchName $adapterName   #reconnects the NIC to the same network it was on
        }
    }
}