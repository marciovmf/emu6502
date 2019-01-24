; **************************************
; *      6502 mEMULATION ENGINE        *
; * copyright - (c) nEuRoMaNcEr 2003   *
; *     marciomanbr@yahoo.com.br       *
; **************************************
; * module: loader.exe                 *
; **************************************
.386
.model Flat,stdcall
UNICODE=0
include inc/w32.inc
include inc/6502types.inc

extrn _wsprintfA:proc
extrn _lopen:proc
extrn _lread:proc
; ******************************
; * The VM memory organization *
; ******************************
%OUT ################################

ZERO_PAGE    = 0                       ;; 0000-00FF - Zero-Page
STACK_       = 255                     ;; 0100-01FF - Stack
RAM          = 511                     ;; RAM memory
NMIB_ADDR    = 65530                   ;; NMIB routine addres
RESET_ADDR   = 65532                   ;; RESET routine
IRQ_ADDR     = 65534                   ;; IRQ routine

.data
E_ALLOC_MSG         db "Could Not alloc memory,",10,13,"terminatting application",0
MSG_TITLE           db "(X) Error",0
MSG_SUCCESS         db "Gracefull Exit!",0
code2exec:
include src\code6502.asm
code2execlen        equ $ - offset code2exec
MSG_INV             db "INVALID OPCODE",0
MSG_ORA             db "ORA INSTRUCTION",0
MSG_BRK             db "BRK INSTRUCTION",0
MSG_TSB             db "TSB INSTRUCTION",0
MSG_ASL             db "ASL INSTRUCTION",0
MSG_AND             db "AND INSTRUCTION",0
MSG_PHP             db "PHP INSTRUCTION",0
MSG_PLP             db "PLP INSTRUCTION",0
MSG_PLA             db "PLA INSTRUCTION",0
MSG_BPL             db "BPL INSTRUCTION",0
MSG_BVC             db "BVC INSTRUCTION",0
MSG_BMI             db "BMI INSTRUCTION",0
MSG_CLC             db "CLC INSTRUCTION",0
MSG_CLI             db "CLI INSTRUCTION",0
MSG_CLV             db "CLV INSTRUCTION",0
MSG_CLD             db "CLD INSTRUCTION",0
MSG_SEC             db "SEC INSTRUCTION",0
MSG_JSR             db "JSR INSTRUCTION",0
MSG_EOR             db "EOR INSTRUCTION",0
MSG_BIT             db "BIT INSTRUCTION",0
MSG_ROL             db "ROL INSTRUCTION",0
MSG_ROR             db "ROR INSTRUCTION",0
MSG_PHA             db "PHA INSTRUCTION",0
MSG_JMP             db "JMP INSTRUCTION",0
MSG_ADC             db "ADC INSTRUCTION",0
MSG_SEI             db "SEI INSTRUCTION",0
MSG_BVS             db "BVD INSTRUCTION",0
MSG_STA             db "STA INSTRUCTION",0
MSG_STY             db "STY INSTRUCTION",0
MSG_STX             db "STX INSTRUCTION",0
MSG_DEY             db "DEY INSTRUCTION",0
MSG_TXA             db "TXA INSTRUCTION",0
MSG_TXS             db "TXS INSTRUCTION",0
MSG_TYA             db "TYA INSTRUCTION",0
MSG_TAY             db "TAY INSTRUCTION",0
MSG_TSX             db "TSX INSTRUCTION",0
MSG_TAX             db "TAX INSTRUCTION",0
MSG_LDA             db "LDA INSTRUCTION",0
MSG_LDY             db "LDY INSTRUCTION",0
MSG_LDX             db "LDX INSTRUCTION",0
MSG_BCC             db "BCC INSTRUCTION",0
MSG_BCS             db "BCS INSTRUCTION",0
MSG_CPX             db "CPX ISNTRUCTION",0
MSG_CPY             db "CPY ISNTRUCTION",0
MSG_CMP             db "CMP ISNTRUCTION",0
MSG_DEC             db "DEC ISNTRUCTION",0
MSG_DEX             db "DEX ISNTRUCTION",0
MSG_INY             db "INY ISNTRUCTION",0
MSG_INX             db "INX ISNTRUCTION",0
MSG_BNE             db "BNE INSTRUCTION",0
MSG_BEQ             db "BEQ INSTRUCTION",0
MSG_INC             db "INC INSTRUCTION",0

MSG_IMM             db "Addressing mode immediate",0
MSG_IMP             db "Addressing mode implied",0
MSG_ZP              db "Addressing mode Zero-Page",0
MSG_INDX            db "Addressing mode indirect X",0
MSG_INDY            db "Addressing mode indirect Y",0
MSG_IND             db "Addressing mode indirect",0
MSG_ACM             db "Addressing mode Accumulator",0
MSG_ABS             db "Addressing mode Absolute",0
MSG_REL             db "Addressing mode Relative",0
wavesound           db "tada.wav",0
LBL_STACK           db "Virtual 6502 Stack Window",0
MSG_STATE           db "Virtual 6502 CPU State Window",0
szFmt               db 10,13,"______________________________________________________",10,13
                    db "REGISTERS [REG_A] = 0x%Xh [REG_X] = 0x%Xh   [REG_Y] = 0x%Xh",10,13
                    db "FLAGS            [%s]    0x%Xh",10,13
                    db "STACK POINTER    [S] = 0x%Xh",10,13
                    db "PROGRAM COUNTER  [C] = 0x%Xh",0
                    
