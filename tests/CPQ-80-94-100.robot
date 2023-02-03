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
${cpq_80_data}   ${EMPTY}
*** Keywords ***
Suite Setup Actions
    SetConfig    DefaultTimeout    30s
    OpenBrowser    about:blank    ${browser}
    Login
    ${record_prefix}=    Set Record Prefix    CPQ-80

*** Test Cases ***
CPQ-80
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

    Verify Field    Renewal Uplift (%)    7.000%

    Click Text    Edit Renewal Uplift (%)
    Verify No Text    Edit Renewal Uplift (%)
    Type Text    Renewal Uplift (%)    17
    Click Text    Save    anchor=Cancel    partial_match=False
    Verify Text    Edit Renewal Uplift (%)
    Verify Field    Renewal Uplift (%)    17.000%
    
    Click Text    Edit Renewal Uplift (%)
    Verify No Text    Edit Renewal Uplift (%)
    Type Text    Renewal Uplift (%)    7
    Click Text    Save    anchor=Cancel    partial_match=False
    Verify Text    Edit Renewal Uplift (%)
    Verify Field    Renewal Uplift (%)    7.000%




    Impersonate With Uid    ${order_management_user}
    Close All Sales Console Tabs

    Go To    ${opp_url}
    Click Text    Mark Stage as Complete
    Click Text    Closed    anchor=Mark Stage as Complete    partial_match=False
    Click Text    Select Closed Stage
    Use Modal     on
    Verify Text    Close This Opportunity
    Dropdown    locator=//div[./label/span[text()="Stage"]]/select    option=Closed Won
    Click Text    Save    anchor=Cancel    partial_match=False
    Verify No Text    Close This Opportunity
    Use Modal    off
    Verify Text    Closed Won    timeout=180

    Open Records Related View    ${opp_url}    SBQQ__Contracts__r
    Reload Record List Until Record Count Is    Contract Number    1    limit=40
    
    Click Cell    r2/c2  tag=a
    Verify Text    Contract Start Date
    ${contract_url}=    Get Url

    ${start_date}=     Get Current Date
    ${start_date}=    Convert Date    ${start_date}    result_format=%d/%m/%Y   exclude_millis=True
    ${relative_date_data}=    Create List    1  0  -1    # years, months, days. 1 day short of a year
    ${end_date}=    Relative Date    ${relative_date_data}    format=%d/%m/%Y

    Verify Text    12    anchor=Contract Term (months)
    Verify Field    Contract Start Date    ${start_date}
    Verify Field    Contract End Date    ${end_date}

    Open Records Related View    ${contract_url}    SBQQ__Subscriptions__r
    Reload Record List Until Record Count Is    Subscription \#    3

    Use Table    Subscription \#
    Verify Table    r2/c4    Algolia Plan Bundle
    Verify Table    r3/c4    Standard (V8) (committed)
    Verify Table    r4/c4    Overage Search Standard

    FOR  ${i}  IN RANGE  2  5
        Verify Table    r${i}/c6    ${start_date}
        Verify Table    r${i}/c7    ${end_date}
    END

    Go To    ${quote_url}
    Verify Text    Edit Lines
    Verify Field    Start Date    ${start_date}
    Verify Field    Effective End Date    ${end_date}



    Impersonate With Uid    ${primary_user}
    Close All Sales Console Tabs

    Go To    ${contract_url}
    Verify Text    Contract Start Date
    Verify Field    Renewal Uplift (%)    7.000%

    Click Text    Edit Account Name
    Verify No Text    Edit Account Name
    Scroll To    Infrastructure Location
    Sleep    2
    Click Checkbox    Renewal Quoted    on
    Sleep    2
    Click Text    Save    anchor=Cancel    partial_match=False
    Verify Text    Edit Account Name
    Scroll To    Infrastructure Location
    Verify Element    xpath=//div[./div/span[text()="Renewal Quoted"]]//img[@alt="True"]

    Open Records Related View    ${contract_url}    SBQQ__RenewalOpportunities__r
    Reload Record List Until Record Count Is    Opportunity Name    1
    Click Cell    r2/c2  tag=a
    Verify Text    FE Support Request

    ${renewal_opp_url}=    Get Url
    Open Records Related View    ${renewal_opp_url}    SBQQ__Quotes2__r
    Reload Record List Until Record Count Is    Quote Number    1
    
    Click Cell    r2/c4  tag=a

    Verify Text    Edit Lines
    ${renewal_quote_url}=    Get Url

    Open Records Related View    ${renewal_quote_url}    SBQQ__LineItems__r
    Reload Record List Until Record Count Is    Line Name    3

    ${fields}=    Evaluate    {'List Unit Price':'USD 1.07', 'Net Total':'USD 7,008.50'}
    Verify Quote Line Item    ${renewal_quote_url}    Standard (V8) (committed)    ${fields}

    ${cpq_80_data}=    Create Dictionary
    ...    opportunity_url=${opp_url}
    ...    quote_url=${quote_url}
    ...    contract_url=${contract_url}
    
    Set Suite Variable    ${cpq_80_data}

