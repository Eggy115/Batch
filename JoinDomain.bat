@Echo off
Title Please wait

netdom join %computername% /Domain:Corp.local /UserD:Corp\USER /PasswordD:PASS /ReBoot

:end
exit