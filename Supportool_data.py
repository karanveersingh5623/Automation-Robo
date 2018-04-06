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
