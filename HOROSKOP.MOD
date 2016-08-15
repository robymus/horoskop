MODULE horoskop;

IMPORT FIO,Str,IO,Storage,Window,Lib;

TYPE setofchar = SET OF CHAR;
     homeretek = ARRAY[1..12] OF CARDINAL;

CONST maxrekurzio = 6;   (* a generalasnal egymasba agyazhato maximalis *)
                         (* rekurziok, az osszetett mondatok nagysagat *)
                         (* szabalyozza *)
      betuk = setofchar        {'a'..'z','A'..'Z'};
      maganhangzok = setofchar {'a','e','i','o','u','A','E','I','O','U'};
      homeret = homeretek(31,28,31,30,31,30,31,31,30,31,30,31);

TYPE string80    = ARRAY[0..79] OF CHAR;
     szovegek    = ARRAY[1..100] OF string80;
     szovegekmut = POINTER TO szovegek;
     blokkmut    = POINTER TO blokktype;
     blokktype   = RECORD
                    nev:string80;
                    adatszam:CARDINAL;
                    adatmut:szovegekmut;
                    kov:blokkmut;
                   END;
     longstring  = ARRAY[0..767] OF CHAR;
     cardset     = SET OF [0..31];         (* pont egy longcardnyi SET *)
     setmut      = POINTER TO cardset;

VAR blokkkezd,
    elozoblokk,
    tempblokk    : blokkmut;                    (* mutatok *)
    f,fb         : FIO.File;                    (* adatfile *)
    s            : string80;                    (* ideiglenes valtozok... *)
    ok           : BOOLEAN;
    i            : CARDINAL;
    randtable1   : ARRAY[0..116] OF BYTE;
    randtable2   : ARRAY[0..2047-117] OF BYTE;      (* a randomtablazat *)
    randpos1,
    randpos2,
    randdir1,
    randdir2     : CARDINAL;                    (* a random mutatoi...*)
    ev,ho,nap,                                  (* az aktualis *)
    szev,szho,                                  (* es a szuletesi datum *)
    sznap        : CARDINAL;


(* datumellenorzes *)
PROCEDURE jodatum(ev,ho,nap:CARDINAL):BOOLEAN;
VAR b:BOOLEAN;
    maxnap:CARDINAL;
BEGIN
 IF (ev<0) OR (ev>99) OR (ho<1) OR (ho>12) OR (nap<1) THEN
  b:=FALSE;
 ELSE
  maxnap:=homeret[ho];
  IF (ho=2) AND (ev MOD 4=0) THEN
   INC(maxnap);
  END;
  b:=nap<=maxnap;
 END;
 RETURN(b);
END jodatum;

(* datum beolvasas *)
PROCEDURE inputdatum(VAR ev,ho,nap:CARDINAL);
BEGIN
 REPEAT
  IO.WrStr('Ev (0-99) ? ');
  ev:=CARDINAL(IO.RdLngCard());
  IO.WrStr('Ho (1-12) ? ');
  ho:=CARDINAL(IO.RdLngCard());
  IO.WrStr('Nap (1-x) ? ');
  nap:=CARDINAL(IO.RdLngCard());
  IF NOT jodatum(ev,ho,nap) THEN
   IO.WrStr('A datum hibas, probald ujra !!!');
   IO.WrLn;
  END;
 UNTIL jodatum(ev,ho,nap);
END inputdatum;

PROCEDURE csillagjegy(ho,nap:CARDINAL):string80;
VAR s:string80;
BEGIN
 CASE ho*100+nap OF
  |121..219:   s:='Vizonto';
  |220..320:   s:='Halak';
  |321..420:   s:='Kos';
  |421..521:   s:='Bika';
  |522..621:   s:='Ikrek';
  |622..723:   s:='Rak';
  |724..823:   s:='Oroszlan';
  |824..923:   s:='Szuz';
  |924..1023:  s:='Merleg';
  |1024..1122: s:='Skorpio';
  |1123..1222: s:='Nyilas';
  ELSE         s:='Bak';
 END;
 RETURN(s);
END csillagjegy;

(* readstring eljaras, beolvas a filebol egy sort, a kommenteket nem *)
PROCEDURE readstring(file:FIO.File;VAR s:ARRAY OF CHAR);
BEGIN
 REPEAT
  FIO.RdStr(file,s);
 UNTIL s[0]<>';'
