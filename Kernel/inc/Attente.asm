;============================================================================
; Cette procédure bloc le micro en cas de problème grâve dans le système
;
; Paramètre d'entrée  : aucun
; Paramètre de sortie : aucun
; Registre détruit    : aucun
; Autre procédure     : aucune
;============================================================================
Attente PROC NEAR
    ; Oups ! Il est téplan le tèmesys
    Inc Cx
    Loop attente
Attente ENDP