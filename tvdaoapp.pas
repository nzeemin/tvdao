unit tvdaoapp;

interface

uses  tvdaowin, tvdaodlg, dagood,
      SysUtils,
      Objects, Drivers, Views, Editors, Menus, Dialogs, App, FVConsts, Gadgets, MsgBox, ColorTxt, StdDlg;

const cmAppToolbar      = 1000;
      cmHelp            = 1001;
      cmGlobalLabel     = 1002;
      cmFindGlobalLabel = 1003;
      cmMakeData        = 1004;
      cmMakeCode        = 1005;
      cmMakeWord        = 1006;
      cmMakeAddress     = 1007;
      cmDeleteLabel     = 1008;
      cmScan            = 1010;
      cmLoadWork        = 1011;
      cmSaveWork        = 1012;
      cmImportSymbols   = 1014;
      cmImportControl   = 1015;
      cmSaveAsmFile     = 1016;
      cmPrevLine        = 1023;
      cmNextLine        = 1024;
      cmPrevPage        = 1025;
      cmNextPage        = 1026;
      cmPrevByte        = 1027;
      cmNextByte        = 1028;
      cmGotoAddress     = 1029;
      cmLxxxxLabel      = 1030;
      cmGreedCall       = 1031;
      cmSetOrigin       = 1032;
      cmGotoOrigin      = 1033;
      cmGotoModuleBegin = 1034;
      cmGotoModuleStart = 1035;
      cmGotoModuleEnd   = 1036;
      cmDumpPosCurPos   = 1037;
      cmCpuTypeZ80      = 1041;
      cmCpuType8080     = 1042;
      cmCpuType8085     = 1043;
      cmUndocumCommands = 1044;
      cmDumpChar        = 1045;
      cmDataBlock       = 1046;

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
      //procedure ShowHelpBox;
      procedure ShowAboutBox;
      procedure DoSaveWorkFile;
      procedure DoLoadWorkFile;
      procedure DoImportSymbols;
      procedure DoImportControl;
      procedure DoSaveAsmFile;
      procedure DoPrevLine;
      procedure DoNextLine;
      procedure DoPrevPage;
      procedure DoNextPage;
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
      procedure DoSetBookmark(N: integer; Addr: word);
      procedure DoGotoBookmark(N: integer);
      procedure DoFindGlobalLabel;
      procedure DoScan;
    private
      Heap: PHeapView;
      procedure DoUndocumCommands;
    End;

{---------------------------------------------------------------------------}

implementation

const VersionStr = 'tvDAO v.0.01';

type
    PScanDialog = ^TScanDialog;
    TScanDialog = object(TDialog)
    end;

