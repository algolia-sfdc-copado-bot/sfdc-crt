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
    ${record_prefix}=    Set Record Prefix    CPQ-98

*** Test Cases ***
CPQ-98
    Impersonate With Uid    ${primary_user}
    Close All Sales Console Tabs

    ${opp_url}=    Create Opportunity      ${acc_url}    ${common_contact_name}    ${record_prefix}-Opp
    ${quote_url}=  Create Quote    ${opp_url}    ${common_contact_name}

    Open QLE    ${quote_url}

    ClickText  Add Products

    Add Bundle To Quote Lines   Algolia Plan Bundle    Standard (V8) (committed)

    Type Table    Quantity  2  100000
    Sleep    2
    ClickText    Save  partial_match=False

    SetConfig  ShadowDOM  Off
    VerifyText  Edit Lines  timeout=60

    ${std_fields}=    Evaluate    {'Discount Schedule':'Standard (V8) - Committed-USD - Cross Order'}
    Verify Quote Line Item    ${quote_url}    Standard (V8) (committed)    ${std_fields}

    Open QLE    ${quote_url}
    Type Table    Quantity  2  10000
    ClickText    Calculate
    ClickText    Save  partial_match=False
    SetConfig  ShadowDOM  Off
    VerifyText  Edit Lines  timeout=60

    ${std_fields}=    Evaluate    {'Discount Schedule':'Standard (V8) - Committed-USD - Cross Order'}
    Verify Quote Line Item    ${quote_url}    Standard (V8) (committed)    ${std_fields}
    