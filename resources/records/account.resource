*** Settings    
Library    QForce

Resource           ../common/variables.resource

*** Keywords ***
Create Account
    [Arguments]    ${name}
    ...            ${type}=Prospect               # Customer
    ...            ${currency}=USD - U.S. Dollar  # EUR - Euro

    Go To   ${login_url}/lightning/o/Account/list
    Verify Text    Discover Companies
    Click Text   New    anchor=Discover Companies    partial_match=False
    Verify No Text    Discover Companies

    ${on_new_account_page}=  Is Element    xpath=//a[@role="tab" and @title="New Account" and @aria-selected="true"]    timeout=10
    IF  ${on_new_account_page} == ${FALSE}
        Sleep    1
        Click Text    New Account
        Sleep    1
        Refresh Page
    END

    Verify Text  Partner  anchor=Customer    partial_match=False
    Click Text    Customer    anchor=Cancel    partial_match=False
    Click Text    Next    anchor=Cancel
    Verify Text  New Account: Customer

    Type Text    Account Name    ${name}
    Pick List    Account Currency    ${currency}
    Pick List    Type    ${type}    partial_match=False

    Pick List    Billing Country    United States
    Type Text    Billing Street    10th Avenue
    Type Text    Billing City    New York
    Pick List    Billing State/Province    New York
    Type Text    Billing Zip/Postal Code    10001

    Click Checkbox    Copy from Billing Address    on

    Click Text    Save    partial_match=False
    # Occasionally account creation hangs and fails after few minutes with msg:
    #     "Review the errors on this page."
    Verify Text    New Opportunity    timeout=300

    ${url}=    Get Url
    [Return]    ${url}
    # CRT-CPQ-15-EUR-Prospect




