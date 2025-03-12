;-------------------------------------
;
; "MEGA-SCROLLER"
;
; written from 6.7.1991 - 8.7.1991
;
; by ALIEN OF T.T.C.
;
;
;-------------------------------------
;
ROUTI DI         ;Interrupt unterbinden
;
; Frame Fly warten
;
SYNC LD B,&F5    ;Vertikales Synchronisationsregister
IN A,(C)         ;Frame Fly erfolgt ?
RRA              ;Bit ins Carry reinrotieren
JP NC,SYNC       ;wenn nicht, dann nochmal.
;
; Farben scrollen & Synchronisieren
;
LD BC,510        ;- zuerst den Bereich scrollen
LD HL,TAB2       ;  hat den Vorteil, dass oberer
LD DE,TABELL     ;  Bereich des Rasters in den
LDIR             ;  sichbaren Bereich gescrollt wird.
LD HL,TABELL     ;HL auf Anfang der Tabelle setzen
LD B,170         ;170 Rasterzeilen vollschreiben
XOR A            ;A auf 0 setzen
DEFS 9           ;Raster nach rechts verschieben
;
; Rastern
;
LOOP PUSH BC     ;Schleifenzaehler retten
LD B,&7F         ;Gate-Array-Portadresse nach B
INC A            ;Register 0 / Farbe 1
LD C,(HL)        ;die Farbe aus der Tabelle holen
OUT (C),A        ;ans Gate-Array losschicken
OUT (C),C        ;und Farbwert ans Gate-Array
INC HL           ;Tabellenzeiger um eins erhoehen
INC A            ;Register 0 / Farbe 2
LD C,(HL)        ;Pen 2 aus Index-Register bestimmen
OUT (C),A        ;ans Gate-Array
OUT (C),C        ;und Farbwert ans Gate-Array
INC HL           ;Tabellenzeiger um eins erhoehem
INC A            ;Register 0 / Farbe 3
LD C,(HL)        ;Pen 3 aus Index-Register laden
OUT (C),A        ;ans Gate-Array
OUT (C),C        ;und den Farbwert ans Gate-Array
INC HL           ;auf die naechsten drei Farben setzen
XOR A            ;A auf 0 setzen
DEFS 11          ;Sync des Rasters durch 11mal nichtstun
POP BC           ;Schleifenzaehler restaurieren
DJNZ LOOP        ;und die naechste Rasterzeile rastern
;
; Farben-Reset
;
LD B,&7F         ;Portadresse Gate-Array
LD C,84          ;Farbcode fuer Schwarz
INC A            ;A auf 1 setzen
OUT (C),A        ;Paletten-Pointer Farbe 1
OUT (C),C        ;auf Schwarz setzen
INC A            ;
OUT (C),A        ;synchron wie bei Farbe 1
OUT (C),C        ;
INC A            ;
OUT (C),A        ;synchron wie Farbe 1 & 2
OUT (C),C        ;
;
; Neuen Farbwert bestimmen
;
REPEA1 LD HL,(COLPOI)  ;HL indirekt aus COLPOI ladn
LD A,(HL)        ;Akku mit Farbwert
CP 255           ;Ende der Farbtabelle ?
JP NZ,CONT1      ;Nein, dann normal weiter
LD HL,COLORS     ;sonst HL auf Anfang der Farbtabelle setzen
LD (COLPOI),HL   ;- abspeichern
JP REPEA1        ;  und nochmal probieren
CONT1 INC HL     ;- sonst Color-Pointer erhoehen
LD (COLPOI),HL   ;  und abspeichern
PUSH AF          ;Farbcode sichern
;
; neues Segmentstueckchen einfugen
;
LD A,(SEGMEN)    ;Segmentst.zeiger ?
CP 9             ;ist er uebergelaufen ?
JP Z,NEWBIG      ;dann ein neues Segment eines Buchstaben rein
INC A            ;sonst A um eins erhoehem
LD (SEGMEN),A    ;und wieder Abspeichern
JP EINFUG        ;gleich zum Einfuegen springen
;
; neues Segmentbyte einfuegen
;
NEWBIG LD A,1    ;Akku mit eins laden
LD (SEGMEN),A    ;und abspeichern -> Anfang eines Segment
LD A,(LETTER)    ;Segmentzeiger nach A
CP 7             ;ist er 7 (d.h. neuer Buchstabe)
JP Z,NEWLET      ;dann so behandeln
LD E,A           ;
LD D,0           ;sonst A nach DE befoerdern
DEC DE           ;Anfangssegment auch beruecksichtigen !
INC A            ;Segmentzeiger noch um eins erhoehen
LD (LETTER),A    ;und abspeichern
LD HL,(TEXTPO)   ;HL mit Textstelle
LD A,(HL)        ;und den Buchstabenwert
SUB 48           ;A um 48 erniedrigen (damit bei 0 Anfang)
ADD A,A          ;A=A*2
LD C,A           ;C=A*2
ADD A,A          ;A=A*4
ADD A,C          ;A=A+C=6
LD L,A           ;
LD H,0           ;A nach HL befoerdern
LD BC,&9000      ;Anfangsadresse der Buchstben
ADD HL,BC        ;Buchstabenadr=(Buchstabe-48)*6+&9000
ADD HL,DE        ;plus Segmentnr. jetzt Segmentadresse
LD A,(HL)        ;Segment holen
LD (NOWSEG),A    ;und das Segment abgespeichern !
JP EINFUG        ;jetzt erstes Segment einfuegen
;
; Neuen Buchstaben einfuegen
;
NEWLET LD A,1    ;Segmentzeiger reseten
LD (LETTER),A    ;und abspeichern
LD HL,(TEXTPO)   ;HL mit Textpointer laden
INC HL           ;und naechster Buchstabe
LD A,(HL)        ;Akku mit neuen Buchstaben laden
CP 255           ;Ist er 255 ?
JR NZ,CO         ;Nein, dann normal weiter
LD HL,&9200      ;sonst an Anfang des Textes
CO LD (TEXTPO),HL ;Textpointer abspeichern
JP NEWBIG        ;und Segment-Routine wiederholen
;
; Farbwerte einfuegen
;
EINFUG POP AF    ;einzufuegende Farbe restaurieren
LD IX,ENDA       ;IX mit Adresse, wo einfuegen
LD HL,NOWSEG     ;HL mit Adresse, wo Segment gespeichert
LD E,(HL)        ;E mit Segmentwert laden
RR E             ;E nach rechts schieben (Bit ins Carry)
JP C,YES         ;Bit vorhanden ?
LD (IX+2),84     ;- Nein, Schwarz
LD (IX+5),84     ;  einfuegen
JR CO1           ;naechste Linie
YES LD (IX+2),A  ;- Farbe einfuegen
LD (IX+5),A      ;

