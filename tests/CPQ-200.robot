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
    ${record_prefix}=    Set Record Prefix    CPQ-200

*** Test Cases ***
CPQ-200
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
    
    ${products}=  Create List
    ...    Standard (V8) (committed)
    ...    Standard Plus (V8) (committed) 
    ...    Premium (V8) (committed) 
    ...    Recommend (committed) 
    ...    Analytics Extended Retention 
    ...    Crawler 
    ...    DSN 
    ...    HIPAA/BAA 
    ...    Single Tenancy + Vault 
    ...    Enterprise Foundation 
    ...    Platform Foundation 
    ...    Premier Support 
    ...    Core Foundation 
    ...    Essential Foundation 
    ...    Standard Support 
    ...    Extended Support 
    ...    Named Contact 
    ...    Premier SLA 
    ...    Algolia Pulse - Prepaid Services 
    ...    Algolia Merchandising Accelerator - Prepaid Services 
    ...    Algolia Guided Onboarding - Prepaid Services 
    ...    Algolia Kickstart - Prepaid Services 
    ...    Algolia Blueprint - Prepaid Services 
    ...    Algolia Quick Start for Sending Events - Prepaid Services 
    ...    Algolia Advisory 25 - Prepaid Services 
    ...    Algolia Quick Start for Crawler - Prepaid Services 
    ...    Algolia Quick Start for Shopify - Prepaid Service 
    ...    Overage Recommend 

    Verify All    ${products}
    