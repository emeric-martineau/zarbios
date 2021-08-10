;============================================================================
; Cette procédure affiche en binaire un nombre 16 bits en AX
;
; Paramètre d'entrée  : AX
; Paramètre de sortie : aucun
; Registre détruit    : aucun
; Autre procédure     : AffCar
;============================================================================
AffNombre PROC NEAR
    Pushf
    Push Ax
    Push Bx
    Push Cx

    Mov  Bx,10            ; Initialisation du diviseur
    Mov  Cx,0             ; Initialisation du compteur
debut_chiffre:  
    Mov  Dx,0             ; Initialisation d'une partie du dividende

    Div  Bx               ; On divise
    Push Dx               ; On sauvegarde la valeur
    Inc  Cx               ; On incrémente le compteur de chiffre

    Or   Ax,Ax            ; Zéro ?
    Jnz  debut_chiffre    ; Non !
Affiche_nombre:
    Pop  Ax
    Add  Ax,48            ; Chiffre + 48 = Le chiffre visible !
    Call AffCar           ; Allez, on affiche !
    Loop Affiche_nombre   ; On répete jusqu'au bout

    Pop  Cx
    Pop  Bx
    Pop  Ax
    Popf

;    IRet                  ; Bonne nuit les petits :)
    Ret
AffNombre ENDP