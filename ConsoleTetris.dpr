// Descrition:	Portable Tetris implementation
// Author:  	Peter Lorenz - donate on Paypal: webmaster@peter-ebe.de 
// License: 	MPL 2.0
// THE SOFTWARE IS PROVIDED "AS IS" AND WITHOUT WARRANTY
// 

program ConsoleTetris;

{$APPTYPE CONSOLE}

{-$R *.res}

uses
  SysUtils,Windows,
  ConsoleHelperUnit in 'ConsoleHelperUnit.pas',
  TetrisUnit in 'TetrisUnit.pas',
  TetrisDefUnit in 'TetrisDefUnit.pas';

var
  key    : Char;
begin
  PosXY(1,1);
  ClearConsoleScreen;
  Randomize;
  GameInitFirst;
  try
    Repeat
      //PosXY(65,24);
      //write(Inttostr(GetTickCount)+'  ');

      Key:= #0;
      If KeyAvail( stdin ) Then
      Begin
        Key:= GetCh( stdin );
        //PosXY(78,24);
        //Write(Key);
      End;

      GameMain(key);
      Sleep( 10 );
    Until Key = 'q';
    PosXY(25,1);
    WriteLN;
  except
     On E: Exception Do
       WriteLn('Exception ', E.Classname, #13#10, E.Message );
  end;

end.
