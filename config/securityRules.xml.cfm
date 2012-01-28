<?xml version="1.0" encoding="UTF-8"?>
<rules>
    <rule>
        <whitelist></whitelist>
        <securelist>^secure</securelist>
        <roles>user</roles>
        <permissions>read,write</permissions>
        <redirect>login/forbidden</redirect>
    </rule>
    <rule>
        <whitelist></whitelist>
        <securelist>^admin</securelist>
        <roles>admin</roles>
        <permissions>read,write</permissions>
        <redirect>login/forbidden</redirect>
    </rule>
</rules>
