PROGRAM tvdao;

uses tvdaoapp, tvdaowin, DAGood, DATable;

procedure ProHalt;
begin
  if ExitCode = 0 then exit;
  Writeln;
  Write('Exit Code: '); Writeln(ExitCode);
  case ExitCode of
  1    : writeln('No parameters specified!');
  2    : writeln('Bad file name or file not found!');
  3    : writeln('Bad file type, use MAKEGAM.EXE to convert one!');
  203  : writeln('Not enough memory for program.');
  end;
end;

VAR MyApp: TTvDao;
BEGIN
  if ParamCount < 1 then begin
    Writeln('No parameters specified!');
    Writeln('Usage: tvdao filename.gam');
    exit;
  end;

  ExitProc := @ProHalt;

  DAGoodInit;
  MyApp.Init;
  MyApp.CreateWindow;
  if Length(ErrorMessage) > 0 then
    ShowMessage(ErrorMessage, ErrorAttrs)
  else
    ShowMessage('Source file loaded OK!', $1B);
  ErrorMessage := '';
  MyApp.Run;
  MyApp.Done;
END.
