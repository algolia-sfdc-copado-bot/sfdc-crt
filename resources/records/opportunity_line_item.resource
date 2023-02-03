*** Settings ***
Library    QForce
Resource   ../common/salesforce.resource

*** Keywords ***
Verify Opportunity Line Item
    [Arguments]    ${opportunity_url}
    ...            ${item_name}
    ...            ${field_dict}

    Open Records Related View  ${opportunity_url}  OpportunityLineItems
    VerifyText    Product Code
    
    #Go To Url With Link    ${item_name}
    Click Text    ${item_name}    tag=a
    VerifyText    Product Information
    FOR    ${key}    ${value}    IN    &{field_dict}
        Verify Field    ${key}    ${value}
    END

Verify Opportunity Line Item Count
    [Arguments]    ${opportunity_url}    ${line_item_count}
    ${item_count_with_header_row}=    Evaluate    int(${line_item_count}) + 1

    Open Records Related View  ${opportunity_url}  OpportunityLineItems
    Use Table    Product Code
    ${rows}=  Get Table Row  //last

    WHILE    "${rows}"!="${item_count_with_header_row}"    limit=5
        Sleep    5  # wait for a moment and renavigate to the page
        Open Records Related View  ${opportunity_url}  OpportunityLineItems
        Use Table    Product Code
        ${rows}=  Get Table Row  //last
    END

    Should Be Equal As Integers    ${rows}    ${item_count_with_header_row}