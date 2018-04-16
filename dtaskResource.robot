 *** Settings ***
Documentation       Dtask Script Of Support Tools
Library				RoboGalaxyLibrary
Library				Collections
Library				String
Library				FusionLibrary
Variables           Supportool_data.py

 *** Variables ***

${SSH_HOST}     
${param}    ?filter="taskType=User"&deleteNonTerminalTasks=true

 *** Keyword *** 

Get Trusted Token
    [Documentation]    Get Trusted Token for creating task
    #Open DevSSH Connection And Log In    15.212.144.146    root    hpvse1
    ${Pri_Key} =          SSHLibrary.Execute Command         /ci/bin/./get-trustedtoken.sh 'DigitalSig'
    Log    ${Pri_Key}    
    [Return]    ${Pri_Key}

Parse Dictionary Key Value Pair
    [Documentation]     Parse Dictionary Key Value Pair
    [Arguments]    ${dtask}    
    ${Output}=    Create Dictionary
    ${dlines} =     Split To Lines    ${dtask}    4
    :FOR    ${line}    IN    @{dlines}
    \    ${key}    ${value}=    Split String From Right    ${line}    |     1
    \    Set To Dictionary     ${Output}    ${key.strip()}    ${value.strip()}
    Log Dictionary    ${Output}  
    [Return]    ${Output}  
    
Create Task
	[Documentation]		Create task
	[Arguments]		${api}=800    
	${trusted_token} =    Get Trusted Token	
	Set Suite Variable    ${trusted_token}
	Login to OV Via REST API        	
	${Response}=	Fusion Api Create Task   	${task}     ${api}    auth=${trusted_token}
	${status}=		Get From Dictionary		${Response}		status_code
	Log     ${status}   
    Log    ${Response}    
    Should Contain    ['200','201','202','203']   	'${status}'		msg=Failed to Trigger Create Task. Verify it manually.
	${uri}=		Get From Dictionary		${Response}		uri
	Set Suite Variable     ${uri}
	${taskid}    Fetch From Right    ${uri}    /
	Log To Console    Task Created with TaskID:${taskid}
	Set Suite Variable     ${taskid}
	[Return]    ${taskid}

Delete Task
    [Documentation]     Delete Task
    [Arguments]    ${api}=800    
    Login to OV Via REST API      
    ${Response} =     Fusion Api Delete Task     ${uri}    ${api}      auth=${trusted_token}    param=${param}
    ${status}=		Get From Dictionary		${Response}		status_code
	Log     ${status}   
    Log    ${Response}    
    ${dstatus} =     Run Keyword and Return Status    Should Contain    ['204']   	'${status}'		msg=Failed to Delete Task. Verify it manually.
    [return]    ${dstatus}
    
Dtask Verification
    [Documentation]    Execute dtask script and verify the output
    ${taskid} =    Create Task
    ${dtasklist} =    Create Dictionary
    ${dtaskdelete} =    Create Dictionary
    ${tid} =          SSHLibrary.Execute Command         psql -A -t --dbname=cidb --user=postgres -c "select id from taskt.taskentity where id = '${taskid}';"
    Log To Console    Entry in DB found With created TaskID:${tid}
    ${dtasklist} =     SSHLibrary.Execute Command    cd /ci/support/ovsupportability/scripts/ && ./dtask.py -l Running
    ${Output} =     Parse Dictionary Key Value Pair    ${dtasklist}
    ${status} =     Run Keyword and Return Status    Dictionary Should Contain Value    ${Output}    ${tid}    msg=Dtask Script Failed to list the Task
    Log To Console    STATUS OF DTASK LIST:${status}      
    Run Keyword If    '${status}' != 'True'    Fail    ********Dtask Verification for Listing the task Failed********
    ...    ELSE IF    '${status}' == 'True'    Log To Console    ********Dtask Verification for Listing the task Passed********  
    ${dstatus}=    Delete Task
    ${delid} =          SSHLibrary.Execute Command         psql -A -t --dbname=cidb --user=postgres -c "select id from taskt.taskentity where id = '${taskid}';"
    Log To Console    Entry in DB Not found With Deleted TaskID:${delid}     
    ${dtaskdelete} =     SSHLibrary.Execute Command    cd /ci/support/ovsupportability/scripts/ && ./dtask.py -l Running
    ${dOutput} =    Parse Dictionary Key Value Pair    ${dtaskdelete}
    ${delstatus} =     Run Keyword and Return Status     Dictionary Should Not Contain Value    ${dOutput}    ${taskid}    msg=Dtask Script Failed to delete the Task
    Log To Console    STATUS of DELETE TASK:${delstatus}
    Run Keyword If    '${delstatus}' != 'True'    Fail    ********Dtask Verification for Deleting the task Failed********
    ...    ELSE IF    '${delstatus}' == 'True'    Log To Console    ********Dtask Verification for Deleting the task Passed********  

Dtask Help Command
    [Documentation]    Verify the help command of Dtask Script of support tools
    #Open DevSSH Connection And Log In    15.212.144.146    root    hpvse1
   	${Output}=  SSHLibrary.Execute Command    cd /ci/support/ovsupportability/scripts/ && ./dtask.py -h
    ${status}=    Run Keyword and Return Status    Should Contain   ${Output}    ${dtask_help}    
    Run Keyword If    '${status}' != 'True'    Fail    ********Dtask Verification for Help Command Failed********
    ...    ELSE IF    '${status}' == 'True'    Log To Console    ********Dtask Verification for Help Command Passed********  