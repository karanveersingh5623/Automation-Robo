*** Settings ***
 Documentation    Port Communication Script Of Support Tools
 Library      RoboGalaxyLibrary
 Library	  FusionLibrary
 #Library      SSHLibrary
 Library      BuiltIn
 Library      String
 Library      Collections
 Library      String
 #Library      Telnet
 Variables    Supportool_data.py
 Resource     deploy_resource.txt

 *** Variables ***
 ${SSH_HOST}
 ${HOST_USERNAME}    root
 ${HOST_PASSWORD}    hpvse1
 ${command1}    cd /ci/support/ovsupportability/scripts/    
 ${PASS_status}   Open
 ${FAIL_status}    Cannot Connect
 ${ilocommand1}     cd /map1/config1
 ${ilocommand2}     show
 ${ILO_PROMPT}    ->

 *** Keyword ***
 
Open DevSSH Connection And Log In
    [Documentation]     Opens an SSH session to a device and logs in
    [Arguments]         ${SSH_HOST}     ${SSH_USER}    ${SSH_PASS}
    SSHLibrary.Open Connection     ${SSH_HOST}     timeout=180s
    SSHLibrary.Login               ${SSH_USER}     ${SSH_PASS} 
    Log     SSH Connection Eshtablished for ${SSH_HOST}    console=True
    
Open DevTelnet Connection And Log In
    [Documentation]     Opens an Telnet session to a device and logs in
    [Arguments]         ${TEL_HOST}     ${TEL_USER}    ${TEL_PASS}
	Telnet.Open Connection    ${TEL_HOST}    prompt=>     timeout=20s
	Sleep    5
	Telnet.Login    ${TEL_USER}    ${TEL_PASS}    
	Sleep    5
	Log     Telnet Connection Eshtablished    console=True
	sleep    5
    Telnet.Write	ENABLE SECURESH
    sleep    10
	${output}=	Telnet.Read 
	sleep    10 
    Log    [Command]#:${output}    console=true
    Open DevSSH Connection And Log In    ${TEL_HOST}    ${TEL_USER}    ${TEL_PASS}

ILO4 Port Validation
    [Documentation]    Checks port snmp and ssl
    [Arguments]
    ${ILO}=    Create Dictionary 
    Open DevSSH Connection And Log In    ${ilo4_ip}    ${dev_cred['ilo4_user']}    ${dev_cred['ilo4_pass']} 
    SSHLibrary.Write    ${ilocommand1}
    ${stdout1}=          SSHLibrary.Read until    ${ILO_PROMPT}
    SSHLibrary.Write    ${ilocommand2}
    ${stdout2}=          SSHLibrary.Read until    ${ILO_PROMPT}
    sleep    10
    ${ssl}=    Get Lines Containing String    ${stdout2}    oemhp_sslport
    ${snmp}=    Get Lines Containing String    ${stdout2}    oemhp_snmp_port
    Log    Print line ssl: ${ssl}    console=True
    Log    Print line snmp: ${snmp}    console=True
    ${status1}=    Run Keyword and Return Status    Should Contain    ${snmp}    161  
    Log     Status:${status1}    
    Run Keyword If   '${status1}' != 'True'    Log To Console    Port of snmp is not enabled    WARN
    ...    ELSE IF    '${status1}' == 'True'    Set To Dictionary    ${ILO}    Port 161    Open
    ${status}=    Run Keyword and Return Status    Should Contain    ${ssl}    443  
    Log     Status:${status}    
    Run Keyword If   '${status}' != 'True'    Log To Console    Port of ssl is not enabled    WARN
    ...    ELSE IF    '${status}' == 'True'    Set To Dictionary    ${ILO}    Port 443    Open   
    Log Dictionary    ${ILO} 
    [Return]    ${ILO} 

ILO3 Port Validation
    [Documentation]    Checks port snmp and ssl
    [Arguments]
    ${ILO3}=    Create Dictionary 
    Open DevSSH Connection And Log In    ${ilo3_ip}    ${dev_cred['ilo4_user']}    ${dev_cred['ilo4_pass']} 
    SSHLibrary.Write    ${ilocommand1}
    ${stdout1}=          SSHLibrary.Read until    ${ILO_PROMPT}
    SSHLibrary.Write    ${ilocommand2}
    ${stdout2}=          SSHLibrary.Read until    ${ILO_PROMPT}
    sleep    10
    ${ssl}=    Get Lines Containing String    ${stdout2}    oemhp_sslport
    Log    Print line: ${ssl}    console=True
    Set To Dictionary    ${ILO3}    Port 161    Open
    ${status}=    Run Keyword and Return Status    Should Contain    ${ssl}    443  
    Log     Status:${status}    console=True
    Run Keyword If   '${status}' != 'True'    Log To Console    Port of ssl is not enabled    WARN
    ...    ELSE IF    '${status}' == 'True'    Set To Dictionary    ${ILO3}    Port 443    Open   
    Log Dictionary    ${ILO3} 
    [Return]    ${ILO3} 
        
