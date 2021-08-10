;============================================================================
; Cette proc�dure affiche une cha�ne de caract�res ASCII ou ASCIIZ
;
; Param�tre d'entr�e  :
;   Al : d�finit le type de cha�ne
;   Bx : donne le nombre de caract�re � afficher (maximum 65535)
;   Es : segment de la cha�ne
;   Di : offset de la cha�ne
; Param�tre de sortie : aucun
; Registre d�truit    : aucun
; Autre proc�dure     : AffCar
;============================================================================
AfficherMsg PROC NEAR
    ; Sauvegarde des registres qui seront modifi�s
    Push Ax
    Push Cx
    Push Di

    ; S�lection du type de cha�ne
    Or   Al, Al
    Jz   Ascii

  Asciiz:
    Mov  Al, [Di]
    Or   Al, Al             ; Z�ro ?
    Jz   FinAffMsg          ; Si fin de cha�ne, on arr�te
    Call AffCar             ; Sinon, on affiche le caract�re
    Inc  Di
    Jmp  Asciiz

  Ascii:
    Mov  Al, [Di]
    Call AffCar   ; On affiche le caract�re
    Inc  Di
    Loop Ascii

  FinAffMsg:
    ; Restaure les registres
    Pop  Di
    Pop  Cx
    Pop  Ax

;    Iret                    ; Allez, salut !
Ret
AfficherMsg ENDP