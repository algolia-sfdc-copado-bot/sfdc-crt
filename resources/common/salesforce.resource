*** Settings ***
Library            QForce
Library            DateTime
Library            String

Resource           secrets.resource
Resource           variables.resource

*** Keywords ***
Login
    GoTo              ${login_url}
    
    TypeText    Username    ${username}
    TypeText    Password    ${password}
    ClickText   Log In

    ${needs_mfa}=    IsText    Verify Your Identity    timeout=5
    IF    ${needs_mfa}
        ${mfa_code}    Get Otp    ${username}    ${mfa_secret}
        TypeText    Verification Code    ${mfa_code}
        ClickText    Verify    partial_match=False
    END

Set Record Prefix
    [Arguments]    ${test_case_identifier}
    ${timestamp}=    Get Current Date    exclude_millis=True
    ${short_ts}=    Convert Date    ${timestamp}    result_format=%y%m%d-%H%M%S
    Set Suite Variable    ${record_prefix}    CRT-${test_case_identifier}-${short_ts}
    [Return]    ${record_prefix}

Resolve Record Url From Id
    [Arguments]    ${record_id}    ${record_name}
    ${url}=    Set Variable    ${login_url}/lightning/r/${record_name}/${record_id}/view
    [Return]    ${url}

Resolve Record Id From Url
    [Arguments]    ${record_url}    ${record_name}
    ${a}=    Split String    ${record_url}    ${record_name}/
    ${b}=    Split String    ${a}[1]    /view
    [Return]    ${b}[0]

Navigate To Record With Id
    [Arguments]    ${record_id}    ${record_name}    ${verification_text}=${EMPTY}
    ${url}=    Resolve Record Url From Id    ${record_id}    ${record_name}
    Go To    ${url}

    IF    "${verification_text}" != "${EMPTY}"
        Verify Text    ${verification_text}
    END
    [Return]    ${url}

Open Records Related View
    [Arguments]    ${record_url}    ${related_view_name}
    ${related_view_url}=    Replace String    ${record_url}    /view    /related/${related_view_name}/view
    Go To    ${related_view_url}
    [Return]    ${related_view_url}

Close Record Form Edit  # fix to not use click until/while
    [Arguments]    ${close_button_text}    ${verification_text}    ${anchor}=1    ${disappear}=${TRUE}    ${interval}=15
    IF    ${disappear}
        Click While    ${verification_text}    ${close_button_text}    anchor=${anchor}    interval=${interval}
    ELSE
        Click Until    ${verification_text}    ${close_button_text}    anchor=${anchor}    interval=${interval}
    END

Verify Picklist Selection
    [Documentation]    Confirms that picklist is set to expected value
    [Arguments]    ${label}    ${value}    ${timeout}=0.1
    ${lightning}=    Is Element    xpath=//lightning-combobox[./label[Text()="${label}"]]//button[@data-value="${value}"]    timeout=${timeout}
    Return From Keyword If    ${lightning}
    Verify Element    xpath=//div[./span[@data-aura-class="uiPicklistLabel" and contains(.,"${label}")]]//a[@class="select" and .="${value}"]    timeout=${timeout}

Verify Field Mandatory Indicator
    [Arguments]    ${field_name}    ${timeout}=0.1
    ${found}=  Is Element    xpath=//label[./span[text()="*"] and ./span[text()="${field_name}"]]    timeout=${timeout}
    Return From Keyword If    ${found}
    Verify Element    xpath=//span[./span[text()="*"] and ./span[text()="${field_name}"]]    timeout=${timeout}

Go To Url With Link
    [Arguments]    ${locator}
    ${url}=    Set Variable    javascript:void(0);
    WHILE    ${TRUE}    limit=10
        ${url}=    Get Attribute    ${locator}    href    tag=a  element_type=item  anchor=item
        IF    "${url}"=="javascript:void(0);"
            Sleep    2
        ELSE
            Go To    ${url}
            BREAK
        END
    END
        
Close All Sales Console Tabs
    Verify Text    Lightning Sales Console

    ${tab_xpath}=    Set Variable    //li[./a[@role="tab" and @aria-selected="true" and not(contains(@data-tabid, "_"))]]//button[contains(@title, "Close")]
    ${tabs_present}=    Is Element    ${tab_xpath}    timeout=5

    WHILE    ${tabs_present}
        Run Keyword And Ignore Error    Click Element    ${tab_xpath}    timeout=1
        ${tabs_present}=    Is Element    ${tab_xpath}    timeout=5
    END
    
Reload Record List Until Record Count Is
    [Arguments]    ${table_name}    ${expected_count}    ${limit}=20
    Use Table    ${table_name}
    ${rows}=    Get Table Row    //last
    
    ${expected}=    Convert To Integer    ${expected_count}
    ${expected_rows}=   Set Variable    ${expected + 1}
    WHILE    "${rows}" != "${expected_rows}"    limit=${limit}
        Sleep    6
        Refresh Page
        Use Table    ${table_name}
        ${rows}=    Get Table Row    //last
    END