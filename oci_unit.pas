unit oci_unit;

interface

uses
  sysutils, windows;

const
  OCI_HTYPE_ENV      = 1;       // environment handle
  OCI_HTYPE_ERROR    = 2;       // error handle

  OCI_SUCCESS           = 0;        // maps to SQL_SUCCESS of SAG CLI
  OCI_ERROR             = -1;       // maps to SQL_ERROR
  OCI_SUCCESS_WITH_INFO = 1;        // maps to SQL_SUCCESS_WITH_INFO

  OCI_DEFAULT        = $00; // the default value for parameters and attributes
  OCI_OBJECT         = $02; // the application is in object environment

  OCI_NUMBER_SIZE = 22;

  dllOK         = 0;
  dllNoFile     = 1;    // No dll file found

type

  sb4 = LongInt;
  ub4 = LongInt;
  sword = Integer;
  uword = Integer;
  ub1 = Byte;

  OCINumber = record
     OCINumberPart: array[0..OCI_NUMBER_SIZE] of ub1;
  end;

  OCIEnv             = pointer;  // OCI environment handle
  OCIError           = pointer;  // OCI error handle

var
  HDLL: THandle;
  OCIDLL: String = '';                   // Name of OCI DLL
  InitOCILog:      String = '';        // InitOCI logging

  OCIHandleAlloc:
    function(parenth:pointer;
             var hndlpp:pointer;
             htype: ub4;
             xtramem_sz: Integer;
             usrmempp: pointer): sword; cdecl;
  OCIHandleFree:
    function(hndlp: pointer;
             hType: ub4): sword; cdecl;
  OCIErrorGet:
    function(hndlp: pointer;
             recordno: ub4;
             sqlstate: PAnsiChar;
             var errcodep: sb4;
             bufp: PAnsiChar;
             bufsiz: ub4;
             eType: ub4): sword; cdecl;
   OCIEnvCreate:
     function(var envhp: OCIEnv;
              mode: ub4;
              ctxp: Pointer;
              malocfp: Pointer;
              ralocfp: Pointer;
              mfreefp: Pointer;
              xtramemsz: Integer;
              usrmempp: Pointer): sword; cdecl;

   OCINumberFromReal:
     function(errhp: OCIError;
              rnum: Pointer;
              rnum_length: uword;
              number: Pointer): sword; cdecl;

   OCITerminate:
     function(mode: ub4): sword; cdecl;

  procedure InitOCI;
  function  DLLInit: Integer;
  procedure DLLExit;

implementation

procedure InitOCI;
var Error: Integer;
    oraclehome: string;
begin
  oraclehome := GetEnvironmentVariable('ORACLE_HOME');
  if oraclehome = '' then
    OCIDLL := 'oci.dll'
  else
    OCIDLL := oraclehome + '\oci.dll';

  Error := DLLInit;
  if Error <> dllOK then
  begin
    DLLExit;
    raise Exception.Create('Initialization error: ' + OCIDLL);
  end
  else
    InitOCILog := 'oci.dll forced to ' + OCIDLL;
end;

function DLLInit:Integer;
begin
  Result := dllOK;
  HDLL := LoadLibrary(PChar(OCIDLL));
  if HDLL <> 0 then
  begin
    OCIHandleAlloc := GetProcAddress(HDLL, 'OCIHandleAlloc');
    OCIEnvCreate := GetProcAddress(HDLL, 'OCIEnvCreate');
    OCINumberFromReal := GetProcAddress(HDLL, 'OCINumberFromReal');
    OCIHandleFree := GetProcAddress(HDLL, 'OCIHandleFree');
    OCITerminate := GetProcAddress(HDLL, 'OCITerminate');
    OCIErrorGet := GetProcAddress(HDLL, 'OCIErrorGet');
  end
  else
    Result := dllNoFile;
end;

procedure DLLExit;
begin
  if HDLL <> 0 then FreeLibrary(HDLL);
end;

end.
