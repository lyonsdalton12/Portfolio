  @echo off
setlocal enabledelayedexpansion

echo =======================================================
echo Starting Automated Data Pull and Processing
echo Started at %date% %time%
echo =======================================================

:: Change to the directory where your Newman and Python files are located
echo Changing directory to: C:Example\Directory
cd /d "C:Example\Directory"
if %errorlevel% neq 0 (
    echo ERROR: Failed to change directory. Exiting with error code 1.
    exit /b 1
)
echo Directory change successful.
echo.
:: Run the Newman command to pull data and export to JSON (This essentially runs the files created via our exported GET collection previously listed above)
echo Running Newman data pull...
CALL newman run "ExampleCollection.postman_collectionXSESSIONCODE.json" -e "ExampleEnv1.postman_environment.json" -r cli,json --reporter-json-export json-file-reports 
if %errorlevel% neq 0 (
    echo ERROR: Newman run failed with return code !errorlevel!.
    echo The Postman collection pull was unsuccessful.
    exit /b !errorlevel!
)
echo Newman run completed successfully.
echo.

:: Check if the Newman output file was created
if not exist "json-file-reports" (
    echo ERROR: The Newman output file was not found. Exiting with error code 2.
    exit /b 2
)
echo Newman output file "json-file-reports" found.
echo.

:: Run your Python script (This section then calls our Python section of logic to parse the data via Pyodbc/Pandas frameworks into our TSQL database.)
echo Running Python script to process data...
CALL py.exe "WorkingExample_To_SQL_Script.py"
if %errorlevel% neq 0 (
    echo ERROR: Python script failed with return code !errorlevel!.
    echo The data was not loaded to the SQL database.
    exit /b !errorlevel!
)
echo Python script completed successfully.
echo.

echo =======================================================
echo Automation Finished Successfully.
echo Finished at %date% %time%
echo =======================================================
pause
endlocal
exit /b 0
