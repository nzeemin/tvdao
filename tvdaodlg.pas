unit tvdaodlg;

interface

function EnterAddr(var A: word): boolean;

function EnterRange(var A1, A2: word; Prompt: string): boolean;

function EnterLabel(var L: string): boolean;

{---------------------------------------------------------------------------}

implementation

uses Objects, Dialogs, App, FVConsts, Views, Drivers,
     DAGood { Hex4 };

type
  PHex4InputLine = ^THex4InputLine;
  THex4InputLine = object(TInputLine)
    constructor Init(R: TRect);
    function DataSize: dword; virtual;
    procedure GetData(var Rec); virtual;
    procedure SetData(var Rec); virtual;
    procedure HandleEvent(Var Event: TEvent); virtual;
  end;

  PTvDaoEnterAddrDialog = ^TTvDaoEnterAddrDialog;
  TTvDaoEnterAddrDialog = object(TDialog)
    Edit: PHex4InputLine;
    constructor Init(R: TRect);
  end;

  PTvDaoEnterRangeDialog = ^TTvDaoEnterRangeDialog;
  TTvDaoEnterRangeDialog = object(TDialog)
    EditFrom,EditTo,EditLen: PHex4InputLine;
    constructor Init(R: TRect; Prompt: string);
  end;

  TEnterRangeData = record
    A1, A2, A3: word;
  end;

  PTvDaoEnterLabelDialog = ^TTvDaoEnterLabelDialog;
  TTvDaoEnterLabelDialog = object(TDialog)
    Edit: PInputLine;
    constructor Init(R: TRect);
  end;

{---------------------------------------------------------------------------}

function ParseHex4(S: string): word;
var Res: word; I: integer; C: char;
begin
  Res := 0;
  for I := 1 to Length(S) - 1 do begin
    Res := Res shl 4;
    C := S[I];
    if (C >= '0') and (C <= '9') then Res := Res + (Ord(C) - 48)
    else if (C >= 'A') and (C <= 'F') then Res := Res + Word(Ord(C) - 65 + 10)
    else if (C >= 'a') and (C <= 'f') then Res := Res + Word(Ord(C) - 97 + 10);
  end;
  ParseHex4 := Res;
end;

{---------------------------------------------------------------------------}

constructor THex4InputLine.Init(R: TRect);
begin
  inherited Init(R, 4);
end;

function THex4InputLine.DataSize: dword;
begin
  DataSize := SizeOf(Word);
end;

procedure THex4InputLine.GetData(var Rec);
begin
  word(Rec) := ParseHex4(Data^);
end;

procedure THex4InputLine.SetData(var Rec);
begin
  Data^ := Hex4(word(Rec));
end;

procedure THex4InputLine.HandleEvent(Var Event: TEvent);
begin
  if Event.What = evKeyDown then begin
    { Filter out unwanted symbols, except for 0..9, a..f, A..F }
    if  (Event.CharCode >= ' ') and (Event.CharCode <= '/') or
        (Event.CharCode >= ':') and (Event.CharCode <= '@') or
        (Event.CharCode >= 'g') and (Event.CharCode <= '~') or
        (Event.CharCode >= 'G') and (Event.CharCode <= '`') then begin
      ClearEvent(Event);
      exit;
    end;
  end;
  inherited HandleEvent(Event);
end;

{---------------------------------------------------------------------------}

constructor TTvDaoEnterAddrDialog.Init(R: TRect);
begin
  inherited Init(R, 'Enter Address');

  R.Assign(4, 5, 14, 7);
  Insert(New(PButton, Init(R, '~O~K', cmOK, bfDefault)));
  R.Assign(15, 5, 26, 7);
  Insert(new(PButton, Init(R, '~C~ancel', cmCancel, bfNormal)));
  R.Assign(15, 2, 22, 3);
  Edit := New(PHex4InputLine, Init(R));
  Insert(Edit);
  R.Assign(3, 2, 12, 3);
  Insert(New(PLabel, Init(R, '~A~ddress:', Edit)));
