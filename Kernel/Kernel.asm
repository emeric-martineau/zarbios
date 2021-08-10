;=================================
; Zarbi-os CopyRight 2000 Bubule
;
; Noyau du syst�me d'exploitation
;
; e-mail: bubulemaster@ifrance.com
;
;=================================


; D�finition du processeur
.8086

;****************************************************************************
; D�finition des constantes
;****************************************************************************
FINCHAINE     equ 0     ; Terminateur de cha�ne
OSSEGMENT     equ 0050h ; Segment o� est log� l'OS
PILE          equ 1000h ; Adresse de la pile
LF            equ 10    ; LineFeed => Saut de ligne
CR            equ 13    ; CarryReturn => retour au d�but

VERSIONMAJEUR equ 0     ; Version majeur du syst�me d'exploitaion
VERSIONMINEUR equ 0     ; Version mineur du syst�me d'exploitaion
VERSIONSOUS   equ 1     ; x.xx

; D�finition des codes erreurs
SYSRUN        equ 1

; Num�ro d'interruption du syst�me
NBKERNELINT   equ 44h
KERNEL_IP     equ NBKERNELINT * 4
KERNEL_CS     equ NBKERNELINT * 4 + 2


;============================================================================
; D�but programme
Kernel SEGMENT                 ;d�finition du segment
        ASSUME CS:Kernel,DS:Kernel

Start:  
    ; Allez, on commence ? Ouais !
    Cli
    Jmp  KernelEntry

;****************************************************************************
; D�finition des constantes pr�sentent dans  le  syst�me  d'exploitation
; qui ne serviront qu'au d�marage et qui serviront comme lieu de sockage
; pour la pile syst�me.
; Db ->  8 bits
; Dw -> 16 bits
; Dd -> 32 bits
;****************************************************************************
    ; Ajoute 48 pour obtenir le caract�re correspondant au chiffre
    ZarbiOS       Db 'Zarbi-OS v', VERSIONMAJEUR + 48, '.', VERSIONMINEUR + 48, VERSIONSOUS + 48
                  Db ' 2000 CopyRight Bubule', LF, CR 
                  Db 'Compil� le ', ??date, ' � ', ??time, LF, CR, FINCHAINE
    MemorySize    Db 'M�moire basse : ', FINCHAINE
    KiloOctet     Db ' Ko', LF, CR, FINCHAINE

;----------------------------------------------------------------------------
;point d'entr�e au noyau lors de l'initialisation
;----------------------------------------------------------------------------
KernelEntry:
    ; D�finie la pile
;    Xor  Ax, Ax
    Mov  Ax, 0FFFEh
    Mov  Ss, Ax
    Mov  Sp, PILE

    ; Param�tre l'environnement
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

    ; r�activation des interruptions
    Sti

    ; Affiche le message de d�marrage
    Mov  Al, 1             ; Cha�ne Assciiz
    Mov  Di, Offset ZarbiOs
    Call AfficherMsg

    ; Affiche la taille de la m�moire
    Mov  Di, Offset MemorySize
    Call AfficherMsg
    Int  12h                ; M�moire basse dans Ax
;    Mov  MemSize, Ax        ; Sauvegarde la taille de la m�moire
    Call AffNombre
    Mov  Al, 1              ; Cha�ne Assciiz
    Mov  Di, Offset KiloOctet
    Call AfficherMsg

    ; Test la r�ussite du noyau
    int 44h
;****************************************************************************

;****************************************************************************
; D�finition de variable pr�sente dans le syst�me et qui ne devront en aucun
; cas �tre effac�es !!!
;****************************************************************************
VarSysUnDel:
    SystemInit    Db 'SysInit Ok', LF, CR, FINCHAINE
    SysArrete     Db 'Syst�me arr�t� !!!', LF, CR, FINCHAINE
    MsgArrete     Db LF, CR, FINCHAINE  ; cette cha�ne ne sert � rien sauf
                                            ; � �vit� que le noyau ne plante !
    ; Indique s'il le syst�me est d�j� utilis�
    InOS          Db 0
    ; Indique la position de la pile syst�me
    PileSeg       Dw 0
    PileOff       Dw 0
    MemSize       Dw 0                  ; Taille m�moire pr�sent sur l'ordi

;============================================================================
; Proc�dure interne, inutile � conna�tre pour un autre usage que AfficherMsg
; Affiche le caract�re en cours.
;============================================================================
AffCar PROC NEAR
    Mov  Ah, 0Eh
    Int  10h
    Ret
AffCar ENDP

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
    Cmp  Al, 0
    Jz   Ascii

  Asciiz:
    Mov  Al, Es:[Di]
    Cmp  Al, 0              ; Z�ro ?
    Jz   FinAffMsg          ; Si fin de cha�ne, on arr�te
    Call AffCar             ; Sinon, on affiche le caract�re
    Inc  Di
    Jmp  Asciiz

  Ascii:
    Mov  Al, Es:[Di]
    Call AffCar             ; On affiche le caract�re
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

    Cmp  Ax, 0            ; Z�ro ?
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

    Ret                   ; Bonne nuit les petits :)
AffNombre ENDP

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

;============================================================================
; Cette proc�dure bloc le micro en cas de probl�me gr�ve dans le syst�me
;
; Param�tre d'entr�e  : aucun
; Param�tre de sortie : aucun
; Registre d�truit    : aucun
; Autre proc�dure     : aucune
;============================================================================
Attente PROC NEAR
    ; Affiche le message de d�marrage
    Mov  Al, 1             ; Cha�ne Assciiz
    Mov  Di, Offset SysArrete
    Call AfficherMsg

AttKJW1:
    ; Oups ! Il est t�plan le t�mesys
    Inc  Cx
    Loop AttKJW1
Attente ENDP

;----------------------------------------------------------------------------
; Point d'entr�e du noyau lors de l'appel par interruption
; Lors d'un Int 44h, Cs = OSSEGMENT
;----------------------------------------------------------------------------
KernelInt:
    ; V�rifie que le syst�me n'est pas d�j� en cours d'ex�cution
    ; car le syst�me �tant mono-t�che, il n'est pas r�-entrant.
    Cmp  InOS, 0   ; Z�ro ?
    Jnz  KernelFinErr
    ; Marque que le syst�me est en cours d'ex�cution
    Mov  InOS, 1
    Cli
    ; sauve l'ancienne pile
    Mov  PileSeg, Ss
    Mov  PileOff, Sp
    ; D�finie la pile
    Push OSSEGMENT
    Pop  Ss
    Mov  Sp, Offset VarSysUnDel - 2
    ; Param�tre l'environnement
    ; Ds = Es = OSSEGMENT
    Mov  Ax, OSSEGMENT 
    Mov  Ds, Ax
    Push Ds
    Pop  Es
    ; r�activation des interruptions
    Sti
;-------------------------------------------
    ; Affiche le message de d�marrage
    Mov  Al, 1             ; Cha�ne Assciiz
    Mov  Di, Offset SystemInit
    Call AfficherMsg

    Call Attente
;-------------------------------------------
    ; Le syst�me n'est plus actif !
    Cli
    Mov  InOS, 0
    ; resteure l'ancienne pile
    Mov  Ss, PileSeg
    Mov  Sp, PileOff
    Jmp  KernelFin

KernelFinErr:
    ; Le noyau est en cours d'ex�cution
    Mov  Ax, SYSRUN
    Stc                     ; Set Carry Flag : Indique dans notre cas une erreur

KernelFin:
    mov  ax, 40h
    out  20h, ax
    Sti
    Iret

Kernel ENDS
        END Start
