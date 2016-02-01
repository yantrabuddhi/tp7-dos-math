  Program TinyCAD;{Tiny 3d Draw CAD}

  Uses Graf256,{KeyBoard,{Tiny_Lib,Trans_3d,PostEval}interprt;

  type
  pbase=^interpreter;
  Var

  DraWin:pbase;{Draw Buffer Object}
  ch:char;

  FUNCTION ReadKeyEnh : Word; Assembler;
  ASM
    MOV AH, 10h
    INT 16h
  END;

  Function ReadKey:char;
  Begin
  READKEY:=CHR(ReadKeyEnh AND $00FF);
  End;

  Begin
  SetTextMode;
  drawin:=new(pbase,init);
  if drawin=nil then
  begin
  writeln('Cannot initialise...');
  exit;
  end;

  {ask params}
  {
  writeln;
  writeln('Enter Program File Path and Name:');
  readln(IfileName);
  writeln;
  writeln('Enter Output Bitmap file Path and Name(enter=none):');
  readln(OfileName);
  {line from text file is command line}

  SetVGA256Mode;{Graphics}
  drawin^.clear_depth_buffer;
  { experiment success}
  drawin^.draw_color:=8;
  drawin^.interpret('set_draw_color 10');
  drawin^.interpret('line -50,-50,-50,50,50,50');
  drawin^.interpret('set_plot_eqn "sin(x)*sin(y)"');
  drawin^.interpret('set_plot_range -10,10,-10,10,10,10');
  drawin^.interpret('set_axis_range -10,10,-10,10,-5,5');
  drawin^.interpret('plot');
  {}
  ch:=readkey;{let person see the display}
  dispose(drawin,done);
  SetTextMode;{Text}
  End.
