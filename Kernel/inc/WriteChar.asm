;============================================================================
; Proc�dure interne, inutile � conna�tre pour un autre usage que AfficherMsg
; Affiche le caract�re en cours.
;============================================================================
AffCar PROC NEAR
    Mov  Ah, 0Eh
    Int  10h
    Ret
AffCar ENDP