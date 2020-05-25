@echo off
REM ---------------------------------------------
REM
REM Solace Systems sdkperf_java startup script.
REM
REM --------------------------------------------- 

REM ---------------------------------------------
REM Start of user customizable properties
REM ---------------------------------------------
set SOLACE_VM_ARGS=
REM To enable cpu usage, set the SOLACE_SDKPERF_CPU_USAGE environment variable
REM or force the SOLACE_VM_ARGS update.
if defined SOLACE_SDKPERF_CPU_USAGE ^
set SOLACE_VM_ARGS=%SOLACE_VM_ARGS% -Dcom.sun.management.jmxremote.port=9999 -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.ssl=false

REM To use a non-default Kerberos library, set the SOLACE_SDKPERF_KRB_LIB environment variable 
REM or force the SOLACE_VM_ARGS update.
if defined SOLACE_SDKPERF_KRB_LIB ^
set SOLACE_VM_ARGS=%SOLACE_VM_ARGS% -Dsun.security.jgss.native=true -Djavax.security.auth.useSubjectCredsOnly=false -Dsun.security.jgss.lib=%SOLACE_SDKPERF_KRB_LIB%

REM To use a non-default Kerberos configuration file, set the SOLACE_SDKPERF_KRB_CONF environment variable 
REM or force the SOLACE_VM_ARGS update.
if defined SOLACE_SDKPERF_KRB_CONF ^
set SOLACE_VM_ARGS=%SOLACE_VM_ARGS% -Djava.security.krb5.conf=%SOLACE_SDKPERF_KRB_CONF%

REM To use a non-default JAAS configuration file, set the SOLACE_SDKPERF_JAAS_CONF environment variable 
REM or force the SOLACE_VM_ARGS update.
if defined SOLACE_SDKPERF_JAAS_CONF ^
set SOLACE_VM_ARGS=%SOLACE_VM_ARGS% -Djava.security.auth.login.config=%SOLACE_SDKPERF_JAAS_CONF%
echo.%* | findstr /C:"-as=kerberos">nul && (
if not defined SOLACE_SDKPERF_JAAS_CONF ^
set SOLACE_VM_ARGS=%SOLACE_VM_ARGS% -Djava.security.auth.login.config=./jaas/login.conf
)

REM To customize VM memory, set the SOLACE_SDKPERF_VM_MEM environment variable.
set TMP_VM_MEM=-Xms512m -Xmx1024m
if defined SOLACE_SDKPERF_VM_MEM ^
set TMP_VM_MEM=%SOLACE_SDKPERF_VM_MEM%
set SOLACE_VM_ARGS=%SOLACE_VM_ARGS% %TMP_VM_MEM%

REM Try to determine if the Java VM supports the -server arg.  If so, then use it.
java -server -version
IF %ERRORLEVEL% == 0 ^
set SOLACE_VM_ARGS=%SOLACE_VM_ARGS% -server

REM ---------------------------------------------
REM End of user customizable properties
REM ---------------------------------------------


set CP=

REM ---------------------------------------------
REM Uncomment line below to enable LOG4J logging
REM ---------------------------------------------
set SOLACE_ENABLE_LOG4J=1
if defined SOLACE_ENABLE_LOG4J (
for %%i in (./lib/optional/*.jar) do call :addjar optional/%%i
call :addjar optional
)

for %%i in (lib/*.jar) do call :addjar %%i
goto :run

:addjar
set CP=%CP%lib/%1;
goto :eof

:run
REM
REM If you experience difficulties, ensure "java" is on your PATH.
REM
REM echo sdkperf classpath: %CP% JMX: %JMX%
echo SOLACE_VM_ARGS: %SOLACE_VM_ARGS%

java -server %SOLACE_VM_ARGS% -cp %CP% com.solacesystems.pubsub.sdkperf.SDKPerf_java %*
goto :eof

:eof