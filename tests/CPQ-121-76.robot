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
${quote_url}      ${EMPTY}

*** Keywords ***
Suite Setup Actions
    SetConfig    DefaultTimeout    30s
    OpenBrowser    about:blank    ${browser}
    Login
    ${record_prefix}=    Set Record Prefix    CPQ-121

*** Test Cases ***
CPQ-121
    #[Teardown]    Debug
    Impersonate With Uid    ${primary_user}
    Close All Sales Console Tabs

    ${opp_url}=    Create Opportunity      ${acc_url}    ${common_contact_name}    ${record_prefix}-Opp
    ${quote_url}=  Create Quote    ${opp_url}    ${common_contact_name}

    Open QLE    ${quote_url}

    ClickText  Add Products

    Add Bundle To Quote Lines   Algolia Plan Bundle    Standard (V8) (committed)

    Type Table    Quantity  2  10000
    ClickText  Calculate
    VerifyText  USD 6,550.00  anchor=Quote Total  partial_match=False

    ClickText  Save  partial_match=False
    SetConfig  ShadowDOM  Off
    VerifyText  Edit Lines  timeout=60

    Click Text    Preview Approval
    Click Text    Submit for Approval  timeout=120
    Verify Text    You are required to populate the Docusign Signer, Bill To and Business Contacts at this time.

    Click Text    Return to Quote

    Verify Text    Edit Lines
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
    Click Text    Submit for Approval  timeout=120
    Verify Text    Quote Details    timeout=120

    ${approval_status}=    Get Field Value    Approval Status
    IF    "Approval Status" != "Approved"
        Sleep    5
        RefreshPage
        Verify Text    Quote Details
    END
    Verify Field    Approval Status    Approved
    Set Suite Variable    ${quote_url}
    
CPQ-76
    IF    "${quote_url}"=="${EMPTY}"
        Fail     Pre-requisite test case CPQ-121 has not been executed successfully before running this test case!"
    END

    Impersonate With Uid    ${primary_user}
    Close All Sales Console Tabs
    Go To    ${quote_url}
    Click Text    Show more actions
    Click Text    Generate Document
    Verify No Text    Output Format


    Impersonate With Uid    ${deal_desk_user}
    Close All Sales Console Tabs
    Go To    ${quote_url}
    Click Text    Show more actions
    Click Text    Generate Document
    Verify Text    Output Format
    ${output_formats}=    Get Drop Down Values    Output Format

    Should Contain    ${output_formats}    PDF
    Should Contain    ${output_formats}    MS Word


    Impersonate With Uid    ${legal_user}
    Close All Sales Console Tabs
    Go To    ${quote_url}
    Click Text    Show more actions
    Click Text    Generate Document
    Verify Text    Output Format
    ${output_formats}=    Get Drop Down Values    Output Format

    Should Contain    ${output_formats}    PDF
    Should Contain    ${output_formats}    MS Word