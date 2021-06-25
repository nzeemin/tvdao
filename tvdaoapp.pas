unit tvdaoapp;

interface

uses  tvdaowin, tvdaodlg, dagood,
      Objects, Drivers, Views, Editors, Menus, Dialogs, App, FVConsts, Gadgets, MsgBox, ColorTxt;

const cmAppToolbar      = 1000;
      cmHelp            = 1001;
      cmGlobalLabel     = 1002;
      cmReloc           = 1003;
      cmMakeData        = 1004;
      cmMakeCode        = 1005;
      cmMakeWord        = 1006;
      cmMakeAddress     = 1007;
      cmDeleteLabel     = 1008;
      cmScan            = 1010;
      cmLoadWork        = 1011;
      cmSaveWork        = 1012;
      cmImportSymbols   = 1014;
      cmSaveAsmFiles    = 1015;
      cmPrevLine        = 1033;
      cmNextLine        = 1034;
      cmPrevByte        = 1035;
      cmNextByte        = 1036;
      cmGotoAddress     = 1037;
      cmLxxxxLabel      = 1038;
      cmGreedCall       = 1039;
      cmCpuTypeZ80      = 1041;
      cmCpuType8080     = 1042;
      cmCpuType8085     = 1043;
      cmUndocumCommands = 1044;
      cmDumpChar        = 1045;

{---------------------------------------------------------------------------}

type
   PTvDao = ^TTvDao;
   TTvDao = OBJECT (TApplication)
        P1,P2,P3: PGroup;
      CONSTRUCTOR Init;
      procedure Idle; virtual;
      procedure HandleEvent(var Event: TEvent); virtual;
      procedure InitMenuBar; virtual;
      procedure InitDeskTop; virtual;
      procedure InitStatusLine; virtual;
      procedure CreateWindow;
      procedure CloseWindow(var P: PGroup);
      procedure ShowHelpBox;
      procedure ShowAboutBox;
      procedure DoSaveWorkFile;
      procedure DoLoadWorkFile;
      procedure DoPrevLine;
      procedure DoNextLine;
      procedure DoPrevByte;
      procedure DoNextByte;
      procedure DoGotoAddress;
      procedure DoMakeData;
      procedure DoMakeCode;
      procedure DoMakeWord;
      procedure DoMakeAddress;
      procedure DoLxxxxLabel;
      procedure DoGlobalLabel;
      procedure DoDeleteLabel;
      procedure DoGreedCall;
    private
      Heap: PHeapView;
      procedure DoUndocumCommands;
    End;


implementation

const VersionStr = 'tvDAO v.0.0';

procedure ClearMessages;
begin
  ErrorMessage := '';  { Clear message in DAGood }
  ClearMessage;        { Clear message in the info view }
end;

{---------------------------------------------------------------------------}

CONSTRUCTOR TTvDao.Init;
BEGIN
  EditorDialog := @StdEditorDialog;
  Inherited Init;
END;

procedure TTvDao.Idle;
begin
  Heap^.Update;
end;

procedure TTvDao.HandleEvent(var Event : TEvent);
begin
   Inherited HandleEvent(Event);
   If (Event.What = evCommand) Then Begin
     ClearMessages;  { Clear any messages shown in the info view, clear DAGood error }
     Case Event.Command Of
       cmSaveWork        : DoSaveWorkFile;
       cmLoadWork        : DoLoadWorkFile;
       cmPrevLine        : DoPrevLine;
       cmNextLine        : DoNextLine;
       cmPrevByte        : DoPrevByte;
       cmNextByte        : DoNextByte;
       cmGotoAddress     : DoGotoAddress;
       cmMakeData        : DoMakeData;
       cmMakeCode        : DoMakeCode;
       cmMakeWord        : DoMakeWord;
       cmMakeAddress     : DoMakeAddress;
       cmGlobalLabel     : DoGlobalLabel;
       cmDeleteLabel     : DoDeleteLabel;
       cmGreedCall       : DoGreedCall;
       cmLxxxxLabel      : DoLxxxxLabel;
       cmCpuTypeZ80      : begin Z80 := true; RedrawWindow; end;
       cmCpuType8080     : begin Z80 := false; Type8085 := false; RedrawWindow; end;
       cmCpuType8085     : begin Z80 := false; Type8085 := true; RedrawWindow; end;
       cmDumpChar        : begin DumpChar := not DumpChar; RedrawWindow; end;
       cmUndocumCommands : DoUndocumCommands;
       cmAbout           : ShowAboutBox;
       cmHelp            : ShowHelpBox;
       Else Exit;
     end;
   end;
   ClearEvent(Event);
end;

