unit tvdaowin;

interface

uses  DAGood,
      SysUtils,
      Objects, Gadgets, Views, ColorTxt, Drivers;

type
  PTvDaoInfoView = ^TTvDaoInfoView;
  TTvDaoInfoView = object(TView)
    procedure Draw; virtual;
    procedure ShowMessage(Msg: string; MsgAttrs: byte);
  private
    Message: string;
    MessageAttrs: byte;
  end;

  PTvDaoDisasmView = ^TTvDaoDisasmView;
  TTvDaoDisasmView = object(TView)
    procedure Draw; virtual;
  end;

  PTvDaoMemoryView = ^TTvDaoMemoryView;
  TTvDaoMemoryView = object(TView)
    procedure Draw; virtual;
  end;

  PTvDaoWindow = ^TTvDaoWindow;
  TTvDaoWindow = object(TWindow)
    constructor Init(R: TRect);
  private
    WD: PTvDaoDisasmView;
    WI: PTvDaoInfoView;
    WM: PTvDaoMemoryView;
    TH, BH: integer;  { Heights of top and bottom parts }
  end;

procedure ShowMessage(Msg: string; MsgAttrs: byte);
procedure ClearMessage;
procedure RedrawWindow;

{---------------------------------------------------------------------------}

implementation

const DisasmHeight: integer = 14;
const LeftPartWidth: integer = 74;  { width of left part }

var DaoWindow: PTvDaoWindow = nil;
    InfoView: PTvDaoInfoView = nil;

{---------------------------------------------------------------------------}

procedure ShowMessage(Msg: string; MsgAttrs: byte);
begin
  if InfoView = nil then exit;
  InfoView^.ShowMessage(Msg, MsgAttrs);
end;

procedure ClearMessage;
begin
  if InfoView = nil then exit;
  InfoView^.ShowMessage('', $70);
end;

procedure RedrawWindow;
begin
  if DaoWindow = nil then exit;
  DaoWindow^.Redraw;
  ClearMessage;
end;

{---------------------------------------------------------------------------}

procedure TTvDaoInfoView.ShowMessage(Msg: string; MsgAttrs: byte);
begin
  Message := Msg; MessageAttrs := MsgAttrs;
  DrawView;
end;

