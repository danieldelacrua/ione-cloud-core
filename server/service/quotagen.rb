def NewQuota(login, vmquota, cpu, memory, disk)
    quota = "VM=[
            CPU=\"#{cpu}\",
            MEMORY=\"#{memory}\",
            SYSTEM_DISK_SIZE=\"#{disk}\",
            VMS=\"#{vmquota}\" ]"
    return quota
end