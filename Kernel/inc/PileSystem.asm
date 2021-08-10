;============================================================================
; Cette renvoit l'adresse de la pile système
;
; Paramètre d'entrée  : aucun
; Paramètre de sortie : Es : segment de la pile système
;                       Di : offset de la pile système
; Registre détruit    : aucun
; Autre procédure     : aucune
;============================================================================
PileSys PROC NEAR
    Push OSSEGMENT
    Pop  Es
    Mov  Di, Offset VarSysUnDel - 2
    Ret
PileSys ENDP