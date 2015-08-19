import os
import sys
import subprocess


def executeSingleCommand(user, database, cmd):
    command ='psql -U {} -d {} -t -q -c "{}"'.format(user, database, cmd)
    commandResponse = subprocess.check_output(command, universal_newlines=True, stderr=subprocess.STDOUT, shell=True).rstrip().lstrip()
    return commandResponse





def recallPersistentDatabaseState(user, database):
    
    input = sys.stdin.read()
    persisted = eval(input)
    print (persisted)
    
    if(persisted['saved_values'] != False):
        executeSingleCommand(user, database, "UPDATE control_port_state SET dhcp_enabled='{}'".format(persisted['dhcp_enabled']))
        executeSingleCommand(user, database, "UPDATE control_port_state SET ipv4_address='{}'".format(persisted['ipv4_address']))
        executeSingleCommand(user, database, "UPDATE control_port_state SET subnet_mask='{}'".format(persisted['subnet_mask']))
        executeSingleCommand(user, database, "UPDATE control_port_state SET gateway='{}'".format(persisted['gateway']))

    # All done
    print (' done.')
    


def main():
    recallPersistentDatabaseState("admin", "endor")

if __name__ == "__main__":
   main()psql a
    
