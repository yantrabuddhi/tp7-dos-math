{$O-,V-}
UNIT KeyBoard;
(**) INTERFACE (**)
USES Dos;

CONST
{EXTRA CONSTANTS START HERE->}
{ Extended key codes }
{2nd byte= ascii & chars=$20 to $7e rest are special}
{kbEnter & num pad enter have common 2nd byte-0d}

  kbEsc       = $011B;  kbAltSpace  = $0200;  kbCtrlIns   = $0400;
  kbShiftIns  = $0500;  kbCtrlDel   = $0600;  kbShiftDel  = $0700;
  kbBack      = $0E08;  kbCtrlBack  = $0E7F;  kbShiftTab  = $0F00;
  kbTab       = $0F09;  kbAltQ      = $1000;  kbAltW      = $1100;
  kbAltE      = $1200;  kbAltR      = $1300;  kbAltT      = $1400;
  kbAltY      = $1500;  kbAltU      = $1600;  kbAltI      = $1700;
  kbAltO      = $1800;  kbAltP      = $1900;  kbCtrlEnter = $1C0A;
  kbEnter     = $1C0D;  kbAltA      = $1E00;  kbAltS      = $1F00;
  kbAltD      = $2000;  kbAltF      = $2100;  kbAltG      = $2200;
  kbAltH      = $2300;  kbAltJ      = $2400;  kbAltK      = $2500;
  kbAltL      = $2600;  kbAltZ      = $2C00;  kbAltX      = $2D00;
  kbAltC      = $2E00;  kbAltV      = $2F00;  kbAltB      = $3000;
  kbAltN      = $3100;  kbAltM      = $3200;  kbF1        = $3B00;
  kbF2        = $3C00;  kbF3        = $3D00;  kbF4        = $3E00;
  kbF5        = $3F00;  kbF6        = $4000;  kbF7        = $4100;
  kbF8        = $4200;  kbF9        = $4300;  kbF10       = $4400;
  kbF11       = $8500;  kbF12       = $8600;  kbGrayPgDn  = $51E0;
  kbGrayUp    = $48E0;  kbGrayDown  = $50E0;  kbGrayleft  = $4BE0;
  kbGrayRight = $4DE0;  kbGrayIns   = $52E0;  kbGrayDel   = $53E0;
  kbGrayHome  = $47E0;  kbGrayEnd   = $4FE0;  kbGrayPgUp  = $49E0;
  kbHome      = $4700;  kbUp        = $4800;  kbPgUp      = $4900;
  kbGrayMinus = $4A2D;  kbLeft      = $4B00;  kbRight     = $4D00;
  kbGrayPlus  = $4E2B;  kbEnd       = $4F00;  kbDown      = $5000;
  kbPgDn      = $5100;  kbIns       = $5200;  kbDel       = $5300;
  kbShiftF1   = $5400;  kbShiftF2   = $5500;  kbShiftF3   = $5600;
  kbShiftF4   = $5700;  kbShiftF5   = $5800;  kbShiftF6   = $5900;
  kbShiftF7   = $5A00;  kbShiftF8   = $5B00;  kbShiftF9   = $5C00;
  kbShiftF10  = $5D00;  kbCtrlF1    = $5E00;  kbCtrlF2    = $5F00;
  kbCtrlF3    = $6000;  kbCtrlF4    = $6100;  kbCtrlF5    = $6200;
  kbCtrlF6    = $6300;  kbCtrlF7    = $6400;  kbCtrlF8    = $6500;
  kbCtrlF9    = $6600;  kbCtrlF10   = $6700;  kbAltF1     = $6800;
  kbAltF2     = $6900;  kbAltF3     = $6A00;  kbAltF4     = $6B00;
  kbAltF5     = $6C00;  kbAltF6     = $6D00;  kbAltF7     = $6E00;
  kbAltF8     = $6F00;  kbAltF9     = $7000;  kbAltF10    = $7100;
  kbCtrlPrtSc = $7200;  kbCtrlLeft  = $7300;  kbCtrlRight = $7400;
  kbCtrlEnd   = $7500;  kbCtrlPgDn  = $7600;  kbCtrlHome  = $7700;
  kbAlt1      = $7800;  kbAlt2      = $7900;  kbAlt3      = $7A00;
  kbAlt4      = $7B00;  kbAlt5      = $7C00;  kbAlt6      = $7D00;
  kbAlt7      = $7E00;  kbAlt8      = $7F00;  kbAlt9      = $8000;
  kbAlt0      = $8100;  kbAltMinus  = $8200;  kbAltEqual  = $8300;
  kbCtrlPgUp  = $8400;  kbAltBack   = $0800;  kbNoKey     = $0000;
  kbNumEnter  = $E00D;
  {first byte=keyboard layout key num, 2nd byte=ascii code attatched}

