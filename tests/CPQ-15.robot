*** Settings ***
*** Settings ***
Library            QForce
Library            ../resources/python/ImpersonationUtils.py

Resource           ../resources/common/variables.resource
Resource           ../resources/records/account.resource
Resource           ../resources/records/contact.resource
Resource           ../resources/records/opportunity.resource
Resource           ../resources/records/quote.resource
Resource           ../resources/records/qle.resource
Resource           ../resources/records/opportunity_line_item.resource

Suite Setup        Suite Setup Actions
Suite Teardown     CloseAllBrowsers

*** Keywords ***
Suite Setup Actions
    SetConfig    DefaultTimeout    30s
    OpenBrowser    about:blank    ${browser}
    Login
    ${record_prefix}=    Set Record Prefix    CPQ-15

*** Test Cases ***
Prospect Account Currency
    #[Teardown]    Debug
    Impersonate With Uid    ${primary_user_2}
    Close All Sales Console Tabs

    ${acc_type}=    Set Variable    Prospect
    ${acc_url}=    Create Account    ${record_prefix}-${acc_type}    ${acc_type}    EUR - Euro
    ${contact_url}=    Create Contact    ${acc_url}    ${record_prefix}    ${acc_type}-User    EUR - Euro
    ${opp_url}=    Create Opportunity    ${acc_url}    ${record_prefix} ${acc_type}-User    ${record_prefix}-${acc_type}-Opp    creator_id=${primary_user_2}

    Click Text    Edit Opportunity Name
    Verify No Text    Edit Opportunity Name

    Pick List    Opportunity Currency    USD - U.S. Dollar
    Click Text    Save    anchor=Cancel
    Verify Text    Edit Opportunity Name
    
    Go To    ${acc_url}
    Verify Text    New FE Support Request
    Verify Field    Account Currency    USD - U.S. Dollar


Customer Account Currency
    #[Teardown]    Debug
    Impersonate With Uid    ${primary_user_2}
    Close All Sales Console Tabs

    ${acc_type}=    Set Variable    Customer
    ${acc_url}=    Create Account    ${record_prefix}-${acc_type}    ${acc_type}    EUR - Euro
    ${contact_url}=    Create Contact    ${acc_url}    ${record_prefix}    ${acc_type}-User    EUR - Euro
    
    Go To    ${acc_url}
    Verify Text    New FE Support Request

    Click Text    Edit Account Name
    Verify No Text    Edit Account Name
    Pick List    Account Currency    USD - U.S. Dollar
    Click Text    Save    partial_match=False
    Verify Text    We hit a snag.
    Verify Text    The Account's currency can not be changed. Please reach out to Deal Desk if you require assistance.
    Click Text    Cancel    anchor=Save
    Verify Text    Edit Account Name

    ${opp_url}=    Create Opportunity    ${acc_url}    ${record_prefix} ${acc_type}-User    ${record_prefix}-${acc_type}-Opp    creator_id=${primary_user_2}

# Record owner is able to change opportunity currency
    #Click Text    Edit Opportunity Name
    #Verify No Text    Edit Opportunity Name
    #Pick List    Opportunity Currency    USD - U.S. Dollar    timeout=5
    #Click Text    Save    anchor=Cancel
    #Verify Text    Edit Opportunity Name
    

    Impersonate With Uid    ${deal_desk_user}
    Close All Sales Console Tabs
    Go To    ${acc_url}
    Verify Text    New FE Support Request

    Click Text    Edit Account Name
    Verify No Text    Edit Account Name
    Pick List    Account Currency    USD - U.S. Dollar
    Click Text    Save    partial_match=False
    Verify Text    Edit Account Name