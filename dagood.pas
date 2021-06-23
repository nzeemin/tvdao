{$I-}
unit DAGood;

interface uses DAtable;

const
  Version   : string[8]='v(1.12) ';{TODO}

  ParamS    : string[14]=('/*#?&%~^@!|"`');  { - must be last}
  HexChar   : string[16]=('0123456789ABCDEF');
  IndexName : array[1..2] of string[2]=('IX','IY');
  IndexVar  : array[1..2] of string[8]=('(IX|)','(IY|)');
{  IndexName8: array[1..2] of string[2]=('di','si');}
  IndexVar8 : array[1..2] of string[8]=('[di|]','[si|]');
  SegName   : array[0..1] of string[2]=('ds','cs');
  DAAval    : array[0..1] of string[3]=('daa','das');
  Z80SName  : array[0..1] of string[1]=('','>');
  WrkHeader : string[16]='DA_WorkFile V1.0';
  Format    : array[False..True] of string[5]=('8080 ','Z80  ');
  TabSize   : byte = 10;
  InterSize : byte = 4;
  RealDataLoc: boolean = False;
  Type8085   : boolean = False;
  UndoCode   : boolean = False;
  DataBlock  : boolean = False;
  LabelShow  : boolean = False;
  RemEnable  : boolean = True;
  RemLast    : boolean = False;
  SizeDB    = 4;

  MaxLabels = 1000;
  MaxBlocks = 8;

  BCode     = 1;
  BData     = 2;

  LCode     = 1;
  LData     = 2;
  LTable    = 3;

  BIOSenabled    : boolean = True;
  BIOShigh       : word    = $159;

  MaxFol         = 10;

type
 LabelType   = string[8];
  ByteArray  = array[0..65535-1] of byte;
 PByteArray  = ^ByteArray;
  LabelArray = array[1..MaxLabels] of LabelType;
 PLabelArray = ^LabelArray;

var
 FileName                   : string; {TODO: rename}
 FileLength                 : longint;

 PrgMem, ShadowH, ShadowL   : PByteArray;
 Labels                     : PLabelArray;

 PrgType, PrgStart,
 PrgBegin, PrgLength,
 PrgData                    : word;
 PLow, PHigh                : word;

 LabelNum, TinyLabels       : word;
 MemPos, DumpPos, RealPos,
 OriginPos, CallerPos       : word;
 LineNo                     : integer;

 GreedCall                  : array[1..10] of word;
 DumpChar                   : boolean;

 ProcQ                      : array[1..1000] of word;
 Proc                       : array[1..5000] of word;
 ProcNum, TotalProcs        : integer;

 Follow                     : array[1..MaxFol] of word;
 FolNum                     : byte;

 FindString, FControl       : string;
 FindPos                    : word;

 KeyReg                     : array[1..10] of word;
 Z80                        : boolean;
 FirstZ80                   : boolean;
 LongCode                   : boolean;
 Remark                     : boolean;
 RemarkDec                  : boolean;
 RemarkEnable               : boolean;
 CharDec                    : byte;

 PageByte                   : word;
 Adds                       : array[1..14] of word;

 ILength                    : byte;
 IndexNo, SegmentNo         : byte;
 IndexOfs                   : shortint;
 LabelNo                    : integer;

 CurHeader                  : string[16];
 ErrorLine                  : byte;
 OldDump, sadr              : word;
 DAttr                      : boolean;

 IPtr                       : word;

 ldw                        : boolean; { Flag indicating we have the .WRK file and need to load it }

 LongCodeS                  : String;

 ErrorMessage: string;
 ErrorAttrs: byte;

function Hex2(b:byte):string;
function Hex4(w:word):string;

function AsmFormat: string;

procedure DAGoodInit;
procedure SaveEnvir;
procedure LoadEnvir;
function DisAsmZ80(addr:word):string;
function DisAsm8088(addr:word):string;


implementation

var
 push1                      : byte;
 push2                      : byte;
 push3                      : byte;
 push4                      : byte;
 f                          : file;
 t                          : text;
 a                          : char;

function ReadKey: char; {STUB for Crt}
begin end;
function KeyPressed: boolean; {STUB for Crt}
begin end;
procedure GotoXY(X: integer; Y: integer); {STUB for Crt}
begin end;
function WhereX: integer; {STUB for Crt}
begin end;
function WhereY: integer; {STUB for Crt}
begin end;

procedure SetError(Msg: string; Attrs: byte);
begin
  ErrorMessage := Msg;
  ErrorAttrs := Attrs;
end;

function Hex2(b:byte):string;
begin
 Hex2:=HexChar[b shr 4+1]+HexChar[b and $F+1]
end;

function Hex4(w:word):string;
begin
 Hex4:=HexChar[w shr 12+1]+HexChar[(w shr 8) and $F+1]+
       HexChar[(w shr 4) and $F+1]+HexChar[w and $F+1];
end;

function DataByte(b:byte):string;
begin
 DataByte:='0'+HexChar[b shr 4+1]+HexChar[b and $F+1]+'h';
end;

function Index(b:shortint):string;
var sgn:char; bb:byte;
begin
 if b<0 then begin bb:=-b; sgn:='-' end else begin bb:=b;sgn:='+';end;
 Index:=Sgn+'0'+HexChar[bb shr 4+1]+HexChar[bb and $F+1]+'h';
end;

function DataWord(w:word):string;
begin
 DataWord:='0'+HexChar[w shr 12+1]+HexChar[(w shr 8) and $F+1]+
               HexChar[(w shr 4) and $F+1]+HexChar[w and $F+1]+'h';
end;

function SStr(w:word;d:byte):string;
var s:string;
begin
 Str(w:d,s);
 SStr:=s;
end;

function Strg(ch : char; Num : byte) : string;
var a : String;
begin
 a[0] := char(num);
 fillchar(a[1],num,ch);
 Strg := a;
end;

function GetByte(addr:word):string;
var b:byte;
begin
 b:=PrgMem^[addr];
 GetByte:='0'+HexChar[b shr 4+1]+HexChar[b and $F+1]+'h';
end;

function GetWord(addr:word):string;
var w:word;
begin
 w:=PrgMem^[addr+1] shl 8+PrgMem^[addr];
 GetWord:='0'+HexChar[w shr 12+1]+HexChar[(w shr 8) and $F+1]+
              HexChar[(w shr 4) and $F+1]+HexChar[w and $F+1]+'h';
end;

function GetHex4(addr:word):string;
var w:word;
begin
 w:=PrgMem^[addr+1] shl 8+PrgMem^[addr];
 GetHex4:=HexChar[w shr 12+1]+HexChar[(w shr 8) and $F+1]+
        HexChar[(w shr 4) and $F+1]+HexChar[w and $F+1];
end;

procedure WriteTo(s:string;x,y,attr:byte);
begin
{TODO: Remove}
end;

function Space(l:byte):string;
var i:byte; s:string;
begin
 s:='';for i:=1 to l do s:=s+' ';Space:=s
end;

function Strng(l:byte;ch:char):string;
var i:byte; s:string;
begin
 s:='';for i:=1 to l do s:=s+ch;Strng:=s
end;

procedure Suck(var s:string);
var i:integer;
begin
 i:=1; while i<=Length(s) do if s[i]=' ' then Delete(s, i, 1) else Inc(i);
end;

procedure Replace(var Dest:string;Source:string;p:byte);
begin
 Delete(Dest,p,1); Insert(Source, Dest, p);
end;

function LabelExist(addr:word):boolean;
var w:word;
begin
 LabelExist:=True;
{ if ShadowH^[addr] and $10>0 then begin LabelNo:=0; Exit end;}
 w:=(ShadowH^[addr] and $7) shl 8+ShadowL^[addr];
 if w>0 then begin LabelNo:=w end else LabelExist:=False;
end;

