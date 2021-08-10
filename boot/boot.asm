;=================================
; Zarbi-os CopyRight 2000 Bubule
;
; Secteur de boot
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
BOOTSEGMENT   equ 07C0h ; Segment o� est log� le boot
PILE          equ 1000h ; Adresse de la pile
LF            equ 10    ; LineFeed => Saut de ligne
CR            equ 13    ; CarryReturn => retour au d�but

VERSIONMAJEUR equ 0     ; Version majeur du boot
VERSIONMINEUR equ 0     ; Version mineur du boot
VERSIONSOUS   equ 1     ; x.xx
;============================================================================
; D�but programme
Kernel SEGMENT                 ;d�finition du segment
        ASSUME CS:Kernel,DS:Kernel

Start:
    Cli
    Jmp  BootEntry

                   Db   'ZFS'       ; Zarbi-os File System
                   Db   1           ; Version of File System

    KernelSector   Db   2           ; Secteur o� se trouve le noyau
    KernelFace     Db   0           ; Face o� se trouve le noyau
    KernelNbSector Db   1           ; Nombre de secteur que prend le noyau
    KernelTrack    Db   0           ; Num�ro de la piste o� se trouve le noyau

    ; Configuration du support
    DiskNbHead     Dw   1           ; Nombre de t�te du support 1 = 2 t�te
    DiskNbTrack    Db   80          ; Nombre de piste par face
    DiskNbSector   Db   18          ; Nombre de secteur par piste
    DiskNumber     Db   0           ; Num�ro du disk : 0 = floppy 1, 1 = floppy 2
                                    ; 80h = disk 1 ...

    ; Messages
    WellcomMsg     Db   'Zarbi-Os Boot Loader v', VERSIONMAJEUR + 48, '.', VERSIONMINEUR + 48, VERSIONSOUS + 48, LF, CR, FINCHAINE
    ErrorDiskMsg   Db   'Erreur lors du chargement !', LF, CR, FINCHAINE
    DskNoSys       Db   'Disque non syst�me !', LF, CR, FINCHAINE
    AttenteMsg     Db   'Appuyer sur une touche pour relancer le syst�me.', LF, CR, FINCHAINE

;============================================================================
; Affiche le caract�re en cours.
;============================================================================
AffCar PROC NEAR
    Mov  Ah, 0Eh
    Int  10h
    Ret
AffCar ENDP

;============================================================================
; Cette proc�dure affiche une cha�ne de caract�res ASCIIZ
;
; Param�tre d'entr�e  :
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

  Asciiz:
    Mov  Al, Es:[Di]
    Or   Al, Al             ; Z�ro ?
    Jz   FinAffMsg          ; Si fin de cha�ne, on arr�te
    Call AffCar             ; Sinon, on affiche le caract�re
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
; R�initialise le lecteur
;
; Param�tre d'entr�e  : Dl : le lecteur � r�initialiser
; Param�tre de sortie : Carry Flag
; Registre d�truit    : aucun
; Autre proc�dure     : aucune
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
    Xor  Ax, Ax     ; Z�ro register
    Int  16h

    ; Relance la proc�dure de boot
    Int  19h
Reboot ENDP

;============================================================================
; Erreur disque on arr�te
;============================================================================
ErreurSys PROC NEAR
    Mov  Di, Offset DskNoSys
    Call AfficherMsg

    Jmp  Reboot
ErreurSys ENDP

;----------------------------------------------------------------------------
; Point d'entr�e du boot lors du d�marrage
; Ce secteur est charg� � l'adresse 07C0h:0000
;----------------------------------------------------------------------------
BootEntry:
    ; Fixe la pile � l'adresse 1000h:0000
    mov  Ax,1000h
    mov  Ss, Ax
    Xor  Sp, Sp

    Mov  Ax, BOOTSEGMENT
    Mov  Es, Ax
    Mov  Ds, Ax

    Sti

    ; Affiche le message de d�marrage
    Mov  Di, Offset WellcomMsg
    Call AfficherMsg

    Mov  Cx, 3

    ; On r�initialise le disque
    Mov  Dl, DiskNumber
    Call Reset

    ; V�rifie qu'il y a bien une noyau
    Or  KernelNbSector, 0
    Jz  ErreurSys

    ; V�rifie que le lecteur est pret
    Mov  Ah, 01h
    Mov  Dl, DiskNumber
    Int  13h

    ; Chargement du noyau
    Mov  Ax, OSSEGMENT
    Mov  Es, Ax           ; es=segment du noyau=0050h

    Mov  Ah, 02h                ; Fonction 2: Lecture de secteur(s)
    Mov  Al, KernelNbSector     ; al=nombre de secteurs � lire
    Xor  Bx, Bx                 ; bx=offset pour l'�criture=0 {ES:BX=0050h:0000}
    Mov  Ch, KernelTrack        ; ch=num�ro de la piste
    Mov  Cl, KernelSector       ; cl=lire � partir du x^�me secteur
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