// Delphi Spezifischer Teil
unit TetrisUnit;

interface

procedure GameMain(key:Char);
procedure GameInitFirst;

implementation

uses SysUtils, Windows,
     TetrisDefUnit, consolehelperunit;

const cspielfeldoffsetX=10;
      cspielfeldoffsetY=4;
      ctextposX=25;

var tLast:TDateTime;

// ============================================================================

procedure VisuStein(xOfs,yOfs:Integer; r:Integer; Stein:RStein; VisuAktion:RVisuAktion);
var x,y:integer;
    i:integer;
    c:char;
begin
  if ( R <  0 ) or
     ( R >  cMaxSteinRotation ) then
     exit;

  if VisuAktion = vaPaint then
   c:= cBelegt
  else
   c:= cFrei;
  for i:= 0 to cMaxSteinElement do
  begin
    x:= xOfs+Stein.Rotation[r].SteinElemente[i].x;
    y:= yOfs+Stein.Rotation[r].SteinElemente[i].y;
    PosXY(x, y);
    if y >= cspielfeldoffsetY then
    Write(c);
  end;
end;

procedure VisuNext;
var y:integer;
begin
  for y:= 10 to 16 do
  begin
    PosXY(ctextposX, y);
    write('......');
  end;
  VisuStein(ctextposX+2, 13, 0, nextStein, vaPaint); // nächster
end;

procedure VisuPunkte;
begin
  PosXY(ctextposX, 8);
  write(punkte);
end;

// ============================================================================

procedure VisuSpielfeld;
var i:integer;
    x,y:integer;
    s:String;
begin
 // Beschriftung oben
 //for i:= 0 to cMaxFeldSpalte do
 //begin
 //  PosXY(cspielfeldoffsetX+i, 1);
 //  write(i);
 //end;

 // Linie oben
 s:= '';
 for i:= 1 to cFeldSpalten do
   s:= s + '-';
 PosXY(cspielfeldoffsetX,cspielfeldoffsetY-1);
 write(s);

 // Feld (+Linie links/rechts +Zeilennummer)
 s:= '';
 for i:= 1 to cFeldSpalten do
   s:= s + ' ';
 for i:= 0 to cMaxFeldZeile do
 begin
   PosXY(cspielfeldoffsetX-1, cspielfeldoffsetY+i);
   write('|'+s+'|'); //+inttostr(i));
 end;

 // Linie unten
 s:= '';
 for i:= 1 to cFeldSpalten do
   s:= s + '-';
 PosXY(cspielfeldoffsetX,cspielfeldoffsetY+cFeldZeilen);
 write(s);

 // Feld Inhalt
 for y:= 0 to cMaxFeldZeile do
 begin
  for x:= 0 to cMaxFeldSpalte do
  begin
    PosXY(cspielfeldoffsetX+x, cspielfeldoffsetY+y);
    write(Spielfeld.zeilen[y].spalten[x]);
  end;
 end;

end;

// ============================================================================

procedure GameInitFirst;
begin
  // Stein Array aufbauen, globale Variablen Preset, usw.
  TetisInit;

  // Stein wählen
  NeuerStein;

  // Spielfeld anzeigen
  VisuSpielfeld;

  // nächster Stein
  VisuNext;

  // Punkte
  VisuPunkte;

  PosXY(cTextPosX,3);
  Write('Bewegung: a/d/s');
  PosXY(cTextPosX,4);
  Write('Rotation: ,/.');
  PosXY(cTextPosX,5);
  Write('Ende:     q');

  tLast:= 0;
end;

procedure GameMain(key:Char);
var bDo:Boolean;
    tmpR:Integer;
    y,c:Integer;
begin
  bDo:= false;
  if (key <> #0) then
  begin
    bDo:= true;
  end;
  if (now >= tLast+1/24/60/60*0.5) then
  begin
    tLast:= Now;
    bDo:= true;
    if CheckSteinPos(aktStein, aktSteinX, aktSteinY+1, aktSteinR) then
    begin
      key:= 's';
    end
    else
    begin
      //übernehmen an aktueller Pos
      SetzeStein(aktStein, aktSteinX, aktSteinY, aktSteinR);

      // Punkte
      inc(Punkte, 10);

      // Prüfe volle Zeilen
      c:= 0;
      for y:= 0 to cMaxFeldZeile do
      begin
        if ZeileVoll(y) then
        begin
          LoescheZeile(y);
          VisuSpielfeld;

          // Punkte
          inc(Punkte, 100);
          inc(c);
        end;
      end;
      if c = 4 then
      begin
        // Punkte
        inc(Punkte, 400);
      end;

      // Punkte visualisieren
      VisuPunkte;

      // neuen Stein bilden
      //VisuSpielfeld;
      NeuerStein;
      VisuStein(aktSteinX+cspielfeldoffsetX, aktSteinY+cspielfeldoffsetY, aktSteinR, aktStein, vaPaint);

      // nächsten Stein visualisieren
      VisuNext;

      //Prüfe auf Ende (Ausgangsposition+1 nicht möglich)
      if not CheckSteinPos(aktStein, aktSteinX, aktSteinY+1, aktSteinR) then
      begin
        VisuSpielfeld;
        VisuStein(aktSteinX+cspielfeldoffsetX, aktSteinY+cspielfeldoffsetY, aktSteinR, aktStein, vaPaint);

        PosXY(cTextPosX,20);
        write('Game Over!');
        sleep(3000);
        Halt(0);
      end;
    end;
  end;

  if bDo=true then
  begin
    VisuStein(aktSteinX+cspielfeldoffsetX, aktSteinY+cspielfeldoffsetY, aktSteinR, aktStein, vaErase);

    if key = '#' then
    begin
      // kompletter Refresh
      VisuSpielfeld;
    end;

    // bewegung
    if key = 'a' then
    begin
      if CheckSteinPos(aktStein, aktSteinX-1, aktSteinY, aktSteinR) then
       dec(aktSteinX)
    end;
    if key = 'd' then
    begin
      if CheckSteinPos(aktStein, aktSteinX+1, aktSteinY, aktSteinR) then
       inc(aktSteinX)
    end;
    if key = 's' then
    begin
      if CheckSteinPos(aktStein, aktSteinX, aktSteinY+1, aktSteinR) then
       inc(aktSteinY);
    end;
    if key = ',' then
    begin
      tmpR:= aktSteinR;
      dec(tmpR);
      if tmpR<0 then tmpR:= cMaxSteinRotation;
      if CheckSteinPos(aktStein, aktSteinX, aktSteinY, tmpR) then
       aktSteinR:= tmpR;
    end;
    if key = '.' then
    begin
      tmpR:= aktSteinR;
      inc(tmpR);
      if tmpR>cMaxSteinElement then tmpR:= 0;
      if CheckSteinPos(aktStein, aktSteinX, aktSteinY, tmpR) then
       aktSteinR:= tmpR;
    end;

    VisuStein(aktSteinX+cspielfeldoffsetX, aktSteinY+cspielfeldoffsetY, aktSteinR, aktStein, vaPaint);
  end; // of Key

end;


end.

