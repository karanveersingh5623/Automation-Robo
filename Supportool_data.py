OA_ip = "15.154.122.101"
stor_ip = "16.114.216.190"
ilo_ip = "15.154.126.8"

###############################################################3
admin1_credentials = {'userName': 'Administrator', 'password': 'hpeadmin'}

######################################
add_enclosure_uri = '/rest/enclosures'
add1_enclosure_body = {"hostname": OA_ip, "username": "admin", "password": "admin1234", "licensingIntent": "OneViewStandard", "state": "Monitored", "force": "true"} 
                      
####################################################################################

storage1_systems = {"hostname": stor_ip, "username": "3paradm", "password": "3pardata", "family": "StoreServ"}

#############################################################################################################################

rackservers1 = {"hostname": ilo_ip, "username": "admin", "password": "admin123", "force": "true", "licensingIntent": "OneView", "configurationState": "Monitored"}
#############################################################################

devComm_commands1 = ['./device_communication.py -ip' + ' ' + stor_ip + ' ' + '-devtype 3par', './device_communication.py -ip' + ' ' + OA_ip + ' ' + '-devtype OA',
                      './device_communication.py -ip' + ' ' + ilo_ip + ' ' + '-devtype ILO']

ilo_devComm = '''Device Type : ilo
Note: REST and SNMP access are supported only on iLO 4.
Supported protocols :  ping,rest,ribcl,snmp

ping : passed
checking REST communication for iLO...
REST : passed
checking RIBCL communication for iLO...
RIBCL : Passed
checking snmp communication ...
snmp : failed'''

devComm_3par = '''Device Type : 3par
Supported protocols :  ping,rest

ping : passed


checking REST communication for 3PAR ...
REST : passed'''

devComm_OA = '''Device Type : oa
Supported protocols :  ping,ssh,soap

ping : passed
checking ssh communication ...
SSH : passed
checking SOAP communication ...
SOAP failed'''

#              '''"./check_port_communication.py -h", "./check_port_communication.py -ip 15.154.122.101 -devtype OA", "./check_port_communication.py -ip 15.154.126.8 -devtype ilo", 
#              "./check_port_communication.py -ip 16.114.216.190 -devtype 3PAR", "./dtask.py -h", "./dtask.py --list running", "./rabbitmq.py -h", "./rabbitmq.py -l PM", "./dbSync.py -h", 
#              "./dbSync.py -rm fulldb -diff", "./dbSync.py -report -filename fulldbreport.pdf"]'''
##############################################


portComm_OA = '''IP Address : 15.154.122.101
Supported ports are 161,22,443

Checking for port...
Port 161:        Open
Latency 0:00:00.000054:

Checking for port...
Port 22:         Open
Latency 0:00:00.001341:

Checking for port...
Port 443:        Open
Latency 0:00:00.001088:


Port check completed'''

output_list = ilo_devComm