OA Port Validation
    [Documentation]    Enable SNMP, HTTPS and SECURESH ports for OA
    #[Arguments]    ${OA_ip}    ${dev_cred['OA_user']}    ${dev_cred['OA_pass']} 
    #${OA}=    Create Dictionary 
    ${ssh_login}=    Run Keyword and Return Status    Open DevSSH Connection And Log In    ${OA_ip}    ${dev_cred['OA_user']}    ${dev_cred['OA_pass']} 
    Run Keyword If    '${ssh_login}' != 'True'    
    ...    Run Keyword and Return Status    Open DevTelnet Connection And Log In    ${OA_ip}    ${dev_cred['OA_user']}    ${dev_cred['OA_pass']}  
    @{OA_commands}    Create List    ENABLE SNMP    ENABLE HTTPS    ENABLE SECURESH
    :FOR    ${Command}    IN    @{OA_commands}
    \    ${stdout}    ${stderr}    ${rc}=    SSHLibrary.Execute Command    ${Command}    return_stderr=True    return_rc=True
    \    Log    [Command]#:${Command}    console=True
    \    Log    ${stdout}
    \    ${lines}=     Split To Lines    ${stdout}    7    8   
    \    Log    enableStatus:${lines[0]}    console=True
    \    ${status}=    Run Keyword and Return Status    Should Contain    ${lines[0]}    enabled  
    \    Log     Status:${status}    console=True
    \    Run Keyword If   '${status}' != 'True'    Log    Output of '${Command}' is not enabled    WARN
    \    Should Be Empty    ${stderr}                 msg=Error returned: ${rc} ${stderr}
    \    Should Be Equal As Integers    ${rc}    0    msg=non-zero return code ${rc}

IPDU Port Validation
    [Documentation]    Check SNMP and REST protocol
    #[Arguments]    ${ipdu_ip}  
    ${IPDU}=    Create Dictionary
    #Open DevSSH Connection And Log In    ${HOST_IP}    ${HOST_USERNAME}    ${HOST_PASSWORD} 
    ${snmp}=    SSHLibrary.Execute Command     nc -vzu ${ipdu_ip} 161
    ${status1}=    Run Keyword and Return Status    Should Contain    ${snmp}    161 port [udp/snmp] succeeded  
    #Log     Status:${status1}    console=True
    Run Keyword If   '${status1}' != 'True'    Log To Console    SNMP port is not enabled for IPDU    WARN
    ...    ELSE IF    '${status1}' == 'True'    Set To Dictionary    ${IPDU}    Port 161    Open
    Log    ${snmp}    console=true
    ${rc}=    SSHLibrary.Execute Command    timeout 120s openssl s_client -tls1 -crlf -ign_eof -connect ${ipdu_ip}:50443
    Log    ${rc}
    ${value}=    Evaluate    "CONNECTED"
    ${status}=  Run Keyword and Return Status    Should Contain    ${rc}    ${value}
    #Run Keyword If   '${status}' != 'True'    Log To Console    REST port is not enabled for IPDU   WARN
    Run Keyword If   '${status}' != 'True'    Set To Dictionary    ${IPDU}    Port 443    Cannot Connect
    ...    ELSE IF    '${status}' == 'True'    Set To Dictionary    ${IPDU}    Port 443    Open
    Log    ${IPDU}    console=true
    [Return]     ${IPDU}    

3PAR Port Validation
    [Documentation]    Check SNMP protocol and HTTPS port
    ${3PAR}=    Create Dictionary
    #Open DevSSH Connection And Log In    ${HOST_IP}    ${HOST_USERNAME}    ${HOST_PASSWORD} 
    ${snmp}=    SSHLibrary.Execute Command     nc -vzu ${stor_ip} 161
    Log    ${snmp}    console=true
    ${https}=    SSHLibrary.Execute Command     nc -vzu ${stor_ip} 8080
    Log    ${https}    console=true
    ${status1}=    Run Keyword and Return Status    Should Contain    ${snmp}    161 port [udp/snmp] succeeded  
    Run Keyword If   '${status1}' != 'True'    Log To Console    SNMP port is not enabled for 3PAR    WARN
    ...    ELSE IF    '${status1}' == 'True'    Set To Dictionary    ${3PAR}    Port 161    Open
    ${status}=    Run Keyword and Return Status    Should Contain    ${https}    8080 port [udp/webcache] succeeded  
    Run Keyword If   '${status}' != 'True'    Log To Console    HTTPS port is not enabled for 3PAR    WARN
    ...    ELSE IF    '${status}' == 'True'    Set To Dictionary    ${3PAR}    Port 8080    Open  
    Log Dictionary    ${3PAR} 
    [Return]    ${3PAR} 
    
