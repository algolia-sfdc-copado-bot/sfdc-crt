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
    ${record_prefix}=    Set Record Prefix    CPQ-20

*** Test Cases ***
CPQ-20
    Impersonate With Uid    ${primary_user}
    Close All Sales Console Tabs

    ${opp_url}=    Create Opportunity      ${acc_url}    ${common_contact_name}    ${record_prefix}-Opp
    Validate Quote Defaults    ${opp_url}

    ${quote_url}=  Create Quote    ${opp_url}    ${common_contact_name}

    Open QLE    ${quote_url}

    ClickText  Add Products

    ${add_on_names}=    Create List    Core Foundation
    Add Bundle To Quote Lines   Algolia Plan Bundle    Standard (V8) (committed)    ${add_on_names}

    VerifyText  USD 12,000.00  anchor=Quote Total  partial_match=False
    Type Table    Quantity  2  10000
    ClickText  Calculate
    VerifyText  USD 18,550.00  anchor=Quote Total  partial_match=False

    ClickText  Save  partial_match=False
    SetConfig  ShadowDOM  Off
    VerifyText  Edit Lines  timeout=60

    
    ${bundle_fields}=    Evaluate    {'Quantity':'1.00', 'List Price':'USD 0.00', 'Total Price':'USD 0.00'}
    Verify Opportunity Line Item    ${opp_url}    Algolia Plan Bundle    ${bundle_fields}

    ${cf_fields}=    Evaluate    {'Quantity':'1.00', 'List Price':'USD 12,000.00', 'Total Price':'USD 12,000.00'}
    Verify Opportunity Line Item    ${opp_url}    Core Foundation    ${cf_fields}

    ${std_fields}=    Evaluate    {'Quantity':'1.00', 'List Price':'USD 1.00', 'Total Price':'USD 6,550.00'}
    Verify Opportunity Line Item    ${opp_url}    Standard (V8) (committed)    ${std_fields}


    ${new_quote_url}=  Create Quote    ${opp_url}    ${common_contact_name}    is_primary=${FALSE}
    Set Quote As Primary  ${new_quote_url}
    Verify Opportunity Line Item Count    ${opp_url}    0

    Set Quote As Primary  ${quote_url}
    Verify Opportunity Line Item Count    ${opp_url}    3

    Verify Opportunity Line Item    ${opp_url}    Algolia Plan Bundle    ${bundle_fields}
    Verify Opportunity Line Item    ${opp_url}    Core Foundation    ${cf_fields}
    Verify Opportunity Line Item    ${opp_url}    Standard (V8) (committed)    ${std_fields}


    GoTo  ${opp_url}
    VerifyText  Opportunity Information
    Verify Field    TCV    USD 18,550.00
