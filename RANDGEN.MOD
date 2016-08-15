MODULE randgen;

IMPORT FIO,Lib,IO;

VAR randtable:ARRAY[0..2047] OF BYTE;
    f:FIO.File;
    i:CARDINAL;

BEGIN
 IO.WrStr('Eloallitom a csillagallastablazatot (astrolog.dat)...');
 Lib.RANDOMIZE;
 FOR i:=0 TO 2047 DO
  randtable[i]:=BYTE(Lib.RANDOM(256));
 END;
 f:=FIO.Create('astrolog.dat');
 FIO.WrBin(f,randtable,2048);
 FIO.Close(f);
 IO.WrStr('Kesz');
 IO.WrLn;
END randgen.