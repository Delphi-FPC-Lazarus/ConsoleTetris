// Delphi Spezifischer Teil
unit ConsoleHelperUnit;

interface

uses Windows, SysUtils;

Function GetCh( handle: THandle ): Char;
Function OldConsoleMode( handle: THandle ): Cardinal;
Function KeyAvail( handle: THandle ): Boolean;

procedure PosXY(x,y:word);
procedure ClearConsoleScreen;

var
  stdin  : THandle;
  stdout : THandle;

implementation

// ------------------------------------------------------------------
procedure PosXY(x,y:word);
var Coord:_Coord;
begin
  Coord.X:= x-1;
  Coord.Y:= y-1;
  SetConsoleCursorPosition(stdout, Coord);
end;
// ------------------------------------------------------------------
procedure ClearConsoleScreen;
const
  BUFSIZE = 80*25;
var
  Han,Dummy: LongWord;
  i: Integer;
  buf: string;
  coord: TCoord;
begin
  Han := GetStdHandle(STD_OUTPUT_HANDLE);
  if Han <> INVALID_HANDLE_VALUE then
  begin
    if SetConsoleTextAttribute(han, FOREGROUND_RED or FOREGROUND_GREEN or FOREGROUND_BLUE) then
    begin
      //SetLength(buf,BUFSIZE);
      //FillChar(buf[1],Length(buf),' ');
      buf:= '';
      for i:= 1 to BUFSIZE do buf:= buf + ' ';
      if WriteConsole(han,PChar(buf),BUFSIZE,Dummy,nil) then
      begin
        coord.X := 0;
        coord.Y := 0;
        if SetConsoleCursorPosition(han,coord) then
        begin
        end;
      end;
    end;
  end;
end;
// ------------------------------------------------------------------
Function GetCh( handle: THandle ): Char;
var
  charsread: Cardinal;
begin
  Win32Check(
    ReadConsole( handle,
                 @result, 1,
                 charsread, nil ));
End;

Function OldConsoleMode( handle: THandle ): Cardinal;
Begin
  Win32Check( GetConsoleMode( handle, Result ));
End;

Function KeyAvail( handle: THandle ): Boolean;
Var
  i, numEvents: Cardinal;
  events : Array of TInputRecord;
Begin
  Result := False;
  Win32Check(GetNumberOfConsoleInputEvents( handle, numEvents ));
  If numEvents > 0 Then Begin
    SetLength( events, numEvents );
    Win32Check(PeekConsoleInput( handle, events[0], numEvents, numEvents ));
    For i:= 0 to numEvents-1 Do
      If (events[i].EventType = key_event) and
         (events[i].Event.KeyEvent.bKeyDown) and
         (events[i].Event.KeyEvent.AsciiChar <> #0)
      Then Begin
        Result := true;
        Break;
      End;
  End;
End;

// ------------------------------------------------------------------

initialization
    stdin  := GetStdHandle( STD_INPUT_HANDLE );
    stdout := GetStdHandle( STD_OUTPUT_HANDLE );
    SetConsoleMode( stdin,
                    OldConsoleMode( stdin )
                    and not (ENABLE_LINE_INPUT or ENABLE_ECHO_INPUT));
finalization


end.