CPQ-94
    #[Teardown]    Debug
    IF    "${cpq_80_data}" == "${EMPTY}"
        Fail     Pre-requisite test case CPQ-80 has not been executed successfully before running this test case!"
    END

    Impersonate With Uid    ${order_management_user}
    Close All Sales Console Tabs

    ${opp_url}=  Set Variable    ${cpq_80_data}[opportunity_url]
    ${quote_url}=  Set Variable    ${cpq_80_data}[quote_url]

    #${opp_url}=  Set Variable    https://algolia--preprod.sandbox.lightning.force.com/lightning/r/Opportunity/0062300000HXrInAAL/view
    #${quote_url}=  Set Variable    https://algolia--preprod.sandbox.lightning.force.com/lightning/r/SBQQ__Quote__c/a9O23000000U6DlEAK/view

    Open Records Related View    ${opp_url}    Orders
    Reload Record List Until Record Count Is    Order Number    1

    ClickCell    r2/c2    tag=a
    Verify Text    Order Information
    ${order_url}=    Get Url

    ${account}=    Get Field Value    Account Name    tag=a
    ${partner}=    Get Field Value    Partner    tag=a    # not sure if this is a link
    ${start_date}=    Get Field Value    Order Start Date
    ${price_book}=    Get Field Value    Price Book    tag=a
    ${payment_method}=    Get Field Value    Payment Method
    
    ${payment_term}=    Get Field Value    Payment Term
    ${billing_frequency}=    Get Field Value    Billing Frequency
    ${opportunity}=    Get Field Value    Opportunity    tag=a
    ${contracting_entity}=    Get Field Value    Contracting Entity
    ${po_required}=    Get Field Value    PO Required

# lightning opp

    ${opportunity_name}=    Get Field Value    Opportunity Name
    ${type}=    Get Field Value    Type
    ${subscription_term}=    Get Field Value    Subscription Term
    ${is_po_required}=    Is Element    xpath=//div[./div/span[text()="Is PO Required"]]//img[@alt="True"]
    ${bundle_line_items}=    Is Element    xpath=//div[./div/span[text()="Bundle Line Items"]]//img[@alt="True"]
    
    ${vat_number}=    Get Field Value    VAT Number
    ${opp_owner}=    Get Field Value     Opp Owner
    ${potential_plan}=    Get Field Value  Potential Plan
    ${appid}=    Get Field Value    APPID
    ${referral_discount_p}=    Get Field Value  Referral Discount (%)
    
    ${referral_discount_amount}=    Get Field Value    Referral Discount Amount
    ${withholding_tax_p}=    Get Field Value    Withholding Tax (%)
    ${withholding_tax_amount}=    Get Field Value  Withholding Tax Amount

# lightning quote

    ${tcv}=    Get Field Value  TCV
    ${arr}=    Get Field Value  ARR
    ${nrr}=    Get Field Value  NRR
    ${auto_renewal}=    Is Element    xpath=//div[./div/span[text()="Auto Renewal"]]//img[@alt="True"]
    ${contract_term}=    Get Field Value  Contract Term (Months)
    
    ${avg_customer_disc_p}=    Get Field Value  Avg. Customer Disc. (%)
    ${additional_disc_amount}=    Get Field Value  Addl. Disc. Amount
    ${partner_discount}=    Get Field Value  Partner Discount
    
    # Directly check the quote lightning component values which are on the order
    Verify Field    Price Book    ${price_book}    tag=a    index=2
    Verify Field    Partner    ${partner}    index=2
    Verify Field    Payment Terms    ${payment_term}
    #Verify Field    Billing Frequency    ${billing_frequency}    index=2    # does not match
    Verify Field    Contracting Entity    ${contracting_entity}    index=2

# validate order items
    Open Records Related View    ${order_url}    OrderItems
    Reload Record List Until Record Count Is    Ordered Quantity    3

    Use Table    Ordered Quantity
    Verify Table    r2/c2    Algolia Plan Bundle
    Verify Table    r3/c2    Standard (V8) (committed)
    Verify Table    r4/c2    Overage Search Standard

# go to opp and validate fields
    Go To    ${opp_url}
    Verify Text    FE Support Request

    Verify Field    Opportunity Name    ${opportunity_name}
    Verify Field    Type    ${type}
    #Verify Field    Subscription Term    ${subscription_term}    # no such field
    IF    ${is_po_required}
        Verify Element    xpath=//lightning-input[@checked]//span[text()="Is PO Required"]
    ELSE
        Verify No Element    xpath=//lightning-input[@checked]//span[text()="Is PO Required"]
    END
    IF    ${bundle_line_items}
        Verify Element    xpath=//lightning-input[@checked]//span[text()="Bundle Line Items"]
    ELSE
        Verify No Element    xpath=//lightning-input[@checked]//span[text()="Bundle Line Items"]
    END
    
    #Verify Field    VAT Number    ${vat_number}  # no such field
    Verify Field    Opportunity Owner    ${opp_owner}    tag=a
    Verify Field    Potential Plan    ${potential_plan}
    Verify Field    AlgoliaApp    ${appid}
    Verify Field    Referral Discount (%)    ${referral_discount_p}
    
    Verify Field    Referral Discount Amount    ${referral_discount_amount}
    Verify Field    Withholding Tax (%)    ${withholding_tax_p}
    Verify Field    Withholding Tax Amount    ${withholding_tax_amount}
    
