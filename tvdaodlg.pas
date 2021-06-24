unit tvdaodlg;

interface

function EnterAddr(var A: word): boolean;

function EnterRange(var A1, A2: word): boolean;

{---------------------------------------------------------------------------}

implementation

uses Objects, Dialogs, App, FVConsts, Views,
     DAGood { Hex4 };

type
  PTvDaoEnterAddrDialog = ^TTvDaoEnterAddrDialog;
  TTvDaoEnterAddrDialog = object(TDialog)
    Edit: PInputLine;
    constructor Init(R: TRect);
  end;

  PTvDaoEnterRangeDialog = ^TTvDaoEnterRangeDialog;
  TTvDaoEnterRangeDialog = object(TDialog)
  end;

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
end;

constructor TTvDaoEnterAddrDialog.Init(R: TRect);
begin
  inherited Init(R, 'Enter Address');

  R.Assign(4, 5, 14, 7);
  Insert(New(PButton, Init(R, '~O~K', cmOK, bfDefault)));
  R.Assign(15, 5, 26, 7);
  Insert(new(PButton, Init(R, '~C~ancel', cmCancel, bfNormal)));
  R.Assign(13, 2, 20, 3);
  Edit := New(PInputLine, Init(R, 10));
  Insert(Edit);
  R.Assign(2, 2, 11, 3);
  Insert(New(PLabel, Init(R, '~A~ddress:', Edit)));
end;

function EnterAddr(var A: word): boolean;
var D: PTvDaoEnterAddrDialog; R: TRect; S: string; Res: word;
begin
  Desktop^.GetExtent(R);
  R.Assign(60, R.A.X + 1, 60 + 30, R.A.X + 9);
  D := New(PTvDaoEnterAddrDialog, Init(R));
  S := Hex4(A);
  D^.SetData(S);
  Res := Desktop^.ExecView(D);
  D^.GetData(S);
  Dispose(D, Done);
  A := ParseHex4(S);
  EnterAddr := Res = cmOK;
end;

function EnterRange(var A1, A2: word): boolean;
var D: PTvDaoEnterRangeDialog; R: TRect;
begin
  Desktop^.GetExtent(R);
  R.Assign(60, R.A.X + 1, 60 + 30, R.A.X + 20);
  D := New(PTvDaoEnterRangeDialog, Init(R, 'Enter Address Range'));
  Desktop^.ExecView(D);
  Dispose(D, Done);
end;

end.