Check Port State
    [Arguments]    ${result}
    ${Output}=    Parse Key Value Output    ${result}
    Log    Output : ${Output}    console=True
    #Dictionary Should Contain Key    ${Output}    Port
    ${snmp}=    Get From Dictionary  ${Output}  Port 161  #default=Port 161 is not supported for this device
    Log    Command output:snmp port value    console=true
    Log    ${snmp}    console=true
    Run Keyword If  '${snmp}' == '${FAIL_status}'    Run Keyword And Continue On Failure    Fail    PORT 161 CHECK FAILED
    ...    ELSE IF   '${snmp}' == '${PASS_status}'    Log To Console    PORT 161 CHECK PASSED 
    ${http}=    Get From Dictionary  ${Output}  Port 443   #default=Port 443 is not supported for this device 
    Log    Command output:http port value     console=true
    Log    ${http}    console=true
    Run Keyword If  '${http}' == '${FAIL_status}'    Run Keyword And Continue On Failure    Fail    PORT 443 CHECK FAILED    
    ...    ELSE IF     '${http}' == '${PASS_status}'   Log To Console    PORT 443 CHECK PASSED   
    ${ssh}=    Get From Dictionary  ${Output}  Port 22   #default=Port 22 is not supported for this device  
    Log    Command output:ssh port value    console=true
    Log    ${ssh}    console=true
    Run Keyword If  '${ssh}' == '${FAIL_status}'    Run Keyword And Continue On Failure    Fail    PORT 22  CHECK FAILED    
    ...    ELSE IF     '${ssh}' == '${PASS_status}'   Log To Console  PORT 22 CHECK PASSED    
    #${Internet}=    Pop From Dictionary  ${Output}  Port 8080  default=Port 8080 is not supported for this device 
    #Log    Command output:web port value    console=true
    #Log    ${Internet}    console=true
    #Run Keyword If  '${Internet}' == '${FAIL_status}'    Run Keyword And Continue On Failure    Fail    PORT 8080 CHECK FAILED    
    #...    ELSE IF    '${Internet}' == '${PASS_status}'     Log To Console  PORT 8080 CHECK PASSED  
    
Parse Key Value Output
	[Arguments]    ${result}    
    ${Output}=    Create Dictionary
    ${result1}=    Get Lines Containing String    ${result}    :
    ${result2}=    Get Lines Containing String    ${result1}    Port
    @{lines}=     Split To Lines    ${result2}
    :FOR    ${line}    IN    @{lines}
    \    ${key}    ${value}=    Split String    ${line}    :     1
    \    Set To Dictionary     ${Output}    ${key.strip()}    ${value.strip()}
    Log Dictionary    ${Output}    
    [Return]    ${Output}  

Port Communication Check for OA 
    [Documentation]     Port Communication check for OA
    #[Arguments]         ${OA_ip}     ${dev_cred['OA_user']}    ${dev_cred['OA_pass']}
    OA Port Validation    
   	Open DevSSH Connection And Log In    ${SSH_HOST}    ${HOST_USERNAME}    ${HOST_PASSWORD}
    ${OA}=  SSHLibrary.Execute Command    cd /ci/support/ovsupportability/scripts/ && ./check_port_communication.py -ip ${OA_ip} -devtype OA
    Log    Command output:Port communication for OA    console=True
    Log    ${OA}    console=true
    ${Status}=    Run Keyword and Return Status    Check Port State    ${OA}
    Log    status:${Status}    console=True
    Run Keyword If    '${Status}' != 'True'    Fail    ********Port Communication check for OA FAILED********
    ...    ELSE IF    '${Status}' == 'True'    Log To Console    ********Port Communication check for OA PASSED********
   
