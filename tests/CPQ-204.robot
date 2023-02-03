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
    ${record_prefix}=    Set Record Prefix    CPQ-204

*** Test Cases ***
CPQ-204
    Impersonate With Uid    ${primary_user}
    Close All Sales Console Tabs

    ${opp_url}=    Create Opportunity      ${acc_url}    ${common_contact_name}    ${record_prefix}-Opp

    ${infrastructure_locations}=    Create List    US-East    US-West
    ${quote_url}=  Create Quote    ${opp_url}    ${common_contact_name}    infrastructure_locations=${infrastructure_locations}

    Open QLE    ${quote_url}

    ClickText  Add Products
    Verify Text  Product Selection

    ClickItem  checkbox  anchor=Algolia Plan Bundle
    ClickText    Select    partial_match=False

    Verify Text  Configure Products

    
    ClickItem    radioContainer   anchor=Standard (V8) (committed)
    ClickItem  checkbox  anchor=DSN
    Sleep    1
    ClickText  Save

    Use Modal    on
    Verify Text    You have more Infrastructure Locations selected than Quantity of DSN. Please attempt to upsell additional DSN.    timeout=60
    # Couldn't set quantities from configuration page
    # Click Continue -> move to QLE
    # Set quantities in QLE
    # Click Reconfigure Line to get back to configuration page
    # Clicking Save does no longer show alert modal
    Click Text    Continue    partial_match=False
    Use Modal    off

    VerifyText  Add Products
    Type Table    Quantity  2  10000
    Type Table    Quantity  3  2
    ClickText  Calculate

    Click Item    Reconfigure Line
    Sleep    2
    ClickText  Save
    VerifyText  Add Products

    VerifyTableCell    Net Total  2  USD 6,550.00
    VerifyTableCell    List Unit Price  3  USD 1,965.00000
    VerifyTableCell    Net Total  3  USD 3,930.00
    