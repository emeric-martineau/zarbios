;=================================
; Zarbi-os CopyRight 2000 Bubule
;
; Noyau du système d'exploitation
;
; e-mail: bubulemaster@ifrance.com
;
;=================================


; Définition du processeur
.8086

;****************************************************************************
; Définition des constantes
;****************************************************************************
FINCHAINE     equ 0     ; Terminateur de chaîne
OSSEGMENT     equ 0050h ; Segment où est logé l'OS
PILE          equ 1000h ; Adresse de la pile
LF            equ 10    ; LineFeed => Saut de ligne
CR            equ 13    ; CarryReturn => retour au début

VERSIONMAJEUR equ 0     ; Version majeur du système d'exploitaion
VERSIONMINEUR equ 0     ; Version mineur du système d'exploitaion
VERSIONSOUS   equ 1     ; x.xx

; Définition des codes erreurs
SYSRUN        equ 1

; Numéro d'interruption du système
NBKERNELINT   equ 44h
KERNEL_IP     equ NBKERNELINT * 4
KERNEL_CS     equ NBKERNELINT * 4 + 2


;============================================================================
; Début programme
Kernel SEGMENT                 ;définition du segment
        ASSUME CS:Kernel,DS:Kernel

Start:  
    ; Allez, on commence ? Ouais !
    Cli
    Jmp  KernelEntry

;****************************************************************************
; Définition des constantes présentent dans  le  système  d'exploitation
; qui ne serviront qu'au démarage et qui serviront comme lieu de sockage
; pour la pile système.
; Db ->  8 bits
; Dw -> 16 bits
; Dd -> 32 bits
;****************************************************************************
    ; Ajoute 48 pour obtenir le caractère correspondant au chiffre
    ZarbiOS       Db 'Zarbi-OS v', VERSIONMAJEUR + 48, '.', VERSIONMINEUR + 48, VERSIONSOUS + 48
                  Db ' 2000 CopyRight Bubule', LF, CR 
                  Db 'Compil‚ le ', ??date, ' … ', ??time, LF, CR, FINCHAINE
    MemorySize    Db 'M‚moire basse : ', FINCHAINE
    KiloOctet     Db ' Ko', LF, CR, FINCHAINE

;----------------------------------------------------------------------------
;point d'entrée au noyau lors de l'initialisation
;----------------------------------------------------------------------------
KernelEntry:
    ; Définie la pile
;    Xor  Ax, Ax
    Mov  Ax, 0FFFEh
    Mov  Ss, Ax
    Mov  Sp, PILE

    ; Paramètre l'environnement
    ; Ds = Es = 0050h
    Mov  Ax, OSSEGMENT
    Mov  Ds, Ax
    Push Ds
    Pop  Es

    ; Inscrit le noyau dans la table des vecteurs
    Mov  Bx, KERNEL_IP
    Mov  Word Ptr [Bx], Offset KernelInt
    Mov  Bx, KERNEL_CS
    Mov  Word Ptr [Bx], OSSEGMENT

    ; réactivation des interruptions
    Sti

    ; Affiche le message de démarrage
    Mov  Al, 1             ; Chaîne Assciiz
    Mov  Di, Offset ZarbiOs
    Call AfficherMsg

    ; Affiche la taille de la mémoire
    Mov  Di, Offset MemorySize
    Call AfficherMsg
    Int  12h                ; Mémoire basse dans Ax
;    Mov  MemSize, Ax        ; Sauvegarde la taille de la mémoire
    Call AffNombre
    Mov  Al, 1              ; Chaîne Assciiz
    Mov  Di, Offset KiloOctet
    Call AfficherMsg

    ; Test la réussite du noyau
    int 44h
;****************************************************************************

