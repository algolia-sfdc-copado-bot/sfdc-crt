*** Settings ***
Library            QForce
Library            ../resources/python/ImpersonationUtils.py

Resource           ../resources/common/variables.resource
Resource           ../resources/records/opportunity.resource
Resource           ../resources/records/quote.resource
Resource           ../resources/records/qle.resource
Resource           ../resources/records/opportunity_line_item.resource

Suite Setup        Suite Setup Actions
Suite Teardown     CloseAllBrowsers

*** Variables ***
${acc_url}        ${login_url}/lightning/r/Account/0012300000iWG8XAAW/view

*** Keywords ***
Suite Setup Actions
    SetConfig    DefaultTimeout    30s
    OpenBrowser    about:blank    ${browser}
    Login
    ${record_prefix}=    Set Record Prefix    CPQ-35

*** Test Cases ***
CPQ-35
    Impersonate With Uid    ${primary_user}
    Close All Sales Console Tabs

    ${opp_url}=    Create Opportunity      ${acc_url}    ${common_contact_name}    ${record_prefix}-Opp
    ${quote_url}=  Create Quote    ${opp_url}    ${common_contact_name}

    Open QLE    ${quote_url}

    ClickText  Add Products
    Verify Text  Product Selection
    ClickItem  checkbox  anchor=Algolia Plan Bundle
    ClickText    Select    partial_match=False
    Verify Text  Configure Products
    
    Verify Configuration Checkbox Disabled State    Premier Support    true

    ClickItem  checkbox  anchor=Standard Support

    Verify Configuration Checkbox Disabled State    Enterprise Foundation    true
    Verify Configuration Checkbox Disabled State    Core Foundation    true
    
    ClickItem  checkbox  anchor=Standard Support
    Verify Configuration Checkbox Disabled State    Enterprise Foundation    false
    Verify Configuration Checkbox Disabled State    Core Foundation    false


    ClickItem  checkbox  anchor=Extended Support
    Verify Configuration Checkbox Disabled State    Premier Support    false
    ClickItem  checkbox  anchor=Extended Support
    Verify Configuration Checkbox Disabled State    Premier Support    true
