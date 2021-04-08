program float;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  Windows,
  oci_unit in 'oci_unit.pas';

var
  i: integer;
  vLiczba: Double;
  vOracleHome, vOciDll: string;

  vOCINumber: OCINumber;

  envhp: OCIEnv;
  errhp: OCIError;

  LastOCIError: Integer;


  EnvMode: ub4;

  s: string;
  function OCICall(err:Integer ): Boolean;
  begin
    LastOCIError := err;
    Result := (err = OCI_SUCCESS);
  end;

  function ReturnCode: Integer;
  begin
    if (LastOCIError = OCI_ERROR) or (LastOCIError = OCI_SUCCESS_WITH_INFO) then
      OCIErrorGet(errhp, 1, nil, ub4(Result), nil, 0, OCI_HTYPE_ERROR)
    else
      Result := LastOCIError;
  end;

  function ErrorHandle: Integer;
  begin
    Result := Integer(errhp);
  end;

begin
  vLiczba := 369.0;

  InitOCI;
  Writeln(InitOCILog);

  EnvMode := OCI_DEFAULT or OCI_OBJECT;
  OCICall(OCIHandleAlloc(nil, envhp, OCI_HTYPE_ENV, 0, nil));
  OCICall(OCIEnvCreate(envhp, EnvMode, nil, nil, nil, nil, 0, nil));
  OCICall(OCIHandleAlloc(envhp, errhp, OCI_HTYPE_ERROR, 0, nil));

  OCICall(OCINumberFromReal(errhp, @vLiczba, SizeOf(vLiczba), @vOCINumber));
  if ReturnCode <> 0 then
    Writeln('Error: OCINumberFromReal: ' + inttostr(ErrorHandle))
  else
  begin
     Write(UintToStr(vOCINumber.OCINumberPart[0]));
     for i := 1 to vOCINumber.OCINumberPart[0] do
       Write(',' + UintToStr(vOCINumber.OCINumberPart[i]));
     Writeln('');
     Writeln('Exiting...');
  end;
  OCIHandleFree(errhp, OCI_HTYPE_ERROR);
  OCIHandleFree(envhp, OCI_HTYPE_ENV);
  OCITerminate(OCI_OBJECT);
end.