{========================== „¨§ áá¥¬¡«¥à z80 ==========================}
function DisAsmZ80(addr:word):string;
var dt,lb:byte; LNo, ad:word; r:boolean;
function Instruction:string;
var s:string;c,p:byte;
begin
 IndexNo:=0; IndexOfs:=0;
 s:=Instr[PrgMem^[iptr]];
 SegmentNo:=(ShadowH^[iptr] shr 5) and 1;
 repeat
  for c:=1 to Length(ParamS) do
   begin
    p:=Pos(Params[c], s);
    if p>0 then break;
   end;
  if c=Length(ParamS) then c:=0;
  if c>0 then
  case ParamS[c] of
   '/' : Replace(s,Space(InterSize-p+3), p);
   '*' : begin
          Inc(ILength,2);
          case ShadowH^[iptr+1] shr 6 of
           00, 01, 02 : Replace(s, GetWord(iptr+1), p);
           03 : begin
                 ad:=PrgMem^[iptr+1]+PrgMem^[iptr+2] shl 8;
                 r:=False;
                 if (ad>=PLow) and (ad<=PHigh) then
                    if LabelExist(ad)
                       then begin Replace(s, {'offset '+}Labels^[LabelNo], p); r:=true; end;
                 if not r then Replace(s, {'offset L'}'L'+Hex4(ad), p);
                end;
          end;
         end;
   '#' : begin
          Inc(ILength, 1);
          if IndexNo>0 then Inc(iptr);
          Replace(s, GetByte(iptr+1), p);
         end;
   '&' : begin
          ad:=PrgMem^[iptr+1]+PrgMem^[iptr+2] shl 8;
          r:=False;
          if (ad>=PLow) and (ad<=PHigh) then
             if LabelExist(ad)
                then begin Replace(s, Labels^[LabelNo], p); r:=true; end;
          if not r then Replace(s, 'L'+Hex4(ad), p);
          Inc(ILength, 2);
         end;
   '?' : begin
          ad:=iptr+shortint(PrgMem^[iptr+1])+2;
          Inc(ILength, 1);
          r:=False;
          if (ad>=PLow) and (ad<=PHigh) then
               if LabelExist(ad)
                  then begin Replace(s, Labels^[LabelNo], p); r:=true; end;
          if not r then Replace(s, 'L'+Hex4(ad), p);
         end;
   '%' : begin
          ad:=PrgMem^[iptr+1]+PrgMem^[iptr+2] shl 8;
          Inc(ILength, 2);
          r:=False;
          if (ad>=PLow) and (ad<=PHigh) then
               if LabelExist(ad)
                  then begin Replace(s, Labels^[LabelNo], p); r:=true; end;
          if not r and (ad>=PrgData) then begin Replace(s, DataWord(ad), p);r:=true end;
          if not r then Replace(s, Hex4(ad), p);
         end;
   '~' : if IndexNo>0 then
          begin
           Replace(s,IndexVar[IndexNo],p);
           Inc(ILength);
          end else Replace(s, '(HL)', p);
   '"' : Replace(s, Z80SName[SegmentNo],p);
   '|' : begin
          Replace(s,Index(IndexOfs),p);
         end;
   '^' : if IndexNo>0 then
          begin
           Replace(s, IndexName[IndexNo], p);
          end else Replace(s, 'HL', p);
   '!' : Replace(s, 'Bad opcode', p);
   '@' : begin
          Inc(ILength);Inc(iptr);
          case s[p+1] of
     {CB}  '0' : if IndexNo>0 then
                   begin
                    {Inc(iptr);
                    Inc(ILength);}
                    s:=InstrCB[PrgMem^[iptr+1]]
                   end else s:=InstrCB[PrgMem^[iptr]];
     {ED}  '1' : s:=InstrED[PrgMem^[iptr]];
     {DD}  '2' : begin {IX}
                  IndexNo:=1;
                  s:=Instr[PrgMem^[iptr]];
                  IndexOfs:=shortint(PrgMem^[iptr+1]);
                 end;
     {FD}  '3' : begin {IX}
                  IndexNo:=2;
                  s:=Instr[PrgMem^[iptr]];
                  IndexOfs:=shortint(PrgMem^[iptr+1]);
                 end;
          end;
         end;
  end;
{  if Keypressed then a:=ReadKey;}
 until (a=#27) or (p=0);
 Instruction:=s;
end;

function ByteBlock:string;
var s:string;Done:boolean;i:byte;w,l:word;
begin
 Done:=False;w:=iptr;s:='';i:=0;
 repeat
  s:=s+DataByte(PrgMem^[w]); Inc(w); Inc(i);
  l:=ShadowH^[w] shl 8+ShadowL^[w];
  if (ShadowH^[w]<>$40) or (l and $3FFF>$0) or (i>3) or (DataBlock) then Done:=True else if i<4 then s:=s+',';
  if not Done then Inc(ILength);
 until Done;
 ByteBlock:='.db'+Space(InterSize)+s;
end;

function WordBlock:string;
begin
 Inc(ILength);
 WordBlock:='.dw'+Space(InterSize)+DataWord(PrgMem^[iptr]+PrgMem^[iptr+1] shl 8);
end;

function Address:string;
begin
 Inc(ILength);
 ad:=PrgMem^[iptr]+PrgMem^[iptr+1] shl 8;
 if (ad>=PLow) and (ad<=PHigh) then
    if LabelExist(ad)
       then begin Address:='.dw'+Space(InterSize)+{'offset '+}Labels^[LabelNo]; Exit end;
 Address:='.dw'+Space(InterSize)+{'offset }'L'+Hex4(ad);
end;
var s:string;
begin
 if Remark then begin
  DisAsmZ80:=Instruction;
  exit;
 end;
 LongCode:=false;
 iptr:=addr;
 ILength:=1;
 LNo:=(ShadowH^[iptr] and $7) shl 8+ShadowL^[iptr];
 dt:=ShadowH^[iptr] shr 6;{only 2 high bits}
 lb:=(ShadowH^[iptr] shr 4) and $3;
 case dt of
  00 : s:=Instruction;
  01 : s:=ByteBlock;
  02 : s:=WordBlock;
  03 : s:=Address;
 end;
 if LNo>0 then s:=Labels^[LNo]+':'+Space(TabSize-Length(Labels^[LNo])-1)+s
          else if ShadowH^[addr] and $10>0
                  then s:='L'+Hex4(addr)+':'+Space(TabSize-6)+s
                  else s:=Space(TabSize)+s;
 while Length(s)<46 do s:=s+' ';
 DisAsmZ80:=s;
end;

{========================= „¨§ áá¥¬¡«¥à i8080 =========================}
function DisAsm8088(addr:word):string;
var dt,lb:byte; LNo, ad:word; r:boolean;
iptrPM: word;
function Instruction:string;
var s:string;c,p:byte;
ss : string;
LenCodeS :byte;
procedure LongCodeWork;
var c:byte;
begin
  LongCode:=true;
  s:=''; LenCodeS:=Length(LongCodeS);
  for c:=1 to LenCodeS do begin
    ss:=Copy(LongCodeS,c,1);
    if ss='\' then begin
      LongCodeS:=Copy(LongCodeS,c+1,LenCodeS-c);
      break;
    end else s:=s+ss;
  end;
  if c=LenCodeS then begin
    LongCode:=false;
  end;
end;
begin
 if LongCode then LongCodeWork else begin
                                     IndexNo:=0; IndexOfs:=0;
                                     s:=Instr8088[PrgMem^[iptr]];
                                    end;
 SegmentNo:=(ShadowH^[iptr] shr 5) and 1;
 repeat
  for c:=1 to Length(ParamS) do
   begin
    p:=Pos(Params[c], s);
    if p>0 then break;
   end;
  if c=Length(ParamS) then c:=0;
  if c>0 then
  case ParamS[c] of
   '/' : Replace(s,Space(InterSize-p+3), p);
   '*' : begin
          Inc(ILength,2);
          case ShadowH^[iptr+1] shr 6 of
           00, 01, 02 : Replace(s, GetWord(iptr+1), p);
           03 : begin
                 ad:=PrgMem^[iptr+1]+PrgMem^[iptr+2] shl 8;
                 r:=False;
                 if (ad>=PLow) and (ad<=PHigh) then
                    if LabelExist(ad)
                       then begin Replace(s, {'offset '+}Labels^[LabelNo], p); r:=true; end;
                 if not r then Replace(s, {'offset L'}'L'+Hex4(ad), p);
                end;
          end;
         end;
   '#' : begin
          Inc(ILength, 1);
          Replace(s, GetByte(iptr+1), p);
          if IndexNo>0 then Inc(iptr);
         end;
   '&' : begin
          ad:=PrgMem^[iptr+1]+PrgMem^[iptr+2] shl 8;
          r:=False;
          if (ad>=PLow) and (ad<=PHigh) then
             if LabelExist(ad)
                then begin Replace(s, Labels^[LabelNo], p); r:=true; end;
          if not r then Replace(s, 'L'+Hex4(ad), p);
          Inc(ILength, 2);
         end;
   '?' : begin
          ad:=iptr+shortint(PrgMem^[iptr+1])+2;
          Inc(ILength, 1);
          r:=False;
          if (ad>=PLow) and (ad<=PHigh) then
               if LabelExist(ad)
                  then begin Replace(s, Labels^[LabelNo], p); r:=true; end;
          if not r then Replace(s, 'L'+Hex4(ad), p);
         end;
   '%' : begin
          ad:=PrgMem^[iptr+1]+PrgMem^[iptr+2] shl 8;
          Inc(ILength, 2);
          r:=False;
          if (ad>=PLow) and (ad<=PHigh) then
               if LabelExist(ad)
                  then begin Replace(s, Labels^[LabelNo], p); r:=true; end;
          if not r and ((ad>PrgBegin+PrgLength) or (ad<PrgBegin)) then begin Replace(s, DataWord(ad), p);r:=true end;
          if not r then
             if (PrgMem^[iptr] in [$3A,$32])
               then begin Insert('byte ptr ',s,p-3); Replace(s, 'L'+Hex4(ad), p+9); end
               else begin Insert('word ptr ',s,p-3); Replace(s, 'L'+Hex4(ad), p+9); end;
         end;
   '~' : if IndexNo>0 then
          begin
           Replace(s,IndexVar8[IndexNo],p);
           Inc(ILength);
          end{ else Replace(s, '[bx]', p)};
   '"' : Replace(s, SegName[SegmentNo],p);
   '`' : Replace(s, DAAval[SegmentNo],p);
   '|' : begin
          Replace(s,Index(IndexOfs),p);
         end;
   '^' : if IndexNo>0 then
          begin
           Replace(s, IndexName[IndexNo], p);
          end {else Replace(s, 'bx', p)};
   '!' : if FirstZ80 then begin
           Remark:=RemEnable;
           RemarkDec:=false;
           case PrgMem^[iptr] of
{EXXA}       $08 : begin
                     LongCodeS:='push/h\push/psw\lhld/AF\xthl\shld/AF\pop/psw\pop/h';
                     LongCodeWork;
                   end;
{DJNZ}       $10 : begin
                     LongCodeS:='push/psw\dcr/b\jz/$+7\pop/psw\jmp/?\pop/psw';
                     LongCodeWork;
                   end;
             $18 : s:='jmp/?';
             $20 : s:='jnz/?';
             $28 : s:='jz/?';
             $30 : s:='jnc/?';
             $38 : s:='jc/?';
             $CB : begin
                     RemarkDec:=true;
                     Inc(ILength); Inc(iptr);
                     if IndexNo>0 then s:=InstrCB8088[PrgMem^[iptr+1]]
                     else s:=InstrCB8088[PrgMem^[iptr]];
                     LongCodeS:=s; LongCodeWork;
                   end;
{EXX}        $D9 : begin
                     LongCodeS:='push/h\lhld/DE\xchg\shld/DE\push/b\lhld/BC\xthl\shld/BC\pop/B\lhld/HL\xthl\shld/HL\pop/h';
                     LongCodeWork;
                   end;
             $ED : begin
                     RemarkDec:=true;
                     Inc(ILength); Inc(iptr);
                     iptrPM:=PrgMem^[iptr];
                     if iptrPM<$40 then s:='nop/nop' else
                     if iptrPM<$80 then s:=InstrED8088_2[iptrPM-$40] else
                     if iptrPM<$A0 then s:='nop/nop' else
                     if iptrPM<$BC then s:=InstrED8088_4[iptrPM-$A0] else
                                        s:='nop/nop';
                     LongCodeS:=s; LongCodeWork;
                   end;
             $DD : begin
                     RemarkDec:=true;
                     Inc(ILength); Inc(iptr); IndexNo:=1;
                     iptrPM:=PrgMem^[iptr];
                     if iptrPM<$40 then s:=InstrDD8088_1[iptrPM] else
                     if iptrPM<$80 then s:=InstrDD8088_2[iptrPM-$40] else
                     if iptrPM<$C0 then s:=InstrDD8088_3[iptrPM-$80] else
                     if iptrPM<$FA then s:=InstrDD8088_4[iptrPM-$C0] else
                                        s:='!';
                     IndexOfs:=shortint(PrgMem^[iptr+1]);
                     LongCodeS:=s; LongCodeWork;
                   end;
             $FD : begin
                     RemarkDec:=true;
                     Inc(ILength); Inc(iptr); IndexNo:=2;
                     iptrPM:=PrgMem^[iptr];
                     if iptrPM<$40 then s:=InstrDD8088_1[iptrPM] else
                     if iptrPM<$80 then s:=InstrDD8088_2[iptrPM-$40] else
                     if iptrPM<$C0 then s:=InstrDD8088_3[iptrPM-$80] else
                     if iptrPM<$FA then s:=InstrDD8088_4[iptrPM-$C0] else
                                        s:='!';
                     IndexOfs:=shortint(PrgMem^[iptr+1]);
                     LongCodeS:=s; LongCodeWork;
                   end
           else
             Replace(s, '.db'+Space(InterSize)+GetByte(iptr)+Space(InterSize)+'; Bad opcode', p)
           end
         end
         else begin
           if UndoCode then if PrgMem^[iptr] in [$08,$10,$18,$20,$28,$30,$38] then s:='nop' else
                            if PrgMem^[iptr]=$CB then s:='jmp/&' else
                            if PrgMem^[iptr]=$D9 then s:='ret' else
                            if PrgMem^[iptr] in [$DD,$ED,$FD] then s:='call/&';
           if Type8085 then if PrgMem^[iptr]=$20 then s:='rim' else
                            if PrgMem^[iptr]=$30 then s:='sim';
           if s='!' then Replace(s, '.db'+Space(InterSize)+GetByte(iptr)+Space(InterSize)+'; Bad opcode', p);
         end;
  end;
{  if KeyPressed then a:=ReadKey;}
 until (a=#27) or (p=0);
 Instruction:=s;
end;
function ByteBlock:string;
var s:string;Done:boolean;i:byte;w,l:word;
begin
 Done:=False;w:=iptr;s:='';i:=0;
 repeat
  s:=s+DataByte(PrgMem^[w]); Inc(w); Inc(i);
  l:=ShadowH^[w] shl 8+ShadowL^[w];
  if (ShadowH^[w]<>$40) or (l and $3FFF>$0) or (i>SizeDB-1) or (DataBlock) then Done:=True else if i<SizeDB then s:=s+',';
  if not Done then Inc(ILength);
 until Done;
 ByteBlock:='.db'+Space(InterSize)+s;
end;
function WordBlock:string;
begin
 Inc(ILength);
 WordBlock:='.dw'+Space(InterSize)+DataWord(PrgMem^[iptr]+PrgMem^[iptr+1] shl 8);
end;
function Address:string;
begin
 Inc(ILength);
 ad:=PrgMem^[iptr]+PrgMem^[iptr+1] shl 8;
 if (ad>=PLow) and (ad<=PHigh) then
    if LabelExist(ad)
       then begin Address:='.dw'+Space(InterSize)+{'offset '+}Labels^[LabelNo]; Exit end;
 Address:='.dw'+Space(InterSize)+{'offset }'L'+Hex4(ad);
end;
var s:string;
begin
 if not LongCode then begin
  iptr:=addr;
  ILength:=1;
  LabelShow:=true;
 end else LabelShow:=false;
  LNo:=(ShadowH^[addr] and $7) shl 8+ShadowL^[addr];
  dt:=ShadowH^[addr] shr 6;{only 2 high bits}
  lb:=(ShadowH^[addr] shr 4) and $3;
 case dt of
  00 : s:=Instruction;
  01 : s:=ByteBlock;
  02 : s:=WordBlock;
  03 : s:=Address;
 end;
 if LNo>0 then s:=Labels^[LNo]+':'+Space(TabSize-Length(Labels^[LNo])-1)+s
          else if (ShadowH^[addr] and $10>0) and LabelShow
                  then s:='L'+Hex4(addr)+':'+Space(TabSize-6)+s
                  else s:=Space(TabSize)+s;
 while Length(s)<26 do s:=s+' ';
 if Remark then begin
  push1:=ILength;
  push2:=IndexNo;
  push3:=IndexOfs;
  push4:=SegmentNo;
{  push5:=iptr;}
  if RemarkDec then Dec(iptr);
  s:=s+'; '+DisasmZ80(iptr);
  Remark:=false;
{  iptr:=push5;}
  SegmentNo:=push4;
  IndexOfs:=push3;
  IndexNo:=push2;
  ILength:=push1;
 end
 else if (RemEnable) and (RemLast) then s:=s+'; ';
 RemLast:=LongCode;
 while Length(s)<46 do s:=s+' ';
 DisAsm8088:=s;
end;

procedure SetTinyLabel(addr:word);{1-code, 2-data, 3-table }
var l:word;
begin
 if (addr<PLow) or (addr>PHigh) then Exit;
 l:=ShadowH^[addr] shr 8+ShadowL^[addr];
 if l and $1FFF=0 then
     begin
      ShadowH^[addr]:=ShadowH^[addr] or $10;
      Inc(TinyLabels);
      WriteTo('Tiny  labels :  '+Hex4(TinyLabels),58,18,$30);
     end;
end;

procedure ScanProc(addr:word);
var ip,w:word;Done:boolean;b,st:byte;IL,l:byte;i:integer;

procedure AddNewProc(addr:word);
var i:integer;
begin
 if BIOSenabled and (addr<=BIOShigh) then Exit;
 if (addr<PrgBegin) or (addr>PrgBegin+PrgLength) then
    begin
     WriteTo('Call beyond program area: '+Hex4(addr),49,6,$1F);
     WriteTo('at '+Hex4(ip)+': (A)bort or (I)gnore? ',49,7,$1F);
     repeat
      case upCase(readkey) of
       'A' : halt(2000);
       'I' : begin
              WriteTo(Strg(' ',30),49,6,$30);
              WriteTo(Strg(' ',30),49,7,$30);
              Exit;
             end;
      end;
     until false;
    end;

 for i:=1 to TotalProcs+1 do
  if (i<=TotalProcs) and (Proc[i]=addr) then
       begin
        break
       end;
 if i>TotalProcs then
   begin
    Inc(TotalProcs); Proc[TotalProcs]:=addr;
    Inc(ProcNum);    ProcQ[ProcNum]:=addr;
      WriteTo('Entry points :  '+Hex4(TotalProcs),58,17,$30);
   end;
end;

begin
 Done:=False;
 ip:=addr;
 repeat
  b:=Stat[PrgMem^[ip]]; IL:=1;
  ShadowH^[ip]:=ShadowH^[ip] and $3F;
  st:=b shr 4;  l:=b and 7;
  Inc(IL, l);
  case st of
    0 : {ordinary command};
    3 : {(HL)-oriented command};
    1,2,10 :
        begin {Load reg16, data }
         w:=PrgMem^[ip+1]+PrgMem^[ip+2] shl 8;
         if (w>=PLow) and (w<=PHigh) then
           begin
            SetTinyLabel(w);
            ShadowH^[ip+1]:=ShadowH^[ip+1] or $C0;
            ShadowH^[ip+2]:=ShadowH^[ip+2] or $C0;
           end;
        end;
    5 : begin {CB prefix}
         Inc(IL);
        end;
    6 : begin {ED prefix}
         Inc(ip);
         b:=StatED[PrgMem^[ip]];
         Inc(IL, b and 7);
        end;
    7,8 : begin {DD,FD-prefix}
           if PrgMem^[ip+1]=$CB then
             begin
              ShadowH^[ip+1]:=ShadowH^[ip+1] and $3F;
              inc(IL,3);
             end   else
             if Stat[PrgMem^[ip+1]] and $F0=$30 then
               begin
                Inc(IL,Stat[PrgMem^[ip+1]] and $7);
                Inc(IL,2);
               end;
          end;
   11 : begin {JR}
         w:=ip+shortint(PrgMem^[ip+1])+2;
         SetTinyLabel(w);
         AddNewProc(w);
         Done:=True;
        end;
   12 : begin {JR conditional}
         w:=ip+shortint(PrgMem^[ip+1])+2;
         SetTinyLabel(w);
         AddNewProc(w);
        end;
    9 : begin {JP}
         w:=PrgMem^[ip+1]+PrgMem^[ip+2] shl 8;
         SetTinyLabel(w);
         AddNewProc(w);
         Done:=True;
        end;
   14 : begin {call}
         w:=PrgMem^[ip+1]+PrgMem^[ip+2] shl 8;
          for i:=1 to 10 do
             if GreedCall[i]=w then
               begin
                Done:=True;
               end;
          SetTinyLabel(w);
          AddNewProc(w);
        end;
   13 : begin {JP conditional, CALL conditional }
         w:=PrgMem^[ip+1]+PrgMem^[ip+2] shl 8;
         SetTinyLabel(w);
         AddNewProc(w);
        end;
   15 : begin {RET or JP (HL)}
         Done:=True;
        end;
   else Halt(3000)
  end;
  Inc(ip, IL);
  if not ((ip>=PLow) or (ip<=PHigh)) then Done:=True;
 until Done;
end;

procedure Scan(addr:word);
var cp:word;i:integer;
begin
 WriteTo('[Scanning area]',60,16,$3F);
 SetTinyLabel(addr);
 ProcNum:=0;
 Inc(ProcNum); ProcQ[ProcNum]:=addr;
 while ProcNum>0 do
   begin
    cp:=ProcQ[1];
    if ProcNum>1 then
      begin
       for i:=2 to ProcNum do ProcQ[i-1]:=ProcQ[i];
       ProcQ[i]:=0;
      end;
    Dec(ProcNum);
    ScanProc(cp);
   end;
 WriteTo(Strng(15,'Í'),60,16,$3F);
end;

procedure TypeError(No:word);
var attr:byte;
begin
 case No of
  0      : attr:=$33;
  1..31  : attr:=$44;
  50     : attr:=$55;
  else     attr:=$11;
 end;
 case No of {0-must ne free}
   1 : SetError('Bad header in WorkFile!', $4C);
   2 : SetError('Error while rewrite WorkFile!', $4C);
   3 : SetError('Error while write WorkFile!', $4C);
   4 : SetError('Error while read WorkFile!', $4C);
   5 : SetError('Such WorkFile does not exist!', $4C);
   6 : SetError('Bad WorkFile contents!', $4C);
  10 : SetError('Can''t make ASM file!', $4C);
  11 : SetError('Can''t write to ASM file!', $4C);
  29 : SetError('Label not found!', $4C);
  32 : SetError('Search string not found!', $1B);
  33 : SetError('CodeSeg bit not found!', $4C);
  40 : SetError('WorkFile saved normally!', $1B);
  41 : SetError('WorkFile loaded OK!', $1B);
  50 : SetError('ASM file saved OK!', $5F);
  53 : SetError('ASM file saving aborted.', $4B);
  58 : SetError('SYM file loaded.', $1B);
  59 : SetError('CTL file loaded.', $1B);
  100: SetError('Real Data Offsets OFF', $1B);
  101: SetError('Real Data Offsets ON', $1B);
  102: SetError('Type processor i8085 OFF', $1B);
  103: SetError('Type processor i8085 ON', $1B);
(*  104: SetError('Using undocument code OFF', $1B);
  105: SetError('Using undocument code ON', $1B);*)
  106: SetError('Comment Z80 code OFF', $1B);
  107: SetError('Comment Z80 code ON', $1B);
 end;
 ErrorLine:=7;
end;

function AsmFormat: string;
var Fmt: string;
begin
  if Type8085 then Format[False] := '8085' else Format[False] := '8080';
  Fmt := Format[Z80];
  if (not Z80) and (UndoCode) then Fmt := Fmt + '+' else Fmt := Fmt + ' ';
  AsmFormat := Fmt;
end;

Procedure WriteFormat;
begin
{TODO: remove}
end;

procedure LoadFile;
var i,p,l:byte; tf:file;
code :integer;
begin
 if ParamCount<1 then Halt(1);
 FileName:=ParamStr(1);
 Assign(f, FileName); ReSet(f, 1); if IOresult>0 then Halt(2);
 if ParamCount=1 then begin
   BlockRead(f, PrgType, 2);
   BlockRead(f, PrgStart, 2);
   Z80:=True;
   if PrgType=$4241 then begin
     if FileSize(f)>16384 then PrgLength:=32768 else PrgLength:=16384;
     PrgBegin:=PrgStart and $C000;
   end else begin
     PrgLength:=FileSize(f);
     PrgBegin:=0;
     PrgStart:=PrgBegin;
   end;
 end
 else
 if ParamCount=2 then begin
   Z80:=true;
   if ParamStr(2)='/m' then begin
    if FileSize(f)>16384 then PrgLength:=32768 else PrgLength:=16384;
    PrgBegin:=$C000;
    PrgStart:=PrgBegin;
   end else begin
     PrgLength:=FileSize(f);
     Val(Copy(ParamStr(2),1,Length(ParamStr(2))),PrgBegin,Code);
     PrgStart:=PrgBegin;
   end;
 end
 else
 if ParamCount=3 then begin
   if ParamStr(3)='/m' then begin
     Z80:=true;
     if FileSize(f)>16384 then PrgLength:=32768 else PrgLength:=16384;
   end else
   if ParamStr(3)='/i' then begin
     Z80:=false;
     PrgLength:=FileSize(f);
   end;
   Val(Copy(ParamStr(2),1,Length(ParamStr(2))),PrgBegin,Code);
   PrgStart:=PrgBegin;
 end
 else Halt(1);
 FirstZ80:=Z80;
 Seek(f, 0);
 BlockRead(f, PrgMem^[PrgBegin], PrgLength);
 Close(f);
 PLow:=PrgBegin; PHigh:=PrgBegin+PrgLength;
 PrgData:=$E000;
 p:=0;l:=0;
 for i:=1 to Length(FileName) do
  begin
   FileName[i]:=UpCase(FileName[i]);
   if FileName[i]='.' then p:=i;
   if (FileName[i] in ['A'..'Z','0'..'9','-']) and (l=0) then l:=i;
   if FileName[i]='\' then l:=0;
  end;
 Delete(FileName,p+1,3);
 Delete(FileName,1,l-1);
 Assign(tf, FileName+'WRK'); Reset(tf,1);
 if IOresult=0 then begin ldw:=True; Close(tf); end else ldw:=False;
 if IOresult>0 then ;
end;

function EnterRange(var r1,r2:word):boolean;
var ch:char;c,p:byte; t:word;ox,oy:byte;i:integer;
s:array[1..3] of string;
d:array[1..3] of word;
procedure Restore;var i:byte;
begin
 for i:=0 to 3 do WriteTo(Space(15), 50, 6+i,$33);
 GotoXY(ox, oy);
end;
begin
 ox:=WhereX; oy:=WhereY;
 WriteTo('< Enter range >', 50, 6, $3E);
 c:=1;p:=1;d[1]:=r1;d[2]:=r2;
 repeat
  d[3]:=d[2]-d[1]+1;
  WriteTo(' From : '+Hex4(d[1])+' ', 51, 7, $1F);
  WriteTo(' To   : '+Hex4(d[2])+' ', 51, 8, $1F);
  WriteTo(' Len  : '+Hex4(d[3])+' ', 51, 9, $1F);
  GotoXY(59+p, 7+c);
  ch:=ReadKey;
  case ch of
   #0 : case ReadKey of
         #77 : if p<4 then Inc(p);
         #75 : if p>1 then Dec(p);
         #72 : if c>1 then Dec(c) else c:=3;
         #80 : if c<3 then Inc(c) else c:=1;
        end;
   '0'..'9','A'..'F','a'..'f' :
         begin
          s[1]:=Hex4(d[1]);s[2]:=Hex4(d[2]);s[3]:=Hex4(d[3]);
          s[c][p]:=ch; if p<4 then Inc(p);
          Val('$'+s[c], t, i);
          case c of
           1, 2 : d[c]:=t;
           3 : d[2]:=d[1]+t-1;
          end;
         end;
   #27 : begin
          Restore;
          EnterRange:=False;
          Exit
         end;
   #13 : begin
          Restore;
          r1:=d[1];r2:=d[2];
          EnterRange:=True;
          Exit;
         end;
  end;
 until False;
end;

function EnterAddr(var r:word):boolean;
var ch:char;c,p:byte; t:word;ox,oy:byte;i:integer;
s:string;d:word;
procedure Restore;var i:byte;
begin
 for i:=0 to 3 do WriteTo(Space(15), 50, 6+i,$33);
 GotoXY(ox, oy);
end;
begin
 ox:=WhereX; oy:=WhereY;
 WriteTo('< Enter addr >', 50, 6, $3E);
 c:=1;p:=1;d:=r;
 repeat
  WriteTo(' Addr : '+Hex4(d)+' ', 51, 7, $1F);
  GotoXY(59+p, 7+c);
  ch:=ReadKey;
  case ch of
   #0 : case ReadKey of
         #77 : if p<4 then Inc(p);
         #75 : if p>1 then Dec(p);
        end;
   '+' : Inc(d);
   '-' : Dec(d);
   '0'..'9','A'..'F','a'..'f' :
         begin
          s:=Hex4(d);
          s[p]:=ch; if p<4 then Inc(p);
          Val('$'+s, t, i);
          d:=t;
         end;
   #27 : begin
          Restore; EnterAddr:=False;
          Exit
         end;
   #13 : begin
          Restore; r:=d; EnterAddr:=True;
          Exit;
         end;
  end;
 until False;
end;

procedure MakeCode;
var w1, w2:word;i:longint;
begin
 w1:=RealPos; w2:=RealPos;
 if not EnterRange(w1, w2) then Exit;
 for i:=0 to (w2-w1) do
  ShadowH^[w1+i]:=$00 or (ShadowH^[w1+i] and $3F);
end;

procedure MakeData;
var w1, w2:word;i:longint;
begin
 w1:=RealPos; w2:=RealPos;
 if not EnterRange(w1, w2) then Exit;
 for i:=0 to (w2-w1) do
  ShadowH^[w1+i]:=$40 or (ShadowH^[w1+i] and $3F);
end;

procedure MakeWord;
var w1, w2:word;i:longint;
begin
 w1:=RealPos; w2:=RealPos;
 if not EnterRange(w1, w2) then Exit;
 for i:=0 to (w2-w1) do
  ShadowH^[w1+i]:=$80 or (ShadowH^[w1+i] and $3F);
end;

procedure MakeAddress;
var w1, w2:word;i:longint;
begin
 w1:=RealPos; w2:=RealPos;
 if not EnterRange(w1, w2) then Exit;
 for i:=0 to (w2-w1) do
  ShadowH^[w1+i]:=$80 or (ShadowH^[w1+i] and $3F);
end;

procedure ContinueSearch;
var j:integer;
begin
 if FindString='' then Exit;
 while FindPos<=PrgBegin+PrgLength do
   begin
    for j:=1 to Length(FindString)+1 do
      if (j<=Length(FindString)) and (FControl[j]<>'X') and
         (PrgMem^[FindPos+j-1]<>byte(FindString[j])) then break;
    if j>Length(FindString) then begin MemPos:=FindPos; LineNo:=1; Exit end;
    Inc(FindPos);
   end;
 TypeError(32);
end;

procedure FindBytes;
var s,c:string;Done,Tab:boolean;ch:char;p,b:byte;bt:string[2];i:integer;
begin
 s:='';c:='';
 Done:=False;Tab:=False;
 bt:='';p:=1;
 WriteTo('Find:',49,8,$30);
 repeat
  ch:=ReadKey;
  case Ch of
   #0 : case ReadKey of
         #75 : if p>1 then Dec(p);
         #77 : if p<Length(s) then Inc(p);
        end;
   #27 : begin WriteTo('     ',49,8,$30);Exit; end;
   'A'..'F','a'..'f','0'..'9': if Length(s)<10 then bt:=bt+UpCase(ch);
   'x','X' : begin Insert(#0,s,p); Insert('X',c,p); Inc(p) end;
   #13 : Done:=True;
   #9  : begin Done:=True; Tab:=True end;
   #08 : if bt[0]>#0 then bt:='' else
         if p>1 then begin Dec(p);Delete(s,p,1);Delete(c,p,1);end;
  end;
  if Length(bt)=2 then
    begin
     Val('$'+bt,b,i);
     Insert(char(b),s,p);
     Insert('O',c,p);
     bt:='';
     Inc(p);
    end;
  WriteTo(Space(31),50,9,$30);
  for i:=1 to Length(s) do
   if c[i]<>'X' then WriteTo(Hex2(byte(s[i])),47+i*3,9,$30)
                else WriteTo('XX',47+i*3,9,$30);
  if i>Length(s) then i:=0;
  WriteTo(bt,47+i*3+3,9,$30);
 until Done;
 WriteTo('     ',49,8,$30);
 FindString:=s; FControl:=c;
 if Tab then FindPos:=RealPos else FindPos:=PrgBegin;
 ContinueSearch;
end;

function GetGameID:string;
var s:string;
begin
 if Length(FileName)<5
    then s:=Copy(FileName,1,Length(FileName)-1)
    else s:=Copy(FileName,1,4);
 while Length(s)<4 do s:=s+'_';
 GetGameID:=s
end;

Procedure OutToFile(var T : Text; var S : string);
var I,J : Integer;
begin
 For I := 1 to 8 do
     case S[I] of
      ' ',':' : break;
      '+','-' : begin
                 FillChar(S[1], 8, ' ');
                 break;
                end;
     end;
 While (S <> '') and (S[length(S)] = ' ') do Dec(byte(S[0]));
 I := (length(S) div 8) * 8;
 While I > 0 do
       begin
        J := I;
        While (S[J] = ' ') and (J > I - 7) do Dec(J);
        if J < I then begin Inc(J); Delete(S, J, I - J); S[J] := #9; end;
        Dec(I, 8);
       end;
 Writeln(T, S);
end;

procedure SaveAsmFile;
label ProcExit;
var ip, LNo, prgl:word;s:string;i:integer;
begin
 Assign(t,FileName+'ASM'); ReWrite(t);
 if IOresult>0 then begin TypeError(10);Exit end;
 ip:=PrgStart; lno:=0;
 prgl:=PrgLength div 100;
 WriteTo('Lines saved  :',58,19,$30);
 WriteTo('In progress  :',58,20,$30);
 WriteTo('[Saving *.ASM files]',58,16,$3F);
 WriteFormat;
 Writeln(t,';°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°',
     #13#10';°°°°              This file was created by              °°°°',
     #13#10';°°°°          PROGRAM RECOMPILE SYSTEM ',Version,'         °°°°',
     #13#10';°°°°           (C) 1995 by FRIENDS Software             °°°°',
     #13#10';°°°°     (C) 2000 by TIMSoft  (i8080/i8085 rebuild)     °°°°',
     #13#10';°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°',
     #13#10'          .org '+Hex4(ip)+'h');
 repeat
  if Z80 then s:=DisAsmZ80(ip) else s:=DisAsm8088(ip);
  OutToFile(t,s);
  if IOresult>0 then begin TypeError(11);Close(t);Exit end;
  if not LongCode then inc(ip, ILength);
  Inc(LNo); Str(LNo:5,s);
  WriteTo(s,73,19,$30);
  i:=(ip-PrgBegin) div PrgL; Str(i:3,s);
  WriteTo(s+'%',74,20,$30);
  if keypressed then
    begin
     case ReadKey of
      #0 : case ReadKey of
            #77 :;
           end;
      #27 : begin TypeError(53); Goto ProcExit end;
     end;
    end;
 until ip>=PrgBegin+PrgLength;
 TypeError(50);
ProcExit:
 WriteTo(Strng(20,'Í'),58,16,$3F);
 if FirstZ80 then begin
   Writeln(t,'; Additional registers of Z80');
   Writeln(t,'AF        .dw       0');
   Writeln(t,'BC        .dw       0');
   Writeln(t,'DE        .dw       0');
   Writeln(t,'HL        .dw       0');
   Writeln(t,'IX        .dw       0');
   Writeln(t,'IY        .dw       0');
   Writeln(t,'R         .db       0');
   Writeln(t,'I         .db       0');
   Writeln(t,'; Temporary registers');
   Writeln(t,'TEMP      .dw       0');
   Writeln(t,'TMP       .db       0');
   Writeln(t,'; Procedures for emulation some commands of Z80');
   Writeln(t,'.include "z80code.asm"');
 end;
 Writeln(t,'.end');
 Close(t);
end;

function UpString(s:string):string;
var i:byte;
begin
 UpString:=s;
 for i:=1 to Length(s) do UpString[i]:=UpCase(s[i]);
end;

function CutString(var d:word;var s:string):boolean;
var i:integer;ls:string;
begin
 ls:='XXXX';for i:=1 to 4 do ls[i]:=s[i];
 Delete(s, 1, 5); Val('$'+ls,d,i);
 if i>0 then CutString:=False else CutString:=True;
end;

procedure SetLabelName(ad:word;s:string);
var i:integer;ls,orls:string;Ln:word;
begin
 Suck(s); if s='' then Exit;
 ls:=Copy(s,1,8);orls:=ls;
 for i:=1 to Length(ls) do ls[i]:=UpCase(s[i]);
 Ln:=(ShadowH^[ad] and $7) shl 8+ShadowL^[ad];
 for i:=1 to LabelNum do if Labels^[i]='' then begin Ln:=i;break end;
 if (Ln=0) and (LabelNum>=MaxLabels) then Exit;
 if Ln>0 then Labels^[Ln]:='!';
 for i:=1 to LabelNum do if ls=UpString(Labels^[i]) then Exit;
 if Ln=0 then begin Inc(LabelNum);Ln:=LabelNum; end;
 Labels^[Ln]:=orls;
 ShadowH^[ad]:=(ShadowH^[ad] and $E0)+(Hi(Ln) and $7);
 ShadowL^[ad]:=Lo(Ln);
end;

procedure ImportSymbols;
label CTL, DOC, Exit;
var t:text;s:string;w,ad:word;ch:char;c:byte;
begin
 Assign(t, FileName+'SYM'); {Label names}
 ReSet(t); if IOResult>0 then Goto CTL;
 repeat
  ReadLn(t, s);
  if CutString(ad, s) then SetLabelName(ad, s);
  WriteTo('Label '+Copy(s,1,8)+' at '+Hex4(ad)+'    ',51,13,$30);
 until (s[1]=#26) or Eof(t);
 Close(t);
 TypeError(58);
CTL:
 Assign(t, FileName+'CTL'); {Data type ranges}
 ReSet(t); if IOResult>0 then Goto DOC;
 repeat
  ReadLn(t, s);
  if CutString(ad, s) then
    begin
     ch:=s[1];
     case ch of
      'B':c:=$40;
      'W':c:=$80;
      'I':c:=0;
      else c:=0;
     end;
     WriteTo('  Area type '+s[1]+' at '+Hex4(ad)+'    ',51,13,$30);
     for w:=ad to PrgBegin+PrgLength do
      ShadowH^[w]:=(ShadowH^[w] and $3F) or c;
    end;
 until (s[1]=#26) or Eof(t);
 Close(t);
 TypeError(59);
DOC:
 Assign(t, FileName+'DOC');    {Comments}
 ReSet(t); if IOResult>0 then Goto Exit;
 Close(t);
Exit:
 WriteTo(Strng(28,' '),51,13,$30);
end;

procedure GetLabelName(var ln:string);
var ox,oy,p:byte;s:string;ch:char;l:word;
begin
 WriteTo('[ Real address : '+Hex4(RealPos)+' ]', 3, 1, $3F);
 ox:=WhereX; oy:=WhereY; s:=Space(8); p:=1;
 l:=(ShadowH^[RealPos] and $7) shl 8+ShadowL^[RealPos];
 if l>0 then s:=Labels^[l];
 repeat
  WriteTo(s, 2, LineNo+1, $1F);
  GotoXY(2+p, LineNo+2);
  ch:=ReadKey;
  case ch of
   #0  : case ReadKey of
          #75 : if p>1 then Dec(p);
          #77 : if p<9 then Inc(p);
          #83 : begin Delete(s, p, 1); s:=s+' '; end;
         end;
   'A'..'Z', 'a'..'z', '_','+','-'
       : if p<9 then
         begin
          Delete(s, 8, 1);
          Insert(ch, s, p); Inc(p);
         end;
   '0'..'9' : if (p>1) and (p<9) then
         begin
          Delete(s, 8, 1);
          Insert(ch, s, p); Inc(p);
         end;
   #8  : if p>1 then begin Dec(p); Delete(s, p, 1); s:=s+' ' end;
   #27 : begin
          GotoXY(ox, oy);
          WriteTo(Strng(24,'Í'), 3, 1, $3F);
          ln:='';
          Exit;
         end;
   ':',#13 : begin
              GotoXY(ox, oy);
              WriteTo(Strng(24,'Í'), 3, 1, $3F);
              ln:=s;
              Exit;
             end;
  end;
 until False;
 GotoXY(ox, oy);
end;

procedure InitAllVars;
var i:byte;
begin
 TinyLabels:=0;
 FillChar(GreedCall,20,$FF);
 ProcNum:=0;
 FindString:=''; FindPos:=PrgBegin;
 MemPos:=PrgBegin; DumpPos:=PrgBegin; LineNo:=1;
 OriginPos:=PrgStart;
 Follow[1]:=PrgStart; FolNum:=1;
 LabelNum:=0;
 SetLabelName(PrgBegin,'ModBegin');
 SetLabelName(PrgStart,'ModStart');
 MemPos:=PrgStart;DumpPos:=MemPos; OldDump:=DumpPos+1;
 RealPos:=MemPos;
 ErrorLine:=0; DAttr:=True; {Z80:=True; MYCOR}
 for i:=1 to 10 do KeyReg[i]:=PrgStart;
 CharDec:=0; DumpChar:=False;
end;

procedure ShowPoints;
//var i:byte;
begin
(* for i:=1 to 10 do
   WriteTo(Hex4(GreedCall[i]),50+((i-1) mod 5)*5,11+(i-1) div 5,$30);
 for i:=1 to 10 do
   WriteTo(Hex4(KeyReg[i]),50+((i-1) mod 5)*5,14+(i-1) div 5,$30);*)
end;

procedure SaveEnvir;
begin
 Assign(f,FileName+'WRK'); ReWrite(f,1);
 if IOresult>0 then begin TypeError(2);Exit end;
 BlockWrite(f,WrkHeader[1], 16);
 BlockWrite(f,PrgType,14);
 BlockWrite(f,ShadowH^[PrgBegin],PrgLength);
 BlockWrite(f,ShadowL^[PrgBegin],PrgLength);
 BlockWrite(f,LabelNum,16);
 BlockWrite(f,GreedCall,21); {GreedCall,GreeCallNum}
 BlockWrite(f,Labels^,SizeOf(Labels^));
 BlockWrite(f,Follow,SizeOf(Follow)+1);{Follow,FolNum}
 BlockWrite(f,KeyReg,10*2+2);
 BlockWrite(f,RealDataLoc,1);
 BlockWrite(f,Type8085,1);
 BlockWrite(f,UndoCode,1);
 BlockWrite(f,DataBlock,1);
 BlockWrite(f,RemEnable,1);
 if IOresult>0 then begin TypeError(3);Exit end;
 Close(f);
 TypeError(40);
end;

procedure LoadEnvir;
begin
 Assign(f,FileName+'WRK'); ReSet(f,1);
 if IOresult>0 then begin TypeError(5);Exit end;
 CurHeader[0]:=#16;
 BlockRead(f, CurHeader[1], 16);
 if IOresult>0 then TypeError(6);
 if WrkHeader<>CurHeader then begin TypeError(1);Exit; end;
 BlockRead(f,PrgType,14);
 BlockRead(f,ShadowH^[PrgBegin],PrgLength);
 BlockRead(f,ShadowL^[PrgBegin],PrgLength);
 BlockRead(f,LabelNum,16);
 BlockRead(f,GreedCall,21); {GreedCall,GreeCallNum}
 BlockRead(f,Labels^,SizeOf(Labels^));
 BlockRead(f,Follow,SizeOf(Follow)+1);{Follow,FolNum}
 BlockRead(f,KeyReg,10*2+2);
 if IOresult>0 then
   begin
    TypeError(4);
    InitAllVars;
    ShowPoints;
    Exit;
   end;
 BlockRead(f,RealDataLoc,1); inOutRes := 0;
 BlockRead(f,Type8085,1);
 BlockRead(f,UndoCode,1);
 BlockRead(f,DataBlock,1);
 {$I-}
 BlockRead(f,RemEnable,1);
 {$I+}
 if IOResult>0 then RemEnable:=true;
 WriteFormat;
 Close(f);
(* ShowPoints;*)
 TypeError(41);
end;

procedure ShowDump;
//var i:integer;attr:byte;
begin
(* if CharDec<>0 then WriteTo('['+Hex2(CharDec)+']',2,16,$3F) else WriteTo('ÍÍÍÍ',2,16,$3F);
 if (RealPos>=DumpPos) and (RealPos<=DumpPos+6*16) then DAttr:=True;
 if (OldDump=DumpPos) and not DAttr then Exit;
 if DumpChar then
 for i:=0 to 6*48-1 do
  begin
   if DumpPos+i=RealPos then begin attr:=$17; DAttr:=True end else attr:=$30;
   WriteTo(Char(Byte(PrgMem^[DumpPos+i]+CharDec)), (i mod 48)+8, i div 48+17, attr);
   if i mod 48=0 then WriteTo(Hex4(DumpPos+i)+':', 2, i div 48+17, $30);
  end    else
 for i:=0 to 6*16-1 do
  begin
   if DumpPos+i=RealPos then begin attr:=$17; DAttr:=True end else attr:=$30;
   WriteTo(Hex2(PrgMem^[DumpPos+i]), (i and 15)*3+8, i div 16+17, attr);
   WriteTo(' ', (i and 15)*3+8+2, i div 16+17,$30);
   if i and 15=0 then WriteTo(Hex4(DumpPos+i)+':', 2, i div 16+17, $30);
  end;
 OldDump:=DumpPos;*)
end;

procedure ShowList;
//var i, attr:byte; ip:word; s:string;
begin
(* ip:=MemPos; PageByte:=0;
 for i:=1 to 14 do
  begin
   if i=LineNo then attr:=$17 else attr:=$30;
   if Z80 then s:=DisAsmZ80(ip) else s:=DisAsm8088(ip);
   if ip=OriginPos then s:=chr(16)+s else s:=' '+s;
   if (ShadowH^[ip] and $20<>0) and (ShadowH^[ip] shr 6<>0) then s[11]:='ð';
   WriteTo(s,1,i+1,attr);
   if not LongCode then begin
     inc(ip, ILength); inc(PageByte, ILength);
     Adds[i]:=ILength;
   end;
  end;
  LongCode:=False;*)
end;

procedure DeleteLabel(ad:word);
var i:integer;l:word;
begin
 if (ShadowH^[ad] and $10=0) and (LabelNum=0) then Exit;
 l:=(ShadowH^[ad] and $0F) shl 8+ShadowL^[ad];
 ShadowH^[ad]:=ShadowH^[ad] and $E0;ShadowL^[ad]:=0;
 if (l=0) or (LabelNum=0) then Exit;
 Labels^[l]:='';
 if l=LabelNum then Dec(LabelNum);
 for i:=LabelNum downto 1 do
   begin
    if Labels^[i]<>'' then break;
    Dec(LabelNum);
   end;
end;

procedure GoUp;
var ip:word;
begin
 ip:=MemPos-22;
 repeat
  if Z80 then DisAsmZ80(ip) else DisAsm8088(ip);
  inc(ip, ILength);
 until ip>=MemPos;
 Dec(MemPos,ILength);
end;

procedure PageUp;
var i:byte;
begin
 for i:=1 to 14 do GoUp;
end;

procedure ShowStatus;
var i:byte;s:string;
begin
 RealPos:=MemPos;
 for i:=2 to LineNo do Inc(RealPos,Adds[i-1]);
 WriteTo(Hex4(RealPos), 68, 2, $30);
 if (RealPos>=PrgBegin) and (RealPos<=PrgBegin+PrgLength) then
   begin
    i:=(RealPos-PrgBegin) div (PrgLength div 100);
    Str(i:3,s); WriteTo(s+'%',73,2,$30);
   end else WriteTo(' Out ',73,2,$30);
 WriteTo('Labels:'+SStr(LabelNum,4),51,3,$30);
end;

procedure PutPixel(x,y:integer;Col:byte); {TODO}
begin
(* mem[$A000:x+y*320]:=Col;*)
end;

procedure ShowGraphics(addr:word; Mode : byte);
var p:word; x,y:word; i:integer; rc,cc,a,c,lcl:byte;

procedure ShowByte;
const yp : array[0..15] of byte =
     (0,0,47,72,33,9,249,11,39,64,43,67,144,62,28,15);
      ch : array[0..7] of byte =
     ($7E,$81,$A5,$81,$BD,$99,$81,$7E);
var   bc : byte;
begin
 if Mode = 0
    then for bc:=0 to 7 do
             if c and ($80 shr bc)<>0
                then PutPixel(x+bc,y,15)
                else
    else for bc:=0 to 7 do
             if ch[lcl] and (1 shl bc) <> 0
                then PutPixel(x+bc,y,yp[c and $0F])
                else PutPixel(x+bc,y,yp[c shr 4]);
 lcl := (lcl + 1) and 7;
 Inc(y); Inc(rc);
 if rc=16
    then begin
          Inc(x,8); Dec(y,16); rc:=0; inc(cc);
          if cc=18 then begin Inc(y,16); x:=32; cc:=0; rc:=0; end;
         end;
end;
var bc: byte;
    j : integer;
begin
(* OldScr:=ScrBuf;*)
(* asm mov ax, 13h; int 10h end;*)
 repeat
 if Z80 then begin
   p:=addr; x:=32; y:=90; rc:=0; cc:=0; lcl := 0;
   repeat
    a:=PrgMem^[p]; Inc(p);
    if a=0 then break;
    if a and $80=0
     then begin
           c:=PrgMem^[p]; Inc(p);
           for i:=1 to a do
               ShowByte;
          end
     else begin
           for i:=1 to a and $7F do
            begin
             c:=PrgMem^[p]; Inc(p);
             ShowByte;
            end;
          end;
   until false;
 end
 else begin
   p:=addr; x:=0; y:=5;
   for j:=0 to 22 do
     for i:=1 to 192 do begin
       c:=PrgMem^[p]; Inc(p);
       for bc:=0 to 7 do if c and ($80 shr bc)<>0 then PutPixel(x+bc+j*14,y+i,15)
                                                  else PutPixel(x+bc+j*14,y+i,0)
     end
 end;
 Repeat until keypressed;
 case ReadKey of
   #0 : case ReadKey of
{Left}   #75 : Dec(addr, 192);
{Right}  #77 : Inc(addr, 192);
{PgUp}   #73 : Dec(addr, 16);
{PgDn}   #81 : Inc(addr, 16);
{Up}     #72 : Dec(addr);
{Down}   #80 : Inc(addr);
{Home}   #71 : addr:=PrgBegin;
{End}    #79 : begin
                addr:=PrgBegin+PrgLength-23*192;
                //if addr<0 then addr:=0;
               end;
        else a:=255;
        end;
   #13 : begin
           MemPos:=addr; LineNo:=1; a:=255;
         end;
 else a:=255;
 end
 Until (a=255) or (Z80);
(* asm mov ax,3; int 10h end;*)
(* ScrBuf:=OldScr;*)
end;

var ln:string;
    i:word;

procedure DAGoodInit;
begin
  GetMem(PrgMem, 65535);  FillChar(PrgMem^, 65535, 0);
  GetMem(ShadowH, 65535); FillChar(ShadowH^, 65535, $40);
  GetMem(ShadowL, 65535); FillChar(ShadowL^, 65535, $00);
  New(Labels); FillChar(Labels^, SizeOf(Labels^), 0);

  LoadFile;
  InitAllVars;

  if ldw then LoadEnvir;
end;

{TODO: procedure DAGoodDone}

procedure StartUp;
begin
{NOTE: Initialization moved to DAGoodInit}
(* ShowPoints;*)
(* if ldw then LoadEnvir;*)
 repeat
(*  repeat
   ShowStatus;
   ShowList;
   ShowDump;
  until keypressed;*)
  case ReadKey of
   #0 : case ReadKey of
{F1}     (* #59 : ShowKeyboardHelp;*)
         #75 : Dec(DumpPos);
         #77 : Inc(DumpPos);
         #72 : if LineNo>1  then dec(LineNo) else GoUp;
         #80 : if LineNo<14 then inc(LineNo) else inc(MemPos, Adds[1]);
         #73 : PageUp;
         #81 : Inc(MemPos, PageByte);
{F2}     #60 : begin GetLabelName(ln); if ln<>'' then SetLabelName(RealPos,ln); end;
{F3}     #61 : begin
                GetLabelName(ln); ln:=UpString(ln);
                While (ln <> '') and (ln[length(ln)] = ' ') do Dec(byte(ln[0]));
                if ln<>'' then
                   for i:=PrgBegin to PrgBegin+PrgLength do
                     if LabelExist(i) and (copy(UpString(Labels^[LabelNo]),1,length(ln))=ln)
                        then begin
                              MemPos:=i; LineNo:=1;
                              break;
                             end;
                if i=PrgBegin+PrgLength then TypeError(29);
               end;
{F4}     #62 : MakeData;
{F5}     #63 : MakeCode;
{F6}     #64 : MakeWord;
{F7}     #65 : MakeAddress;
{F8}     #66 : DeleteLabel(RealPos);
{F9}     #67 : Scan(RealPos);
{Alt+ F9}#112: begin                  {if code}
                if ShadowH^[RealPos] and $C0=0 then
                 case Stat[PrgMem^[RealPos]] shr 4 of
                  1 : begin {LD reg16, xx}
                       sadr:=PrgMem^[RealPos+1]+PrgMem^[RealPos+2] shl 8;
                       ShadowH^[RealPos+1]:=ShadowH^[RealPos] or $C0;
                       ShadowH^[RealPos+2]:=ShadowH^[RealPos+1] or $C0;
                      end;
                  else sadr:=0; {invalid oper. to scan over}
                 end        else
                 begin                {if data, make }
                  sadr:=PrgMem^[RealPos]+PrgMem^[RealPos+1] shl 8;
                  ShadowH^[RealPos]:=ShadowH^[RealPos] or $C0;
                  ShadowH^[RealPos+1]:=ShadowH^[RealPos+1] or $C0;
                 end;
                if (sadr>=PrgBegin) and (sadr<PrgBegin+PrgLength)
                  then Scan(sadr);
                ShadowH^[RealPos]:=ShadowH^[RealPos] or $20;
               end;
{Ctrl+F9}#102: SaveASMfile;
{Ctrl+F2}#95 : ShadowH^[RealPos]:=ShadowH^[RealPos] xor $10;
{Alt +F2}#105: if ShadowH^[RealPos] shr 6=0 then
                  ShadowH^[RealPos+1]:=(ShadowH^[RealPos+1] xor $80) or $40 else
                   begin
                    ShadowH^[RealPos]:=(ShadowH^[RealPos] xor $80) or $40;
                    ShadowH^[RealPos+1]:=(ShadowH^[RealPos+1] xor $80) or $40;
                   end;
{ShiftF2}#85 : if ShadowH^[RealPos] shr 6=0 then
                  ShadowH^[RealPos+1]:=(ShadowH^[RealPos+1] xor $80) or $40 else
                   begin
                    sadr:=PrgMem^[RealPos]+PrgMem^[RealPos+1] shl 8;
                    ShadowH^[RealPos]:=(ShadowH^[RealPos] xor $80) or $40;
                    ShadowH^[RealPos+1]:=(ShadowH^[RealPos+1] xor $80) or $40;
                    SetTinyLabel(sadr);
                   end;
(*{Alt +x} #45 : Halt;*)
{Alt +B} #48 : DataBlock:=not DataBlock;
{Alt +1} #120: begin MemPos:=KeyReg[1];  LineNo:=1 end;
{Alt +2} #121: begin MemPos:=KeyReg[2];  LineNo:=1 end;
{Alt +3} #122: begin MemPos:=KeyReg[3];  LineNo:=1 end;
{Alt +4} #123: begin MemPos:=KeyReg[4];  LineNo:=1 end;
{Alt +5} #124: begin MemPos:=KeyReg[5];  LineNo:=1 end;
{Alt +6} #125: begin MemPos:=KeyReg[6];  LineNo:=1 end;
{Alt +7} #126: begin MemPos:=KeyReg[7];  LineNo:=1 end;
{Alt +8} #127: begin MemPos:=KeyReg[8];  LineNo:=1 end;
{Alt +9} #128: begin MemPos:=KeyReg[9];  LineNo:=1 end;
{Alt +0} #129: begin MemPos:=KeyReg[10]; LineNo:=1 end;
(* {Alt +Q} #16 : SaveEnvir;
{Alt +W} #17 : LoadEnvir;*)
{Alt +C} #46 : begin
                 RemEnable:=not RemEnable;
                 TypeError(106 + byte(RemEnable));
               end;
{Alt +R} #19 : begin
                 RealDataLoc := not RealDataLoc;
                 TypeError(100 + byte(RealDataLoc));
               end;
{Alt +T} #20 : if not Z80 then begin
                 Type8085 := not Type8085;
                 TypeError(102 + byte(Type8085));
                 WriteFormat;
               end;
(*{Alt +U} #22 : if not Z80 then begin
                 UndoCode := not UndoCode;
                 TypeError(104 + byte(UndoCode));
                 WriteFormat;
               end;*)
{Alt +S} #31 : ShadowH^[RealPos]:=ShadowH^[RealPos] xor $20;
{Alt +I} #23 : ImportSymbols;
{Alt +D} #32 : DumpPos:=RealPos;
{Alt +G} #34 : begin
                sadr:=1;
                while sadr <= 10 do begin
                  if GreedCall[sadr]=RealPos
                    then begin GreedCall[sadr]:=$FFFF;sadr:=100;break end;
                  sadr:=sadr+1;
                end;
                if sadr<>100 then for sadr:=1 to 10 do if GreedCall[sadr]=$FFFF then
                  begin GreedCall[sadr]:=RealPos; break end;
                ShowPoints;
               end;
        end;
{ÍÍÍÍÍÍÍÍÍ end of doublecoded chars ÍÍÍÍÍÍÍÍÍ}
{Ctrl+D} #4  : begin
                for sadr:=RealPos+1 to PrgBegin+PrgLength do
                  if (ShadowH^[sadr] shr 6>0) and (ShadowH^[sadr+1] shr 6>0)
                  and (ShadowH^[sadr+2] shr 6>0) and (ShadowH^[sadr+3] shr 6>0)
                    then break;
                if sadr<PrgBegin+PrgLength then begin MemPos:=sadr; LineNo:=1 end;
               end;
{Ctrl+T} #20 : begin
                for sadr:=RealPos+1 to PrgBegin+PrgLength do
                    if Pos('offset', DisAsmZ80(sadr)) > 0 then break;
                if sadr<PrgBegin+PrgLength then begin MemPos:=sadr; LineNo:=1 end;
               end;
{Ctrl+C} #3  : DumpChar:=not DumpChar;
{Ctrl+A} #1  : begin
                for sadr:=RealPos+1 to PrgBegin+PrgLength do
                  if (ShadowH^[sadr] and $20>0) then break;
                if sadr<PrgBegin+PrgLength then begin MemPos:=sadr;LineNo:=1 end
                   else TypeError(33);
               end;
{Ctrl+G} #7  : begin
                sadr:=RealPos;
                if EnterAddr(sadr) then begin MemPos:=sadr; LineNo:=1; end;
               end;
{Ctrl+O} #15 : begin MemPos:=OriginPos; LineNo:=1 end;
{Ctrl+N} #14 : OriginPos:=RealPos;
{Ctrl+F} #6  : begin
                Inc(FolNum); if FolNum>MaxFol then FolNum:=MaxFol;
                Follow[FolNum]:=RealPos;
                LineNo:=1;
                if ShadowH^[RealPos] and $C0=0 then
                  case Stat[PrgMem^[RealPos]] shr 4 of
                   11,12:MemPos:=RealPos+shortint(PrgMem^[RealPos+1])+2;
                   else MemPos:=PrgMem^[RealPos+1]+PrgMem^[RealPos+2] shl 8;
                  end        else
                  MemPos:=PrgMem^[RealPos]+PrgMem^[RealPos+1] shl 8;
               end;
{Ctrl+P} #16 : begin
                LineNo:=1;
                if FolNum>0 then begin MemPos:=Follow[FolNum];Dec(FolNum) end
                            else MemPos:=Follow[1];
               end;
{Ctrl+R} #18 : begin
                FindString:=chr(Lo(RealPos))+chr(Hi(RealPos));
                FControl:=FindString;
                FindPos:=PrgBegin;
                ContinueSearch;
               end;
{Ctrl+X} #24 : FindBytes;
{Ctrl+L} #12 : begin Inc(FindPos);ContinueSearch; end;
{Ctrl+B} #2  : begin MemPos:=PrgBegin;LineNo:=1 end;
{Ctrl+S} #19 : begin MemPos:=PrgStart;LineNo:=1 end;
{Ctrl+E} #5  : begin MemPos:=PrgBegin+PrgLength;LineNo:=1 end;
{Ctrl+Z} #26 : begin Z80:=not Z80;WriteFormat;end;
{Shift1} '!' : begin KeyReg[1]:=RealPos; ShowPoints end;
{Shift2} '@' : begin KeyReg[2]:=RealPos; ShowPoints  end;
{Shift3} '#' : begin KeyReg[3]:=RealPos; ShowPoints  end;
{Shift4} '$' : begin KeyReg[4]:=RealPos; ShowPoints  end;
{Shift5} '%' : begin KeyReg[5]:=RealPos; ShowPoints  end;
{Shift6} '^' : begin KeyReg[6]:=RealPos; ShowPoints  end;
{Shift7} '&' : begin KeyReg[7]:=RealPos; ShowPoints  end;
{Shift8} '*' : begin KeyReg[8]:=RealPos; ShowPoints  end;
{Shift9} '(' : begin KeyReg[9]:=RealPos; ShowPoints  end;
{Shift0} ')' : begin KeyReg[10]:=RealPos;ShowPoints  end;
     '=','+' : Inc(CharDec);
         '-' : Dec(CharDec);
{enter}  #13 : ShowGraphics(RealPos, 0);
{Ctrl/En}#10 : ShowGraphics(RealPos, 1);
{Space}  #32 : ShadowH^[RealPos]:=ShadowH^[RealPos] xor $20;
(*{$IFDEF Debug}
{Shift~} '~' : begin
                asm nop end{ Here will be extra stop }
               end;
         #27 : Halt;
{$ENDIF}*)
  end;
(*  memw[0:$41A]:=memw[0:$41C];*)
  if ErrorLine>0 then Dec(ErrorLine); if ErrorLine=1 then TypeError(0);
 until False;
end;

end.