{ Keyboard state and shift masks }
  {maybe and of read code with mask if doesn't give zero then its pressed}
  kbRightShift  = $0001;
  kbLeftShift   = $0002;
  kbCtrlShift   = $0004;
  kbAltShift    = $0008;
  kbScrollState = $0010;
  kbNumState    = $0020;
  kbCapsState   = $0040;
  kbInsState    = $0080;

  KbStart = $1E;
VAR {purely for dos , protected memory may not allow such direct mem use}
  ShiftState : Byte ABSOLUTE $40:$17;
  KbHead     : Word ABSOLUTE $40:$1A;
  KbTail     : Word ABSOLUTE $40:$1C;
  KbBuff     : ARRAY[0..15] OF Word ABSOLUTE $40:KbStart;

{EXTRA CONSTANTS END HERE}
TYPE String15 = String[15];
  FUNCTION IsEnhanced : Boolean;
  FUNCTION ReadKeyEnh : Word;{}
  Function ReadKey:char;
  Function IsCharKeyCode(code:Word):Boolean;
  FUNCTION KeyPressedEnh : Boolean;{}
  Function KeyPressedRead:Word;{}{usable in dos, win written by me}
  PROCEDURE ClearBuffer;
  PROCEDURE StuffBuffer(S : String15);
  FUNCTION FastKeyPressed : Boolean;
  FUNCTION FasterKeyPressed : Boolean;
  PROCEDURE DisableKeyboard;
  PROCEDURE EnableKeyboard;
  PROCEDURE MaskOutKbd;
  PROCEDURE UnMaskKbd;

(**) IMPLEMENTATION (**)
  VAR
  OldKeyVec  : Pointer;


  Function IsCharKeyCode(code:Word):Boolean;{Assembler;}
  var h,l:byte;
  Begin
  h:=code and $ff00;
  l:=code and $00ff;
  IsCharKeyCode:= ((h>=$02)and(h<=$35)and(l>=$20)and(l<=$7e));
  end;
  {
  asm
     xor ax,ax
     mov bx,code
     cmp bh,02h
     jb next
     cmp bh,35h
     ja next
     cmp bl,20h
     jb next
     cmp bl,7eh
     ja next
     dec ax {inc al may do.. char used
     next:
  end;
  }
  FUNCTION IsEnhanced : Boolean;
  VAR StateFrom16 : Byte;
  BEGIN
    IsEnhanced := FALSE;
    ASM
      MOV AH, 12h
      INT 16h
      MOV StateFrom16, AL
    END;
    IF StateFrom16 <> ShiftState THEN Exit;
    ShiftState := ShiftState XOR $20;
    ASM
      MOV AH, 12h
      INT 16h
      MOV StateFrom16, AL
    END;
    IsEnhanced := StateFrom16 = ShiftState;
    ShiftState := ShiftState XOR $20;
  END;

  FUNCTION ReadKeyEnh : Word; Assembler;
  ASM
    MOV AH, 10h
    INT 16h
  END;

  Function ReadKey:char;
  Begin
  READKEY:=CHR(ReadKeyEnh AND $00FF);
  End;

  FUNCTION KeyPressedEnh : Boolean; Assembler;
  ASM
    MOV AH, 11h
    INT 16h
    MOV AX, 0
    JZ @NoKey
    INC AX
    @NoKey:
  END;

  Function KeyPressedRead : Word; Assembler;
  Asm
     mov ah,11h
     int 16h
     mov ax,0
     jz @Nokey
     mov ah,10h
     int 16h
     @Nokey:
  End;{if keypressed then return code}

  PROCEDURE ClearBuffer;
  BEGIN
    ASM CLI END;
    KbHead := KbStart;
    KbTail := KbStart;
    ASM STI END;
  END;

  FUNCTION FastKeyPressed : Boolean;
  BEGIN
    FastKeyPressed := KbHead <> KbTail;
  END;

  FUNCTION FasterKeyPressed : Boolean; Assembler;
  ASM
    PUSH DS
    MOV AX, 40h
    MOV DS, AX
    CLI
    MOV AX, [1Ah]
    CMP AX, [1Ch]
    STI
    MOV AX, 0
    JZ @NoPress
    INC AX
    @NoPress:
    POP DS
  END;

  PROCEDURE StuffBuffer(S : String15);
  VAR N, max : Byte;
  BEGIN
    max := 15;
    IF length(S) < max THEN max := length(S);
    ASM CLI END;
    KbHead := KbStart;
    KbTail := KbStart + 2*max;
    FOR N := 1 to max DO
      KbBuff[pred(N)] := Word(S[N]);
    ASM STI END;
  END;

  PROCEDURE MaskOutKbd; Assembler;
  ASM
    IN AL, 21h
    OR AL, 00000010b
    OUT 21h, AL
  END;

  PROCEDURE UnMaskKbd; Assembler;
  ASM
    IN AL, 21h
    AND AL,11111101b
    OUT 21h, AL
  END;

  PROCEDURE EatAllKeys; Assembler;
  ASM
    PUSH AX      {save AX, 'cause we gonna use it}
    PUSHF        {save flags}
    IN AL,60h    {read the keyboard port}
    IN AL,61h    {read kbd controller}
    MOV AH,AL
    OR AL,80h    {set the "reset" bit}
    OUT 61h,AL   {send it back out}
    XCHG AH,AL   {get back original value}
    OUT 61h,AL   {send it out too}
    POPF
    CLI          {no interrupts for a moment}
    MOV AL,20h   {End-Of-Interrupt signal}
    OUT 20h,AL   {send EOI to PIC}
    POP AX
    IRET
  END;

  PROCEDURE DisableKeyboard;
  BEGIN
    GetIntVec(9, OldKeyVec);
    SetIntVec(9, @EatAllKeys);
  END;

  PROCEDURE EnableKeyboard;
  BEGIN
    SetIntVec(9, OldKeyVec);
  END;

BEGIN
  {$IFOPT O+}
  CRASH HERE -- must not use O+ directive
  {$ENDIF}
  IF NOT IsEnhanced THEN
    BEGIN
      MEM[CSeg : Ofs(ReadKeyEnh)+1] := $00;
      MEM[CSeg : Ofs(KeyPressedEnh)+1] := $01;
    END;
END.