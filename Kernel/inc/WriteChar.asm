;============================================================================
; Procédure interne, inutile à connaître pour un autre usage que AfficherMsg
; Affiche le caractère en cours.
;============================================================================
AffCar PROC NEAR
    Mov  Ah, 0Eh
    Int  10h
    Ret
AffCar ENDP