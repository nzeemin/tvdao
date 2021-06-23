unit tvdaoapp;

interface

uses  tvdaowin, dagood,
      Objects, Drivers, Views, Editors, Menus, Dialogs, App, FVConsts, Gadgets, MsgBox, ColorTxt;

const cmAppToolbar      = 1000;
      cmHelp            = 1001;
      cmLabel           = 1002;
      cmReloc           = 1003;
      cmData            = 1004;
      cmCode            = 1005;
      cmWord            = 1006;
      cmAddress         = 1007;
      cmDelete          = 1008;
      cmScan            = 1009;
      cmLoadWork        = 1011;
      cmSaveWork        = 1012;
      cmPrevLine        = 1013;
      cmNextLine        = 1014;
      cmCpuTypeZ80      = 1021;
      cmCpuType8080     = 1022;
      cmCpuType8085     = 1023;
      cmUndocumCommands = 1024;

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
      procedure ShowHelpBox;
      procedure ShowAboutBox;
      procedure DoSaveWorkFile;
      procedure DoLoadWorkFile;
      procedure CloseWindow(var P: PGroup);
    private
      Heap: PHeapView;
      procedure DoUndocumCommands;
    End;

implementation

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
     Case Event.Command Of
       cmSaveWork        : DoSaveWorkFile;
       cmLoadWork        : DoLoadWorkFile;
       cmHelp            : ShowHelpBox;
       cmAbout           : ShowAboutBox;
       cmCpuTypeZ80      : begin Z80 := true; RedrawWindow; end;
       cmCpuType8080     : begin Z80 := false; Type8085 := false; RedrawWindow; end;
       cmCpuType8085     : begin Z80 := false; Type8085 := true; RedrawWindow; end;
       cmUndocumCommands : DoUndocumCommands;
       Else Exit;
     end;
   end;
   ClearEvent(Event);
end;

procedure TTvDao.InitMenuBar;
const TitleWidth:integer = 18;
VAR R: TRect; PS: PStaticText;
BEGIN
   GetExtent(R);   { Get view extents }
   R.B.Y := R.A.Y + 1;  { One line high  }
   R.A.X := R.A.X + TitleWidth;
   MenuBar := New(PMenuBar, Init(R, NewMenu(
    NewSubMenu('~F~ile', 0, NewMenu(
      NewItem('~L~oad WRK file', 'Alt-W', kbAltW, cmLoadWork, hcNoContext,
      NewItem('~S~ave WRK file', 'Alt-Q', kbAltQ, cmSaveWork, hcNoContext,
      NewLine(
      NewItem('E~x~it', 'Alt-X', kbAltX, cmQuit, hcNoContext,
      nil))))),
    NewSubMenu('~N~avigation', 0, NewMenu(
      NewItem('Prev Line', 'Up', kbUp, cmPrevLine, hcNoContext,
      NewItem('Next Line', 'Down', kbDown, cmNextLine, hcNoContext,
      nil))),
    NewSubMenu('~E~dit', 0, NewMenu(
      NewItem('Global ~L~abel Here', 'F2', kbF2, cmLabel, hcNoContext,
      NewItem('~F~ind Global Label', 'F3', kbF3, cmReloc, hcNoContext,
      NewItem('Define Byte Data Area', 'F4', kbF4, cmData, hcNoContext,
      NewItem('Define ~C~ode Area', 'F5', kbF5, cmCode, hcNoContext,
      NewItem('Define Word Data Area', 'F6', kbF6, cmWord, hcNoContext,
      NewItem('Define Offset Table', 'F7', kbF7, cmData, hcNoContext,
      NewItem('Delete Label', 'F8', kbF8, cmData, hcNoContext,
      NewItem('~S~can from Here', 'F9', kbF9, cmScan, hcNoContext,
      nil))))))))),
    NewSubMenu('~O~ptions', 0, NewMenu(
      NewItem('CPU Type ~Z~80', '', kbNoKey, cmCpuTypeZ80, hcNoContext,
      NewItem('CPU Type i~8~080', '', kbNoKey, cmCpuType8080, hcNoContext,
      NewItem('CPU Type i808~5~', '', kbNoKey, cmCpuType8085, hcNoContext,
      NewItem('~U~ndocumented Commands', 'Alt-U', kbAltU, cmUndocumCommands, hcNoContext,
      nil))))),
    // NewSubMenu('~W~indow', 0, NewMenu(
    //   StdWindowMenuItems(Nil)),        { Standard window menu }
    NewSubMenu('~H~elp', hcNoContext, NewMenu(
      NewItem('~A~bout','', kbNoKey, cmAbout, hcNoContext,
      NewItem('~K~eyboard Quick Help', 'F1', kbF1, cmHelp, hcNoContext,
      nil))),
    nil))))) //end NewSubMenus
   ))); //end MenuBar

   R.A.X := 0;
   R.B.X := TitleWidth;
   PS := New(PColoredText, Init(R, '  tvDAO v.0.0', $F0));
   Insert(PS);
END;

procedure TTvDao.InitDesktop;
VAR R: TRect;
BEGIN
   GetExtent(R);  { Get app extents }
   Inc(R.A.Y);    { Adjust top down }
   Dec(R.B.Y);    { Adjust bottom up }
   Desktop := New(PDeskTop, Init(R));
END;

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
        NewStatusKey('~F2~ Label', kbF2, cmLabel,
        NewStatusKey('~F3~ Reloc', kbF3, cmReloc,
        NewStatusKey('~F4~ Data', kbF4, cmData,
        NewStatusKey('~F5~ Code', kbF5, cmCode,
        NewStatusKey('~F6~ Word', kbF6, cmWord,
        NewStatusKey('~F7~ Address', kbF7, cmAddress,
        NewStatusKey('~F8~ Delete', kbF8, cmDelete,
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

procedure TTvDao.DoUndocumCommands;
begin
  if not Z80 then begin
    UndoCode := not UndoCode;
    RedrawWindow;
    if UndoCode then ShowMessage('Using undocument code ON', $1B) else ShowMessage('Using undocument code OFF', $1B);
  end;
end;

end.
