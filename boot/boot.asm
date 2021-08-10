;=================================
; Zarbi-os CopyRight 2000 Bubule
;
; Secteur de boot
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
BOOTSEGMENT   equ 07C0h ; Segment où est logé le boot
PILE          equ 1000h ; Adresse de la pile
LF            equ 10    ; LineFeed => Saut de ligne
CR            equ 13    ; CarryReturn => retour au début

VERSIONMAJEUR equ 0     ; Version majeur du boot
VERSIONMINEUR equ 0     ; Version mineur du boot
VERSIONSOUS   equ 1     ; x.xx
;============================================================================
; Début programme
Kernel SEGMENT                 ;définition du segment
        ASSUME CS:Kernel,DS:Kernel

Start:
    Cli
    Jmp  BootEntry

                   Db   'ZFS'       ; Zarbi-os File System
                   Db   1           ; Version of File System

    KernelSector   Db   2           ; Secteur où se trouve le noyau
    KernelFace     Db   0           ; Face où se trouve le noyau
    KernelNbSector Db   1           ; Nombre de secteur que prend le noyau
    KernelTrack    Db   0           ; Numéro de la piste où se trouve le noyau

    ; Configuration du support
    DiskNbHead     Dw   1           ; Nombre de tête du support 1 = 2 tête
    DiskNbTrack    Db   80          ; Nombre de piste par face
    DiskNbSector   Db   18          ; Nombre de secteur par piste
    DiskNumber     Db   0           ; Numéro du disk : 0 = floppy 1, 1 = floppy 2
                                    ; 80h = disk 1 ...

    ; Messages
    WellcomMsg     Db   'Zarbi-Os Boot Loader v', VERSIONMAJEUR + 48, '.', VERSIONMINEUR + 48, VERSIONSOUS + 48, LF, CR, FINCHAINE
    ErrorDiskMsg   Db   'Erreur lors du chargement !', LF, CR, FINCHAINE
    DskNoSys       Db   'Disque non système !', LF, CR, FINCHAINE
    AttenteMsg     Db   'Appuyer sur une touche pour relancer le système.', LF, CR, FINCHAINE

;============================================================================
; Affiche le caractère en cours.
;============================================================================
AffCar PROC NEAR
    Mov  Ah, 0Eh
    Int  10h
    Ret
AffCar ENDP

;============================================================================
; Cette procédure affiche une chaîne de caractères ASCIIZ
;
; Paramètre d'entrée  :
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

  Asciiz:
    Mov  Al, Es:[Di]
    Or   Al, Al             ; Zéro ?
    Jz   FinAffMsg          ; Si fin de chaîne, on arrête
    Call AffCar             ; Sinon, on affiche le caractère
    Inc  Di
    Jmp  Asciiz

  FinAffMsg:
    ; Restaure les registres
    Pop  Di
    Pop  Cx
    Pop  Ax

    ; Allez, salut !
    Ret
AfficherMsg ENDP

;============================================================================
; Réinitialise le lecteur
;
; Paramètre d'entrée  : Dl : le lecteur à réinitialiser
; Paramètre de sortie : Carry Flag
; Registre détruit    : aucun
; Autre procédure     : aucune
;============================================================================
Reset PROC NEAR
    Mov  Ah, 0Dh
    Int  13h
    Ret
Reset ENDP

;============================================================================
; Relance la chinema
;============================================================================
Reboot PROC NEAR
    Mov  Di, Offset AttenteMSg
    Call AfficherMsg

    ; Attent le frappe d'une touche
    Xor  Ax, Ax     ; Zéro register
    Int  16h

    ; Relance la procédure de boot
    Int  19h
Reboot ENDP

;============================================================================
; Erreur disque on arrête
;============================================================================
ErreurSys PROC NEAR
    Mov  Di, Offset DskNoSys
    Call AfficherMsg

    Jmp  Reboot
ErreurSys ENDP

;----------------------------------------------------------------------------
; Point d'entrée du boot lors du démarrage
; Ce secteur est chargé à l'adresse 07C0h:0000
;----------------------------------------------------------------------------
BootEntry:
    ; Fixe la pile à l'adresse 1000h:0000
    mov  Ax,1000h
    mov  Ss, Ax
    Xor  Sp, Sp

    Mov  Ax, BOOTSEGMENT
    Mov  Es, Ax
    Mov  Ds, Ax

    Sti

    ; Affiche le message de démarrage
    Mov  Di, Offset WellcomMsg
    Call AfficherMsg

    Mov  Cx, 3

    ; On réinitialise le disque
    Mov  Dl, DiskNumber
    Call Reset

    ; Vérifie qu'il y a bien une noyau
    Or  KernelNbSector, 0
    Jz  ErreurSys

    ; Vérifie que le lecteur est pret
    Mov  Ah, 01h
    Mov  Dl, DiskNumber
    Int  13h

    ; Chargement du noyau
    Mov  Ax, OSSEGMENT
    Mov  Es, Ax           ; es=segment du noyau=0050h

    Mov  Ah, 02h                ; Fonction 2: Lecture de secteur(s)
    Mov  Al, KernelNbSector     ; al=nombre de secteurs à lire
    Xor  Bx, Bx                 ; bx=offset pour l'écriture=0 {ES:BX=0050h:0000}
    Mov  Ch, KernelTrack        ; ch=numéro de la piste
    Mov  Cl, KernelSector       ; cl=lire à partir du x^ème secteur
    Mov  Dh, KernelFace         ; Dh= face de disque
    Mov  Dl, DiskNumber
    Int  13h                    ; appel du BIOS

    DB  0EAH            ;\
    DW  0000H           ; > SAUTE A 0050h:0000 => noyau
    DW  0050H           ;/

; Indique qu'il s'agit d'un secteur de boot
ORG 510
    Dw  0AA55h

Kernel ENDS
        END Start