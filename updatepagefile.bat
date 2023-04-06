wmic pagefileset create name="C:\pagefile.sys"
wmic pagefileset where name="C:\\pagefile.sys" set InitialSize=6144,MaximumSize=6144