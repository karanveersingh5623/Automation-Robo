OA_ip = "15.212.144.11"
stor_ip = "15.212.144.135"
ilo4_ip = "15.212.144.90"
ilo3_ip = "15.212.144.16"
ipdu_ip = "15.212.144.94"
ipdu = "IPDU"

###############################################################
admin1_credentials = {'userName': 'Administrator', 'password': 'admin123'}
ssh_cred = {'username': 'root', 'password': 'hpvse1'}
dev_cred = {'OA_user': 'Administrator', 'OA_pass' : 'hpinvent', 'ilo4_user' : 'admin', 'ilo4_pass' : 'admin123', 'ilo3_user' : 'admin', 
            'ilo3_pass' : 'admin123', 'iPDU_user' : 'admin', 'iPDU_pass' : 'admin123'}
##############################################################
add_enclosure_uri = '/rest/enclosures'
add1_enclosure_body = {"hostname": OA_ip, "username": dev_cred['OA_user'], "password": dev_cred['OA_pass'], "licensingIntent": "OneViewStandard", "state": "Monitored", "force": "true"} 
                      
##############################################################

ipdu_systems = {"force": True, "hostname": ipdu_ip, "username": dev_cred['iPDU_user'], "password": dev_cred['iPDU_pass']} 

CERTIFICATE = {"aliasName": "", "base64SSLCertData": "", "status": None, "type": "SSLCertificateDTO"}
                
###############################################################

storage1_systems = {"hostname": stor_ip, "username": "3paradm", "password": "3pardata", "family": "StoreServ"}

#############################################################################

rackservers1 = {"hostname": ilo4_ip, "username": "admin", "password": "admin123", "force": "true", "licensingIntent": "OneView", "configurationState": "Monitored"}
#############################################################################

dbsync_Index_body = {"type": "IndexResourceV300", "attributes": {}, "ownerId": "tasks", "name": "ResourceV3001", "uri": "/rest/server-hardware/test-1", "category": "server-hardware", "scopeUris":["/rest/scope/production", "/rest/scope/dev"]}
dbsync_db_query = '''psql -d cidb -U postgres -h 127.0.0.1 -c "Select uri from index.node where uri='/rest/server-hardware/test-1'";'''
##################################################################################################################################
port_help = '''usage: check_port_communication.py [-h] -ip IPADDRESS [-devtype DEVICETYPE]
                                   [-p PORT]

optional arguments:
  -h, --help            show this help message and exit
  -ip IPADDRESS, --ipaddress IPADDRESS
                        remote host ip address
  -devtype DEVICETYPE, --deviceType DEVICETYPE
                        deviceType of the host i.e ILO or OA or IPDU or 3PAR
                        or I3S or EM
  -p PORT, --port PORT  port number to check whether port is open or not'''
  
  ###################################################################################################################################

task = {"type": "TaskResourceV2", "taskState": "Running", "owner": "Administrator", "userInitiated": "true", "name": "ROBO TASK", "taskType": "User", "associatedResource": {"associationType": "MANAGED_BY", "resourceCategory": "enclosures", "resourceName": "enclosure789", "resourceUri": "/rest/enclosures/ABCD789" }}
  
####################################################################################################################################
headers = {'Content-Type':'application/json','Accept':'application/json'}

############################################################################################################################################

dtask_help = '''usage: dtask.py [-h] [-l LIST] [-i ID] [-t TIME] [-r] [-a ALERTS] [-da] [-tt]
                [-dt] [-f OUTPUTFILE]

optional arguments:
  -h, --help            show this help message and exit
  -l LIST, --list LIST  List tasks on appliance which are in state provided by
                        argumenet value. Argument value can be
                        running,interrupted,completed,pending,error,warning or
                        all
  -i ID, --id ID        Used with -tt (terminating a task) and -dt (deleting a
                        task)options. When used alone it lists down the task
                        details
  -t TIME, --time TIME  List tasks in running state and created certain time
                        ago. Valid format for time is '6d' for 6 days and '4h'
                        for 4 hours ago
  -r, --runningtask     List running tasks on the appliance
  -a ALERTS, --alerts ALERTS
                        List all Alerts on appliance which are in particular
                        state provided by argument value. Argument value can
                        be locked,cleared,or active
  -da, --deletealert    Delete Alert/Alerts on appliance. When no argument is
                        provided then all alerts in locked state are deleted.
                        When -i option is provided along with alertId then
                        alert with that particular alertId is deleted
  -tt, --terminatetask  Interuppt Running/Pending task provided by id
  -dt, --deletetask     Delete a Completed/Interuupted task or delete a task
                        which is in terminal state provided by id. If the task
                        is running or pending then it is first interrupted and
                        then deleted
  -f OUTPUTFILE, --outputFile OUTPUTFILE
                        Write the output of command to provided file'''