CO1 RR E         ;- Vorgang ist
JP C,YES2        ;  synchron zu
LD (IX+1),84     ;  oben, jetzt mit
LD (IX+4),84     ;  dem 2.Byte
JR CO2           ;
YES2 LD (IX+1),A ;
LD (IX+4),A      ;

CO2 RR E          ;- Ebenfalls synchron
JP C,YES3         ;
LD (IX),84        ;
LD (IX+3),84      ;
JP THEEND         ;
YES3 LD (IX),A    ;
LD (IX+3),A       ;
THEEND EI         ;
CALL &6272 ;Soundroutine aufrufen
CALL &BB09        ;
RET C             ;
DI                ;auf Lady DI warten.
JP SYNC           ;

;
; Variablen
;
COLPOI DEFW COLORS  ;Farbzeiger auf Farben
SEGMEN DEFB 1       ;erstes Segmentstueckchen
LETTER DEFB 1       ;erster Teil eines Buchstabens
NOWSEG DEFB 0       ;augenblickliches Segment
TEXTPO DEFW &9200   ;Textzeiger
;
; Farbcode-Tabelle fuer Regenbogeneffekt
;
COLORS DEFB 85,93,87,95,83,75,83,95,87,93,255
; Farbwerttabelle  (510 Bytes, 3*170 Zeilen)
;
TABELL DEFB 84,84,84,84,84,84
TAB2 DEFB 84,84,84,84,84,84
DEFB 84,84,84,84,84,84,84,84,84,84,84,84,84,84,84,84,84,84,84,84
DEFB 84,84,84,84,84,84,84,84,84,84,84,84,84,84,84,84,84,84,84,84
DEFB 84,84,84,84,84,84,84,84,84,84,84,84,84,84,84,84,84,84,84,84
DEFB 84,84,84,84,84,84,84,84,84,84,84,84,84,84,84,84,84,84,84,84
DEFB 84,84,84,84,84,84,84,84,84,84,84,84,84,84,84,84,84,84,84,84
DEFB 84,84,84,84,84,84,84,84,84,84,84,84,84,84,84,84,84,84,84,84
DEFB 84,84,84,84,84,84,84,84,84,84,84,84,84,84,84,84,84,84,84,84
DEFB 84,84,84,84,84,84,84,84,84,84,84,84,84,84,84,84,84,84,84,84
DEFB 84,84,84,84,84,84,84,84,84,84,84,84,84,84,84,84,84,84,84,84
DEFB 84,84,84,84,84,84,84,84,84,84,84,84,84,84,84,84,84,84,84,84
DEFB 84,84,84,84,84,84,84,84,84,84,84,84,84,84,84,84,84,84,84,84
DEFB 84,84,84,84,84,84,84,84,84,84,84,84,84,84,84,84,84,84,84,84
DEFB 84,84,84,84,84,84,84,84,84,84,84,84,84,84,84,84,84,84,84,84
DEFB 84,84,84,84,84,84,84,84,84,84,84,84,84,84,84,84,84,84,84,84
DEFB 84,84,84,84,84,84,84,84,84,84,84,84,84,84,84,84,84,84,84,84
DEFB 84,84,84,84,84,84,84,84,84,84,84,84,84,84,84,84,84,84,84,84
DEFB 84,84,84,84,84,84,84,84,84,84,84,84,84,84,84,84,84,84,84,84
DEFB 84,84,84,84,84,84,84,84,84,84,84,84,84,84,84,84,84,84,84,84
DEFB 84,84,84,84,84,84,84,84,84,84,84,84,84,84,84,84,84,84,84,84
DEFB 84,84,84,84,84,84,84,84,84,84,84,84,84,84,84,84,84,84,84,84
DEFB 84,84,84,84,84,84,84,84,84,84,84,84,84,84,84,84,84,84,84,84
DEFB 84,84,84,84,84,84,84,84,84,84,84,84,84,84,84,84,84,84,84,84
DEFB 84,84,84,84,84,84,84,84,84,84,84,84,84,84,84,84,84,84,84,84
DEFB 84,84,84,84,84,84,84,84,84,84,84,84,84,84,84,84,84,84,84,84
DEFB 84,84,84,84,84,84,84,84,84,84,84,84,84,84,84
ENDA DEFB 84
ENDB DEFB 84
ENDC DEFB 84
ENEA DEFB 84
ENEB DEFB 84
ENEC DEFB 84

en from 6.7.1991 - 8.7.1991
;
; by ALIEN OF T.T.C.
;