*** Settings ***
Library            QForce
Library            DebugLibrary
Library            ../resources/python/ImpersonationUtils.py
Library            ../resources/python/DateUtils.py

Resource           ../resources/common/variables.resource
Resource           ../resources/records/account.resource
Resource           ../resources/common/salesforce.resource
Resource           ../resources/common/common.resource

Suite Setup        Suite Setup Actions
Suite Teardown     CloseAllBrowsers

*** Keywords ***
Suite Setup Actions
    SetConfig    DefaultTimeout    30s
    OpenBrowser    about:blank    ${browser}
    Login
    ${record_prefix}=    Set Record Prefix    CPQ-273
    ${zero_strip_char}=  Set Date Zero Strip Char

*** Test Cases ***
CPQ-273
    Impersonate With Uid    ${primary_user}
    Close All Sales Console Tabs

    ${acc_url}=    Create Account    ${record_prefix}-Acc

    Verify Field    Payment Terms     ${EMPTY}
    Verify Field    MSA in place      ${EMPTY}
    Verify Field    MSA Date          ${EMPTY}

    Verify No Text    Edit Payment Terms
    Verify No Text    Edit MSA in place
    Verify No Text    Edit MSA Date
    
    
    Impersonate With Uid    ${deal_desk_user}
    Close All Sales Console Tabs

    Go To    ${acc_url}
    Verify Text    Edit MSA Date
    Click Text    Edit MSA Date
    Verify No Text    Edit MSA Date
    
    ${date}=    Get Current Date    result_format=%${zero_strip_char}m/%${zero_strip_char}d/%Y
    Type Text    MSA Date    ${date}
    Pick List    Payment Terms    Net 30
    Pick List    MSA in place    Yes

    Click Text    Save    anchor=Cancel    partial_match=False
    Verify Text    Edit MSA Date

    Verify Field    MSA Date    ${date}
    Verify Field    Payment Terms    Net 30
    Verify Field    MSA in place    Yes