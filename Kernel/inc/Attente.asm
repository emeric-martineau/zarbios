;============================================================================
; Cette proc�dure bloc le micro en cas de probl�me gr�ve dans le syst�me
;
; Param�tre d'entr�e  : aucun
; Param�tre de sortie : aucun
; Registre d�truit    : aucun
; Autre proc�dure     : aucune
;============================================================================
Attente PROC NEAR
    ; Oups ! Il est t�plan le t�mesys
    Inc Cx
    Loop attente
Attente ENDP