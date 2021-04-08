# ociproblem
This is demonstration of oci19 bug with converting numbers to internal Oracle format when called from Pascal

1. Compile code in Embarcadero Delphi XE

2. Run in cmd (substitute Your OCI path)
SET ORACLE_HOME= <INSTANT CLIENT ORACLE DIRECTORY WITH OCI.DLL>
SET PATH=%ORACLE_HOME%;%path%

3. Run compiled program:
float.exe

4. Results interpretation:
The program result (converting double 369.0 to internal Oracle Number representation) is:
3,194,4,70 (correct) – on Intel processor or OCI version below 19
4,194,4,69,101 (wrong!) – OCI 19 or newer with AMD processor