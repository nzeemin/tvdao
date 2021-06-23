unit DATable;

interface

 { /-tabulation }
 { *-data16 }
 { #-data08 }
 { ?-128 replacement }
 { &-code address }
 { %-memory address }
 { ~-(HL), (IX), (IY) }
 { ^-HL, IX, IY }
 { @xx-Prefix CB(0), ED(1), DD(2), FD(3) }
 { !-invalid instruction }
 { `-alternate command daa, das }
 { \-two and more commands }
const
 Instr : array[$00..$FF] of string[11]=
 (
 {00-3F}
 'nop'      ,'ld/BC, *'  ,'ld/"(BC), A','inc/BC','inc/B' ,'dec/B' ,'ld/B, #' ,'rlca',
 'ex/A, A''','add/^, BC' ,'ld/A, "(BC)','dec/BC','inc/C' ,'dec/C' ,'ld/C, #' ,'rrca',
 'djnz/?'   ,'ld/DE, *'  ,'ld/"(DE), A','inc/DE','inc/D' ,'dec/D' ,'ld/D, #' ,'rla',
 'jr/?'     ,'add/^, DE' ,'ld/A, "(DE)','dec/DE','inc/E' ,'dec/E' ,'ld/E, #' ,'rra',
 'jr/nz, ?' ,'ld/^, *'   ,'ld/"(%), ^' ,'inc/^' ,'inc/H' ,'dec/H' ,'ld/H, #' ,'daa',
 'jr/z, ?'  ,'add/^, ^'  ,'ld/^, "(%)' ,'dec/^' ,'inc/L' ,'dec/L' ,'ld/L, #' ,'cpl',
 'jr/nc, ?' ,'ld/SP, *'  ,'ld/"(%), A' ,'inc/SP','inc/"~','dec/"~','ld/"~, #','scf',
 'jr/c, ?'  ,'add/^, SP' ,'ld/A, "(%)' ,'dec/SP','inc/A' ,'dec/A' ,'ld/A, #' ,'ccf',
 {40-7F}
 'ld/B, B' ,'ld/B, C' ,'ld/B, D' ,'ld/B, E' ,'ld/B, H' ,'ld/B, L' ,'ld/B, "~','ld/B, A',
 'ld/C, B' ,'ld/C, C' ,'ld/C, D' ,'ld/C, E' ,'ld/C, H' ,'ld/C, L' ,'ld/C, "~','ld/C, A',
 'ld/D, B' ,'ld/D, C' ,'ld/D, D' ,'ld/D, E' ,'ld/D, H' ,'ld/D, L' ,'ld/D, "~','ld/D, A',
 'ld/E, B' ,'ld/E, C' ,'ld/E, D' ,'ld/E, E' ,'ld/E, H' ,'ld/E, L' ,'ld/E, "~','ld/E, A',
 'ld/H, B' ,'ld/H, C' ,'ld/H, D' ,'ld/H, E' ,'ld/H, H' ,'ld/H, L' ,'ld/H, "~','ld/H, A',
 'ld/L, B' ,'ld/L, C' ,'ld/L, D' ,'ld/L, E' ,'ld/L, H' ,'ld/L, L' ,'ld/L, "~','ld/L, A',
 'ld/"~, B','ld/"~, C','ld/"~, D','ld/"~, E','ld/"~, H','ld/"~, L','halt'    ,'ld/"~, A',
 'ld/A, B' ,'ld/A, C' ,'ld/A, D' ,'ld/A, E' ,'ld/A, H' ,'ld/A, L' ,'ld/A, "~','ld/A, A',
 {80-BF}
 'add/A, B','add/A, C','add/A, D','add/A, E','add/A, H','add/A, L','add/A, "~','add/A, A',
 'adc/A, B','adc/A, C','adc/A, D','adc/A, E','adc/A, H','adc/A, L','adc/A, "~','adc/A, A',
 'sub/B'   ,'sub/C'   ,'sub/D'   ,'sub/E'   ,'sub/H'   ,'sub/L'   ,'sub/"~'   ,'sub/A'   ,
 'sbc/A, B','sbc/A, C','sbc/A, D','sbc/A, E','sbc/A, H','sbc/A, L','sbc/A, "~','sbc/A, A',
 'and/B'   ,'and/C'   ,'and/D'   ,'and/E'   ,'and/H'   ,'and/L'   ,'and/"~'   ,'and/A'   ,
 'xor/B'   ,'xor/C'   ,'xor/D'   ,'xor/E'   ,'xor/H'   ,'xor/L'   ,'xor/"~'   ,'xor/A'   ,
 'or/B'    ,'or/C'    ,'or/D'    ,'or/E'    ,'or/H'    ,'or/L'    ,'or/"~'    ,'or/A'    ,
 'cp/B'    ,'cp/C'    ,'cp/D'    ,'cp/E'    ,'cp/H'    ,'cp/L'    ,'cp/"~'    ,'cp/A'    ,
 {C0-FF}
 'ret/nz','pop/BC'   ,'jp/nz, &','jp/&'       ,'call/nz, &','push/BC','add/A, #','rst/00',
 'ret/z' ,'ret'      ,'jp/z, &' ,'@0'         ,'call/z, &' ,'call/&' ,'adc/A, #','rst/08',
 'ret/nc','pop/DE'   ,'jp/nc, &','out/(#), A' ,'call/nc, &','push/DE','sub/#'   ,'rst/10',
 'ret/c' ,'exx'      ,'jp/c, &' ,'in/A, (#)'  ,'call/c, &' ,'@2'     ,'sbc/A, #','rst/18',
 'ret/po','pop/^'    ,'jp/po, &','ex/"(SP), ^','call/po, &','push/^' ,'and/#'   ,'rst/20',
 'ret/pe','jp/(^)'   ,'jp/pe, &','ex/DE, ^'   ,'call/pe, &','@1'     ,'xor/#'   ,'rst/28',
 'ret/p' ,'pop/AF'   ,'jp/p, &' ,'di'         ,'call/p, &' ,'push/AF','or/#'    ,'rst/30',
 'ret/m' ,'ld/SP, ^' ,'jp/m, &' ,'ei'         ,'call/m, &' ,'@3'     ,'cp/#'    ,'rst/38' );

 InstrCB : array[$00..$FF] of string[9]=
 (
 {00-3F}
 'rlc/B','rlc/C','rlc/D','rlc/E','rlc/H','rlc/L','rlc/"~','rlc/A',
 'rrc/B','rrc/C','rrc/D','rrc/E','rrc/H','rrc/L','rrc/"~','rrc/A',
 'rl/B' ,'rl/C' ,'rl/D' ,'rl/E' ,'rl/H' ,'rl/L' ,'rl/"~' ,'rl/A' ,
 'rr/B' ,'rr/C' ,'rr/D' ,'rr/E' ,'rr/H' ,'rr/L' ,'rr/"~' ,'rr/A' ,
 'sla/B','sla/C','sla/D','sla/E','sla/H','sla/L','sla/"~','sla/A',
 'sra/B','sra/C','sra/D','sra/E','sra/H','sra/L','sra/"~','sra/A',
 'sll/B','sll/C','sll/D','sll/E','sll/H','sll/L','sll/"~','sll/A',
 'srl/B','srl/C','srl/D','srl/E','srl/H','srl/L','srl/"~','srl/A',
 {40-7F}
 'bit/0, B','bit/0, C','bit/0, D','bit/0, E','bit/0, H','bit/0, L','bit/0, "~','bit/0, A',
 'bit/1, B','bit/1, C','bit/1, D','bit/1, E','bit/1, H','bit/1, L','bit/1, "~','bit/1, A',
 'bit/2, B','bit/2, C','bit/2, D','bit/2, E','bit/2, H','bit/2, L','bit/2, "~','bit/2, A',
 'bit/3, B','bit/3, C','bit/3, D','bit/3, E','bit/3, H','bit/3, L','bit/3, "~','bit/3, A',
 'bit/4, B','bit/4, C','bit/4, D','bit/4, E','bit/4, H','bit/4, L','bit/4, "~','bit/4, A',
 'bit/5, B','bit/5, C','bit/5, D','bit/5, E','bit/5, H','bit/5, L','bit/5, "~','bit/5, A',
 'bit/6, B','bit/6, C','bit/6, D','bit/6, E','bit/6, H','bit/6, L','bit/6, "~','bit/6, A',
 'bit/7, B','bit/7, C','bit/7, D','bit/7, E','bit/7, H','bit/7, L','bit/7, "~','bit/7, A',
 {80-BF}
 'res/0, B','res/0, C','res/0, D','res/0, E','res/0, H','res/0, L','res/0, "~','res/0, A',
 'res/1, B','res/1, C','res/1, D','res/1, E','res/1, H','res/1, L','res/1, "~','res/1, A',
 'res/2, B','res/2, C','res/2, D','res/2, E','res/2, H','res/2, L','res/2, "~','res/2, A',
 'res/3, B','res/3, C','res/3, D','res/3, E','res/3, H','res/3, L','res/3, "~','res/3, A',
 'res/4, B','res/4, C','res/4, D','res/4, E','res/4, H','res/4, L','res/4, "~','res/4, A',
 'res/5, B','res/5, C','res/5, D','res/5, E','res/5, H','res/5, L','res/5, "~','res/5, A',
 'res/6, B','res/6, C','res/6, D','res/6, E','res/6, H','res/6, L','res/6, "~','res/6, A',
 'res/7, B','res/7, C','res/7, D','res/7, E','res/7, H','res/7, L','res/7, "~','res/7, A',
 {C0-FF}
 'set/0, B','set/0, C','set/0, D','set/0, E','set/0, H','set/0, L','set/0, "~','set/0, A',
 'set/1, B','set/1, C','set/1, D','set/1, E','set/1, H','set/1, L','set/1, "~','set/1, A',
 'set/2, B','set/2, C','set/2, D','set/2, E','set/2, H','set/2, L','set/2, "~','set/2, A',
 'set/3, B','set/3, C','set/3, D','set/3, E','set/3, H','set/3, L','set/3, "~','set/3, A',
 'set/4, B','set/4, C','set/4, D','set/4, E','set/4, H','set/4, L','set/4, "~','set/4, A',
 'set/5, B','set/5, C','set/5, D','set/5, E','set/5, H','set/5, L','set/5, "~','set/5, A',
 'set/6, B','set/6, C','set/6, D','set/6, E','set/6, H','set/6, L','set/6, "~','set/6, A',
 'set/7, B','set/7, C','set/7, D','set/7, E','set/7, H','set/7, L','set/7, "~','set/7, A' );

 InstrED : array[$00..$FF] of string[11]=
 (
 {00-3F}
 '!','!','!','!','!','!','!','!',   '!','!','!','!','!','!','!','!',
 '!','!','!','!','!','!','!','!',   '!','!','!','!','!','!','!','!',
 '!','!','!','!','!','!','!','!',   '!','!','!','!','!','!','!','!',
 '!','!','!','!','!','!','!','!',   '!','!','!','!','!','!','!','!',
 {40-7F}
 'in/B, (C)','out/(C), B','sbc/^, BC','ld/"(%), BC','neg','retn','im/0','ld/I, A',
 'in/C, (C)','out/(C), C','adc/^, BC','ld/BC, "(%)','neg','reti','im/01','ld/R, A',
 'in/D, (C)','out/(C), D','sbc/^, DE','ld/"(%), DE','neg','retn','im/1','ld/A, I',
 'in/E, (C)','out/(C), E','adc/^, DE','ld/DE, "(%)','neg','retn','im/2','ld/A, R',
 'in/H, (C)','out/(C), H','sbc/^, ^' ,'ld/"(%), ^' ,'neg','retn','im/0','rrd',
 'in/L, (C)','out/(C), L','adc/^, ^' ,'ld/^, "(%)' ,'neg','retn','im/01','rld',
 'in/?, (C)','out/(C), 0','sbc/^, SP','ld/"(%), SP','neg','retn','im/1','!',
 'in/A, (C)','out/(C), A','adc/^, SP','ld/SP, "(%)','neg','retn','im/2','!',
 {80-9F}
 '!','!','!','!','!','!','!','!',   '!','!','!','!','!','!','!','!',
 '!','!','!','!','!','!','!','!',   '!','!','!','!','!','!','!','!',
 {A0-BF}
 'ldi'   ,'cpi' ,'ini' ,'outi','!','!','!','!',
 'ldd'   ,'cpd' ,'ind' ,'outd','!','!','!','!',
 'ldir "','cpir','inir','otir','!','!','!','!',
 'lddr "','cpdr','indr','otdr','!','!','!','!',
 '!','!','!','!','!','!','!','!',   '!','!','!','!','!','!','!','!',
 '!','!','!','!','!','!','!','!',   '!','!','!','!','!','!','!','!',
 '!','!','!','!','!','!','!','!',   '!','!','!','!','!','!','!','!',
 '!','!','!','!','!','!','!','!',   '!','!','!','!','!','!','!','!');

 Stat : array[$00..$FF] of byte=
 (
{00} $00,$12,$00,$00,$00,$00,$01,$00,$00,$00,$00,$00,$00,$00,$01,$00,
{10} $C1,$12,$00,$00,$00,$00,$01,$00,$B1,$00,$00,$00,$00,$00,$01,$00,
{20} $C1,$12,$A2,$00,$00,$00,$01,$00,$C1,$00,$22,$00,$00,$00,$01,$00,
{30} $C1,$12,$02,$00,$30,$30,$31,$00,$C1,$00,$02,$00,$00,$00,$01,$00,
{40} $00,$00,$00,$00,$00,$00,$30,$00,$00,$00,$00,$00,$00,$00,$30,$00,
{50} $00,$00,$00,$00,$00,$00,$30,$00,$00,$00,$00,$00,$00,$00,$30,$00,
{60} $00,$00,$00,$00,$00,$00,$30,$00,$00,$00,$00,$00,$00,$00,$30,$00,
{70} $30,$30,$30,$30,$30,$30,$00,$30,$00,$00,$00,$00,$00,$00,$30,$00,
{80} $00,$00,$00,$00,$00,$00,$30,$00,$00,$00,$00,$00,$00,$00,$30,$00,
{90} $00,$00,$00,$00,$00,$00,$30,$00,$00,$00,$00,$00,$00,$00,$30,$00,
{A0} $00,$00,$00,$00,$00,$00,$30,$00,$00,$00,$00,$00,$00,$00,$30,$00,
{B0} $00,$00,$00,$00,$00,$00,$30,$00,$00,$00,$00,$00,$00,$00,$30,$00,
{C0} $00,$00,$D2,$92,$D2,$00,$01,$00,$00,$F0,$D2,$50,$D2,$E2,$01,$00,
{D0} $00,$00,$D2,$01,$D2,$00,$01,$00,$00,$00,$D2,$01,$D2,$70,$01,$00,
{E0} $00,$00,$D2,$00,$D2,$00,$01,$00,$00,$F0,$D2,$00,$D2,$60,$01,$00,
{F0} $00,$00,$D2,$00,$D2,$00,$01,$00,$00,$00,$D2,$00,$D2,$80,$01,$00 );

 StatED : array[$00..$FF] of byte=
 (
 {00-3F}
 $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
 $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
 $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
 $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
             {03}
 $00,$00,$00,$A2,$00,$00,$00,$00,
 $00,$00,$00,$22,$00,$00,$00,$00,
 $00,$00,$00,$A2,$00,$00,$00,$00,
 $00,$00,$00,$22,$00,$00,$00,$00,
 $00,$00,$00,$A2,$00,$00,$00,$00,
 $00,$00,$00,$22,$00,$00,$00,$00,
 $00,$00,$00,$A2,$00,$00,$00,$00,
 $00,$00,$00,$22,$00,$00,$00,$00,

 $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
 $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
 $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
 $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,

 $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
 $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
 $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
 $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 );

 Instr8088 : array[$00..$FF] of string[9]=
 (
 {00-3F}
 'nop' ,'lxi/b, *' ,'stax/b','inx/b'  ,'inr/b' ,'dcr/b' ,'mvi/b, #' ,'rlc',
 '!'   ,'dad/b'    ,'ldax/b','dcx/b'  ,'inr/c' ,'dcr/c' ,'mvi/c, #' ,'rrc',
 '!'   ,'lxi/d, *' ,'stax/d','inx/d'  ,'inr/d' ,'dcr/d' ,'mvi/d, #' ,'ral',
 '!'   ,'dad/d   ' ,'ldax/d','dcx/d'  ,'inr/e' ,'dcr/e' ,'mvi/e, #' ,'rar',
 '!'   ,'lxi/h, *' ,'shld/*','inx/h'  ,'inr/h' ,'dcr/h' ,'mvi/h, #' ,'daa',
 '!'   ,'dad/h'    ,'lhld/*','dcx/h'  ,'inr/l' ,'dcr/l' ,'mvi/l, #' ,'cma',
 '!'   ,'lxi/sp, *','sta/*' ,'inx/sp' ,'inr/m' ,'dcr/m' ,'mvi/m, #' ,'stc',
 '!'   ,'dad/sp'   ,'lda/*' ,'dcx/sp' ,'inr/a' ,'dcr/a' ,'mvi/a, #' ,'cmc',
 {40-7F}
 'mov/b, b' ,'mov/b, c' ,'mov/b, d' ,'mov/b, e' ,'mov/b, h' ,'mov/b, l' ,'mov/b, m' ,'mov/b, a' ,
 'mov/c, b' ,'mov/c, c' ,'mov/c, d' ,'mov/c, e' ,'mov/c, h' ,'mov/c, l' ,'mov/c, m' ,'mov/c, a',
 'mov/d, b' ,'mov/d, c' ,'mov/d, d' ,'mov/d, e' ,'mov/d, h' ,'mov/d, l' ,'mov/d, m' ,'mov/d, a',
 'mov/e, b' ,'mov/e, c' ,'mov/e, d' ,'mov/e, e' ,'mov/e, h' ,'mov/e, l' ,'mov/e, m' ,'mov/e, a',
 'mov/h, b' ,'mov/h, c' ,'mov/h, d' ,'mov/h, e' ,'mov/h, h' ,'mov/h, l' ,'mov/h, m' ,'mov/h, a',
 'mov/l, b' ,'mov/l, c' ,'mov/l, d' ,'mov/l, e' ,'mov/l, h' ,'mov/l, l' ,'mov/l, m' ,'mov/l, a',
 'mov/m, b' ,'mov/m, c' ,'mov/m, d' ,'mov/m, e' ,'mov/m, h' ,'mov/m, l' ,'hlt'      ,'mov/m, a',
 'mov/a, b' ,'mov/a, c' ,'mov/a, d' ,'mov/a, e' ,'mov/a, h' ,'mov/a, l' ,'mov/a, m' ,'mov/a, a',
 {80-BF}
 'add/b' ,'add/c' ,'add/d' ,'add/e' ,'add/h' ,'add/l' ,'add/m' ,'add/a' ,
 'adc/b' ,'adc/c' ,'adc/d' ,'adc/e' ,'adc/h' ,'adc/l' ,'adc/m' ,'adc/a' ,
 'sub/b' ,'sub/c' ,'sub/d' ,'sub/e' ,'sub/h' ,'sub/l' ,'sub/m' ,'sub/a' ,
 'sbb/b' ,'sbb/c' ,'sbb/d' ,'sbb/e' ,'sbb/h' ,'sbb/l' ,'sbb/m' ,'sbb/a' ,
 'ana/b' ,'ana/c' ,'ana/d' ,'ana/e' ,'ana/h' ,'ana/l' ,'ana/m' ,'ana/a' ,
 'xra/b' ,'xra/c' ,'xra/d' ,'xra/e' ,'xra/h' ,'xra/l' ,'xra/m' ,'xra/a' ,
 'ora/b' ,'ora/c' ,'ora/d' ,'ora/e' ,'ora/h' ,'ora/l' ,'ora/m' ,'ora/a' ,
 'cmp/b' ,'cmp/c' ,'cmp/d' ,'cmp/e' ,'cmp/h' ,'cmp/l' ,'cmp/m' ,'cmp/a' ,
 {C0-FF}
 'rnz'  ,'pop/b'  ,'jnz/&' ,'jmp/&' ,'cnz/&' ,'push/b'  ,'adi/#' ,'rst/0' ,
 'rz'   ,'ret'    ,'jz/&'  ,'!'     ,'cz/&'  ,'call/&'  ,'aci/#' ,'rst/1' ,{@0}
 'rnc'  ,'pop/d'  ,'jnc/&' ,'out/#' ,'cnc/&' ,'push/d'  ,'sui/#' ,'rst/2' ,
 'rc'   ,'!'      ,'jc/&'  ,'in/#'  ,'cc/&'  ,'!'       ,'sbi/#' ,'rst/3' ,{@2}
 'rpo'  ,'pop/h'  ,'jpo/&' ,'xthl'  ,'cpo/&' ,'push/h'  ,'ani/#' ,'rst/4' ,
 'rpe'  ,'pchl'   ,'jpe/&' ,'xchg'  ,'cpe/&' ,'!'       ,'xri/#' ,'rst/5' ,{@1}
 'rp'   ,'pop/psw','jp/&'  ,'di'    ,'cp/&'  ,'push/psw','ori/#' ,'rst/6' ,
 'rm'   ,'sphl'   ,'jm/&'  ,'ei'    ,'cm/&'  ,'!'       ,'cpi/#' ,'rst/7' );{@3}

{---------------------------------------------------------------------------}
{ команды префикса CB                                                       }
{---------------------------------------------------------------------------}
 InstrCB8088 : array[$00..$FF] of string[48]=
 (
 {команды 00-3F}
 'sta/TMP\mov/a, b\rlc\mov/b, a\lda/TMP','sta/TMP\mov/a, c\rlc\mov/c, a\lda/TMP',
 'sta/TMP\mov/a, d\rlc\mov/d, a\lda/TMP','sta/TMP\mov/a, e\rlc\mov/e, a\lda/TMP',
 'sta/TMP\mov/a, h\rlc\mov/h, a\lda/TMP','sta/TMP\mov/a, l\rlc\mov/l, a\lda/TMP',
 'sta/TMP\mov/a, m\rlc\mov/m, a\lda/TMP','rlc',
 'sta/TMP\mov/a, b\rrc\mov/b, a\lda/TMP','sta/TMP\mov/a, c\rrc\mov/c, a\lda/TMP',
 'sta/TMP\mov/a, d\rrc\mov/d, a\lda/TMP','sta/TMP\mov/a, e\rrc\mov/e, a\lda/TMP',
 'sta/TMP\mov/a, h\rrc\mov/h, a\lda/TMP','sta/TMP\mov/a, l\rrc\mov/l, a\lda/TMP',
 'sta/TMP\mov/a, m\rrc\mov/m, a\lda/TMP','rrc',
 'sta/TMP\mov/a, b\ral\mov/b, a\lda/TMP','sta/TMP\mov/a, c\ral\mov/c, a\lda/TMP',
 'sta/TMP\mov/a, d\ral\mov/d, a\lda/TMP','sta/TMP\mov/a, e\ral\mov/e, a\lda/TMP',
 'sta/TMP\mov/a, h\ral\mov/h, a\lda/TMP','sta/TMP\mov/a, l\ral\mov/l, a\lda/TMP',
 'sta/TMP\mov/a, m\ral\mov/m, a\lda/TMP','ral',
 'sta/TMP\mov/a, b\rar\mov/b, a\lda/TMP','sta/TMP\mov/a, c\rar\mov/c, a\lda/TMP',
 'sta/TMP\mov/a, d\rar\mov/d, a\lda/TMP','sta/TMP\mov/a, e\rar\mov/e, a\lda/TMP',
 'sta/TMP\mov/a, h\rar\mov/h, a\lda/TMP','sta/TMP\mov/a, l\rar\mov/l, a\lda/TMP',
 'sta/TMP\mov/a, m\rar\mov/m, a\lda/TMP','rar',
 'sta/TMP\mov/a, b\ora/a\ral\mov/b, a\lda/TMP','sta/TMP\mov/a, c\ora/a\ral\mov/c, a\lda/TMP',
 'sta/TMP\mov/a, c\ora/a\ral\mov/c, a\lda/TMP','sta/TMP\mov/a, d\ora/a\ral\mov/d, a\lda/TMP',
 'sta/TMP\mov/a, h\ora/a\ral\mov/h, a\lda/TMP','sta/TMP\mov/a, l\ora/a\ral\mov/l, a\lda/TMP',
 'sta/TMP\mov/a, m\ora/a\ral\mov/m, a\lda/TMP','ora/a\ral',
 'call/sraB', 'call/sraC', 'call/sraD', 'call/sraE',
 'call/sraH', 'call/sraL', 'call/sraM',
 {sraA}'rlc\jnc/$+9\rrc\stc\rar\jmp/$+6\rrc\ora/a\rar',
 'sta/TMP\mov/a, b\rlc\ori/001h\mov/b, a\lda/TMP','sta/TMP\mov/a, c\rlc\ori/001h\mov/c, a\lda/TMP',
 'sta/TMP\mov/a, d\rlc\ori/001h\mov/d, a\lda/TMP','sta/TMP\mov/a, e\rlc\ori/001h\mov/e, a\lda/TMP',
 'sta/TMP\mov/a, h\rlc\ori/001h\mov/h, a\lda/TMP','sta/TMP\mov/a, l\rlc\ori/001h\mov/l, a\lda/TMP',
 'sta/TMP\mov/a, m\rlc\ori/001h\mov/m, a\lda/TMP','rlc\ori/001h',
 'sta/TMP\mov/a, b\ora/a\rar\mov/b, a\lda/TMP','sta/TMP\mov/a, c\ora/a\rar\mov/c, a\lda/TMP',
 'sta/TMP\mov/a, d\ora/a\rar\mov/d, a\lda/TMP','sta/TMP\mov/a, e\ora/a\rar\mov/e, a\lda/TMP',
 'sta/TMP\mov/a, h\ora/a\rar\mov/h, a\lda/TMP','sta/TMP\mov/a, l\ora/a\rar\mov/l, a\lda/TMP',
 'sta/TMP\mov/a, m\ora/a\rar\mov/m, a\lda/TMP','ora/a\rar',
 {команды 40-7F}
 'sta/TMP\mov/a, b\cpi/001h\mov/b, a\lda/TMP','sta/TMP\mov/a, c\cpi/001h\mov/c, a\lda/TMP',
 'sta/TMP\mov/a, d\cpi/001h\mov/d, a\lda/TMP','sta/TMP\mov/a, e\cpi/001h\mov/e, a\lda/TMP',
 'sta/TMP\mov/a, h\cpi/001h\mov/h, a\lda/TMP','sta/TMP\mov/a, l\cpi/001h\mov/l, a\lda/TMP',
 'sta/TMP\mov/a, m\cpi/001h\mov/m, a\lda/TMP','cpi/001h',
 'sta/TMP\mov/a, b\cpi/002h\mov/b, a\lda/TMP','sta/TMP\mov/a, c\cpi/002h\mov/c, a\lda/TMP',
 'sta/TMP\mov/a, d\cpi/002h\mov/d, a\lda/TMP','sta/TMP\mov/a, e\cpi/002h\mov/e, a\lda/TMP',
 'sta/TMP\mov/a, h\cpi/002h\mov/h, a\lda/TMP','sta/TMP\mov/a, l\cpi/002h\mov/l, a\lda/TMP',
 'sta/TMP\mov/a, m\cpi/002h\mov/m, a\lda/TMP','cpi/002h',
 'sta/TMP\mov/a, b\cpi/004h\mov/b, a\lda/TMP','sta/TMP\mov/a, c\cpi/004h\mov/c, a\lda/TMP',
 'sta/TMP\mov/a, d\cpi/004h\mov/d, a\lda/TMP','sta/TMP\mov/a, e\cpi/004h\mov/e, a\lda/TMP',
 'sta/TMP\mov/a, h\cpi/004h\mov/h, a\lda/TMP','sta/TMP\mov/a, l\cpi/004h\mov/l, a\lda/TMP',
 'sta/TMP\mov/a, m\cpi/004h\mov/m, a\lda/TMP','cpi/004h',
 'sta/TMP\mov/a, b\cpi/008h\mov/b, a\lda/TMP','sta/TMP\mov/a, c\cpi/008h\mov/c, a\lda/TMP',
 'sta/TMP\mov/a, d\cpi/008h\mov/d, a\lda/TMP','sta/TMP\mov/a, e\cpi/008h\mov/e, a\lda/TMP',
 'sta/TMP\mov/a, h\cpi/008h\mov/h, a\lda/TMP','sta/TMP\mov/a, l\cpi/008h\mov/l, a\lda/TMP',
 'sta/TMP\mov/a, m\cpi/008h\mov/m, a\lda/TMP','cpi/008h',
 'sta/TMP\mov/a, b\cpi/010h\mov/b, a\lda/TMP','sta/TMP\mov/a, c\cpi/010h\mov/c, a\lda/TMP',
 'sta/TMP\mov/a, d\cpi/010h\mov/d, a\lda/TMP','sta/TMP\mov/a, e\cpi/010h\mov/e, a\lda/TMP',
 'sta/TMP\mov/a, h\cpi/010h\mov/h, a\lda/TMP','sta/TMP\mov/a, l\cpi/010h\mov/l, a\lda/TMP',
 'sta/TMP\mov/a, m\cpi/010h\mov/m, a\lda/TMP','cpi/010h',
 'sta/TMP\mov/a, b\cpi/020h\mov/b, a\lda/TMP','sta/TMP\mov/a, c\cpi/020h\mov/c, a\lda/TMP',
 'sta/TMP\mov/a, d\cpi/020h\mov/d, a\lda/TMP','sta/TMP\mov/a, e\cpi/020h\mov/e, a\lda/TMP',
 'sta/TMP\mov/a, h\cpi/020h\mov/h, a\lda/TMP','sta/TMP\mov/a, l\cpi/020h\mov/l, a\lda/TMP',
 'sta/TMP\mov/a, m\cpi/020h\mov/m, a\lda/TMP','cpi/020h',
 'sta/TMP\mov/a, b\cpi/040h\mov/b, a\lda/TMP','sta/TMP\mov/a, c\cpi/040h\mov/c, a\lda/TMP',
 'sta/TMP\mov/a, d\cpi/040h\mov/d, a\lda/TMP','sta/TMP\mov/a, e\cpi/040h\mov/e, a\lda/TMP',
 'sta/TMP\mov/a, h\cpi/040h\mov/h, a\lda/TMP','sta/TMP\mov/a, l\cpi/040h\mov/l, a\lda/TMP',
 'sta/TMP\mov/a, m\cpi/040h\mov/m, a\lda/TMP','cpi/040h',
 'sta/TMP\mov/a, b\cpi/080h\mov/b, a\lda/TMP','sta/TMP\mov/a, c\cpi/080h\mov/c, a\lda/TMP',
 'sta/TMP\mov/a, d\cpi/080h\mov/d, a\lda/TMP','sta/TMP\mov/a, e\cpi/080h\mov/e, a\lda/TMP',
 'sta/TMP\mov/a, h\cpi/080h\mov/h, a\lda/TMP','sta/TMP\mov/a, l\cpi/080h\mov/l, a\lda/TMP',
 'sta/TMP\mov/a, m\cpi/080h\mov/m, a\lda/TMP','cpi/080h',
 {команды 80-BF}
 'push/psw\mov/a, b\ani/0FEh\mov/b, a\pop/psw','push/psw\mov/a, c\ani/0FEh\mov/c, a\pop/psw',
 'push/psw\mov/a, d\ani/0FEh\mov/d, a\pop/psw','push/psw\mov/a, e\ani/0FEh\mov/e, a\pop/psw',
 'push/psw\mov/a, h\ani/0FEh\mov/h, a\pop/psw','push/psw\mov/a, l\ani/0FEh\mov/l, a\pop/psw',
 'push/psw\mov/a, m\ani/0FEh\mov/m, a\pop/psw','ani/0FEh',
 'push/psw\mov/a, b\ani/0FDh\mov/b, a\pop/psw','push/psw\mov/a, c\ani/0FDh\mov/c, a\pop/psw',
 'push/psw\mov/a, d\ani/0FDh\mov/d, a\pop/psw','push/psw\mov/a, e\ani/0FDh\mov/e, a\pop/psw',
 'push/psw\mov/a, h\ani/0FDh\mov/h, a\pop/psw','push/psw\mov/a, l\ani/0FDh\mov/l, a\pop/psw',
 'push/psw\mov/a, m\ani/0FDh\mov/m, a\pop/psw','ani/0FDh',
 'push/psw\mov/a, b\ani/0FBh\mov/b, a\pop/psw','push/psw\mov/a, c\ani/0FBh\mov/c, a\pop/psw',
 'push/psw\mov/a, d\ani/0FBh\mov/d, a\pop/psw','push/psw\mov/a, e\ani/0FBh\mov/e, a\pop/psw',
 'push/psw\mov/a, h\ani/0FBh\mov/h, a\pop/psw','push/psw\mov/a, l\ani/0FBh\mov/l, a\pop/psw',
 'push/psw\mov/a, m\ani/0FBh\mov/m, a\pop/psw','ani/0FBh',
 'push/psw\mov/a, b\ani/0F7h\mov/b, a\pop/psw','push/psw\mov/a, c\ani/0F7h\mov/c, a\pop/psw',
 'push/psw\mov/a, d\ani/0F7h\mov/d, a\pop/psw','push/psw\mov/a, e\ani/0F7h\mov/e, a\pop/psw',
 'push/psw\mov/a, h\ani/0F7h\mov/h, a\pop/psw','push/psw\mov/a, l\ani/0F7h\mov/l, a\pop/psw',
 'push/psw\mov/a, m\ani/0F7h\mov/m, a\pop/psw','ani/0F7h',
 'push/psw\mov/a, b\ani/0EFh\mov/b, a\pop/psw','push/psw\mov/a, c\ani/0EFh\mov/c, a\pop/psw',
 'push/psw\mov/a, d\ani/0EFh\mov/d, a\pop/psw','push/psw\mov/a, e\ani/0EFh\mov/e, a\pop/psw',
 'push/psw\mov/a, h\ani/0EFh\mov/h, a\pop/psw','push/psw\mov/a, l\ani/0EFh\mov/l, a\pop/psw',
 'push/psw\mov/a, m\ani/0EFh\mov/m, a\pop/psw','ani/0EFh',
 'push/psw\mov/a, b\ani/0DFh\mov/b, a\pop/psw','push/psw\mov/a, c\ani/0DFh\mov/c, a\pop/psw',
 'push/psw\mov/a, d\ani/0DFh\mov/d, a\pop/psw','push/psw\mov/a, e\ani/0DFh\mov/e, a\pop/psw',
 'push/psw\mov/a, h\ani/0DFh\mov/h, a\pop/psw','push/psw\mov/a, l\ani/0DFh\mov/l, a\pop/psw',
 'push/psw\mov/a, m\ani/0DFh\mov/m, a\pop/psw','ani/0DFh',
 'push/psw\mov/a, b\ani/0BFh\mov/b, a\pop/psw','push/psw\mov/a, c\ani/0BFh\mov/c, a\pop/psw',
 'push/psw\mov/a, d\ani/0BFh\mov/d, a\pop/psw','push/psw\mov/a, e\ani/0BFh\mov/e, a\pop/psw',
 'push/psw\mov/a, h\ani/0BFh\mov/h, a\pop/psw','push/psw\mov/a, l\ani/0BFh\mov/l, a\pop/psw',
 'push/psw\mov/a, m\ani/0BFh\mov/m, a\pop/psw','ani/0BFh',
 'push/psw\mov/a, b\ani/07Fh\mov/b, a\pop/psw','push/psw\mov/a, c\ani/07Fh\mov/c, a\pop/psw',
 'push/psw\mov/a, d\ani/07Fh\mov/d, a\pop/psw','push/psw\mov/a, e\ani/07Fh\mov/e, a\pop/psw',
 'push/psw\mov/a, h\ani/07Fh\mov/h, a\pop/psw','push/psw\mov/a, l\ani/07Fh\mov/l, a\pop/psw',
 'push/psw\mov/a, m\ani/07Fh\mov/m, a\pop/psw','ani/07Fh',
 {команды C0-FF}
 'push/psw\mov/a, b\ori/001h\mov/b, a\pop/psw','push/psw\mov/a, c\ori/001h\mov/c, a\pop/psw',
 'push/psw\mov/a, d\ori/001h\mov/d, a\pop/psw','push/psw\mov/a, e\ori/001h\mov/e, a\pop/psw',
 'push/psw\mov/a, h\ori/001h\mov/h, a\pop/psw','push/psw\mov/a, l\ori/001h\mov/l, a\pop/psw',
 'push/psw\mov/a, m\ori/001h\mov/m, a\pop/psw','ori/001h',
 'push/psw\mov/a, b\ori/002h\mov/b, a\pop/psw','push/psw\mov/a, c\ori/002h\mov/c, a\pop/psw',
 'push/psw\mov/a, d\ori/002h\mov/d, a\pop/psw','push/psw\mov/a, e\ori/002h\mov/e, a\pop/psw',
 'push/psw\mov/a, h\ori/002h\mov/h, a\pop/psw','push/psw\mov/a, l\ori/002h\mov/l, a\pop/psw',
 'push/psw\mov/a, m\ori/002h\mov/m, a\pop/psw','ori/002h',
 'push/psw\mov/a, b\ori/004h\mov/b, a\pop/psw','push/psw\mov/a, c\ori/004h\mov/c, a\pop/psw',
 'push/psw\mov/a, d\ori/004h\mov/d, a\pop/psw','push/psw\mov/a, e\ori/004h\mov/e, a\pop/psw',
 'push/psw\mov/a, h\ori/004h\mov/h, a\pop/psw','push/psw\mov/a, l\ori/004h\mov/l, a\pop/psw',
 'push/psw\mov/a, m\ori/004h\mov/m, a\pop/psw','ori/004h',
 'push/psw\mov/a, b\ori/008h\mov/b, a\pop/psw','push/psw\mov/a, c\ori/008h\mov/c, a\pop/psw',
 'push/psw\mov/a, d\ori/008h\mov/d, a\pop/psw','push/psw\mov/a, e\ori/008h\mov/e, a\pop/psw',
 'push/psw\mov/a, h\ori/008h\mov/h, a\pop/psw','push/psw\mov/a, l\ori/008h\mov/l, a\pop/psw',
 'push/psw\mov/a, m\ori/008h\mov/m, a\pop/psw','ori/008h',
 'push/psw\mov/a, b\ori/010h\mov/b, a\pop/psw','push/psw\mov/a, c\ori/010h\mov/c, a\pop/psw',
 'push/psw\mov/a, d\ori/010h\mov/d, a\pop/psw','push/psw\mov/a, e\ori/010h\mov/e, a\pop/psw',
 'push/psw\mov/a, h\ori/010h\mov/h, a\pop/psw','push/psw\mov/a, l\ori/010h\mov/l, a\pop/psw',
 'push/psw\mov/a, m\ori/010h\mov/m, a\pop/psw','ori/010h',
 'push/psw\mov/a, b\ori/020h\mov/b, a\pop/psw','push/psw\mov/a, c\ori/020h\mov/c, a\pop/psw',
 'push/psw\mov/a, d\ori/020h\mov/d, a\pop/psw','push/psw\mov/a, e\ori/020h\mov/e, a\pop/psw',
 'push/psw\mov/a, h\ori/020h\mov/h, a\pop/psw','push/psw\mov/a, l\ori/020h\mov/l, a\pop/psw',
 'push/psw\mov/a, m\ori/020h\mov/m, a\pop/psw','ori/020h',
 'push/psw\mov/a, b\ori/040h\mov/b, a\pop/psw','push/psw\mov/a, c\ori/040h\mov/c, a\pop/psw',
 'push/psw\mov/a, d\ori/040h\mov/d, a\pop/psw','push/psw\mov/a, e\ori/040h\mov/e, a\pop/psw',
 'push/psw\mov/a, h\ori/040h\mov/h, a\pop/psw','push/psw\mov/a, l\ori/040h\mov/l, a\pop/psw',
 'push/psw\mov/a, m\ori/040h\mov/m, a\pop/psw','ori/040h',
 'push/psw\mov/a, b\ori/080h\mov/b, a\pop/psw','push/psw\mov/a, c\ori/080h\mov/c, a\pop/psw',
 'push/psw\mov/a, d\ori/080h\mov/d, a\pop/psw','push/psw\mov/a, e\ori/080h\mov/e, a\pop/psw',
 'push/psw\mov/a, h\ori/080h\mov/h, a\pop/psw','push/psw\mov/a, l\ori/080h\mov/l, a\pop/psw',
 'push/psw\mov/a, m\ori/080h\mov/m, a\pop/psw','ori/080h');
{---------------------------------------------------------------------------}
{ команды префиксов DD, FD   подпрефикс CB не реализован                    }
{---------------------------------------------------------------------------}
 InstrDD8088_1 : array[$00..$3F] of string[75]=
 (
 {команды 00-3F}
 '!' ,'!' ,'!' ,'!' ,'!' ,'!' ,'!' ,'!', '!' ,
 'push/h\lhld/^\push/psw\dad/b\pop/psw\shld/^\pop/h',
 '!' ,'!' ,'!' ,'!' ,'!' ,'!', '!' ,'!' ,'!' ,'!' ,'!' ,'!' ,'!' ,'!', '!' ,
 'push/h\lhld/^\push/psw\dad/d\pop/psw\shld/^\pop/h',
 '!' ,'!' ,'!' ,'!' ,'!' ,'!', '!' ,
 'push/h\lxi/h, *\shld/^\pop/h' ,'push/h\lhld/^\shld/*\pop/h',
 'push/h\lhld/^\inx/h\shld/^\pop/h' ,'push/h\lhld/^\inr/h\shld/^\pop/h',
 'push/h\lhld/^\dcr/h\shld/^\pop/h' ,'push/h\lhld/^\mvi/h, #\shld/^\pop/h' ,
 '!', '!' ,'push/h\lhld/^\push/psw\dad/h\pop/psw\shld/^\pop/h' ,
 'push/h\lhld/*\shld/^\pop/h',
 'push/h\lhld/^\dcx/h\shld/^\pop/h','push/h\lhld/^\inr/l\shld/^\pop/h',
 'push/h\lhld/^\dcr/l\shld/^\pop/h' ,'push/h\lhld/^\mvi/l, #\shld/^\pop/h' ,
 '!', '!' ,'!','!' ,'!' ,
 'push/h\push/b\lhld/^\lxi/b, 00#\dad/b\inr/m\pop/b\pop/h' ,
 'push/h\push/b\lhld/^\lxi/b, 00#\dad/b\dcr/m\pop/b\pop/h' ,
 'push/h\push/b\lhld/^\lxi/b, 00#\push/psw\dad/b\pop/psw\mvi/m, #\pop/b\pop/h' , '!', '!' ,
 'push/h\lhld/^\push/psw\dad/sp\pop/psw\shld/^\pop/h' ,'!' ,'!' ,'!' ,'!' ,'!' ,'!');

 InstrDD8088_2 : array[$00..$3F] of string[84]=
 (
 {кодманды 40-7F}
 '!','!','!','!','push/h\lhld/^\mov/b, h\pop/h','push/h\lhld/^\mov/b, l\pop/h',
 'push/h\push/d\lhld/^\lxi/d, 00#\push/psw\dad/d\pop/psw\mov/b, m\pop/d\pop/h' ,'!', '!' ,'!',
 '!' ,'!' ,'push/h\lhld/^\mov/c, h\pop/h' ,'push/h\lhld/^\mov/c, l\pop/h' ,
 'push/h\push/d\lhld/^\lxi/d, 00#\push/psw\dad/d\pop/psw\mov/c, m\pop/d\pop/h' ,'!', '!' ,'!',
 '!' ,'!' ,'push/h\lhld/^\mov/d, h\pop/h' ,'push/h\lhld/^\mov/d, l\pop/h' ,
 'push/h\push/b\lhld/^\lxi/b, 00#\push/psw\dad/b\pop/psw\mov/d, m\pop/b\pop/h' ,'!', '!' ,'!',
 '!' ,'!' ,'push/h\lhld/^\mov/e, h\pop/h' ,'push/h\lhld/^\mov/e, l\pop/h' ,
 'push/h\push/b\lhld/^\lxi/b, 00#\push/psw\dad/b\pop/psw\mov/e, m\pop/b\pop/h' ,'!',
 'push/h\mov/h, b\shld/^\pop/h' ,'push/h\mov/h, c\shld/^\pop/h' ,
 'push/h\mov/h, d\shld/^\pop/h', 'push/h\mov/h, e\shld/^\pop/h' ,
 'push/h\mov/h, h\shld/^\pop/h' ,'push/h\mov/h, l\shld/^\pop/h',
 'push/b\push/h\lhld/^\lxi/b, 00#\push/psw\dad/b\pop/psw\mov/b, m\pop/h\mov/h, b\pop/b' ,
 'push/h\mov/h, a\shld/^\pop/h', 'push/h\mov/l, b\shld/^\pop/h' ,
 'push/h\mov/l, c\shld/^\pop/h' ,'push/h\mov/l, d\shld/^\pop/h',
 'push/h\mov/l, e\shld/^\pop/h' ,'push/h\mov/l, h\shld/^\pop/h' ,
 'push/h\mov/l, l\shld/^\pop/h',
 'push/b\push/h\lhld/^\lxi/b, 00#\push/psw\dad/b\pop/psw\mov/b, m\pop/h\mov/l, b\pop/b' ,
 'push/h\mov/l, a\shld/^\pop/h',
 'push/h\push/b\lhld/^\lxi/b, 00#\push/psw\dad/b\pop/psw\mov/m, b\pop/b\pop/h' ,
 'push/h\push/b\lhld/^\lxi/b, 00#\push/psw\dad/b\pop/psw\mov/m, c\pop/b\pop/h' ,
 'push/h\push/b\lhld/^\lxi/b, 00#\push/psw\dad/b\pop/psw\mov/m, d\pop/b\pop/h' ,
 'push/h\push/b\lhld/^\lxi/b, 00#\push/psw\dad/b\pop/psw\mov/m, e\pop/b\pop/h' ,
 'push/h\push/b\lhld/^\lxi/b, 00#\push/psw\dad/b\pop/psw\mov/m, h\pop/b\pop/h' ,
 'push/h\push/b\lhld/^\lxi/b, 00#\push/psw\dad/b\pop/psw\mov/m, l\pop/b\pop/h' ,'!' ,
 'push/h\push/b\lhld/^\lxi/b, 00#\push/psw\dad/b\pop/psw\mov/m, a\pop/b\pop/h','!','!','!','!',
 'push/h\lhld/^\mov/a, h\pop/h' ,'push/h\lhld/^\mov/a, l\pop/h' ,
 'push/h\push/b\lhld/^\lxi/b, 00#\push/psw\dad/b\pop/psw\mov/a, m\pop/b\pop/h' ,'!');

 InstrDD8088_3 : array[$00..$3F] of string[72]=
 (
 {команды 80-BF}
 '!','!','!','!','push/h\lhld/^\add/h\pop/h' ,'push/h\lhld/^\add/l\pop/h' ,
 'push/h\push/b\lhld/^\lxi/b, 00#\push/psw\dad/b\pop/psw\add/m\pop/b\pop/h' ,
 '!','!','!','!','!','push/h\lhld/^\adc/h\pop/h' ,'push/h\lhld/^\adc/l\pop/h' ,
 'push/h\push/b\lhld/^\lxi/b, 00#\push/psw\dad/b\pop/psw\adc/m\pop/b\pop/h' ,
 '!','!','!','!','!','push/h\lhld/^\sub/h\pop/h' ,'push/h\lhld/^\sub/l\pop/h' ,
 'push/h\push/b\lhld/^\lxi/b, 00#\push/psw\dad/b\pop/psw\sub/m\pop/b\pop/h' ,
 '!','!','!','!','!','push/h\lhld/^\sbb/h\pop/h' ,'push/h\lhld/^\sbb/l\pop/h' ,
 'push/h\push/b\lhld/^\lxi/b, 00#\push/psw\dad/b\pop/psw\sbb/m\pop/b\pop/h' ,
 '!','!','!','!','!','push/h\lhld/^\ana/h\pop/h' ,'push/h\lhld/^\ana/l\pop/h' ,
 'push/h\push/b\lhld/^\lxi/b, 00#\push/psw\dad/b\pop/psw\ana/m\pop/b\pop/h' ,
 '!','!','!','!','!','push/h\lhld/^\xra/h\pop/h' ,'push/h\lhld/^\xra/l\pop/h' ,
 'push/h\push/b\lhld/^\lxi/b, 00#\push/psw\dad/b\pop/psw\xra/m\pop/b\pop/h' ,
 '!','!','!','!','!','push/h\lhld/^\ora/h\pop/h' ,'push/h\lhld/^\ora/l\pop/h' ,
 'push/h\push/b\lhld/^\lxi/b, 00#\push/psw\dad/b\pop/psw\ora/m\pop/b\pop/h' ,
 '!','!','!','!','!','push/h\lhld/^\cmp/h\pop/h' ,'push/h\lhld/^\cmp/l\pop/h' ,
 'push/h\push/b\lhld/^\lxi/b, 00#\push/psw\dad/b\pop/psw\cmp/m\pop/b\pop/h' ,'!');

 InstrDD8088_4 : array[$00..$39] of string[31]=
 (
 {команды C0-FF}  {подпрефикс CB не реализован}
 '!' ,'!' ,'!'  ,'!'     ,'!'  ,'!'     ,'!'     ,'!',
 '!' ,'!' ,'!'  ,{@}'!'  ,'!'  ,'!'     ,'!'     ,'!',
 '!' ,'!' ,'!'  ,'!'     ,'!'  ,'!'     ,'!'     ,'!',
 '!' ,'!' ,'!'  ,'!'     ,'!'  ,'!'     ,'!'     ,'!',
 '!' ,'xthl\shld/^\pop/h' ,'!' ,'push/h\lhld/^\xthl\shld/^\pop/h' ,
 '!' ,'push/h\lhld/^\xthl','!' ,'!',
 '!' ,'push/h\lhld/^\xthl\ret' ,'!' ,'!' ,'!' ,'!' ,'!' ,'!',
 '!' ,'!' ,'!'  ,'!' ,'!' ,'!' ,'!' ,'!' ,
 '!' ,'shld/TEMP\lhld/^\sphl\lhld/TEMP');

{---------------------------------------------------------------------------}
{ команды префикса ED                                                       }
{---------------------------------------------------------------------------}
{ команды 00-3F,80-9F,BC-FF интерпретируются, как nop/nop }

 InstrED8088_2 : array[$00..$3F] of string[48]=
 (
 {команды 40-7F}  {заменены все, кроме некоторых IN, OUT, а также IM}
 {RETN, RETI заменены на RET}
 {in_B_C}'push/psw\mov/a, c\sta/$+4\in/0\mov/b, a\pop/psw',
 {out_C_B}'push/psw\mov/a, c\sta/$+5\mov/a, b\out/0\pop/psw','call/sbcHB',
 'push/h\mov/h, b\mov/l, c\shld/*\pop/h','cma\inr/a',{RETN}'ret',
 {!}'call/IM0','sta/I',
 {in_C_C}'push/psw\mov/a, c\sta/$+4\in/0\mov/c, a\pop/psw',
 {out_C_C}'push/psw\mov/a, c\sta/$+5\mov/a, c\out/0\pop/psw','call/adcHB',
 'push/h\lhld/*\mov/b, h\mov/c, l\pop/h','cma\inr/a',{RETI}'ret',
 {!}'call/IM01','sta/R',
 {in_D_C}'push/psw\mov/a, c\sta/$+4\in/0\mov/d, a\pop/psw',
 {out_C_D}'push/psw\mov/a, c\sta/$+5\mov/a, d\out/0\pop/psw','call/sbcHD',
 'xchg\shld/*\xchg','cma\inr/a',{RETN}'ret',{!}'call/IM1','lda/I',
 {in_E_C}'push/psw\mov/a, c\sta/$+4\in/0\mov/e, a\pop/psw',
 {out_C_E}'push/psw\mov/a, c\sta/$+5\mov/a, e\out/0\pop/psw','call/adcHD',
 'xchg\lhld/*\xchg','cma\inr/a',{RETN}'ret',{!}'call/IM2','lda/R',
 {in_H_C}'push/psw\mov/a, c\sta/$+4\in/0\mov/h, a\pop/psw',
 {out_C_H}'push/psw\mov/a, c\sta/$+5\mov/a, l\out/0\pop/psw','lxi/h, 00000h',
 'shld/*','cma\inr/a',{RETN}'ret',{!}'call/IM0','call/RRD',
 {in_L_C}'push/psw\mov/a, c\sta/$+4\in/0\mov/l, a\pop/psw',
 {out_C_L}'push/psw\mov/a, c\sta/$+5\mov/a, l\out/0\pop/psw','call/adcHH',
 'lhld/*','cma\inr/a',{RETN}'ret',{!}'call/IM01','call/RLD',
 {!}'call/in_0_C',
 {out_C_0}'push/psw\mov/a, c\sta/$+5\xra/a\out/0\pop/psw','call/sbcHS',
 'push/h\lxi/h, 00000h\dad/sp\shld/*\pop/h',
 'cma\inr/a',{RETN}'ret',{!}'call/IM1','nop/nop',
 {in_A_C}'mov/a, c\sta/$+4\in/0',
 {out_C_A}'push/psw\mov/a, c\sta/$+5\pop/psw','call/adcHC',
 'shld/TEMP\lhld/*\sphl\lhld/TEMP',
 'cma\inr/a',{RETN}'ret',{!}'call/IM2','nop/nop');

 InstrED8088_4 : array[$00..$1B] of string[86]=
 {команды A0-BB}
 (
 {LDI}'push/psw\mov/a, m\stax/d\inx/h\inx/d\inx/b\pop/psw' ,
 {CPI}'cmp/m\inx/h\dcx/b' ,
 {INI}'sta/TMP\mov/a, c\sta/$+4\in/0\mov/m, a\inx/h\dcr/b\lda/TMP' ,
 {OUTI}'sta/TMP\mov/a, c\sta/$+4\out/0\mov/m, a\inx/h\dcr/b\lda/TMP',
 'nop/nop','nop/nop','nop/nop','nop/nop',
 {LDD}'push/psw\mov/a, m\stax/d\dcx/h\dcx/d\dcx/b\pop/psw' ,
 {CPD}'cmp/m\dcx/h\dcx/b' ,
 {IND}'sta/TMP\mov/a, c\sta/$+4\in/0\mov/m, a\dcx/h\dcr/b\lda/TMP' ,
 {OUTD}'sta/TMP\mov/a, c\sta/$+4\out/0\mov/m, a\dcx/h\dcr/b\lda/TMP',
 'nop/nop','nop/nop','nop/nop','nop/nop',
 {LDIR}'push/psw\mov/a, m\stax/d\inx/h\inx/d\dcx/b\mov/a, b\ora/c\jnz/$-7\pop/psw',
 {CPIR}'cmp/m\jz/$+21\inx/h\dcx/b\sta/TMP\mov/a, b\ora/c\lda/TMP\jnz/$-14\xra/a\inr/a\lda/TMP',
 {INIR}'sta/TMP\mov/a, c\sta/$+4\in/0\mov/m, a\inx/h\dcr/b\jnz/$-9\lda/TMP',
 {OTIR}'sta/TMP\mov/a, c\sta/$+4\out/0\mov/m, a\inx/h\dcr/b\jnz/$-9\lda/TMP',
 'nop/nop','nop/nop','nop/nop','nop/nop',
 {LDDR}'push/psw\mov/a, m\stax/d\dcx/h\dcx/d\dcx/b\mov/a, b\ora/c\jnz/$-7\pop/psw',
 {CPDR}'cmp/m\jz/$+21\dcx/h\dcx/b\sta/TMP\mov/a, b\ora/c\lda/TMP\jnz/$-14\xra/a\inr/a\lda/TMP',
 {INDR}'sta/TMP\mov/a, c\sta/$+4\in/0\mov/m, a\dcx/h\dcr/b\jnz/$-9\lda/TMP',
 {OTDR}'sta/TMP\mov/a, c\sta/$+4\out/0\mov/m, a\dcx/h\dcr/b\jnz/$-9\lda/TMP');

(* Stat80 : array[$00..$FF] of byte=
 (   {0} {1} {2} {3} {4} {5} {6} {7}  {8} {9} {A} {B} {C} {D} {E} {F}
{00} $00,$12,$00,$00,$00,$00,$01,$00, $00,$00,$00,$00,$00,$00,$01,$00,
{10} $00,$12,$00,$00,$00,$00,$01,$00, $00,$00,$00,$00,$00,$00,$01,$00,
{20} $00,$12,$A2,$00,$00,$00,$01,$00, $00,$00,$22,$00,$00,$00,$01,$00,
{30} $00,$12,$02,$00,$30,$30,$31,$00, $00,$00,$02,$00,$00,$00,$01,$00,
{40} $00,$00,$00,$00,$00,$00,$30,$00, $00,$00,$00,$00,$00,$00,$30,$00,
{50} $00,$00,$00,$00,$00,$00,$30,$00, $00,$00,$00,$00,$00,$00,$30,$00,
{60} $00,$00,$00,$00,$00,$00,$30,$00, $00,$00,$00,$00,$00,$00,$30,$00,
{70} $30,$30,$30,$30,$30,$30,$00,$30, $00,$00,$00,$00,$00,$00,$30,$00,
{80} $00,$00,$00,$00,$00,$00,$30,$00, $00,$00,$00,$00,$00,$00,$30,$00,
{90} $00,$00,$00,$00,$00,$00,$30,$00, $00,$00,$00,$00,$00,$00,$30,$00,
{A0} $00,$00,$00,$00,$00,$00,$30,$00, $00,$00,$00,$00,$00,$00,$30,$00,
{B0} $00,$00,$00,$00,$00,$00,$30,$00, $00,$00,$00,$00,$00,$00,$30,$00,
{C0} $00,$00,$D2,$92,$D2,$00,$01,$00, $00,$F0,$D2,$92,$D2,$E2,$01,$00,
{D0} $00,$00,$D2,$01,$D2,$00,$01,$00, $00,$F0,$D2,$01,$D2,$E2,$01,$00,
{E0} $00,$00,$D2,$00,$D2,$00,$01,$00, $00,$F0,$D2,$00,$D2,$E2,$01,$00,
{F0} $00,$00,$D2,$00,$D2,$00,$01,$00, $00,$00,$D2,$00,$D2,$E2,$01,$00 );*)

implementation end.