;****************************************************************************
; Définition de variable présente dans le système et qui ne devront en aucun
; cas être effacées !!!
;****************************************************************************
VarSysUnDel:
    SystemInit    Db 'SysInit Ok', LF, CR, FINCHAINE
    SysArrete     Db 'SystŠme arrˆt‚ !!!', LF, CR, FINCHAINE
    MsgArrete     Db LF, CR, FINCHAINE  ; cette chaîne ne sert à rien sauf
                                            ; à évité que le noyau ne plante !
    ; Indique s'il le système est déjà utilisé
    InOS          Db 0
    ; Indique la position de la pile système
    PileSeg       Dw 0
    PileOff       Dw 0
    MemSize       Dw 0                  ; Taille mémoire présent sur l'ordi

;============================================================================
; Procédure interne, inutile à connaître pour un autre usage que AfficherMsg
; Affiche le caractère en cours.
;============================================================================
AffCar PROC NEAR
    Mov  Ah, 0Eh
    Int  10h
    Ret
AffCar ENDP

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
    Cmp  Al, 0
    Jz   Ascii

  Asciiz:
    Mov  Al, Es:[Di]
    Cmp  Al, 0              ; Zéro ?
    Jz   FinAffMsg          ; Si fin de chaîne, on arrête
    Call AffCar             ; Sinon, on affiche le caractère
    Inc  Di
    Jmp  Asciiz

  Ascii:
    Mov  Al, Es:[Di]
    Call AffCar             ; On affiche le caractère
    Inc  Di
    Loop Ascii

  FinAffMsg:
    ; Restaure les registres
    Pop  Di
    Pop  Cx
    Pop  Ax

    Ret                     ; Allez, salut !
AfficherMsg ENDP

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

    Cmp  Ax, 0            ; Zéro ?
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

    Ret                   ; Bonne nuit les petits :)
AffNombre ENDP

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

;============================================================================
; Cette procédure bloc le micro en cas de problème grâve dans le système
;
; Paramètre d'entrée  : aucun
; Paramètre de sortie : aucun
; Registre détruit    : aucun
; Autre procédure     : aucune
;============================================================================
Attente PROC NEAR
    ; Affiche le message de démarrage
    Mov  Al, 1             ; Chaîne Assciiz
    Mov  Di, Offset SysArrete
    Call AfficherMsg

AttKJW1:
    ; Oups ! Il est téplan le tèmesys
    Inc  Cx
    Loop AttKJW1
Attente ENDP

;----------------------------------------------------------------------------
; Point d'entrée du noyau lors de l'appel par interruption
; Lors d'un Int 44h, Cs = OSSEGMENT
;----------------------------------------------------------------------------
KernelInt:
    ; Vérifie que le système n'est pas déjà en cours d'exécution
    ; car le système étant mono-tâche, il n'est pas ré-entrant.
    Cmp  InOS, 0   ; Zéro ?
    Jnz  KernelFinErr
    ; Marque que le système est en cours d'exécution
    Mov  InOS, 1
    Cli
    ; sauve l'ancienne pile
    Mov  PileSeg, Ss
    Mov  PileOff, Sp
    ; Définie la pile
    Push OSSEGMENT
    Pop  Ss
    Mov  Sp, Offset VarSysUnDel - 2
    ; Paramètre l'environnement
    ; Ds = Es = OSSEGMENT
    Mov  Ax, OSSEGMENT 
    Mov  Ds, Ax
    Push Ds
    Pop  Es
    ; réactivation des interruptions
    Sti
;-------------------------------------------
    ; Affiche le message de démarrage
    Mov  Al, 1             ; Chaîne Assciiz
    Mov  Di, Offset SystemInit
    Call AfficherMsg

    Call Attente
;-------------------------------------------
    ; Le système n'est plus actif !
    Cli
    Mov  InOS, 0
    ; resteure l'ancienne pile
    Mov  Ss, PileSeg
    Mov  Sp, PileOff
    Jmp  KernelFin

KernelFinErr:
    ; Le noyau est en cours d'exécution
    Mov  Ax, SYSRUN
    Stc                     ; Set Carry Flag : Indique dans notre cas une erreur

KernelFin:
    mov  ax, 40h
    out  20h, ax
    Sti
    Iret

Kernel ENDS
        END Start
