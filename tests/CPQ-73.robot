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
    ${record_prefix}=    Set Record Prefix    CPQ-73

    Impersonate With Uid    ${primary_user}
    Close All Sales Console Tabs

    ${opp_url}=    Create Opportunity      ${acc_url}    ${common_contact_name}    ${record_prefix}-Opp
    Set Suite Variable    ${opp_url}

*** Test Cases ***
Standard Quote Doc V2
    #[Teardown]    Debug
    
    ${quote_url}=  Create Quote    ${opp_url}    ${common_contact_name}

    Open QLE    ${quote_url}

    ClickText  Add Products

    Add Bundle To Quote Lines   Algolia Plan Bundle    Standard (V8) (committed)
    ClickText    Calculate
    ClickText  Save  partial_match=False

    SetConfig  ShadowDOM  Off
    VerifyText  Edit Lines  timeout=60

    Click Text    Preview Document
    Verify Text  Quote Preview    timeout=180
    Click Element    xpath=//div[@class="sbDialogCon"]//button

    Verify Text    Document Options
    Verify Input Value    Template    Standard Quote Doc V2
    ${is_disabled}=    Get Attribute
    ...    documentModel.templateName
    ...    ng-disabled
    ...    anchor=Template
    ...    tag=input

    Should Be Equal As Strings    ${is_disabled}    true

Standard PAB Quote Doc V2
    #[Teardown]    Debug
    
    ${quote_url}=  Create Quote    ${opp_url}    ${common_contact_name}

    Open QLE    ${quote_url}

    ClickText  Add Products

    ClickItem    checkbox  anchor=Premium Adoption Bundle
    ClickText    Select    partial_match=False
    ClickText    Save  partial_match=False
    ClickText    Calculate
    ClickText    Save  partial_match=False

    SetConfig    ShadowDOM  Off
    VerifyText   Edit Lines  timeout=60

    Click Text    Preview Document
    Verify Text   Quote Preview    timeout=180
    Click Element    xpath=//div[@class="sbDialogCon"]//button

    Verify Text    Document Options
    Verify Input Value    Template    Standard PAB Quote Doc V2
    ${is_disabled}=    Get Attribute
    ...    documentModel.templateName
    ...    ng-disabled
    ...    anchor=Template
    ...    tag=input
    Should Be Equal As Strings    ${is_disabled}    true