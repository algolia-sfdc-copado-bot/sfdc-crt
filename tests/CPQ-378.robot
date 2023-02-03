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
    ${record_prefix}=    Set Record Prefix    CPQ-378

*** Test Cases ***
CPQ-378
    #[Teardown]    Debug
    Impersonate With Uid    ${primary_user}
    Close All Sales Console Tabs

    ${opp_url}=    Create Opportunity      ${acc_url}    ${common_contact_name}    ${record_prefix}-Opp
    ${quote_url}=  Create Quote    ${opp_url}    ${common_contact_name}

    Open QLE    ${quote_url}

    ClickText  Add Products

    Verify Text  Product Selection

    ${services}=    Create List    Algolia Guided Onboarding
    Add Bundle To Quote Lines   Algolia Plan Bundle    Standard (V8) (committed)    services_names=${services}
    
    Type Table    Quantity    2    10000
    Clicktext    Calculate
    ClickText  Save  partial_match=False
    SetConfig     ShadowDOM    off
    Verify Text    Edit Lines    timeout=60



    Click Text    Edit DocuSign Signer
    Verify No Text    Edit DocuSign Signer
    Combobox    DocuSign Signer    ${common_contact_name}    selection_delay=5


    ${linebreak}=    SetConfig    LineBreak    ${EMPTY}
    Type Text    Bill To Contact    ${common_contact_name}
    Verify Element   xpath=//lightning-grouped-combobox[./label[text()="Bill To Contact"]]//lightning-base-combobox-formatted-text[@title="${common_contact_name}"]
    Sleep  1
    Click Element    xpath=//lightning-grouped-combobox[./label[text()="Bill To Contact"]]//lightning-base-combobox-formatted-text[@title="${common_contact_name}"]
    Type Text    Ship To Contact    ${common_contact_name}
    Verify Element   xpath=//lightning-grouped-combobox[./label[text()="Ship To Contact"]]//lightning-base-combobox-formatted-text[@title="${common_contact_name}"]
    Sleep  1
    Click Element    xpath=//lightning-grouped-combobox[./label[text()="Ship To Contact"]]//lightning-base-combobox-formatted-text[@title="${common_contact_name}"]
    SetConfig    LineBreak    ${linebreak}
    Click Text    Save  anchor=Cancel    partial_match=False
    Verify Text    Edit DocuSign Signer

    Click Text    Preview Approval
    Verify Text    Submit for Approval  timeout=120
    Verify Text    Algolia Guided Onboarding Approval
    Click Text    Submit for Approval

    Verify Text    Quote Details    timeout=120

    ${approval_status}=    Get Field Value    Approval Status
    IF    "Approval Status" != "Pending"
        Sleep    5
        RefreshPage
        Verify Text    Quote Details
    END
    Verify Field    Approval Status    Pending
    

    

    Impersonate With Uid    ${deal_desk_user}
    Close All Sales Console Tabs

    Open Records Related View    ${quote_url}    Approvals__r
    Reload Record List Until Record Count Is    Approval \#    1
    Click Cell    r2/c3  tag=a

    Verify Text    Reassign
    ${approval_url}=    Get Url
    Verify Field    Assigned To    ${EMPTY}
    Verify Field    Approval Chain    Algolia Guided Onboarding Approval    tag=a

    ClickText    Approve    anchor=Reject    partial_match=False
    Use Modal    on
    Verify Text    Error:Not Allowed to approve because you don't have permission
    Click Text    Cancel
    Use Modal  off
    
    Go To    ${quote_url}
    Verify Text    Edit Override Approvals
    Click Text    Edit Override Approvals
    Verify No Text    Edit Override Approvals
    Click Checkbox    Override Approvals    on
    Click Text    Save    anchor=Cancel    partial_match=False
    Verify Text    Edit Override Approvals

    Go To    ${approval_url}
    Verify Text    Reassign
    Verify Field    Assigned To    Don Valle    tag=a

    ClickText    Approve    anchor=Reject    partial_match=False
    Use Modal   on
    Verify Text    Cancel
    Click Text    Approve    anchor=Cancel    partial_match=False

    Verify Text    Quote Details    timeout=120

    ${approval_status}=    Get Field Value    Approval Status
    IF    "Approval Status" != "Approved"
        Sleep    5
        RefreshPage
        Verify Text    Quote Details
    END
    Verify Field    Approval Status    Approved