ofncodefile         db 255 dup (0)
ofntitle            db "Choose code to emulate",0
szofntitle          equ $ - ofntitle
ofnFilter           db "6502 Binary Files",0
                    db "*.bin",0,0


fmtstrsz equ ($-szFmt+31)
buffer              db fmtstrsz dup (0)
flag_data           db"00000000",0
written             dd ?
szwrite             dd ?
VMem                dd ?

.data?
vm   VM_STRUCT  <?>
ofn  OPENFILENAME <?>
.code
loader:

       ; choose file to emulate
       mov ofn.on_lStructSize, OPENFILENAME_
       mov ofn.on_hwndOwner,NULL
       push 0
       call GetModuleHandle
       mov ofn.on_hInstance,eax
       mov ofn.on_lpstrFilter, offset ofnFilter
       mov ofn.on_lpstrCustomFilter,NULL
       mov ofn.on_nFilterIndex,0
       mov ofn.on_lpstrFile,offset ofncodefile
       mov ofn.on_nMaxFile,255
       mov ofn.on_lpstrFileTitle, NULL
       mov ofn.on_nMaxFileTitle,NULL
       mov ofn.on_lpstrInitialDir,NULL
       mov ofn.on_lpstrTitle,offset ofntitle
       mov ofn.on_Flags, OFN_FILEMUSTEXIST + OFN_PATHMUSTEXIST
       mov ofn.on_lpstrDefExt, NULL
       push offset ofn
       call GetOpenFileName
       ; open file
       push OF_READ
       push offset ofncodefile
       call _lopen
       push eax            ; salva o handle do arquivo na stack


       push NULL
       push eax
       call GetFileSize
       push eax            ; salva o tamanho na pilha
       
       inc eax
       push eax            ; tamanho do bloco de memória
       push GPTR
       call GlobalAlloc
       JLE AllocError
       mov [VMem],eax
       add eax,RAM
       
                           ; eax = endereço de memmoria do buffer
       pop ecx             ; tamanho
       pop ebx             ; handle do arquivo
       
       ;; certifica-se que o último byte será inválido
       ;; forçando o emulador a terminar
       push eax
       add eax,ecx
       mov BYTE PTR [eax],07h
       pop eax

       push ecx
       push eax
       push ebx
       call _lread


; ----------------------------------------
; Allocate a console to output information
; ----------------------------------------
         call AllocConsole        
         push STD_OUTPUT_HANDLE
         call GetStdHandle
         mov DWORD PTR vm.stateOut, eax
         push offset MSG_STATE
         call SetConsoleTitle
         mov eax,fmtstrsz
         mov [szwrite],eax

; ----------------------------------------
;  Allocate Memory for the VM Structure
; ----------------------------------------
;         push 0ffffh                  ; 65535 bytes
;         push GPTR
;         call GlobalAlloc
;         JLE AllocError
;         mov [VMem],eax

; ----------------------------------------
;     Loads the 6502 code to VM's memory
; ----------------------------------------
;         mov ecx, code2execlen
;         lea esi,code2exec
;         mov edi,dword ptr [VMem]     ; contents of VMem to edi
;         add edi,RAM
;         cld
;         rep movsb
; ----------------------------------------
;         Fills the VM structure
; ----------------------------------------
; Sets the original VM Stack pointer
         mov BYTE ptr vm.reg_SP,0FFh
; Sets the entrypoint PCounter
         mov WORD ptr vm.PCount,RAM
; Give the code to the VM
        mov ebx,[VMem]
        mov DWORD ptr vm.code_buffer,ebx

; TEMPORARY--------------------------------------
         mov BYTE PTR vm.reg_Y,05h
         mov BYTE PTR vm.reg_A,50h
; Sets 'X' to 01h -> just for testing !
         mov BYTE PTR vm.reg_X,00h
         mov eax,[VMem]                           ; not nescessary, coz eax still holds vm address
         mov byte ptr [eax+1],0FFh                 ; ZP[01] = 0FFh
;         mov byte ptr vm.reg_Flag,021h
; TEMPORARY--------------------------------------

; ----------------------------------------
;        Call The virtual machine
; ----------------------------------------
         push offset vm
         call Emu6502
; ----------------------------------------
;   It`s my code, n I do what I wnat to!
; ----------------------------------------
         push 20002h
         push NULL
         push offset wavesound
         call PlaySound

         push 0
         push offset MSG_SUCCESS
         push offset MSG_SUCCESS
         push 0
         call MessageBox
         jmp Loader_exit

AllocError:
         push 0
         push offset MSG_TITLE
         push offset E_ALLOC_MSG
         push 0
         call MessageBox
; ----------------------------------------
;Move your butt from this desk... get a life!
; ----------------------------------------
Loader_exit:
         push 0
         call ExitProcess
         include src\vm6502.asm

END loader
code ends