END readstring;

(* randomize eljaras : beallitja a random kezdoerteket *)
PROCEDURE randomize(szev,szho,sznap,ev,ho,nap:CARDINAL);
BEGIN
 randpos1:=(szev*555+szho*33+sznap*1) MOD 1024;
 randpos2:=(ev  *333+  ho*11+nap  *5) MOD 1024;
 randdir1:=((3*ev*ev+7*szev*ho+11*nap*sznap+sznap) MOD 512) * 2 + 1;
 randdir2:=((szho*szev*ev+137*nap*nap*szho+5*ev*szho*nap) MOD 512) * 2 + 1;
END randomize;

(* random fv : general egy veletlen (?) szamot 0 es range-1 kozott *)
PROCEDURE random(range:CARDINAL):CARDINAL;
VAR rand:BYTE;
BEGIN
 rand:=randtable1[randpos1]-randtable2[randpos2];
 randpos1:=(randpos1+randdir2) MOD 117;
 randpos2:=(randpos2+randdir1) MOD (2048-117);
 RETURN(CARDINAL(rand) MOD range);
END random;

(* ket string egyenloseget vizsgalja... *)
PROCEDURE stringegyenlo(a,b:ARRAY OF CHAR):BOOLEAN;
VAR bo:BOOLEAN;
    i:CARDINAL;
BEGIN
 IF Str.Length(a)#Str.Length(b) THEN
  RETURN(FALSE);
 ELSE
  bo:=TRUE;
  FOR i:=0 TO Str.Length(a)-1 DO
   IF a[i]#b[i] THEN
    bo:=FALSE;
   END;
  END;
  RETURN(bo);
 END;
END stringegyenlo;

(* a mondatgeneralas lelke, egy blokkot feldolgoz, akar rekurzivan is *)
(* ha a szint eleri a maxrekurzio-t, akkor ureset ad vissza! *)
PROCEDURE processblokk(nev:string80;szint:CARDINAL):longstring;
VAR tls:longstring;
    blokk:blokkmut;
    toprocess,ts:string80;
