*** Settings    
Library    QForce

Resource           ../common/variables.resource
Resource           ../common/salesforce.resource

*** Keywords ***
Create Contact
    [Arguments]    ${account_url}
    ...            ${first_name}
    ...            ${last_name}
    ...            ${currency}=USD - U.S. Dollar  # EUR - Euro

    Open Records Related View    ${account_url}    Contacts
    Verify Text    Add to Campaign
    Click Text   New    anchor=Add to Campaign    partial_match=False

    Verify Text  New Contact  anchor=Contact Information

    Type Text    First Name    ${first_name}
    Type Text    Last Name    ${last_name}
    TypeText     Email        ${first_name}.${last_name}@algolia.com.invalid
    Pick List    Contact Currency    ${currency}

    Click Text    Save    partial_match=False
    Verify Text    ${first_name} ${last_name}    anchor=Account Name    partial_match=False    tag=a
    Verify Field    Name    ${first_name} ${last_name}

    ${url}=    Get Url
    [Return]    ${url}




