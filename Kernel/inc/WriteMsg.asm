;============================================================================
; Cette procédure affiche une chaîne de caractères ASCII ou ASCIIZ
;
; Paramètre d'entrée  :
;   Al : définit le type de chaîne
;   Bx : donne le nombre de caractère à afficher (maximum 65535)
;   Es : segment de la chaîne
;   Di : offset de la chaîne
; Paramètre de sortie : aucun
; Registre détruit    : aucun
; Autre procédure     : AffCar
;============================================================================
AfficherMsg PROC NEAR
    ; Sauvegarde des registres qui seront modifiés
    Push Ax
    Push Cx
    Push Di

    ; Sélection du type de chaîne
    Or   Al, Al
    Jz   Ascii

  Asciiz:
    Mov  Al, [Di]
    Or   Al, Al             ; Zéro ?
    Jz   FinAffMsg          ; Si fin de chaîne, on arrête
    Call AffCar             ; Sinon, on affiche le caractère
    Inc  Di
    Jmp  Asciiz

  Ascii:
    Mov  Al, [Di]
    Call AffCar   ; On affiche le caractère
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