;============================================================================
; Cette renvoit l'adresse de la pile syst�me
;
; Param�tre d'entr�e  : aucun
; Param�tre de sortie : Es : segment de la pile syst�me
;                       Di : offset de la pile syst�me
; Registre d�truit    : aucun
; Autre proc�dure     : aucune
;============================================================================
PileSys PROC NEAR
    Push OSSEGMENT
    Pop  Es
    Mov  Di, Offset VarSysUnDel - 2
    Ret
PileSys ENDP