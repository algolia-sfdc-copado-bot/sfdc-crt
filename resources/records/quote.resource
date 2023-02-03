*** Settings ***
Library            QForce
Library            DateTime
Library            String

Library            DebugLibrary
Resource           ../common/salesforce.resource

*** Keywords ***
Create Quote
    [Documentation]    Creates an opportunity to an account, returns the url of created opportunity
    [Arguments]    ${opportunity_url}
    ...            ${primary_contact_name}
    ...            ${start_date}=${EMPTY}
    ...            ${days_to_start_date}=0
    ...            ${infrastructure_locations}=US-East
    ...            ${is_primary}=${TRUE}
    ...            ${subscription_term}=12
    ...            ${billing_frequency}=Annual
    ...            ${payment_terms}=Net 30
    ...            ${payment_method}=Wire Transfer
    ...            ${payment_method_margin}=${EMPTY}
    ...            ${contracting_entity}=Algolia, Inc.
    ...            ${bill_to_contact}=${EMPTY}
    ...            ${ship_to_contact}=${EMPTY}
    ...            ${partner}=${EMPTY}

    Go To    ${opportunity_url}
    Verify Text    Interested
    Click Text    New Quote    anchor=FE Support Request
    Verify Text    Primary Contact

    IF    "${start_date}" == "${EMPTY}"
          ${date}=    Get Current Date
          ${date}=    Add Time To Date    ${date}    ${days_to_start_date} days
          ${date}=    Convert Date    ${date}    result_format=%m/%d/%Y   exclude_millis=True
    ELSE
          ${date}=    Set Variable    ${start_date}
    END

    
    # fill modal form
    Use Modal    on
    # left column
    IF    ${is_primary}
        Click CheckBox    Primary    On
    ELSE
        Click CheckBox    Primary    Off
    END
    
    ${ifl_is_list}    Evaluate    isinstance($infrastructure_locations, list)
    IF    ${ifl_is_list}
        FOR    ${location}    IN    @{infrastructure_locations}
            Multi Pick List    Infrastructure Location    ${location}
        END
    ELSE
        Multi Pick List    Infrastructure Location    ${infrastructure_locations}
    END
    Type Text          Start Date             ${date}
    Type Text          Subscription Term             ${subscription_term}
    Pick List          Payment Terms    ${payment_terms}
    Type Text          Payment Method Margin    ${payment_method_margin}
    Pick List          Contracting Entity      ${contracting_entity}

    IF    "${ship_to_contact}" != "${EMPTY}"
        Combo Box    Ship To Contact    ${ship_to_contact}
    END
    # right column
    Combo Box          Primary Contact    ${primary_contact_name}
    Pick List          Billing Frequency    ${billing_frequency}
    Pick List          Payment Method       ${payment_method}

    IF    "${bill_to_contact}" != "${EMPTY}"
        Combo Box    Bill To Contact    ${bill_to_contact}
    END
    
    IF    "${partner}" != "${EMPTY}"
        Combo Box    Partner    ${partner}
    END
        
    #Close Record Form Edit    Save    Save
    Click Text    Save
    
    ${modal_closed}    Is No Text    Save    timeout=30
    IF    ${modal_closed}
        No Operation
    ELSE
        Click Text    Save
    END
    Verify No Text    Save
    Use Modal    off

    Verify Text    Quote Number:    timeout=60
    
    ${url}=    Get Latest Quote Url    ${opportunity_url}
    [Return]    ${url}

Validate Quote Defaults
    [Arguments]    ${opportunity_url}
    Go To    ${opportunity_url}
    Verify Text    Interested
    Click Text    New Quote    anchor=FE Support Request
    Verify Text    Primary Contact

    Use Modal    on

    Verify Checkbox Value    Primary    on

    #Verify Field Mandatory Indicator    Infrastructure Location
    ${chosen_locations}=    Get Element Count    locator=//lightning-dual-listbox//div[@class="slds-dueling-list__column slds-dueling-list__column_responsive" and contains(.,"Chosen")]//li    timeout=2
    Should Be Equal As Numbers    ${chosen_locations}    0

    ${date}=    Get Current Date
    ${date}=    Add Time To Date    ${date}    1 days
    ${date}=    Convert Date    ${date}    result_format=%${zero_strip_char}m/%${zero_strip_char}d/%Y   exclude_millis=True

    Verify Field Mandatory Indicator    Start Date
    Verify Input Value    Start Date    ${date}

    Verify Field Mandatory Indicator    Subscription Term
    Verify Input Value    Subscription Term    12

    Verify Field Mandatory Indicator    Payment Terms
    Verify Picklist Selection    Payment Terms    Net 30

    Verify Field Mandatory Indicator    Contracting Entity
    Verify Picklist Selection    Contracting Entity    --None--

    Verify Field Mandatory Indicator    Primary Contact
    Verify Input Value    Primary Contact    ${EMPTY}

    Verify Field Mandatory Indicator    Billing Frequency
    Verify Picklist Selection    Billing Frequency    Annual

    Verify Field Mandatory Indicator    Payment Method
    Verify Picklist Selection    Payment Method    Wire Transfer

    Close Record Form Edit    Cancel    Cancel
    Use Modal    off

Get Latest Quote Url
    [Arguments]    ${opportunity_url}
    Open Records Related View    ${opportunity_url}    SBQQ__Quotes2__r
    Use Table   Quote Number

    ${max_quote_number}=    Set Variable    00000

    ${row_count}=    Get Table Row    //last

    IF    "${row_count}"=="1"
        Sleep    10
        Refresh Page
        Use Table   Quote Number
        ${row_count}=    Get Table Row    //last
    END
    
    FOR    ${index}    IN RANGE    2    ${row_count}+1
        ${i_str}=    Convert To String    ${index}
        ${current_quote_number}=    Get Cell Text    r${i_str}/c4    tag=a
        ${curr_number}=    Replace String    ${current_quote_number}    Q-    ${EMPTY}
        
        IF    int("${curr_number}") > int("${max_quote_number}")
            ${max_quote_number}=    Set Variable    ${curr_number}
        END
    END

    ${url}=    Get Attribute    Q-${max_quote_number}    href    tag=a
    [Return]    ${url}

Open QLE
    [Arguments]    ${quote_url}
    Go To    ${quote_url}
    Verify Text    Edit Lines
    Click Text    Edit Lines

    SetConfig  ShadowDOM  On
    VerifyText  Calculate    timeout=60

Set Quote As Primary
    [Arguments]    ${quote_url}
    Go To  ${quote_url}

    ClickText  Edit Primary
    Click Checkbox  Primary  on
    ClickText  Save
    VerifyNoText    Save

Verify Quote Line Item
    [Arguments]    ${quote_url}
    ...            ${item_name}
    ...            ${field_dict}

    Open Records Related View    ${quote_url}    SBQQ__LineItems__r

    Use Table    Line Name
    Sleep    2
    ${r}=    Get Table Row    ${item_name}
    ClickCell  r${r}/c2    tag=a

    VerifyText    Pricing Information
    FOR    ${key}    ${value}    IN    &{field_dict}
        ${status}=    Run Keyword And Return Status    Verify Field    ${key}    ${value}
        IF    ${status}==${FALSE}
            Verify Field    ${key}    ${value}    tag=a
        END
    END