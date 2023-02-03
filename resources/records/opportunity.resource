*** Settings ***
Library            QForce
Library            DateTime
Library            String

Resource           ../common/salesforce.resource

*** Keywords ***
Create Opportunity
    [Documentation]    Creates an opportunity to an account, returns the url of created opportunity
    [Arguments]    ${account_url}
    ...            ${contact_name}
    ...            ${opportunity_name}=${EMPTY}
    ...            ${close_date}=${EMPTY}
    ...            ${days_to_close_date}=0
    ...            ${price_book}=Algolia V8 Pricing
    ...            ${creator_id}=${primary_user}

    Go To    ${account_url}
    Verify Text    Prospect    timeout=60s
    Click Text    New Opportunity    anchor=Prospect    
    Verify Text    Opportunity Creation    timeout=60s

    IF    "${close_date}" == "${EMPTY}"
          ${date}=    Get Current Date
          ${date}=    Add Time To Date    ${date}    ${days_to_close_date} days
          ${date}=    Convert Date    ${date}    result_format=%b %d, %Y   exclude_millis=True
    ELSE
          ${date}=    Set Variable    ${close_date}
    END

    # fill form
    Type Text          Amount                  100000
    Pick List          *Lead Source            Website    
    Pick List          *Current Search Tech    Amazon Cloud Search
    Multi Pick List    *Use cases              Online content / subscription
    Type Text          *Close Date             ${date}
    Pick List          *Type                   New Business

    ${pplan_not_selected}=    Set Variable    ${TRUE}
    WHILE    ${pplan_not_selected}    limit=5
        Run Keyword And Ignore Error    Click Text    Potential Plan    timeout=1
        Sleep              1
        Run Keyword And Ignore Error    Click Text    Standard Committed - V8    timeout=1
        #Run Keyword And Ignore Error    Pick List    Potential Plan    Standard Committed - V8    timeout=1
        Sleep              1
        ${pplan_not_selected}=    Is No Text    Standard Committed - V8    timeout=1
    END
    #Click Text         *Potential Plan
    #Sleep              1
    #Click Text         Standard Committed - V8

    IF    "${creator_id}" == "${primary_user}"
        Pick List          *Opportunity Stage      Interested
        Type Text          *Next Step              Test automation
        # rich text areas
        # turn off element highlighting
        ${previous_value}=    SetConfig    SearchMode      None
        # Activate rich text input
        Click Element      xpath=//lightning-quill[contains(.,"Identified Pain")]//div[@class="slds-rich-text-editor__textarea slds-grid"]
        # sets generated <p> elements innerText with js
        Type Text          locator=//lightning-quill[contains(.,"Identified Pain")]//p    input_text=Test automation
        #Execute Javascript  script=document.querySelectorAll('p')[0].innerText='Test Automation'

        Click Element      xpath=//lightning-quill[contains(.,"Ability to buy")]//div[@class="slds-rich-text-editor__textarea slds-grid"]
        Type Text          locator=//lightning-quill[contains(.,"Ability to buy")]//p    input_text=Test automation
        # set highlighting back on (if it was enabled to begin with)
        SetConfig    SearchMode      ${previous_value}
    END

    # contact
    Click Text         *Contact Name
    Sleep  1
    Click Text         ${contact_name}    anchor=Buyer Type
    Sleep  1
    
    #Pick List    Buyer Type    Champion
    Click Text         Select Buyer Type
    Sleep  1
    Click Text         Champion
    Sleep  1

    Click Text    Create Opportunity
    ${on_opp_page}=    Is Text    Opportunity Information    timeout=60s
    IF    ${on_opp_page}
        No Operation
    ELSE
        Click Text    New Business-Standard Committed - V8
        Verify Text    Opportunity Information   timeout=5
    END

    Verify Field    Price Book    ${price_book}    tag=a
    

    IF    "${opportunity_name}" != "${EMPTY}"
        Click While    Edit Opportunity Name    Edit Opportunity Name    interval=15
        Type Text    Opportunity Name    ${opportunity_name}
        Click Text    Save
        Verify No Text    Save
    END

    ${url}=    GetUrl
    [Return]    ${url}
    
Opportunity Stage To Discovery
    [Arguments]    ${opportunity_url}
    No Operation