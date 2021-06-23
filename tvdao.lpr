PROGRAM tvdao;

uses tvdaoapp, tvdaowin, DAGood, DATable;

procedure ProHalt;
begin
  Writeln;
  Write('Exit Code: '); Writeln(ExitCode);
  case ExitCode of
  0    : writeln('Halted.');
  1    : writeln('No parameters specified!');
  2    : writeln('Bad file name or file not found!');
  3    : writeln('Bad file type, use MAKEGAM.EXE to convert one!');
  203  : writeln('Not enough memory for program.');
  end;
end;

VAR MyApp: TTvDao;
BEGIN
  ExitProc := @ProHalt;
  if ParamCount < 1 then begin
    Writeln('No parameters specified!');
    Writeln('Usage: tvdao filename.gam');
  end else begin
    DAGoodInit;
    MyApp.Init;
    MyApp.CreateWindow;
    if Length(ErrorMessage) > 0 then
      ShowMessage(ErrorMessage, ErrorAttrs)
    else
      ShowMessage('Source file loaded OK!', $97);
    ErrorMessage := '';
    MyApp.Run;
  end;
  MyApp.Done;
END.
