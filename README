
          Dokumentacio a horoszkop keszito program 0.1-es verziojahoz
         -------------------------------------------------------------

  A Horoszkop keszito program (mely egyben az elso Modula programom, es mint
 ilyen, 3 nap munkajanak eredmenye) mukodeset tekintve egy asztrologiai
 szimulacio. Indulaskor a program belenez a 'belso kristalygombje' es
 megnezegeti a csillagokat. [Igazandibol ilyenkor olvassa be az ASTROLOG.DAT
 es NYELVTAN.DAT allomanyokat, lasd kesobb.]
  Ezt kovetoen bekeri a szuletesi datumot, majd a joslas datumat (a program
 akar tobb evvel elore is tud josolni). Ezt kovetoen megjelenik a csillag-
 jegy neve, majd egy rovid, harom mondatos joslat a megadott napra.
  A joslatban neha fura kifejezesek, mondatok, kijelentesek allhatnak. Ez
 annak koszonheto, hogy a kristalygomb homalyos kepeket szokott mutatni,
 a reszleteket a felhasznalonak kell behelyettesitenie, a joslat csak egy
 korvanalat ad ehhez.

              Nehany technikai informacio a horoszkop programhoz
             ----------------------------------------------------

  A program a NYELVTAN.DAT allomany feldolgozasaval allit elo veletlenszeru
 mondatokat ('joslatokat'). A file szerkezete a kovetkezo: blokkokbol all,
 egy blokk a nevevel kezdodik [] kozott, pl [nevelo]. Ezt egy szam koveti,
 a blokkban talalhato bejegyzesek szama, majd a bejegyzesek kovetkeznek.
  Egy bejegyzes lehet ures, egyszeru vagy osszetett. Az ures ill. egyszeru
 bejegyzesek egyszeruen bemasolodnak a mondatokba, az osszetett bejegyzesek-
 ben a %% jelek kozott talalhato blokknev kiirtekelesenek eredmenye kerul
 a helyere, ily modon akar rekurziv mellekmondatszerkezetet is meg lehet
 adni. A rekurzio maximalis melyseget a programban a maxrekurzio konstans
 hatarozza meg, am ez nem vonatkozik a nem mellekmondat jellegu blokk-
 kiertekelesre (mellekmondat=>','-vel kezdodik). A file-ban elhelyezhetok
 megjegyzesek is, ';'-vel kezdodo sorokban...
  A mondatok generalasa a [jos1] ill. a [jos2] blokkok kiertekelesevel
 tortenik, ez utobbit ketszer ertekeli ki a program, igy osszesen harom
 mondatnyi joslatot kapunk minden nap.
  Az ASTROLOG.DAT-ot a GENRAND.MOD program tolti fel veletlenszeru ertekek-
 kel, ez alapjan szamol a horoszkop keszito program veletlenszamokat, melyek
 csak a bevitt szuletesi ill. joslasi datumtol fuggenek, igy ugyanannak az
 embernek ugyanazon nap ugyanazt fogja josolni, igy nem tunik olyan kamunak.
  A program mukodese a forraskod alapjan egyszeruen nyomonkovetheto, a
 benne elhelyezett megjegyzesek utmutatast adnak az egyes reszek, eljarasok
 szereperol.
  A NYELVTAN.DAT beolvasasa dinamikus memoriafoglalassal tortenik, hiba
 eseten a dinamikus memoriat NEM szabaditja fel, de hiba nem is fordulhat
 elo, csak a NYELVTAN.DAT megvaltozasa eseten, igy e hibauzenetek kiirasa
 csak a fejlesztes idejere voltak fontosak.

                               Vegezetul
                              -----------

  A program eredeti otlete egy hir-generatorbol szarmazik, amit anno valaha
 Komuves Balazs cimboram (blala / byteam) kovetett el, ennek csak otlete
 kerult felhasznalasra, semmi nem algoritmuslopas nem tortent. A program
 eme kezdeti verzioja csakis hazi feladat celjabol keszult, hamarosan el
 fog keszulni a teljes, command-line-bol parameterezheto verzio is, ami
 majd terjesztesre is kerul. Zarom a program dokumentaciojat...

  A program hasznalatahoz jo szorakozast kivan :

                             Elek Robert I. eves prog.mat. hallgato
                        (a.k.a. robymus / byteam ^ kyphosis multimedia)
