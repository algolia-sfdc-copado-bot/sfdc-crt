*** Keywords ***
Set Date Zero Strip Char
    ${platform}=   Evaluate    platform.system()    platform
    ${is_win}=    Evaluate    $platform.lower() == "windows"
    IF    ${is_win}
        Set Global Variable    ${zero_strip_char}    \#
    ELSE
        Set Global Variable    ${zero_strip_char}    -
    END
    