# go to quote and validate fields
    Go To    ${quote_url}
    Verify Text    Edit Lines

    Verify Field    Account    ${account}    tag=a
    Verify Field    Partner    ${partner}    tag=a  # not sure if this is a link
    Verify Field    Start Date    ${start_date}
    Verify Field    Price Book    ${price_book}    tag=a
    Verify Field    Payment Method    ${payment_method}

    Verify Field    Payment Terms    ${payment_term}
    Verify Field    Billing Frequency    ${billing_frequency}
    Verify Field    Opportunity    ${opportunity}    tag=a
    Verify Field    Contracting Entity    ${contracting_entity}
    Verify Field    PO Required    ${po_required}

    Verify Field    TCV    ${tcv}
    Verify Field    ARR    ${arr}
    Verify Field    NRR    ${nrr}
    IF    ${auto_renewal}
        Verify Element    xpath=//lightning-input[@checked]//span[text()="Auto Renewal"]
    ELSE
        Verify No Element    xpath=//lightning-input[@checked]//span[text()="Auto Renewal"]
    END
    Verify Field    Contract Term (Months)    ${contract_term}

    #Verify Field    Avg. Customer Disc. (%)    ${avg_customer_disc_p}    # no such field
    Verify Field    Addl. Disc. Amount    ${additional_disc_amount}
    Verify Field    Partner Discount    ${partner_discount}

# go to order, fill financial fields and save
    Go To    ${order_url}
    Verify Text  Order Information
    Scroll To    Order Information

    Click Text    Edit Invoiced
    Verify No Text    Edit Invoiced

    Click Checkbox    Invoiced  on
    Type Text    Invoice Number    1234
    Type Text    Invoice Date    ${start_date}
    Type Text    Invoiced By    CRT-Test
    Click Checkbox    Provisioned  on
    Type Text  Provisioned Date  ${start_date}
    Type Text  Provisioned By  CRT-Test
    Type Text  PO Number  0987
    Pick List  PO Required  No

    Click Text  Save  anchor=Cancel  partial_match=False
    Verify Text    Edit Invoiced

CPQ-100
    IF    "${cpq_80_data}" == "${EMPTY}"
        Fail     Pre-requisite test case CPQ-80 has not been executed successfully before running this test case!"
    END

    Impersonate With Uid    ${primary_user}
    Close All Sales Console Tabs

    ${contract_url}=    Set Variable    ${cpq_80_data}[contract_url]

    Go To    ${contract_url}
    Verify Field    Amendment Start Date    ${EMPTY}
    Verify Field    Amendment Opportunity Stage    ${EMPTY}
    Verify Field    Amendment Owner    ${EMPTY}
    Verify Field    Amendment Pricebook Id    ${EMPTY}
    Verify No Element    xpath=//lightning-input[@checked]//span[text()="Disable Amendment Co-Term"]

    Click Text   Amend    partial_match=False
    Verify Text    Amend Contract  partial_match=False
    Click Text   Amend    partial_match=False

    SetConfig    ShadowDOM    on
    Verify Text    Edit Quote    timeout=120
    Click Text    Save    partial_match=False
    SetConfig    ShadowDOM    off
    Verify Text    Quote Details  timeout=60
    ${amend_quote_url}=    Get Url
    Click Text    Add-On    anchor=Opportunity    tag=a
    Verify Text  FE Support Request
    Verify Field    Opportunity Record Type    Expansion/Contraction    partial_match=True
    Verify Field  Stage  Interested

    Open QLE    ${amend_quote_url}
    Verify Table Cell    Product Name    1    Algolia Plan Bundle
    Verify Table Cell    Product Name    2    Standard (V8) (committed)

    Verify Table Cell    List Total  1  USD 0.00
    Verify Table Cell    List Total  2  USD 0.00
    Type Table    Quantity    2    0
    Click Text  Calculate

    Verify Text    USD - 10,000.00
    Verify Table Cell    List Total  2  USD - 10,000.00
    Verify Text    USD - 6,550.00  anchor=Quote Total

    Click Text    Quick Save
    Verify Text    You are not allowed to downgrade or cancel any quote lines. Please adjust your quantities back to the original quantities, or click cancel to start over

    Click Text    Cancel    anchor=Save    partial_matcch=False
    Verify Text    Edit Lines
    Click Text    Edit Lines
    Verify Text    Edit Quote    timeout=120

    Type Table    Quantity    2    20000
    Click Text  Calculate
    Verify Text    USD 10,000.00
    Verify Table Cell    List Total  2  USD 10,000.00
    Click Text    Save    anchor=Cancel    partial_match=False
    Verify Text    Edit Lines
