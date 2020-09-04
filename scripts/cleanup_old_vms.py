import subprocess
import re
import os
def purge_vm(vms, pattern):
    max_build_number = 0
    for vm in vms:
        search = pattern.search(vm)
        if not search:
            continue
        build_number = int(search.group(1))
        if build_number > max_build_number:
            max_build_number = build_number
    for vm in vms:
        search = pattern.search(vm)
        if not search:
            continue
        build_number = int(search.group(1))
        if build_number < max_build_number - 3:
            print("Killing VM: " + vm)
            subprocess.run(['vboxmanage', 'controlvm', search.group(2), "poweroff"])
            subprocess.run(['vboxmanage', 'unregistervm', search.group(2), "--delete"])
def purge_ubuntu(vms):
    pattern = re.compile('"ubuntu-(.*)\.[0-9]+" \{(.*)\}')
    purge_vm(vms, pattern)
def purge_centos(vms):
    pattern = re.compile('"centos-(.*)" \{(.*)\}')
    purge_vm(vms, pattern)
if __name__ == "__main__":
    process = subprocess.run(['vboxmanage', 'list', 'vms'], stdout=subprocess.PIPE)
    vms = process.stdout.decode('utf-8').split("\n")[:-1]
    print("Running VMs: " + str(vms))
    purge_ubuntu(vms)
    purge_centos(vms)