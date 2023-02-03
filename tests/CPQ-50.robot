*** Settings ***
Library            QForce
Library            ../resources/python/ImpersonationUtils.py
Library            ../resources/python/DateUtils.py

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
    ${record_prefix}=    Set Record Prefix    CPQ-50

*** Test Cases ***
CPQ-50
    Impersonate With Uid    ${primary_user}
    Close All Sales Console Tabs

    ${opp_url}=    Create Opportunity      ${acc_url}    ${common_contact_name}    ${record_prefix}-Opp
    ${quote_url}=  Create Quote    ${opp_url}    ${common_contact_name}

    Open QLE    ${quote_url}

    ClickText  Add Products

    ${add_on_names}=    Create List    Core Foundation
    Add Bundle To Quote Lines   Algolia Plan Bundle    Standard (V8) (committed)    ${add_on_names}

    Type Table    Quantity  2  10000
    ClickText    Calculate

    Verify Table Cell    List Unit Price    2    USD 1.00000
    Verify Table Cell    Net Total    2    USD 6,550.00
    Verify Table Cell    Net Total    3    USD 12,000.00

    Type Text    Subscription Term    18
    Click Text    Calculate
    Verify Table Cell    List Unit Price    2    USD 1.00000
    Verify Table Cell    Net Total    2    USD 9,825.00
    Verify Table Cell    Net Total    3    USD 18,000.00


    
    
    ${relative_date_data}=    Create List    2  0  -1    # years, months, days. 1 day short of two years
    ${end_date}=    Relative Date    ${relative_date_data}
    Type Text    End Date    ${end_date}    partial_match=False
    Click Text    Calculate
    Verify Table Cell    List Unit Price    2    USD 1.00000
    Verify Table Cell    Net Total    2    USD 13,100.00
    Verify Table Cell    Net Total    3    USD 24,000.00

    TypeText    Subscription Term    12
    Type Text    End Date    ${EMPTY}    partial_match=False
    Click Text    Calculate
    Verify Table Cell    List Unit Price    2    USD 1.00000
    Verify Table Cell    Net Total    2    USD 6,550.00
    Verify Table Cell    Net Total    3    USD 12,000.00

    