procedure TTvDaoInfoView.Draw;
var B: TDrawBuffer; Fmt: string; I:integer;
begin
  inherited Draw;

  MoveChar(B, #179, GetColor(1), Size.Y - 2);
  WriteLine(0, 0, 1, Size.Y, B);
  MoveChar(B, #196, GetColor(1), Size.X);
  WriteLine(1, 6, Size.X - 1, 1, B);

  MoveStr(B, 'Source file:', GetColor(1));
  WriteLine(2, 0, 12, 1, B);
  MoveStr(B, ParamStr(1), GetColor(2));
  WriteLine(19, 0, Length(ParamStr(1)), 1, B);
  MoveStr(B, 'InitAddress:', GetColor(1));
  WriteLine(2, 1, 12, 1, B);
  MoveStr(B, Hex4(PrgStart), GetColor(2));
  WriteLine(19, 1, 4, 1, B);
  MoveStr(B, 'Memory position:', GetColor(1));
  WriteLine(2, 2, 16, 1, B);
  MoveStr(B, Hex4(RealPos), GetColor(2));
  WriteLine(19, 2, 4, 1, B);

  Fmt := AsmFormat;
  MoveStr(B, 'ASM Format:', GetColor(1));
  WriteLine(2, 3, 11, 1, B);
  MoveStr(B, Fmt, GetColor(2));
  WriteLine(19, 3, Length(Fmt), 1, B);

  if Length(Message) > 0 then begin
    Fmt := '  ' + Message;
    while (Length(Fmt) < 255) and (Length(Fmt) < Size.X - 1) do
      Fmt := Fmt + ' ';
    MoveStr(B, Fmt, MessageAttrs);
    WriteLine(1, 5, Length(Fmt), 1, B);
  end;

  Fmt := 'Labels: ' + IntToStr(LabelNum);
  MoveStr(B, Fmt, GetColor(1));
  WriteLine(2, 7, Length(Fmt), 1, B);
  for I := 1 to LabelNum do begin
    Fmt := Labels^[I];
    while Length(Fmt) < 10 do Fmt := Fmt + ' ';
    MoveStr(B, Fmt, GetColor(1));
    WriteLine(4, 7 + I, Length(Fmt), 1, B);
  end;

  MoveStr(B, 'GreedCalls:', GetColor(1));
  WriteLine(19, 7, 11, 1, B);
  for I := 1 to 10 do begin
    MoveStr(B, IntToStr(I mod 10) + ': ' + Hex4(GreedCall[I]), GetColor(1));
    WriteLine(20, 7 + I, 7, 1, B);
  end;

  MoveStr(B, 'Bookmarks:', GetColor(1));
  WriteLine(19, 19, 10, 1, B);
  for I := 1 to 10 do begin
    MoveStr(B, IntToStr(I mod 10) + ': ' + Hex4(KeyReg[I]), GetColor(1));
    WriteLine(20, 19 + I, 7, 1, B);
  end;
end;

{---------------------------------------------------------------------------}

procedure TTvDaoDisasmView.Draw;
var B: TDrawBuffer; I: integer; Attr: byte; IP: word; S: string;
begin
  inherited Draw;

  IP := MemPos; PageByte := 0;
  for I := 1 to 14 do begin
    if I = LineNo then Attr := $97 else Attr := GetColor(1);
    S := DisAsm(IP);
    if IP = OriginPos then S := Chr(16) + S else S := ' ' + S;
    if (ShadowH^[IP] and $20 <> 0) and (ShadowH^[ip] shr 6 <> 0) then S[11] := #240;
    MoveStr(B, S, Attr);
    WriteLine(1, I - 1, Length(S), 1, B);
    if not LongCode then begin
      Inc(IP, ILength); Inc(PageByte, ILength);
      Adds[i] := ILength;
    end;
  end;
  LongCode := False;
end;

{---------------------------------------------------------------------------}

procedure TTvDaoMemoryView.Draw;
var B: TDrawBuffer; I,J,JH: integer; IP: word; S,SC,SH: string; C: char;
begin
  inherited Draw;

  MoveChar(B, #196, GetColor(1), Size.X);
  WriteLine(0, 0, Size.X, 1, B);

  IP := DumpPos;
  for I := 0 to Size.Y - 1 do begin
    S := Hex4(IP) + ':'; SC := ''; SH := '';
    if DumpChar then begin
      S := S + '  ';
      for J := 0 to 47 do begin
        C := Chr(PrgMem^[IP]);
        S := S + C;
	if IP = RealPos then begin SH := C; JH := J; end;
        Inc(IP);
      end;
      MoveStr(B, S, GetColor(1));
      WriteLine(1, I + 1, Length(S), 1, B);
      if Length(SH) > 0 then begin
        MoveStr(B, SH, $97);
        WriteLine(8 + JH, I + 1, 1, 1, B);
      end;
    end else begin
      for J := 0 to 15 do begin
        S := S + ' ' + Hex2(PrgMem^[IP]);
        SC := SC + Chr(PrgMem^[IP]);
	if IP = RealPos then begin SH := Hex2(PrgMem^[IP]); JH := J; end;
        Inc(IP);
      end;
      MoveStr(B, SC, GetColor(1));
      WriteLine(56, I + 1, Length(SC), 1, B);
      MoveStr(B, S, GetColor(1));
      WriteLine(1, I + 1, Length(S), 1, B);
      if Length(SH) > 0 then begin
        MoveStr(B, SH, $97);
        WriteLine(7 + JH * 3, I + 1, 2, 1, B);
      end;
    end;
  end;
end;

{---------------------------------------------------------------------------}

constructor TTvDaoWindow.Init(R: TRect);
var RC: TRect;
begin
  inherited Init(R, FileName + 'GAM / ' + FileName + 'WRK', 0);

  //Palette := wpCyanWindow;
  Flags := 0; //Flags and (not (wfClose or wfZoom or wfGrow));

  GetClipRect(RC);
  TH := DisasmHeight; //(RC.B.Y - RC.A.Y - 2) div 3 * 2;
  BH := (RC.B.Y - RC.A.Y - 2) - TH;

  { Left top part, disassembly }
  R.Assign(RC.A.X + 1, RC.A.Y + 1, RC.A.X + LeftPartWidth, RC.A.Y + TH + 1);
  WD := New(PTvDaoDisasmView, Init(R));
  Insert(WD);

  R.Assign(RC.A.X + LeftPartWidth + 1, RC.A.Y + 1, RC.B.X - 1, RC.B.Y - 1);
  WI := New(PTvDaoInfoView, Init(R));
  Insert(WI);

  { Left bottom part, memory view }
  R.Assign(RC.A.X + LeftPartWidth, RC.B.Y - 1 - BH, RC.A.X + 1 + LeftPartWidth, RC.B.Y - 1);
  R.Assign(RC.A.X + 1, RC.B.Y - 1 - BH, RC.A.X + LeftPartWidth + 1, RC.B.Y - 1);
  WM := New(PTvDaoMemoryView, Init(R));
  Insert(WM);

  DaoWindow := @Self;
  InfoView := WI;
end;

end.
