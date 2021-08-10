;============================================================================
; Cette proc�dure affiche en binaire un nombre 16 bits en AX
;
; Param�tre d'entr�e  : AX
; Param�tre de sortie : aucun
; Registre d�truit    : aucun
; Autre proc�dure     : AffCar
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
    Inc  Cx               ; On incr�mente le compteur de chiffre

    Or   Ax,Ax            ; Z�ro ?
    Jnz  debut_chiffre    ; Non !
Affiche_nombre:
    Pop  Ax
    Add  Ax,48            ; Chiffre + 48 = Le chiffre visible !
    Call AffCar           ; Allez, on affiche !
    Loop Affiche_nombre   ; On r�pete jusqu'au bout

    Pop  Cx
    Pop  Bx
    Pop  Ax
    Popf

;    IRet                  ; Bonne nuit les petits :)
    Ret
AffNombre ENDP