Port Communication Check for ILO4
    [Documentation]     Port Communication check for ILO4
    #[Arguments]         ${ilo4_ip}     ${dev_cred['ilo4_user']}    ${dev_cred['ilo4_user']}
    ${ILO}=    ILO4 Port Validation
    Log    Validate:${ILO}    console=True
    Open DevSSH Connection And Log In    ${SSH_HOST}    ${HOST_USERNAME}    ${HOST_PASSWORD}
    ${ILO4}=  SSHLibrary.Execute Command    cd /ci/support/ovsupportability/scripts/ && ./check_port_communication.py -ip ${ilo4_ip} -devtype iLo
    log    Command output:Port communication for ILO4    console=true
    log    ${ILO4}    console=true
    ${ILO4}=    Parse Key Value Output    ${ILO4}  
    Log    Parse:${ILO4}    console=True
    ${Status}=    Run Keyword and Return Status    Dictionaries Should Be Equal    ${ILO4}    ${ILO}
    Log    status:${Status}    console=True
    Run Keyword If    '${Status}' != 'True'    Fail    ********Port Communication check for ILO4 FAILED********
    ...    ELSE IF    '${Status}' == 'True'    Log To Console    ********Port Communication check for ILO4 PASSED********
            
Port Communication Check for ILO3
    [Documentation]     Port Communication check for ILO3
    #[Arguments]         ${ilo3_ip}     ${dev_cred['ilo4_user']}    ${dev_cred['ilo4_user']}
    ${ILO}=    ILO3 Port Validation
    Log    Validate:${ILO}    console=True
    Open DevSSH Connection And Log In    ${SSH_HOST}    ${HOST_USERNAME}    ${HOST_PASSWORD}
    ${ILO3}=  SSHLibrary.Execute Command    cd /ci/support/ovsupportability/scripts/ && ./check_port_communication.py -ip ${ilo3_ip} -devtype iLo
    log    Command output:Port communication for ILO3    console=true
    log    ${ILO3}    console=true
    ${ILO3}=    Parse Key Value Output    ${ILO3}  
    Log    Parse:${ILO3}    console=True
    ${Status}=    Run Keyword and Return Status    Dictionaries Should Be Equal    ${ILO3}    ${ILO}
    Log    status:${Status}    console=True
    Run Keyword If    '${Status}' != 'True'    Fail    ********Port Communication check for ILO3 FAILED********
    ...    ELSE IF    '${Status}' == 'True'    Log To Console    ********Port Communication check for ILO3 PASSED********

Port Communication Check for 3PAR
    [Documentation]      Port communication check for 3PAR
    ${3PAR}=    3PAR Port Validation  
    Log    DEV Ports Dictionary:${3PAR}    console=True
    Open DevSSH Connection And Log In    ${SSH_HOST}    ${HOST_USERNAME}    ${HOST_PASSWORD}
    ${Storage}=  SSHLibrary.Execute Command    cd /ci/support/ovsupportability/scripts/ && ./check_port_communication.py -ip ${stor_ip} -devtype 3par
    log    Command output:Port communication for 3PAR    console=true
    log    ${Storage}    console=true
    ${Storage}=    Parse Key Value Output    ${Storage}  
    Log    Suppot tools Dictionary:${Storage}    console=True
    ${Status}=    Run Keyword and Return Status    Dictionaries Should Be Equal    ${Storage}    ${3PAR}
    Log    status:${Status}    console=True
    Run Keyword If    '${Status}' != 'True'    Fail    ********Port Communication check for 3PAR FAILED********
    ...    ELSE IF    '${Status}' == 'True'    Log To Console    ********Port Communication check for 3PAR PASSED********

Port Communication Check for IPDU
    [Documentation]    Port communication check for IPDU
    ${IPDU}    IPDU Port Validation
    Log    DEV Ports Dictionary:${IPDU}    console=True
    Open DevSSH Connection And Log In    ${SSH_HOST}    ${HOST_USERNAME}    ${HOST_PASSWORD}
    ${AIPDU}=  SSHLibrary.Execute Command    cd /ci/support/ovsupportability/scripts/ && ./check_port_communication.py -ip ${ipdu_ip} -devtype iPDU
    log    Command output:Port communication for IPDU    console=true
    log    ${AIPDU}    console=true
    ${AIPDU}=    Parse Key Value Output    ${AIPDU}  
    Log    Suppot tools Dictionary:${AIPDU}    console=True
    ${Status}=    Run Keyword and Return Status    Dictionaries Should Be Equal    ${AIPDU}    ${IPDU}
    Log    status:${Status}    console=True
    Run Keyword If    '${Status}' != 'True'    Fail    ********Port Communication check for IPDU FAILED********
    ...    ELSE IF    '${Status}' == 'True'    Log To Console    ********Port Communication check for IPDU PASSED******** 

 Port Communication Help Command
 	Open DevSSH Connection And Log In    ${SSH_HOST}    ${HOST_USERNAME}    ${HOST_PASSWORD}
   	${Output}=  SSHLibrary.Execute Command    cd /ci/support/ovsupportability/scripts/ && ./check_port_communication.py -h
    Should Contain   ${Output}    ${port_help}   