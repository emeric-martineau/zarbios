;============================================================================
; Cette proc�dure renvoit la version du syst�me d'exploitaion
;
; Param�tre d'entr�e  : aucun
; Param�tre de sortie : Ah : version majeur du syst�me
;                       Al : version mineur
; Registre d�truit    : aucun
; Autre proc�dure     : aucune
;============================================================================
OsVersion PROC NEAR
    Mov  Ah, VERSIONMAJEUR
    Mov  Al, VERSIONMINEUR
    Ret
OsVersion ENDP