procedure TTvDao.InitMenuBar;
var R: TRect; PS: PStaticText; V: string;
begin
  V := '  ' + VersionStr + '  ';
  GetExtent(R);   { Get view extents }
  R.B.Y := R.A.Y + 1;  { One line high  }
  R.A.X := R.A.X + Length(V);
  MenuBar := New(PMenuBar, Init(R, NewMenu(
    NewSubMenu('~F~ile', 0, NewMenu(
      NewItem('~L~oad WRK file', 'Alt+W', kbAltW, cmLoadWork, hcNoContext,
      NewItem('~S~ave WRK file', 'Alt+Q', kbAltQ, cmSaveWork, hcNoContext,
      NewLine(
      NewItem('~I~mport .SYM .CTL Files', 'Alt+I', kbAltI, cmImportSymbols, hcNoContext,
      NewLine(
      NewItem('Save ~A~SM Files', 'Ctrl+F9', kbCtrlF9, cmSaveAsmFiles, hcNoContext,
      NewLine(
      NewItem('E~x~it', 'Alt-X', kbAltX, cmQuit, hcNoContext,
      nil))))))))),
    NewSubMenu('~N~avigation', 0, NewMenu(
      NewItem('Prev Line', 'Up', kbUp, cmPrevLine, hcNoContext,
      NewItem('Next Line', 'Down', kbDown, cmNextLine, hcNoContext,
      NewItem('Prev Page', 'PgUp', kbPgUp, cmPrevLine, hcNoContext,
      NewItem('Next Page', 'PgDn', kbPgDn, cmNextLine, hcNoContext,
      NewItem('Prev Byte', 'Left', kbLeft, cmPrevByte, hcNoContext,
      NewItem('Next Byte', 'Right', kbRight, cmNextByte, hcNoContext,
      NewLine(
      NewItem('~G~o to Address...', 'Ctrl+G', kbCtrlG, cmGotoAddress, hcNoContext,
      nil))))))))),
    NewSubMenu('~E~dit', 0, NewMenu(
      NewItem('Global ~L~abel Here', 'F2', kbF2, cmGlobalLabel, hcNoContext,
      NewItem('~F~ind Global Label', 'F3', kbF3, cmReloc, hcNoContext,
      NewItem('Define ~B~yte Data Area...', 'F4', kbF4, cmMakeData, hcNoContext,
      NewItem('Define ~C~ode Area...', 'F5', kbF5, cmMakeCode, hcNoContext,
      NewItem('Define ~W~ord Data Area...', 'F6', kbF6, cmMakeWord, hcNoContext,
      NewItem('Define Offset ~T~able...', 'F7', kbF7, cmMakeAddress, hcNoContext,
      NewItem('~D~elete Label', 'F8', kbF8, cmDeleteLabel, hcNoContext,
      NewItem('Set/Delete Lxxxx Label', 'Ctrl+F2', kbCtrlF2, cmLxxxxLabel, hcNoContext,
      NewItem('Mark/Unmark ~G~reed Call', 'Alt+G', kbAltG, cmGreedCall, hcNoContext,
      NewLine(
      NewItem('~S~can from Here', 'F9', kbF9, cmScan, hcNoContext,
      NewItem('~S~can from Word Here', 'Alt+F9', kbAltF9, cmScan, hcNoContext,
      nil))))))))))))),
    NewSubMenu('~O~ptions', 0, NewMenu(
      NewItem('CPU Type ~Z~80', '', kbNoKey, cmCpuTypeZ80, hcNoContext,
      NewItem('CPU Type i~8~080', '', kbNoKey, cmCpuType8080, hcNoContext,
      NewItem('CPU Type i808~5~', '', kbNoKey, cmCpuType8085, hcNoContext,
      NewItem('~U~ndocumented Commands', 'Alt+U', kbAltU, cmUndocumCommands, hcNoContext,
      NewLine(
      NewItem('Hex/~C~har Dump', '', kbNoKey, cmDumpChar, hcNoContext,
      nil))))))),
    // NewSubMenu('~W~indow', 0, NewMenu(
    //   StdWindowMenuItems(Nil)),        { Standard window menu }
    NewSubMenu('~H~elp', hcNoContext, NewMenu(
      NewItem('~A~bout','', kbNoKey, cmAbout, hcNoContext,
      NewItem('~K~eyboard Quick Help', 'F1', kbF1, cmHelp, hcNoContext,
      nil))),
    nil))))) //end NewSubMenus
  ))); //end MenuBar

  R.A.X := 0;
  R.B.X := Length(V);
  PS := New(PColoredText, Init(R, V, $F0));
  Insert(PS);
end;