{---------------------------------------------------------------------------}

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
  inherited HandleEvent(Event);

  if Event.What = evCommand Then Begin
    ClearMessages;  { Clear any messages shown in the info view, clear DAGood error }
    case Event.Command Of
      cmSaveWork        : DoSaveWorkFile;
      cmLoadWork        : DoLoadWorkFile;
      cmSaveAsmFile     : DoSaveAsmFile;
      cmImportSymbols   : DoImportSymbols;
      cmImportControl   : DoImportControl;
      cmPrevLine        : DoPrevLine;
      cmNextLine        : DoNextLine;
      cmPrevPage        : DoPrevPage;
      cmNextPage        : DoNextPage;
      cmPrevByte        : DoPrevByte;
      cmNextByte        : DoNextByte;
      cmGotoModuleBegin : begin MemPos := PrgBegin; LineNo := 1; RealPos := MemPos; RedrawWindow; end;
      cmGotoModuleStart : begin MemPos := PrgStart; LineNo := 1; RealPos := MemPos; RedrawWindow; end;
      cmGotoModuleEnd   : begin MemPos := PrgBegin + PrgLength; LineNo := 1; RealPos := MemPos; RedrawWindow; end;
      cmGotoAddress     : DoGotoAddress;
      cmSetOrigin       : begin OriginPos := RealPos; RedrawWindow; end;
      cmGotoOrigin      : begin MemPos := OriginPos; LineNo := 1; RealPos := MemPos; RedrawWindow; end;
      cmDumpPosCurPos   : begin DumpPos := RealPos; RedrawWindow; end;
      cmFindGlobalLabel : DoFindGlobalLabel;
      cmMakeData        : DoMakeData;
      cmMakeCode        : DoMakeCode;
      cmMakeWord        : DoMakeWord;
      cmMakeAddress     : DoMakeAddress;
      cmGlobalLabel     : DoGlobalLabel;
      cmDeleteLabel     : DoDeleteLabel;
      cmGreedCall       : DoGreedCall;
      cmLxxxxLabel      : DoLxxxxLabel;
      cmDataBlock       : begin DataBlock := not DataBlock; RedrawWindow; end;
      cmScan            : DoScan;
      cmCpuTypeZ80      : begin Z80 := true; RedrawWindow; end;
      cmCpuType8080     : begin Z80 := false; Type8085 := false; RedrawWindow; end;
      cmCpuType8085     : begin Z80 := false; Type8085 := true; RedrawWindow; end;
      cmDumpChar        : begin DumpChar := not DumpChar; RedrawWindow; end;
      cmUndocumCommands : DoUndocumCommands;
      cmAbout           : ShowAboutBox;
      //cmHelp            : ShowHelpBox;
      else exit;
    end; {case of}
  end else if Event.What = evKeyDown then begin
    case Event.CharCode of
      {Shift1} '!' : DoSetBookmark(1, RealPos);
      {Shift2} '@' : DoSetBookmark(2, RealPos);
      {Shift3} '#' : DoSetBookmark(3, RealPos);
      {Shift4} '$' : DoSetBookmark(4, RealPos);
      {Shift5} '%' : DoSetBookmark(5, RealPos);
      {Shift6} '^' : DoSetBookmark(6, RealPos);
      {Shift7} '&' : DoSetBookmark(7, RealPos);
      {Shift8} '*' : DoSetBookmark(8, RealPos);
      {Shift9} '(' : DoSetBookmark(9, RealPos);
      {Shift0} ')' : DoSetBookmark(10, RealPos);
      else
        case Event.KeyCode of
          kbAlt1 : DoGotoBookmark(1);
          kbAlt2 : DoGotoBookmark(2);
          kbAlt3 : DoGotoBookmark(3);
          kbAlt4 : DoGotoBookmark(4);
          kbAlt5 : DoGotoBookmark(5);
          kbAlt6 : DoGotoBookmark(6);
          kbAlt7 : DoGotoBookmark(7);
          kbAlt8 : DoGotoBookmark(8);
          kbAlt9 : DoGotoBookmark(9);
          kbAlt0 : DoGotoBookmark(10);
        end;
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
      NewItem('~I~mport SYM File', '', kbNoKey, cmImportSymbols, hcNoContext,
      NewItem('~I~mport CTL File', '', kbNoKey, cmImportControl, hcNoContext,
      NewLine(
      NewItem('Save ~A~SM Files', 'Ctrl+F9', kbCtrlF9, cmSaveAsmFile, hcNoContext,
      NewLine(
      NewItem('E~x~it', 'Alt-X', kbAltX, cmQuit, hcNoContext,
      nil)))))))))),
    NewSubMenu('~N~avigation', 0, NewMenu(
      NewItem('Prev Disasm Line', 'Up', kbUp, cmPrevLine, hcNoContext,
      NewItem('Next Disasm Line', 'Down', kbDown, cmNextLine, hcNoContext,
      NewItem('Prev Disasm Page', 'PgUp', kbPgUp, cmPrevPage, hcNoContext,
      NewItem('Next Disasm Page', 'PgDn', kbPgDn, cmNextPage, hcNoContext,
      NewItem('Prev Memory Byte', 'Left', kbLeft, cmPrevByte, hcNoContext,
      NewItem('Next Memory Byte', 'Right', kbRight, cmNextByte, hcNoContext,
      NewLine(
      NewItem('Go to Module ~B~egin', 'Ctrl+B', kbCtrlB, cmGotoModuleBegin, hcNoContext,
      NewItem('Go to Module ~S~tart', 'Ctrl+S', kbCtrlS, cmGotoModuleStart, hcNoContext,
      NewItem('Go to Module ~E~nd', 'Ctrl+E', kbCtrlE, cmGotoModuleEnd, hcNoContext,
      NewLine(
      NewItem('~G~o to Address...', 'Ctrl+G', kbCtrlG, cmGotoAddress, hcNoContext,
      NewItem('Memory to Cur.Pos.', 'Alr+D', kbAltD, cmDumpPosCurPos, hcNoContext,
      NewLine(
      NewItem('Go to ~O~rigin', 'Ctrl+O', kbCtrlO, cmGotoOrigin, hcNoContext,
      NewItem('Set Origi~n~', 'Ctrl+N', kbCtrlN, cmSetOrigin, hcNoContext,
      NewLine(
      NewItem('~F~ind Global Label', 'F3', kbF3, cmFindGlobalLabel, hcNoContext,
      nil))))))))))))))))))),
    NewSubMenu('~E~dit', 0, NewMenu(
      NewItem('Global ~L~abel at Cur.Pos.', 'F2', kbF2, cmGlobalLabel, hcNoContext,
      NewItem('Define ~B~yte Data Area...', 'F4', kbF4, cmMakeData, hcNoContext,
      NewItem('Define ~C~ode Area...', 'F5', kbF5, cmMakeCode, hcNoContext,
      NewItem('Define ~W~ord Data Area...', 'F6', kbF6, cmMakeWord, hcNoContext,
      NewItem('Define Offset ~T~able...', 'F7', kbF7, cmMakeAddress, hcNoContext,
      NewItem('~D~elete Global Label', 'F8', kbF8, cmDeleteLabel, hcNoContext,
      NewItem('Set/Delete Lxxxx Label', 'Ctrl+F2', kbCtrlF2, cmLxxxxLabel, hcNoContext,
      NewItem('Mark/Unmark ~G~reed Call', 'Alt+G', kbAltG, cmGreedCall, hcNoContext,
      NewLine(
      NewItem('~S~can from Cur.Pos.', 'F9', kbF9, cmScan, hcNoContext,
      NewItem('~S~can from Word at Cur.Pos.', 'Alt+F9', kbAltF9, cmScan, hcNoContext,
      nil)))))))))))),
    NewSubMenu('~O~ptions', 0, NewMenu(
      NewItem('CPU Type ~Z~80', '', kbNoKey, cmCpuTypeZ80, hcNoContext,
      NewItem('CPU Type i~8~080', '', kbNoKey, cmCpuType8080, hcNoContext,
      NewItem('CPU Type i808~5~', '', kbNoKey, cmCpuType8085, hcNoContext,
      NewItem('~U~ndocumented Commands', 'Alt+U', kbAltU, cmUndocumCommands, hcNoContext,
      NewLine(
      NewItem('Toggle Data Block', 'Alt+B', kbAltB, cmDataBlock, hcNoContext,
      NewItem('Memory as Hex/~C~har', '', kbNoKey, cmDumpChar, hcNoContext,
      nil)))))))),
    // NewSubMenu('~W~indow', 0, NewMenu(
    //   StdWindowMenuItems(Nil)),        { Standard window menu }
    NewSubMenu('~H~elp', hcNoContext, NewMenu(
      NewItem('~A~bout','', kbNoKey, cmAbout, hcNoContext,
      //NewItem('~K~eyboard Quick Help', 'F1', kbF1, cmHelp, hcNoContext,
      nil)),
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
        NewStatusKey('~F3~ Reloc', kbF3, cmFindGlobalLabel,
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

PROCEDURE TTvDao.ShowAboutBox;
var D: PDialog; R: TRect;
begin
  Desktop^.GetExtent(R);
  R.Assign(R.B.X div 2 - 26, R.A.X + 3, R.B.X div 2 + 26, R.A.X + 20);
  New(D, Init(R, 'About'));
  R.Assign(4, 2, 44, 3);
  D^.Insert(New(PStaticText, Init(R, VersionStr)));
  R.Move(0, 2);
  D^.Insert(New(PStaticText, Init(R, 'Compiled at ' + {$I %DATE%} + ' with FPC ' + {$I %FPCVERSION%})));
  R.Move(0, 1);
  D^.Insert(New(PStaticText, Init(R, 'Terget: ' + {$I %FPCTARGET%})));
  R.Move(0, 2);
  D^.Insert(New(PStaticText, Init(R, 'Based on MSX2PC by Val Bostan')));
  R.Move(0, 1);
  D^.Insert(New(PStaticText, Init(R, 'Rebuilt for i8080/i8085 by Tim0xA')));
  R.Move(0, 1);
  D^.Insert(New(PStaticText, Init(R, 'with changes by ivagor')));
  R.Move(0, 1);
  D^.Insert(New(PStaticText, Init(R, 'Adopted for FPC/FV by nzeemin')));
  R.Move(0, 2);
  D^.Insert(New(PStaticText, Init(R, 'https://github.com/nzeemin/tvdao')));
  R.Assign(37, 14, 48, 16);
  D^.Insert(New(PButton, Init(R, '~O~K', cmOK, bfDefault)));
  Desktop^.ExecView(D);
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

procedure TTvDao.DoImportSymbols;
begin
  ShowMessage('Import SYM file...', $1B);
  ErrorMessage := '';
  ImportSymbols;
  RedrawWindow;
  ShowMessage(ErrorMessage, ErrorAttrs);
  ErrorMessage := '';
end;

procedure TTvDao.DoImportControl;
begin
  ShowMessage('Import CTL file...', $1B);
  ErrorMessage := '';
  ImportControl;
  RedrawWindow;
  ShowMessage(ErrorMessage, ErrorAttrs);
  ErrorMessage := '';
end;

procedure TTvDao.DoSaveAsmFile;
begin
  ShowMessage('Saving ASM file...', $1B);
  ErrorMessage := '';
  SaveAsmFile;
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
  if LineNo < LinesCount then Inc(LineNo) else Inc(MemPos, Adds[1]);

  RealPos := MemPos; for I := 2 to LineNo do Inc(RealPos, Adds[I - 1]); {ShowStatus}

  RedrawWindow;
end;

procedure TTvDao.DoPrevPage;
var IP: word; I: integer;
begin
  for I := 1 to LinesCount do begin {GoUp}
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

procedure TTvDao.DoNextPage;
begin
  Inc(MemPos, PageByte);
  RealPos := MemPos; {ShowStatus}
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
var L,Prompt: string;
begin
  L := ''; Prompt := 'New global label:';
  if LabelExist(RealPos) then begin L := Labels^[LabelNo]; Prompt := 'Edit global label:' end;
  if not EnterLabel(L, Prompt) then exit;
  SetLabelName(RealPos, L);
  RedrawWindow;
end;

procedure TTvDao.DoDeleteLabel;
var L: string;
begin
  if not LabelExist(RealPos) then exit;
  L := Labels^[LabelNo];
  if cmOk <> MessageBox('Deleting label "' + L + '".'#13'Proceed?', nil, mfConfirmation or mfOKCancel) then exit;
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
  if not EnterRange(A1, A2, 'Mark as Data block:') then exit;
  MakeData(A1, A2);
  RedrawWindow;
end;

procedure TTvDao.DoMakeCode;
var A1,A2: word;
begin
  A1 := RealPos; A2 := RealPos;
  if not EnterRange(A1, A2, 'Mark as Code block:') then exit;
  MakeCode(A1, A2);
  RedrawWindow;
end;

procedure TTvDao.DoMakeWord;
var A1,A2: word;
begin
  A1 := RealPos; A2 := RealPos;
  if not EnterRange(A1, A2, 'Makr as Word data:') then exit;
  MakeWord(A1, A2);
  RedrawWindow;
end;

procedure TTvDao.DoMakeAddress;
var A1,A2: word;
begin
  A1 := RealPos; A2 := RealPos;
  if not EnterRange(A1, A2, 'Mark as Address data:') then exit;
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

procedure TTvDao.DoSetBookmark(N: integer; Addr: word);
begin
  KeyReg[N] := Addr;
  RedrawWindow;
end;

procedure TTvDao.DoGotoBookmark(N: integer);
begin
  MemPos := KeyReg[N]; LineNo := 1;
  RealPos := MemPos; {ShowStatus}
  RedrawWindow;
end;

procedure TTvDao.DoFindGlobalLabel;
var LF,L: string; IP: word;
begin
  LF := '';
  if not EnterLabel(LF, 'Global label to find:') then exit;
  LF := UpperCase(LF);
  for IP := PrgBegin to PrgBegin + PrgLength do begin
    if LabelExist(IP) then begin
      L := LeftStr(UpperCase(Labels^[LabelNo]), Length(LF));
      if LF = L then begin { Found }
        MemPos := IP; LineNo := 1;
        RealPos := MemPos; {ShowStatus}
        RedrawWindow;
        Exit;
      end;
    end;
  end;
  { Not found }
  ShowMessage('Label not found!', $1C);
end;

procedure TTvDao.DoScan;
var D: PScanDialog; R: TRect;
begin
  NotImplemented;
(*  Desktop^.GetExtent(R);
  R.Assign(R.B.X div 2 - 36, R.A.X + 6, R.B.X div 2 + 36, R.A.X + 24);
  New(D, Init(R, 'Scan'));
  R.Assign(4, 11, 54, 12);
  D^.Insert(New(PStaticText, Init(R, 'Call beyond program area at XXXX.')));
  R.Assign(40, 14, 52, 16);
  D^.Insert(new(PButton, Init(R, '~I~gnore', cmCancel, bfNormal)));
  R.Move(14, 0);
  D^.Insert(new(PButton, Init(R, '~A~bort', cmCancel, bfNormal)));
  {TODO}
  Desktop^.ExecView(D);*)
end;

end.