end;

{---------------------------------------------------------------------------}

constructor TTvDaoEnterRangeDialog.Init(R: TRect; Prompt: string);
begin
  inherited Init(R, 'Enter Range');

  R.Assign(4, 2, 25, 3);
  Insert(New(PStaticText, Init(R, Prompt)));

  R.Assign(4, 7, 14, 9);
  Insert(New(PButton, Init(R, '~O~K', cmOK, bfDefault)));
  R.Assign(15, 7, 26, 9);
  Insert(new(PButton, Init(R, '~C~ancel', cmCancel, bfNormal)));
  R.Assign(15, 3, 22, 4);
  EditFrom := New(PHex4InputLine, Init(R));
  Insert(EditFrom);
  R.Assign(3, 3, 12, 4);
  Insert(New(PLabel, Init(R, '~F~rom:', EditFrom)));
  R.Assign(15, 4, 22, 5);
  EditTo := New(PHex4InputLine, Init(R));
  Insert(EditTo);
  R.Assign(3, 4, 12, 5);
  Insert(New(PLabel, Init(R, '~T~o:', EditTo)));
  R.Assign(15, 5, 22, 6);
  EditLen := New(PHex4InputLine, Init(R));
  Insert(EditLen);
  R.Assign(3, 5, 12, 6);
  Insert(New(PLabel, Init(R, '~L~ength:', EditLen)));
end;

{---------------------------------------------------------------------------}

constructor TTvDaoEnterLabelDialog.Init(R: TRect);
begin
  inherited Init(R, 'Enter Label');

  R.Assign(4, 5, 14, 7);
  Insert(New(PButton, Init(R, '~O~K', cmOK, bfDefault)));
  R.Assign(15, 5, 26, 7);
  Insert(new(PButton, Init(R, '~C~ancel', cmCancel, bfNormal)));
  R.Assign(15, 2, 26, 3);
  Edit := New(PInputLine, Init(R, 8));
  Insert(Edit);
  R.Assign(3, 2, 12, 3);
  Insert(New(PLabel, Init(R, '~L~abel:', Edit)));
end;

{---------------------------------------------------------------------------}

function EnterAddr(var A: word): boolean;
var D: PTvDaoEnterAddrDialog; R: TRect; Data: word; Res: word;
begin
  Desktop^.GetExtent(R);
  R.Assign(60, R.A.X + 1, 60 + 30, R.A.X + 9);
  D := New(PTvDaoEnterAddrDialog, Init(R));
  Data := A;
  D^.SetData(Data);
  Res := Desktop^.ExecView(D);
  D^.GetData(Data);
  Dispose(D, Done);
  A := Data;
  EnterAddr := Res = cmOK;
end;

function EnterRange(var A1, A2: word; Prompt: string): boolean;
var D: PTvDaoEnterRangeDialog; R: TRect; Data: TEnterRangeData; Res: word;
begin
  Desktop^.GetExtent(R);
  R.Assign(60, R.A.X + 1, 60 + 30, R.A.X + 11);
  D := New(PTvDaoEnterRangeDialog, Init(R, Prompt));
  Data.A1 := A1;
  Data.A2 := A2;
  Data.A3 := A2 - A1 + 1;
  D^.SetData(Data);
  Res := Desktop^.ExecView(D);
  D^.GetData(Data);
  Dispose(D, Done);
  A1 := Data.A1;
  A2 := Data.A2;
  EnterRange := Res = cmOK;
end;

function EnterLabel(var L: string): boolean;
var D: PTvDaoEnterLabelDialog; R: TRect; Data: string; Res: word;
begin
  Desktop^.GetExtent(R);
  R.Assign(60, R.A.X + 1, 60 + 30, R.A.X + 9);
  D := New(PTvDaoEnterLabelDialog, Init(R));
  Data := L;
  D^.SetData(Data);
  Res := Desktop^.ExecView(D);
  D^.GetData(Data);
  Dispose(D, Done);
  L := Data;
  EnterLabel := Res = cmOK;
end;

end.
