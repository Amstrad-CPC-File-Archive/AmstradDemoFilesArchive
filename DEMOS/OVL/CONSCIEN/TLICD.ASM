; :::::: The Least I Can Do ::::::
; ---- A 16 (love)bytes entry ----

      ORG 7
          di
          exx
.lp
          xor h:rst 16
          ld a,(hl):inc hl:rst 16
          jr .lp
      IF $-16
 !! error align
      END
          or &44
          out (c),0
          out (c),a:ret

or alignJJ�4DJ�qJ�y�JJ LBLsl� ChCk                                    