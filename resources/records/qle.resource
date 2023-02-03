*** Settings ***
Library            QForce
Library            DateTime
Library            String

Resource           ../common/salesforce.resource

*** Keywords ***
Add Bundle To Quote Lines
    [Arguments]    ${base_name}    ${bundle_name}   ${add_on_names}=${NONE}    ${services_names}=${NONE}    ${other_options_codes}=${NONE}
    Verify Text  Product Selection

    ClickItem  checkbox  anchor=${base_name}
    ClickText    Select    partial_match=False

    #SetConfig  DefaultTimeout  1
    #Debug
    Verify Text  Configure Products

    
    ClickItem    radioContainer   anchor=${bundle_name}
    IF    ${add_on_names} is not ${NONE}
        FOR    ${item}    IN    @{add_on_names}
            ClickItem  checkbox  anchor=${item}
            Sleep    1
        END
    END

    IF    ${services_names} is not ${NONE}
        FOR    ${item}    IN    @{services_names}
            ClickItem  checkbox  anchor=${item}
            Sleep    1
        END
    END

    ClickText  Save
    VerifyText  Add Products    timeout=60

Verify Configuration Checkbox Disabled State
    [Arguments]    ${product_name}    ${expected_state}
    ${elem}=    GetWebElement   checkbox   anchor=${product_name}  tag=paper-checkbox   element_type=item
    ${disabled}=   Evaluate     str($elem.get_attribute("aria-disabled")).lower()
    ${expected}=    Convert To Lower Case    ${expected_state}
    Should Be Equal As Strings    ${disabled}    ${expected}

Find Cpq Table Row
    [Arguments]    ${column_name}    ${row_content}
    No Operation

Verify QLE Additional Disc Editable
    [Arguments]    ${product_name}    ${expected_state}
    ${e}=  GetWebElement  SBQQ__AdditionalDiscount__c  anchor=${product_name}  tag=div  element_type=item
    ${editable}=    Evaluate     "editable" in str($e.get_attribute("class")).lower()

    Should Be Equal As Strings    ${editable}    ${expected_state}