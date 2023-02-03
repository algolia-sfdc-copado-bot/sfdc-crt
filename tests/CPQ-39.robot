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
    ${record_prefix}=    Set Record Prefix    CPQ-39

*** Test Cases ***
CPQ-39
    Impersonate With Uid    ${primary_user}
    Close All Sales Console Tabs

    ${opp_url}=    Create Opportunity      ${acc_url}    ${common_contact_name}    ${record_prefix}-Opp
    ${quote_url}=  Create Quote    ${opp_url}    ${common_contact_name}

    Open QLE    ${quote_url}

    ClickText  Add Products

    ${add_on_names}=    Create List    Core Foundation    Enterprise Foundation
    Add Bundle To Quote Lines   Algolia Plan Bundle    Standard (V8) (committed)    ${add_on_names}

    Type Table    Quantity  2  10000
    ClickText    Calculate
    Verify Table Cell    List Unit Price    3    USD 72,000.00000
    Verify Table Cell    List Unit Price    4    USD 12,000.00000

    Type Table    Quantity  2  1000000
    ClickText    Calculate
    Verify Table Cell    Net Total    2    USD 157,050.00
    Verify Table Cell    Net Total    3    USD 72,000.00
    Verify Table Cell    Net Total    4    USD 15,705.00

    Type Table    Quantity  2  10000000
    ClickText    Calculate
    Verify Table Cell    Net Total    2    USD 417,050.00
    Verify Table Cell    Net Total    3    USD 125,115.00
    Verify Table Cell    Net Total    4    USD 41,705.00
    