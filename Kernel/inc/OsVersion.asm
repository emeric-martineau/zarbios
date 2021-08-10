;============================================================================
; Cette procédure renvoit la version du système d'exploitaion
;
; Paramètre d'entrée  : aucun
; Paramètre de sortie : Ah : version majeur du système
;                       Al : version mineur
; Registre détruit    : aucun
; Autre procédure     : aucune
;============================================================================
OsVersion PROC NEAR
    Mov  Ah, VERSIONMAJEUR
    Mov  Al, VERSIONMINEUR
    Ret
OsVersion ENDP