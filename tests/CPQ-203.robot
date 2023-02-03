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
    ${record_prefix}=    Set Record Prefix    CPQ-203

*** Test Cases ***
CPQ-203
    Impersonate With Uid    ${primary_user}
    Close All Sales Console Tabs

    ${opp_url}=    Create Opportunity      ${acc_url}    ${common_contact_name}    ${record_prefix}-Opp
    ${quote_url}=  Create Quote    ${opp_url}    ${common_contact_name}

    Open QLE    ${quote_url}

    ClickText  Add Products

    ${services_names}=    Create List
    ...    Algolia Pulse - Prepaid Services
    ...    Algolia Blueprint - Prepaid Services
    ...    Algolia Kickstart - Prepaid Services
    Add Bundle To Quote Lines   Algolia Plan Bundle    Standard (V8) (committed)    services_names=${services_names}

    Type Table    Quantity  2  10000

    # Checking the pencil/lock visually is really difficult
    # Instead check if the lines Additional Disc cell has "editable" class
    Verify QLE Additional Disc Editable    Algolia Plan Bundle    False
    Verify QLE Additional Disc Editable    Standard (V8) (committed)    True
    Verify QLE Additional Disc Editable    Algolia Pulse - Prepaid Services    False
    Verify QLE Additional Disc Editable    Algolia Blueprint - Prepaid Services    False
    Verify QLE Additional Disc Editable    Algolia Kickstart - Prepaid Services    False
    
    Type Text    Additional Disc. (%)    50
    Click Text    Calculate

    Verify Table Cell    Customer Total    2    USD 3,275.00
    Verify Table Cell    Customer Total    3    USD 5,000.00
    Verify Table Cell    Customer Total    4    USD 9,500.00
    Verify Table Cell    Customer Total    5    USD 9,500.00
    
    Type Text    Additional Disc. (%)    0
    Type Text    Partner Discount    20
    Click Text    Calculate

    Verify Table Cell    Customer Total    2    USD 6,550.00
    Verify Table Cell    Customer Total    3    USD 5,000.00
    Verify Table Cell    Customer Total    4    USD 9,500.00
    Verify Table Cell    Customer Total    5    USD 9,500.00

    Verify Table Cell    Net Total    2    USD 5,240.00
    Verify Table Cell    Net Total    3    USD 5,000.00
    Verify Table Cell    Net Total    4    USD 9,500.00
    Verify Table Cell    Net Total    5    USD 9,500.00

    Type Text    Partner Discount    0
    Click Text   Calculate

    Verify Table Cell    Customer Total    2    USD 6,550.00
    Verify Table Cell    Customer Total    3    USD 5,000.00
    Verify Table Cell    Customer Total    4    USD 9,500.00
    Verify Table Cell    Customer Total    5    USD 9,500.00

    Verify Table Cell    Net Total    2    USD 6,550.00
    Verify Table Cell    Net Total    3    USD 5,000.00
    Verify Table Cell    Net Total    4    USD 9,500.00
    Verify Table Cell    Net Total    5    USD 9,500.00

    Type Text    Target Customer Amount    28000    timeout=60
    Click Text    Calculate

    Verify Table Cell    Additional Disc.    2    2,550.00000 USD
    Verify Text    8.35%    anchor=Additional Discount Amount (%)
    VerifyText  USD 28,000.00  anchor=Quote Total  partial_match=False

    Type Text    Target Customer Amount    ${SPACE}
    Type Table    Additional Disc.    2    ${SPACE}
    Sleep    5
    Click Text    Calculate
    Sleep    5
    Click Text    Quick Save

    Verify Table Cell    Additional Disc.    2    ${EMPTY}    timeout=60
    Type Table    Additional Disc.    2    -100
    Sleep    2
    Click Text    Calculate
    Click Text    Save    partial_match=False
    Verify Text    You are not able to sell over List price, please adjust your discounts.    timeout=60
    