procedure TTvDao.InitDesktop;
VAR R: TRect;
begin
   GetExtent(R);  { Get app extents }
   Inc(R.A.Y);    { Adjust top down }
   Dec(R.B.Y);    { Adjust bottom up }
   Desktop := New(PDeskTop, Init(R));
end;

procedure TTvDao.InitStatusLine;
const HeapW: integer = 12;
var
   R: TRect;
begin
  GetExtent(R);
  R.A.Y := R.B.Y - 1;
  R.B.X := R.B.X - HeapW;
  New(StatusLine,
    Init(R,
      NewStatusDef(0, $EFFF,
        NewStatusKey('~F1~ Help', kbF1, cmHelp,
        NewStatusKey('~F2~ Label', kbF2, cmGlobalLabel,
        NewStatusKey('~F3~ Reloc', kbF3, cmReloc,
        NewStatusKey('~F4~ Data', kbF4, cmMakeData,
        NewStatusKey('~F5~ Code', kbF5, cmMakeCode,
        NewStatusKey('~F6~ Word', kbF6, cmMakeWord,
        NewStatusKey('~F7~ Address', kbF7, cmMakeAddress,
        NewStatusKey('~F8~ Delete', kbF8, cmDeleteLabel,
        NewStatusKey('~F9~ Scan', kbF9, cmScan,
        NewStatusKey('~Alt+X~ Exit', kbAltX, cmQuit,
        //StdStatusKeys(nil
        nil)))))))))),
      nil)
    )
  );

  GetExtent(R);
  R.A.X := R.B.X - HeapW; R.A.Y := R.B.Y - 1;
  Heap := New(PHeapView, InitKb(R));
  Insert(Heap);
end;

PROCEDURE TTvDao.CreateWindow;
VAR R: TRect;
BEGIN
  Desktop^.GetExtent(R);
  P1 := New(PTvDaoWindow, Init(R));
  Desktop^.Insert(P1);
END;

PROCEDURE TTvDao.ShowHelpBox;
var PD: PDialog; Rect: TRect;
begin
  Rect.Assign(0, 0, 72, 26);
  PD := New(PDialog, Init(Rect, 'Keyboard Quick Help'));
  with PD^ do begin
    Options := Options or ofCentered;
    Rect.Assign(2, 2, 70, 6);
    Insert(New(PStaticText, Init(Rect,
      'F2 Global label at c.p.           | F6 Define data area (word)' + #13 +
      'F3 Find global label              | F7 Define offset table' + #13 +
      'F4 Define data area (byte)        | F8 Delete label (!)'#13 +
      'F5 Define code area               | F9 Scan from cursor position')));
    Rect.Assign(2, 6, 70, 10);
    Insert(New(PStaticText, Init(Rect,
      'Alt+F2 Toggle offset/word         | Ctrl+F2 Set/Delete Lxxx label'#13 +
      'Alt+F9 Scan from WORD at c.p.     | Ctrl+F9 Save ASM files'#13 +
      'Shft+F2 Make offset, tiny label   | Shft+0..9,0 set mark #1..#10'#13 +
      'Ctrl+B Begin of module            | Alt+1..9,0 Goto mark #1..#10')));
    Rect.Assign(2, 10, 70, 14);
    Insert(New(PStaticText, Init(Rect,
      'Ctrl+S Start of module            | Ctrl+R Find reference'#13 +
      'Ctrl+E End of module              | Ctrl+X Find bytes (X - unknown)'#13 +
      'Alt+C Toggle comment Z80 code     | Ctrl+L Find next occurence'#13 +
      'Alt+B Toggle data block           | Ctrl+Z Change asm format')));
    Rect.Assign(2, 14, 70, 18);
    Insert(New(PStaticText, Init(Rect,
      'Alt+G Define "greed" call         | Ctrl+D Find next data from c.p.'#13 +
      'Alt+Q Save .WRK file              | Ctrl+C Hex/char dump, "+"/"-"'#13 +
      'Alt+W Load .WRK file              | Ctrl+A Find next address ref.'#13 +
      'Alt+S Move to data/code segment   | Ctrl+G Goto address, "+"/"-"')));
    Rect.Assign(2, 18, 70, 22);
    Insert(New(PStaticText, Init(Rect,
      'Alt+I Import .SYM, .CTL files     | Ctrl+O Goto origin'#13 +
      'Alt+D Dump offset to c.p.         | Ctrl+N Set origin'#13 +
      'Alt+X Quit the program            | Ctrl+F Follow operator'#13 +
      'Alt+R Toggle real data pos.       | Ctrl+T Find next label ref.')));
    Rect.Assign(2, 22, 70, 24);
    Insert(New(PStaticText, Init(Rect,
      'Alt+T Toggle CPU type i8080/i8085 | Ctrl+P Previous operator'#13 +
      'Alt+U Toggle undocument commands  | Enter  Unpack graphics at c.p.')));
  end;
  Desktop^.ExecView(PD);
  Dispose(PD, Done);
