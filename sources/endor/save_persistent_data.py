import os
import sys
import subprocess


def executeSingleCommand(user, database, cmd):
    command ='psql -U {} -d {} -t -q -c "{}"'.format(user, database, cmd)
    commandResponse = subprocess.check_output(command, universal_newlines=True, stderr=subprocess.STDOUT, shell=True).rstrip().lstrip()
    return commandResponse





def savePersistentDatabaseState(user, database):
    retVal = dict()
    retVal['saved_values'] = True
    
    # Retrieve the information we want to save
    dhcp_enabled = executeSingleCommand(user, database, "SELECT dhcp_enabled FROM control_port_state")
    ipv4_address = executeSingleCommand(user, database, "SELECT ipv4_address FROM control_port_state")
    subnet_mask  = executeSingleCommand(user, database, "SELECT subnet_mask FROM control_port_state")
    gateway      = executeSingleCommand(user, database, "SELECT gateway FROM control_port_state")
    
    # Add it to the dictionary
    retVal['dhcp_enabled'] = dhcp_enabled
    retVal['ipv4_address'] = ipv4_address
    retVal['subnet_mask']  = subnet_mask
    retVal['gateway']      = gateway
    
    # Indicate success
    retVal['saved_values'] = True
    
    # Output the dictionary
    print (str(retVal))
    


def main():
    savePersistentDatabaseState("admin", "endor")

if __name__ == "__main__":
   main()
    