BEGIN
 (* nullazzuk a generalt mondatreszt... *)
 tls:='';
 (* kikeressi, hogy hol van a keresett blokk *)
 blokk:=blokkkezd;
 WHILE (blokk#NIL) AND (NOT stringegyenlo(blokk^.nev,nev)) DO
  blokk:=blokk^.kov;
 END;
 IF blokk=NIL THEN
  IO.WrStr('Hiba az adatfileban !!!');
  IO.WrLn;
  IO.WrStr('%');IO.WrStr(nev);IO.WrStr('%');
  IO.WrLn;
  HALT;
 END;
 (* kivalaszt egy elemet random... *)
 toprocess:=blokk^.adatmut^[random(blokk^.adatszam)+1];
 (* megnezi a rekurzio tullepest, ha ez egy mellekmondat, akkor kilep *)
 IF (szint=maxrekurzio) AND (toprocess[0]=',') THEN
  RETURN(tls);
 END;
 (* es ezt feldolgozza *)
 WHILE Str.Pos(toprocess,'%')<MAX(CARDINAL) DO
  (* Amig van rekurzio ... A rekurzio elotti reszt hozzacsapjuk... *)
  Str.Slice(ts,toprocess,0,Str.Pos(toprocess,'%'));
  Str.Concat(tls,tls,ts);
  (* Majd kitoroljuk *)
  Str.Delete(toprocess,0,Str.Pos(toprocess,'%')+1);
  (* Kivesszuk a rekurziv resz nevet, es kitoroljuk... *)
  Str.Slice(ts,toprocess,0,Str.Pos(toprocess,'%'));
  Str.Delete(toprocess,0,Str.Pos(toprocess,'%')+1);
  (* Meghivjuk a rekurziot... *)
  Str.Concat(tls,tls,processblokk(ts,szint+1));
 END;
 (* A maradekot meg hozzacsapjuk... *)
 Str.Concat(tls,tls,toprocess);
 RETURN(tls);
END processblokk;

(* ez a postprocess nevu dolog, a neveloket korrigalja (a->az), *)
(* tovabba a felesleges space-eket irtja ki, nagybetu, pont... *)
PROCEDURE postprocess(s:longstring):longstring;
VAR tls:longstring;
    i,j:CARDINAL;
    ss:ARRAY[0..1] OF CHAR;
BEGIN
 (* dupla space-ek nelkul legeneralja tls-be... *)
 i:=0;j:=0;
 REPEAT
  IF (s[i]#' ') OR ( (s[i]=' ') AND (j>0) AND (tls[j-1]#' ') ) THEN
   tls[j]:=s[i];
   INC(j);
  END;
  INC(i);
 UNTIL s[i-1]=0C;
 (* tls-ben megkeressuk a neveloket (a), es ha kell, lecsereljuk az-ra... *)
 i:=0;
 REPEAT
  IF (tls[i]='a') AND (tls[i+1]=' ') AND
     ( (i=0) OR (NOT (tls[i-1] IN betuk) ) ) THEN
   (* ez egy 'a' mert, utana space van, elotte meg semmi vagy nem betu *)
   IF tls[i+2] IN maganhangzok THEN
    Str.Insert(tls,'z',i+1);
    INC(i);
   END;
  END;
  (* ha vesszo van, es nincs utana space, akkor rakunk... *)
  IF (tls[i]=',') AND (tls[i+1]#' ') THEN
   Str.Insert(tls,' ',i+1);
   INC(i);
  END;
  (* kiirtjuk a , elotti space-eket... *)
  IF (tls[i]=' ') AND (tls[i+1]=',') THEN
   Str.Delete(tls,i,1);
   DEC(i); (* csokkentjuk, hogy noveles utan visszakeruljunk ugyanide *)
  END;
  INC(i);
 UNTIL tls[i]=0C;
 (* ha a vegen van space, akkor kiirtjuk... *)
 WHILE tls[Str.Length(tls)-1]=' ' DO
  Str.Delete(tls,Str.Length(tls)-1,1);
 END;
 (* nagybetu + pont *)
 Str.Slice(ss,tls,0,1);
 Str.Caps(ss);
 tls[0]:=ss[0];
 Str.Concat(tls,tls,'.');
 (* visszaadjuk az eredmenyt *)
 RETURN(tls);
END postprocess;

(* Kiir egy hosszu stringet, figyel a 80 szelessegre... *)
PROCEDURE writelongstring(s:longstring);
VAR i,j:CARDINAL;
    t,t2:longstring;
BEGIN
 Str.Concat(t,s,'  ');  (* a vegere rakunk ket space-t, ez jelenti a  *)
                        (* veget, csak igy lehet !!! *)
 i:=0;   (* az eddig kiirt karakterek szama *)
 REPEAT
  j:=Str.Pos(t,' ');
  IF (i+j)>=80 THEN (* a jobb szelsobe sem irunk.. atdobjuk a kov. sorba *)
   IO.WrLn;
   i:=0;
  END;
  i:=i+j;
  Str.Slice(t2,t,0,j);
  IO.WrStr(t2);
  Str.Delete(t,0,j+1);
  IF i<79 THEN
   IO.WrStr(' '); (* ha nem a jobb szele, akkor ki space-t is *)
   i:=i+1;
  END;
 UNTIL t[0]=' ';
 IO.WrLn;
END writelongstring;

BEGIN
 (* Adatfile megnyitasa + hibakezeles *)

 IO.WrStr('Megnezegetem a csillagokat');
 FIO.IOcheck:=FALSE;

 (* astrolog.dat olvasasa *)
 fb:=FIO.Open('astrolog.dat');
 IF fb=MAX(CARDINAL) THEN
  IO.WrLn;
  IO.WrStr('Nem latom a csillagok kozott az ASTROLOG.DAT-ot... :(');
  IO.WrLn;
  HALT;
 END;
 IF (FIO.RdBin(fb,randtable1,117)#117) OR
    (FIO.RdBin(fb,randtable2,2048-117)#2048-117) THEN
  IO.WrLn;
  IO.WrStr('Rosszul latom az ASTROLOG.DAT-ot... :(');
  IO.WrLn;
  HALT;
 END;
 FIO.Close(fb);

 (* nyelvtan.dat olvasasa *)
 f:=FIO.Open('nyelvtan.dat');
 IF f=MAX(CARDINAL) THEN
  IO.WrLn;
  IO.WrStr('Nem latom a csillagok kozott a NYELVTAN.DAT-ot... :(');
  IO.WrLn;
  HALT;
 END;

 (* Adatok beolvasasa *)
 blokkkezd:=NIL;

 REPEAT
  (* Blokk nevet beolvassuk *)
  readstring(f,s);
  IF s[0]#'[' THEN
   IO.WrLn;
   IO.WrStr('A NYELVTAN.DAT formatuma nem tul jo !!!');
   IO.WrLn;
   HALT;
  END;
  (* Ha nincs vege... *)
  IF NOT stringegyenlo(s,'[@]') THEN
   (* Foglalunk neki helyet, es bemutogatjuk... *)
   Storage.ALLOCATE(tempblokk,SIZE(blokktype));
   IF blokkkezd=NIL THEN
    blokkkezd:=tempblokk;
   ELSE
    elozoblokk^.kov:=tempblokk;
   END;
   elozoblokk:=tempblokk;
   tempblokk^.kov:=NIL;
   Str.Slice(tempblokk^.nev,s,1,Str.Pos(s,']')-1);
   (* Beolvassuk, hogy hany elemu lesz a blokk *)
   readstring(f,s);
   tempblokk^.adatszam:=CARDINAL(Str.StrToCard(s,10,ok));
   IF NOT ok THEN
    IO.WrLn;
    IO.WrStr('A NYELVTAN.DAT formatuma nem tul jo !!!');
    IO.WrLn;
    HALT;
   END;
   (* Foglalunk neki helyet *)
   Storage.ALLOCATE(tempblokk^.adatmut,SIZE(string80)*tempblokk^.adatszam);
   (* Majd beolvassuk oket *)
   FOR i:=1 TO tempblokk^.adatszam DO
    readstring(f,tempblokk^.adatmut^[i]);
   END;
   (* Progress indicator *)
   IO.WrStr('.');
  END;
 UNTIL stringegyenlo(s,'[@]');

 IO.WrLn;

 (* Foprogram *)

 Window.TextBackground(Window.Black);
 Window.Clear;
 Window.TextColor(Window.LightGreen);

 IO.WrStr('Horoszkop keszito program 0.1');
 IO.WrStr('      - (c) 1998. robymus / byteam ^ kyphosis');
 IO.WrLn;
 IO.WrLn;

 Window.TextColor(Window.LightMagenta);
 IO.WrStr('Mikor szulettel ?');
 IO.WrLn;
 inputdatum(szev,szho,sznap);
 IO.WrLn;
 IO.WrStr('Melyik napra akarsz josoltatni ?');
 IO.WrLn;
 inputdatum(ev,ho,nap);

 randomize(szev,szho,sznap,ev,ho,nap);

 (* Kiirja a horoszkop eredmenyet (+ megcsinalja) *)
 Window.TextBackground(Window.Black);
 Window.Clear;
 Window.TextColor(Window.Yellow);
 IO.WrStr('A te csillagjegyed ');
 IO.WrStr(csillagjegy(szho,sznap));
 IO.WrStr(' ... Horoszkopod a ');
 IO.WrCard(ev,2);IO.WrStr('.');
 IO.WrCard(ho,2);IO.WrStr('.');
 IO.WrCard(nap,2);IO.WrStr('. napra a kovetkezo :');
 IO.WrLn;
 IO.WrLn;

 Window.TextColor(Window.White);
 writelongstring(postprocess(processblokk('jos1',0)));
 IO.WrLn;
 writelongstring(postprocess(processblokk('jos2',0)));
 IO.WrLn;
 writelongstring(postprocess(processblokk('jos2',0)));

 (* Kilepes / Dinamikus felszabaditas *)
 elozoblokk:=blokkkezd;
 REPEAT
  tempblokk:=elozoblokk^.kov;
  Storage.DEALLOCATE(elozoblokk^.adatmut,SIZE(string80)*elozoblokk^.adatszam);
  Storage.DEALLOCATE(elozoblokk,SIZE(blokktype));
  elozoblokk:=tempblokk;
 UNTIL elozoblokk=NIL;
 FIO.Close(f);
END horoskop.