end;

PROCEDURE TTvDao.ShowAboutBox;
begin
  MessageBox(#3'tvDAO v.0.0'#13 +
    #3'Compiled at ' + {$I %DATE%} + #13 +
    #3'with FPC ' + {$I %FPCVERSION%},
    nil, mfInformation or mfOKButton);
end;

PROCEDURE TTvDao.CloseWindow(var P : PGroup);
BEGIN
  If Assigned(P) then
    BEGIN
      Desktop^.Delete(P);
      Dispose(P,Done);
      P:=Nil;
    END;
END;

procedure TTvDao.DoSaveWorkFile;
begin
  ShowMessage('Saving WorkFile...', $1B);
  ErrorMessage := '';
  SaveEnvir;
  ShowMessage(ErrorMessage, ErrorAttrs);
  ErrorMessage := '';
end;

procedure TTvDao.DoLoadWorkFile;
begin
  ShowMessage('Loading WorkFile...', $1B);
  ErrorMessage := '';
  LoadEnvir;
  RedrawWindow;
  ShowMessage(ErrorMessage, ErrorAttrs);
  ErrorMessage := '';
end;

procedure TTvDao.DoPrevLine;
var IP: word; I: integer;
begin
  if LineNo > 1 then
    Dec(LineNo)
  else begin {GoUp}
    IP := MemPos - 22;
    repeat
      DisAsm(ip);
      Inc(IP, ILength);
    until IP >= MemPos;
    Dec(MemPos, ILength);
  end;

  RealPos := MemPos; for I := 2 to LineNo do Inc(RealPos, Adds[I - 1]); {ShowStatus}

  RedrawWindow;
end;

procedure TTvDao.DoNextLine;
var I: integer;
begin
  if LineNo < 14 then Inc(LineNo) else Inc(MemPos, Adds[1]);

  RealPos := MemPos; for I := 2 to LineNo do Inc(RealPos, Adds[I - 1]); {ShowStatus}

  RedrawWindow;
end;

procedure TTvDao.DoPrevByte;
begin
  Dec(DumpPos);
  RedrawWindow;
end;

procedure TTvDao.DoNextByte;
begin
  Inc(DumpPos);
  RedrawWindow;
end;

procedure TTvDao.DoGotoAddress;
var Addr: word;
begin
  Addr := RealPos;
  if not EnterAddr(Addr) then exit;
  MemPos := Addr; LineNo := 1;
  RealPos := MemPos; {ShowStatus}
  RedrawWindow;
end;

procedure TTvDao.DoLxxxxLabel;
begin
  ShadowH^[RealPos] := ShadowH^[RealPos] xor $10;
  RedrawWindow;
end;

procedure TTvDao.DoGlobalLabel;
var L: string;
begin
  {TODO: Get label for RealPos - if LabelExist(RealPos)}
  L := '';
  if not EnterLabel(L) then exit;
  {TODO}
end;

procedure TTvDao.DoDeleteLabel;
begin
  if not LabelExist(RealPos) then exit;
  DeleteLabel(RealPos);
  RedrawWindow;
end;

procedure TTvDao.DoGreedCall;
begin
  MarkGreedCall(RealPos);
  RedrawWindow;
end;

procedure TTvDao.DoMakeData;
var A1,A2: word;
begin
  A1 := RealPos; A2 := RealPos;
  if not EnterRange(A1, A2) then exit;
  MakeData(A1, A2);
  RedrawWindow;
end;

procedure TTvDao.DoMakeCode;
var A1,A2: word;
begin
  A1 := RealPos; A2 := RealPos;
  if not EnterRange(A1, A2) then exit;
  MakeCode(A1, A2);
  RedrawWindow;
end;

procedure TTvDao.DoMakeWord;
var A1,A2: word;
begin
  A1 := RealPos; A2 := RealPos;
  if not EnterRange(A1, A2) then exit;
  MakeWord(A1, A2);
  RedrawWindow;
end;

procedure TTvDao.DoMakeAddress;
var A1,A2: word;
begin
  A1 := RealPos; A2 := RealPos;
  if not EnterRange(A1, A2) then exit;
  MakeAddress(A1, A2);
  RedrawWindow;
end;

procedure TTvDao.DoUndocumCommands;
begin
  if not Z80 then begin
    UndoCode := not UndoCode;
    RedrawWindow;
    if UndoCode then ShowMessage('Using undocument code ON', $1B) else ShowMessage('Using undocument code OFF', $1B);
  end;
end;

end.
