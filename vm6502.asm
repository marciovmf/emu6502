; **************************************
; *      6502 µEMULATION ENGINE        *
; * copyright - (c) nEuRoMaNcEr 2001   *
; *     marciomanbr@yahoo.com.br       *
; **************************************
; * module: vm6502.asm                 *
; **************************************

;-------------------------------------------
;  SOME DEFINITIONS AND RELATIVE DISTANCES
;-------------------------------------------
        %OUT ********************************
        VM_PARAM           = ((8*4)+4)              ; where into the stack is our params
        VM_TABLE_SIZE      = ((0FFh + 1) * 4)       ; size of opcode table
        CPU6502_STACK_SIZE = 4096                   ; should be enough

        ZERO_PAGE          = 0                      ;; 0000-00FF - Zero-Page
        STACK_             = 255                    ;; 0100-01FF - Stack
        RAM                = 511                    ;; RAM memory
        NMIB_ADDR          = 65530                  ;; NMIB routine address
        RESET_ADDR         = 65532                  ;; RESET routine
        IRQ_ADDR           = 65534                  ;; IRQ routine



        .386p
        locals @@
        public Emu6502

Emu6502:
        pusha                                      ; esp + 32 + ret_addr( = 4O)
;-------------------------------------------
;              GET DELTA OFFSET
;-------------------------------------------
        call @EMU_DELTA

@EMU_DELTA:
        pop edi
        PUSH offset @EMU_DELTA
        pop eax
        sub edi,eax                                ; EDI holds DELTA offset


;-------------------------------------------
;       GETS THE STRUCTURE FROM STACK
;-------------------------------------------
;        pusha                                     ; esp + 32 + ret_addr( = 4O)
        mov ebp,[esp].VM_PARAM                     ; EBP holds the structure address
        mov al,[ebp].reg_Flag
        or al,20h
        mov byte ptr [ebp].reg_Flag,al             ; Flag register`s bit 5 always set

        sub esp,CPU6502_STACK_SIZE                 ; Sets up a stack frame for the VM
;-------------------------------------------
;            the opcode table
;-------------------------------------------
        %out ################################
        LEA edx,  @@@@x86_FE +edi                    ; FF    Future Expansion
        push edx
        LEA edx,  @@@@x86_INC+edi                    ; FE    ABSOLUTE,X
        push edx
        LEA edx,  @@@@x86_SBC+edi                    ; FD    ABSOLUTE,X
        push edx
        LEA edx,  @@@@x86_FE +edi                    ; FC    Future Expansion
        push edx
        LEA edx,  @@@@x86_FE +edi                    ; FB    Future Expansion
        push edx
        LEA edx,  @@@@x86_FE +edi                    ; FA    Future Expansion
        push edx
        LEA edx,  @@@@x86_SBC+edi                    ; F9    ABSOLUTE,Y
        push edx
        LEA edx,  @@@@x86_SED+edi                    ; F8    IMPLIED
        push edx
        LEA edx,  @@@@x86_FE +edi                    ; F7    Future Expansion
        push edx
        LEA edx,  @@@@x86_INC+edi                    ; F6    ZERO PAGE ,X
        push edx
        LEA edx,  @@@@x86_SBC+edi                    ; F5    ZERO PAGE ,X
        push edx
        LEA edx,  @@@@x86_FE +edi                    ; F4    Future Expansion
        push edx
        LEA edx,  @@@@x86_FE +edi                    ; F3    Future Expansion
        push edx
        LEA edx,  @@@@x86_FE +edi                    ; F2    Future Expansion
        push edx
        LEA edx,  @@@@x86_SBC+edi                    ; F1    INDIRECT,X
        push edx
        LEA edx,  @@@@x86_BEQ+edi                    ; F0    RELATIVE
        push edx
        LEA edx,  @@@@x86_FE +edi                    ; EF    Future Expansion
        push edx
        LEA edx,  @@@@x86_INC+edi                    ; EE    ABSOLUTE
        push edx
        LEA edx,  @@@@x86_SBC+edi                    ; ED    ABSOLUTE
        push edx
        LEA edx,  @@@@x86_CPX+edi                    ; EC    ABSOLUTE
        push edx
        LEA edx,  @@@@x86_FE +edi                    ; EB    Future Expansion
        push edx
        LEA edx,  @@@@x86_NOP+edi                    ; EA    IMPLIED
        push edx
        LEA edx,  @@@@x86_SBC+edi                    ; E9    IMMEDIATE
        push edx
        LEA edx,  @@@@x86_INX+edi                    ; E8    IMPLIED
        push edx
        LEA edx,  @@@@x86_FE +edi                    ; E7    Future Expansion
        push edx
        LEA edx,  @@@@x86_INC+edx                    ; E6    ZERO PAGE
        push edx
        LEA edx,  @@@@x86_SBC+edi                    ; E5    ZERO PAGE
        push edx
        LEA edx,  @@@@x86_CPX+edi                    ; E4    ZERO PAGE
        push edx
        LEA edx,  @@@@x86_FE +edi                    ; E3    Future Expansion
        push edx
        LEA edx,  @@@@x86_FE +edi                    ; E2    Future Expansion
        push edx
        LEA edx,  @@@@x86_SBC+edi                    ; E1    (IND,X)
        push edx
        LEA edx,  @@@@x86_CPX+edi                    ; E0    IMMEDIATE
        push edx
        LEA edx,  @@@@x86_FE +edi                    ; DF    Future Expansion
        push edx
        LEA edx,  @@@@x86_DEC+edi                    ; DE    ABSOLUTE,X
        push edx
        LEA edx,  @@@@x86_CMP+edi                    ; DD    ABSOLUTE,X
        push edx
        LEA edx,  @@@@x86_FE +edi                    ; DC    Future Expansion
        push edx
        LEA edx,  @@@@x86_FE +edi                    ; DB    Future Expansion
        push edx
        LEA edx,  @@@@x86_FE +edi                    ; DA    Future Expansion
        push edx
        LEA edx,  @@@@x86_CMP+edi                    ; D9    ABSOLUTE,Y
        push edx
        LEA edx,  @@@@x86_CLD+edi                    ; D8    IMPLIED
        push edx
        LEA edx,  @@@@x86_FE +edi                    ; D7    Future Expansion
        push edx
        LEA edx,  @@@@x86_DEC+edi                    ; D6    ZERO PAGE,X
        push edx
        LEA edx,  @@@@x86_CMP+edi                    ; D5    ZERO PAGE,X
        push edx
        LEA edx,  @@@@x86_FE +edi                    ; D4    Future Expansion
        push edx
        LEA edx,  @@@@x86_FE +edi                    ; D3    Future Expansion
        push edx
        LEA edx,  @@@@x86_FE +edi                    ; D2    Future Expansion
        push edx
        LEA edx,  @@@@x86_CPY+edi                    ; D1    (IND),Y
        push edx
        LEA edx,  @@@@x86_BNE+edi                    ; D0    RELATIVE
        push edx
        LEA edx,  @@@@x86_FE +edi                    ; CF    Future Expansion
        push edx
        LEA edx,  @@@@x86_DEC+edi                    ; CE    ABSOLUTE
        push edx
        LEA edx,  @@@@x86_CMP+edi                    ; CD    ABSOLUTE
        push edx
        LEA edx,  @@@@x86_CPY+edi                    ; CC    ABSOLUTE
        push edx
        LEA edx,  @@@@x86_FE +edi                    ; CB    Future Expansion
        push edx
        LEA edx,  @@@@x86_DEX+edi                    ; CA    IMPLIED
        push edx
        LEA edx,  @@@@x86_CMP+edi                    ; C9    IMMEDIATE
        push edx
        LEA edx,  @@@@x86_INY+edi                    ; C8    IMPLIED
        push edx
        LEA edx,  @@@@x86_FE +edi                    ; C7    Future Expansion
        push edx
        LEA edx,  @@@@x86_DEC+edi                    ; C6    ZERO PAGE
        push edx
        LEA edx,  @@@@x86_CMP+edi                    ; C5    ZERO PAGE
        push edx
        LEA edx,  @@@@x86_CPY+edi                    ; C4    ZERO PAGE
        push edx
        LEA edx,  @@@@x86_FE +edi                    ; C3    Future Expansion
        push edx
        LEA edx,  @@@@x86_FE +edi                    ; C2    Future Expansion
        push edx
        LEA edx,  @@@@x86_CMP+edi                    ; C1    INDIRECT,X
        push edx
        LEA edx,  @@@@x86_CPY+edi                    ; C0    IMMEDIATE
        push edx
        LEA edx,  @@@@x86_FE +edi                    ; BF    Future Expansion
        push edx
        LEA edx,  @@@@x86_LDX+edi                    ; BE    ABSOLUTE,Y
        push edx
        LEA edx,  @@@@x86_LDA+edi                    ; BD    ABSOLUTE,X
        push edx
        LEA edx,  @@@@x86_LDY+edi                    ; BC    ABSOLUTE,X
        push edx
        LEA edx,  @@@@x86_FE +edi                    ; BB    Future Expansion
        push edx
        LEA edx,  @@@@x86_TSX+edi                    ; BA    IMPLIED
        push edx
        LEA edx,  @@@@x86_LDA+edi                    ; B9    ABSOLUTE,Y
        push edx
        LEA edx,  @@@@x86_CLV+edi                    ; B8    IMPLIED
        push edx
        LEA edx,  @@@@x86_FE +edi                    ; B7    Future Expansion
        push edx                 
        LEA edx,  @@@@x86_LDX+edi                    ; B6    ABSOLUTE
        push edx
        LEA edx,  @@@@x86_LDA+edi                    ; B5    ABSOLUTE
        push edx                 
        LEA edx,  @@@@x86_LDY+edi                    ; B4    ABSOLUTE
        push edx                 
        LEA edx,  @@@@x86_FE +edi                    ; B3    Future Expansion
        push edx                 
        LEA edx,  @@@@x86_FE +edi                    ; B2    Future Expansion
        push edx                 
        LEA edx,  @@@@x86_LDA+edi                    ; B1    (IND),Y
        push edx
        LEA edx,  @@@@x86_BCC+edi                    ; B0    RELATIVE
        push edx
        LEA edx,  @@@@x86_FE +edi                    ; AF    Future Expansion
        push edx                 
        LEA edx,  @@@@x86_LDX+edi                    ; AE    ABSOLUTE
        push edx                 
        LEA edx,  @@@@x86_LDA+edi                    ; AD    ABSOLUTE
        push edx                 
        LEA edx,  @@@@x86_LDY+edi                    ; AC    ABSOLUTE
        push edx
        LEA edx,  @@@@x86_FE +edi                    ; AB    Future Expansion
        push edx                 
        LEA edx,  @@@@x86_TAX+edi                    ; AA    IMPLIED
        push edx
        LEA edx,  @@@@x86_LDA+edi                    ; A9    Immediate
        push edx
        LEA edx,  @@@@x86_TAY+edi                    ; A8    IMPLIED
        push edx
        LEA edx,  @@@@x86_FE +edi                    ; A7    Future Expansion
        push edx
        LEA edx,  @@@@x86_LDX+edi                    ; A6    ZERO PAGE
        push edx                 
        LEA edx,  @@@@x86_LDA+edi                    ; A5    ZERO PAGE
        push edx                 
        LEA edx,  @@@@x86_LDY+edi                    ; A4    ZERO PAGE
        push edx
        LEA edx,  @@@@x86_FE +edi                    ; A3    Future Expansion
        push edx                 
        LEA edx,  @@@@x86_LDX+edi                    ; A2    Immediate
        push edx                 
        LEA edx,  @@@@x86_LDA+edi                    ; A1    Indirect,X
        push edx                 
        LEA edx,  @@@@x86_LDY+edi                    ; A0    Immediate
        push edx                 
        LEA edx,  @@@@x86_FE +edi                    ; 9F    Future Expansion
        push edx
        LEA edx,  @@@@x86_FE +edi                    ; 9E    Future Expansion
        push edx                 
        LEA edx,  @@@@x86_STA+edi                    ; 9D    ABSOLUTE,X
        push edx                 
        LEA edx,  @@@@x86_FE +edi                    ; 9C    Future Expansion
        push edx                 
        LEA edx,  @@@@x86_FE +edi                    ; 9B    Future Expansion
        push edx
        LEA edx,  @@@@x86_TXS+edi                    ; 9A    IMPLIED
        push edx
        LEA edx,  @@@@x86_STA+edi                    ; 99    ABSOLUTE,Y
        push edx
        LEA edx,  @@@@x86_FE +edi                    ; 98    Future Expansion
        push edx                 
        LEA edx,  @@@@x86_FE +edi                    ; 97    Future Expansion
        push edx
        LEA edx,  @@@@x86_STX+edi                    ; 96    ZERO PAGE,Y
        push edx
        LEA edx,  @@@@x86_STA+edi                    ; 95    ZERO PAGE,X
        push edx
        LEA edx,  @@@@x86_STY+edi                    ; 94    ZERO PAGE,X
        push edx                 
        LEA edx,  @@@@x86_FE +edi                    ; 93    Future Expansion
        push edx                 
        LEA edx,  @@@@x86_FE +edi                    ; 92    Future Expansion
        push edx                 
        LEA edx,  @@@@x86_STA+edi                    ; 91    (IND),Y
        push edx                 
        LEA edx,  @@@@x86_BCC+edi                    ; 90    RELATIVE
        push edx
        LEA edx,  @@@@x86_FE +edi                    ; 8B    Future Expansion
        push edx                 
        LEA edx,  @@@@x86_STX+edi                    ; 8E    ABSOLUTE
        push edx
        LEA edx,  @@@@x86_STA+edi                    ; 8D    ABSOLUTE
        push edx                 
        LEA edx,  @@@@x86_STY+edi                    ; 8C    ABSOLUTE
        push edx                 
        LEA edx,  @@@@x86_FE +edi                    ; 8B    Future Expansion
        push edx
        LEA edx,  @@@@x86_TXA+edi                    ; 8A    IMPLIED
        push edx
        LEA edx,  @@@@x86_FE +edi                    ; 89    Future Expansion
        push edx                 
        LEA edx,  @@@@x86_DEY+edi                    ; 88    IMPLIED
        push edx
        LEA edx,  @@@@x86_FE +edi                    ; 87    Future Expansion
        push edx                 
        LEA edx,  @@@@x86_STX+edi                    ; 86    ZERO PAGE
        push edx
        LEA edx,  @@@@x86_STA+edi                    ; 85    ZERO PAGE
        push edx
        LEA edx,  @@@@x86_STY+edi                    ; 84    ZERO PAGE
        push edx                 
        LEA edx,  @@@@x86_FE +edi                    ; 83    Future Expansion
        push edx                 
        LEA edx,  @@@@x86_FE +edi                    ; 82    Future Expansion
        push edx                 
        LEA edx,  @@@@x86_STA+edi                    ; 81    (IND,X)
        push edx
        LEA edx,  @@@@x86_FE +edi                    ; 80    Future Expansion
        push edx                 
        LEA edx,  @@@@x86_FE +edi                    ; 7F    Future Expansion
        push edx                 
        LEA edx,  @@@@x86_ROR+edi                    ; 7E    ABSOLUTE,X
        push edx                 
        LEA edx,  @@@@x86_ADC+edi                    ; 7D    ABSOLUTE,X
        push edx
        LEA edx,  @@@@x86_FE +edi                    ; 7C    Future Expansion
        push edx
        LEA edx,  @@@@x86_FE +edi                    ; 7B    Future Expansion
        push edx                 
        LEA edx,  @@@@x86_FE +edi                    ; 7A    Future Expansion
        push edx                 
        LEA edx,  @@@@x86_ADC+edi                    ; 79    ABSOLUTE,Y
        push edx
        LEA edx,  @@@@x86_SEI+edi                    ; 78    IMPLIED
        push edx                 
        LEA edx,  @@@@x86_FE +edi                    ; 77    Future Expansion
        push edx
        LEA edx,  @@@@x86_ROR+edi                    ; 76    ZERO PAGE,X
        push edx                 
        LEA edx,  @@@@x86_ADC+edi                    ; 75    ZERO PAGE,X
        push edx                 
        LEA edx,  @@@@x86_FE +edi                    ; 74    Future Expansion
        push edx
        LEA edx,  @@@@x86_FE +edi                    ; 73    Future Expansion
        push edx                 
        LEA edx,  @@@@x86_FE +edi                    ; 72    Future Expansion
        push edx
        LEA edx,  @@@@x86_ADC+edi                    ; 71    (IND,X)
        push edx                 
        LEA edx,  @@@@x86_BVS+edi                    ; 70    Future Expansion
        push edx                 
        LEA edx,  @@@@x86_FE +edi                    ; 6F    Future Expansion
        push edx                 
        LEA edx,  @@@@x86_ROR+edi                    ; 6E    ABSOLUTE
        push edx                 
        LEA edx,  @@@@x86_ADC+edi                    ; 6D    ABSOLUTE
        push edx
        LEA edx,  @@@@x86_JMP+edi                    ; 6C    INDIRECT
        push edx
        LEA edx,  @@@@x86_FE +edi                    ; 6B    Future Expansion
        push edx                 
        LEA edx,  @@@@x86_ROR+edi                    ; 6A    Accumulator
        push edx                 
        LEA edx,  @@@@x86_ADC+edi                    ; 69    Immediate
        push edx                 
        LEA edx,  @@@@x86_PLA+edi                    ; 68    IMPLIED
        push edx
        LEA edx,  @@@@x86_FE +edi                    ; 67    Future Expansion
        push edx                 
        LEA edx,  @@@@x86_ADC+edi                    ; 66    ZERO PAGE
        push edx
        LEA edx,  @@@@x86_ADC+edi                    ; 65    ZERO PAGE
        push edx                 
        LEA edx,  @@@@x86_FE +edi                    ; 64    Future Expansion
        push edx
        LEA edx,  @@@@x86_FE +edi                    ; 63    Future Expansion
        push edx
        LEA edx,  @@@@x86_FE +edi                    ; 62    Future Expansion
        push edx                 
        LEA edx,  @@@@x86_ADC+edi                    ; 61    Indirect,X
        push edx                 
        LEA edx,  @@@@x86_RTS+edi                    ; 60    IMPLIED
        push edx                 
        LEA edx,  @@@@x86_FE +edi                    ; 5F    Future Expansion
        push edx                 
        LEA edx,  @@@@x86_LSR+edi                    ; 5E    ABSOLUTE,X
        push edx
        LEA edx,  @@@@x86_EOR+edi                    ; 5D    ABSOLUTE,X
        push edx                 
        LEA edx,  @@@@x86_FE +edi                    ; 5C    Future Expansion
        push edx                 
        LEA edx,  @@@@x86_FE +edi                    ; 5B    Future Expansion
        push edx
        LEA edx,  @@@@x86_FE +edi                    ; 5A    Future Expansion
        push edx                 
        LEA edx,  @@@@x86_EOR+edi                    ; 59    ABSOLUTE,Y
        push edx
        LEA edx,  @@@@x86_CLI+edi                    ; 58    IMPLIED
        push edx                 
        LEA edx,  @@@@x86_FE +edi                    ; 57    Future Expansion
        push edx
        LEA edx,  @@@@x86_LSR+edi                    ; 56    ZEROPAGE,X
        push edx                 
        LEA edx,  @@@@x86_EOR+edi                    ; 55    ZEROPAGE,X
        push edx
        LEA edx,  @@@@x86_FE +edi                    ; 54    Future Expansion
        push edx
        LEA edx,  @@@@x86_FE +edi                    ; 53    Future Expansion
        push edx                 
        LEA edx,  @@@@x86_FE +edi                    ; 52    Future Expansion
        push edx
        LEA edx,  @@@@x86_EOR+edi                    ; 51    (IND),Y
        push edx                 
        LEA edx,  @@@@x86_BVC+edi                    ; 50    RELATIVE
        push edx                 
        LEA edx,  @@@@x86_FE +edi                    ; 4F    Future Expansion
        push edx
        LEA edx,  @@@@x86_LSR+edi                    ; 4E    Accumulator
        push edx                 
        LEA edx,  @@@@x86_EOR+edi                    ; 4D    ABSOLUTE
        push edx                 
        LEA edx,  @@@@x86_JMP+edi                    ; 4C    ABSOLUTE
        push edx                 
        LEA edx,  @@@@x86_FE +edi                    ; 4B    Future Expansion
        push edx                 
        LEA edx,  @@@@x86_LSR+edi                    ; 4A    Accumulator
        push edx
        LEA edx,  @@@@x86_EOR+edi                    ; 49    Immediate
        push edx                 
        LEA edx,  @@@@x86_PHA+edi                    ; 48    IMPLIED
        push edx                 
        LEA edx,  @@@@x86_FE +edi                    ; 47    Future Expansion
        push edx                 
        LEA edx,  @@@@x86_LSR+edi                    ; 46    ZEROPAGE
        push edx
        LEA edx,  @@@@x86_EOR+edi                    ; 45    ZEROPAGE
        push edx
        LEA edx,  @@@@x86_FE +edi                    ; 44    Future Expansion
        push edx
        LEA edx,  @@@@x86_FE +edi                    ; 43    Future Expansion
        push edx                 
        LEA edx,  @@@@x86_FE +edi                    ; 42    Future Expansion
        push edx                 
        LEA edx,  @@@@x86_EOR+edi                    ; 41    (IND,X)
        push edx
        LEA edx,  @@@@x86_RTI+edi                    ; 40    IMPLIED
        push edx
        LEA edx,  @@@@x86_FE +edi                    ; 3F    Future Expansion
        push edx                 
        LEA edx,  @@@@x86_ROL+edi                    ; 3E    ABSOLUTE,X
        push edx                 
        LEA edx,  @@@@x86_AND+edi                    ; 3D    ABSOLUTE,X
        push edx                 
        LEA edx,  @@@@x86_FE +edi                    ; 3C    Future Expansion
        push edx                 
        LEA edx,  @@@@x86_FE +edi                    ; 3B    Future Expansion
        push edx
        LEA edx,  @@@@x86_FE +edi                    ; 3A    Future Expansion
        push edx                 
        LEA edx,  @@@@x86_AND+edi                    ; 39    ABSOLUTE,Y
        push edx
        LEA edx,  @@@@x86_SEC+edi                    ; 38    IMPLIED
        push edx                 
        LEA edx,  @@@@x86_FE +edi                    ; 37    Future Expansion
        push edx                 
        LEA edx,  @@@@x86_ROL+edi                    ; 36    ZEROPAGE,X
        push edx
        LEA edx,  @@@@x86_AND+edi                    ; 35    ZEROPAGE,X
        push edx
        LEA edx,  @@@@x86_FE +edi                    ; 34    Future Expansion
        push edx                 
        LEA edx,  @@@@x86_FE +edi                    ; 33    Future Expansion
        push edx
        LEA edx,  @@@@x86_FE +edi                    ; 32    Future Expansion
        push edx                 
        LEA edx,  @@@@x86_AND+edi                    ; 31    (IND,X)
        push edx
        LEA edx,  @@@@x86_BMI+edi                    ; 30    RELATIVE
        push edx
        LEA edx,  @@@@x86_FE +edi                    ; 2F    Future Expansion
        push edx                 
        LEA edx,  @@@@x86_ROL+edi                    ; 2E    ABSOLUTE
        push edx                 
        LEA edx,  @@@@x86_AND+edi                    ; 2D    ABSOLUTE
        push edx                 
        LEA edx,  @@@@x86_BIT+edi                    ; 2C    ABSOLUTE
        push edx
        LEA edx,  @@@@x86_FE +edi                    ; 2B    Future Expansion
        push edx                 
        LEA edx,  @@@@x86_ROL+edi                    ; 2A    Accumulator
        push edx                 
        LEA edx,  @@@@x86_AND+edi                    ; 29    Immediate
        push edx
        LEA edx,  @@@@x86_PLP+edi                    ; 28    IMPLIED
        push edx
        LEA edx,  @@@@x86_FE +edi                    ; 27    Future Expansion
        push edx
        LEA edx,  @@@@x86_ROL+edi                    ; 26    ZEROPAGE
        push edx                 
        LEA edx,  @@@@x86_AND+edi                    ; 25    ZEROPAGE
        push edx                 
        LEA edx,  @@@@x86_BIT+edi                    ; 24    ZEROPAGE
        push edx
        LEA edx,  @@@@x86_FE +edi                    ; 23    Future Expansion
        push edx                 
        LEA edx,  @@@@x86_FE +edi                    ; 22    Future Expansion
        push edx
        LEA edx,  @@@@x86_AND+edi                    ; 21    (indirect,X)
        push edx                 
        LEA edx,  @@@@x86_JSR+edi                    ; 20    ABSOLUTE
        push edx                 
        LEA edx,  @@@@x86_FE +edi                    ; 1F    Future Expansion
        push edx
        LEA edx,  @@@@x86_ASL+edi                    ; 1E    ABSOLUTE,Y
        push edx                 
        LEA edx,  @@@@x86_ORA+edi                    ; 1D    ABSOLUTE,X
        push edx
        LEA edx,  @@@@x86_FE +edi                    ; 1C    Future Expansion
        push edx                 
        LEA edx,  @@@@x86_FE +edi                    ; 1B    Future Expansion
        push edx                 
        LEA edx,  @@@@x86_FE +edi                    ; 1A    Future Expansion
        push edx                 
        LEA edx,  @@@@x86_ORA+edi                    ; 19    absolute,Y
        push edx                 
        LEA edx,  @@@@x86_CLC+edi                    ; 18    CLC
        push edx
        LEA edx,  @@@@x86_FE +edi                    ; 17    Future Expansion
        push edx
        LEA edx,  @@@@x86_ASL+edi                    ; 16    ZEROPAGE,X
        push edx                 
        LEA edx,  @@@@x86_ORA+edi                    ; 15    ZEROPAGE,X
        push edx                 
        LEA edx,  @@@@x86_FE +edi                    ; 14    Future Expansion
        push edx                 
        LEA edx,  @@@@x86_FE +edi                    ; 13    Future Expansion
        push edx
        LEA edx,  @@@@x86_FE +edi                    ; 12    Future Expansion
        push edx                 
        LEA edx,  @@@@x86_ORA+edi                    ; 11    (IND),Y
        push edx
        LEA edx,  @@@@x86_BPL+edi                    ; 10    RELATIVE
        push edx                 
        LEA edx,  @@@@x86_FE +edi                    ; 0F    Future Expansion
        push edx                 
        LEA edx,  @@@@x86_ASL+edi                    ; 0E    Absolute
        push edx
        LEA edx,  @@@@x86_ORA+edi                    ; 0D    absolute
        push edx                 
        LEA edx,  @@@@x86_FE +edi                    ; 0C    Future Expansion
        push edx
        LEA edx,  @@@@x86_FE +edi                    ; 0B    Future Expansion
        push edx                 
        LEA edx,  @@@@x86_ASL+edi                    ; 0A    Accumulator
        push edx                 
        LEA edx,  @@@@x86_ORA+edi                    ; 09    Immediate
        push edx
        LEA edx,  @@@@x86_PHP+edi                    ; 08    IMPLIED
        push edx                 
        LEA edx,  @@@@x86_FE +edi                    ; 07    Future Expansion
        push edx
        LEA edx,  @@@@x86_ASL+edi                    ; 06    Zero Page
        push edx
        LEA edx,  @@@@x86_ORA+edi                    ; 05    Zero Page
        push edx                 
        LEA edx,  @@@@x86_FE +edi                    ; 04    Future Expansion
        push edx
        LEA edx,  @@@@x86_FE +edi                    ; 03    Future Expansion
        push edx
        LEA edx,  @@@@x86_FE +edi                    ; 02    Future Expansion
        push edx
        LEA edx,  @@@@x86_ORA+edi                    ; 01    (IND,X)
        push edx                 
        LEA edx,  @@@@x86_BRK+edi                    ; 00    implied
        push edx


;-------------------------------------------
;         the addressing modes table
;-------------------------------------------
        %OUT ################################
        LEA edx,  @@@@mode_implied+edi               ; FF Future Expansion
        push edx
        LEA edx,  @@@@mode_absolute_x+edi            ; FE ABSOLUTE,X
        push edx
        LEA edx,  @@@@mode_absolute_x+edi            ; FD ABSOLUTE,X
        push edx
        LEA edx,  @@@@mode_implied+edi               ; FC Future Expansion
        push edx
        LEA edx,  @@@@mode_implied+edi               ; FB Future Expansion
        push edx
        LEA edx,  @@@@mode_implied+edi               ; FA Future Expansion
        push edx
        LEA edx,  @@@@mode_absolute_y+edi            ; F9 ABSOLUTE,Y
        push edx
        LEA edx,  @@@@mode_implied+edi               ; F8 IMPLIED
        push edx
        LEA edx,  @@@@mode_implied+edi               ; F7 Future Expansion
        push edx
        LEA edx,  @@@@mode_zp_x+edi                  ; F6 ZEROPAGE,X
        push edx
        LEA edx,  @@@@mode_zp_x+edi                  ; F5 ZEROPAGE,X
        push edx
        LEA edx,  @@@@mode_implied+edi               ; F4 Future Expansion
        push edx
        LEA edx,  @@@@mode_implied+edi               ; F3 Future Expansion
        push edx
        LEA edx,  @@@@mode_implied+edi               ; F2 Future Expansion
        push edx
        LEA edx,  @@@@mode_ind_x+edi                 ; F1 (INDIRECT, X)
        push edx
        LEA edx,  @@@@mode_relative+edi              ; F0 RELATIVE
        push edx
        LEA edx,  @@@@mode_implied+edi               ; EF Future Expansion
        push edx
        LEA edx,  @@@@mode_absolute+edi              ; EE Absolute
        push edx
        LEA edx,  @@@@mode_absolute+edi              ; ED Absolute
        push edx
        LEA edx,  @@@@mode_absolute+edi              ; EC Absolute
        push edx
        LEA edx,  @@@@mode_implied+edi               ; EB Future Expansion
        push edx
        LEA edx,  @@@@mode_implied+edi               ; EA IMPLIED
        push edx
        LEA edx,  @@@@mode_immediate+edi             ; E9 IMMEDIATE
        push edx
        LEA edx,  @@@@mode_implied+edi               ; E8 IMPLIED
        push edx
        LEA edx,  @@@@mode_implied+edi               ; E7 Future Expansion
        push edx
        LEA edx,  @@@@mode_zp+edi                    ; E6 zero page
        push edx
        LEA edx,  @@@@mode_zp+edi                    ; E5 zero page
        push edx
        LEA edx,  @@@@mode_zp+edi                    ; E4 zero page
        push edx
        LEA edx,  @@@@mode_implied+edi               ; E3 Future Expansion
        push edx
        LEA edx,  @@@@mode_implied+edi               ; E2 Future Expansion
        push edx
        LEA edx,  @@@@mode_ind_x+edi                 ; E1 (INDIRECT, X)
        push edx
        LEA edx,  @@@@mode_immediate+edi             ; D0 IMMEDIATE
        push edx
        LEA edx,  @@@@mode_implied+edi               ; DF Future Expansion
        push edx
        LEA edx,  @@@@mode_absolute_x+edi            ; DE ABSOLUTE,X
        push edx
        LEA edx,  @@@@mode_absolute_x+edi            ; DD ABSOLUTE,X
        push edx
        LEA edx,  @@@@mode_implied+edi               ; DC Future Expansion
        push edx
        LEA edx,  @@@@mode_implied+edi               ; DB Future Expansion
        push edx
        LEA edx,  @@@@mode_implied+edi               ; DA Future Expansion
        push edx
        LEA edx,  @@@@mode_absolute_y+edi            ; D9 ABSOLUTE,Y
        push edx
        LEA edx,  @@@@mode_implied+edi               ; D8 IMPLIED
        push edx
        LEA edx,  @@@@mode_implied+edi               ; D7 Future Expansion
        push edx
        LEA edx,  @@@@mode_zp_x+edi                  ; D6 ZEROPAGE,X
        push edx
        LEA edx,  @@@@mode_zp_x+edi                  ; D5 ZEROPAGE,X
        push edx
        LEA edx,  @@@@mode_implied+edi               ; D4 Future Expansion
        push edx
        LEA edx,  @@@@mode_implied+edi               ; D3 Future Expansion
        push edx
        LEA edx,  @@@@mode_implied+edi               ; D2 Future Expansion
        push edx
        LEA edx,  @@@@mode_ind_y+edi                 ; D1 (IND),Y
        push edx
        LEA edx,  @@@@mode_relative+edi              ; D0 RELATIVE
        push edx
        LEA edx,  @@@@mode_implied+edi               ; CF Future Expansion
        push edx
        LEA edx,  @@@@mode_absolute+edi              ; CE Absolute
        push edx
        LEA edx,  @@@@mode_absolute+edi              ; CD Absolute
        push edx
        LEA edx,  @@@@mode_absolute+edi              ; CC Absolute
        push edx
        LEA edx,  @@@@mode_implied+edi               ; CB Future Expansion
        push edx
        LEA edx,  @@@@mode_implied+edi               ; CA IMPLIED
        push edx
        LEA edx,  @@@@mode_immediate+edi             ; C9 IMMEDIATE
        push edx
        LEA edx,  @@@@mode_implied+edi               ; C8 IMPLIED
        push edx
        LEA edx,  @@@@mode_implied+edi               ; C7 Future Expansion
        push edx
        LEA edx,  @@@@mode_zp+edi                    ; C6 zero page
        push edx
        LEA edx,  @@@@mode_zp+edi                    ; C5 zero page
        push edx
        LEA edx,  @@@@mode_zp+edi                    ; C4 zero page
        push edx
        LEA edx,  @@@@mode_implied+edi               ; C3 Future Expansion
        push edx
        LEA edx,  @@@@mode_implied+edi               ; C2 Future Expansion
        push edx
        LEA edx,  @@@@mode_ind_x+edi                 ; C1 INDIRECT,X
        push edx
        LEA edx,  @@@@mode_immediate+edi             ; C0 IMMEDIATE
        push edx
        LEA edx,  @@@@mode_implied+edi               ; BF Future Expansion
        push edx
        LEA edx,  @@@@mode_absolute_y+edi            ; BE ABSOLUTE,Y
        push edx
        LEA edx,  @@@@mode_absolute_x+edi            ; BD ABSOLUTE,X
        push edx
        LEA edx,  @@@@mode_absolute_x+edi            ; BC ABSOLUTE,X
        push edx
        LEA edx,  @@@@mode_implied+edi               ; BB Future Expansion
        push edx
        LEA edx,  @@@@mode_implied+edi               ; BA IMPLIED
        push edx
        LEA edx,  @@@@mode_absolute_y+edi            ; B9 ABSOLUTE,Y
        push edx
        LEA edx,  @@@@mode_implied+edi               ; B8 IMPLIED
        push edx
        LEA edx,  @@@@mode_implied+edi               ; B7 Future Expansion
        push edx
        LEA edx,  @@@@mode_absolute+edi              ; B6 Absolute
        push edx
        LEA edx,  @@@@mode_absolute+edi              ; B5 Absolute
        push edx
        LEA edx,  @@@@mode_absolute+edi              ; B4 Absolute
        push edx
        LEA edx,  @@@@mode_implied+edi               ; B3 Future Expansion
        push edx
        LEA edx,  @@@@mode_implied+edi               ; B2 Future Expansion
        push edx
        LEA edx,  @@@@mode_ind_y+edi                 ; B1 (IND),Y
        push edx
        LEA edx,  @@@@mode_relative+edi              ; B0 RELATIVE          
        push edx
        LEA edx,  @@@@mode_implied+edi               ; AF Future Expansion  
        push edx
        LEA edx,  @@@@mode_absolute+edi              ; AE Absolute
        push edx
        LEA edx,  @@@@mode_absolute+edi              ; AD Absolute          
        push edx
        LEA edx,  @@@@mode_absolute+edi              ; AC Absolute          
        push edx
        LEA edx,  @@@@mode_implied+edi               ; AB Future Expansion  
        push edx                                                            
        LEA edx,  @@@@mode_implied+edi               ; AA IMPLIED
        push edx                                                            
        LEA edx,  @@@@mode_immediate+edi             ; A9 immediate
        push edx
        LEA edx,  @@@@mode_implied+edi               ; A8 IMPLIED           
        push edx
        LEA edx,  @@@@mode_implied+edi               ; A7 Future Expansion  
        push edx                                                            
        LEA edx,  @@@@mode_zp+edi                    ; A6 zero page         
        push edx
        LEA edx,  @@@@mode_zp+edi                    ; A5 zero page         
        push edx                                                            
        LEA edx,  @@@@mode_zp+edi                    ; A4 zero page         
        push edx                                                            
        LEA edx,  @@@@mode_implied+edi               ; A3 Future Expansion  
        push edx                                                            
        LEA edx,  @@@@mode_immediate+edi             ; A2 immediate         
        push edx
        LEA edx,  @@@@mode_ind_x+edi                 ; A1 (INDIRECT, X)
        push edx
        LEA edx,  @@@@mode_immediate+edi             ; A0 immediate
        push edx
        LEA edx,  @@@@mode_implied+edi               ; 9F Future Expansion
        push edx
        LEA edx,  @@@@mode_implied+edi               ; 9E Future Expansion
        push edx
        LEA edx,  @@@@mode_absolute_x+edi            ; 9D ABSOLUTE,X
        push edx
        LEA edx,  @@@@mode_implied+edi               ; 9C Future Expansion
        push edx
        LEA edx,  @@@@mode_implied+edi               ; 9B Future Expansion  
        push edx
        LEA edx,  @@@@mode_implied+edi               ; 9A IMPLIED           
        push edx                                                            
        LEA edx,  @@@@mode_absolute_y+edi            ; 99 ABSOLUTE,Y
        push edx
        LEA edx,  @@@@mode_implied+edi               ; 98 IMPLIED
        push edx
        LEA edx,  @@@@mode_implied+edi               ; 97 Future Expansion
        push edx
        LEA edx,  @@@@mode_zp_y+edi                  ; 96 ZEROPAGE,Y
        push edx
        LEA edx,  @@@@mode_zp_x+edi                  ; 95 ZEROPAGE,X
        push edx
        LEA edx,  @@@@mode_zp_x+edi                  ; 94 ZEROPAGE,X
        push edx
        LEA edx,  @@@@mode_implied+edi               ; 93 Future Expansion
        push edx
        LEA edx,  @@@@mode_implied+edi               ; 92 Future Expansion
        push edx
        LEA edx,  @@@@mode_ind_y+edi                 ; 91 (IND),Y           
        push edx
        LEA edx,  @@@@mode_relative+edi              ; 90 RELATIVE
        push edx                                                            
        LEA edx,  @@@@mode_implied+edi               ; 8F Future Expansion
        push edx
        LEA edx,  @@@@mode_absolute+edi              ; 8E Absolute          
        push edx
        LEA edx,  @@@@mode_absolute+edi              ; 8D Absolute          
        push edx                                                            
        LEA edx,  @@@@mode_absolute2+edi             ; 8C Absolute
        push edx
        LEA edx,  @@@@mode_implied+edi               ; 8B Future Expansion  
        push edx                                                            
        LEA edx,  @@@@mode_implied+edi               ; 8A IMPLIED           
        push edx
        LEA edx,  @@@@mode_implied+edi               ; 89 Future Expansion  
        push edx                                                            
        LEA edx,  @@@@mode_implied+edi               ; 88 IMPLIED           
        push edx                                                            
        LEA edx,  @@@@mode_implied+edi               ; 87 Future Expansion
        push edx
        LEA edx,  @@@@mode_zp+edi                    ; 86 zero page
        push edx
        LEA edx,  @@@@mode_zp+edi                    ; 85 zero page
        push edx
        LEA edx,  @@@@mode_zp+edi                    ; 84 zero page         
        push edx
        LEA edx,  @@@@mode_implied+edi               ; 83 Future Expansion
        push edx                                                            
        LEA edx,  @@@@mode_implied+edi               ; 82 Future Expansion  
        push edx                                                            
        LEA edx,  @@@@mode_ind_x+edi                 ; 81 (INDIRECT, X)     
        push edx                                                            
        LEA edx,  @@@@mode_implied+edi               ; 80 Future Expansion  
        push edx
        LEA edx,  @@@@mode_implied+edi               ; 7F Future Expansion
        push edx                                                            
        LEA edx,  @@@@mode_absolute_x+edi            ; 7E ABSOLUTE,X
        push edx
        LEA edx,  @@@@mode_absolute_x+edi            ; 7D ABSOLUTE,X        
        push edx
        LEA edx,  @@@@mode_implied+edi               ; 7C Future Expansion  
        push edx                                                            
        LEA edx,  @@@@mode_implied+edi               ; 7B Future Expansion
        push edx
        LEA edx,  @@@@mode_implied+edi               ; 7A Future Expansion  
        push edx                                                            
        LEA edx,  @@@@mode_absolute_y+edi            ; 79 ABSOLUTE,Y        
        push edx
        LEA edx,  @@@@mode_implied+edi               ; 78 IMPLIED           
        push edx                                                            
        LEA edx,  @@@@mode_implied+edi               ; 77 IMPLIED           
        push edx                                                            
        LEA edx,  @@@@mode_zp_x+edi                  ; 76 ZEROPAGE,X
        push edx
        LEA edx,  @@@@mode_zp_x+edi                  ; 75 ZEROPAGE,X
        push edx
        LEA edx,  @@@@mode_implied+edi               ; 74 Future Expansion
        push edx                                                            
        LEA edx,  @@@@mode_implied+edi               ; 73 Future Expansion  
        push edx
        LEA edx,  @@@@mode_implied+edi               ; 72 Future Expansion  
        push edx                                                            
        LEA edx,  @@@@mode_ind_y+edi                 ; 71 (IND),Y
        push edx                                                            
        LEA edx,  @@@@mode_relative+edi              ; 70 RELATIVE          
        push edx
        LEA edx,  @@@@mode_implied+edi               ; 6F Future Expansion
        push edx
        LEA edx,  @@@@mode_absolute+edi              ; 6E Absolute
        push edx
        LEA edx,  @@@@mode_absolute+edi              ; 6D Absolute
        push edx
        LEA edx,  @@@@mode_indirect+edi              ; 6C INDIRECT
        push edx
        LEA edx,  @@@@mode_implied+edi               ; 6B Future Expansion
        push edx
        LEA edx,  @@@@mode_accumulator+edi           ; 4A ACCUMULATOR
        push edx
        LEA edx,  @@@@mode_immediate+edi             ; 69 immediate
        push edx
        LEA edx,  @@@@mode_implied+edi               ; 68 IMPLIED
        push edx
        LEA edx,  @@@@mode_implied+edi               ; 67 Future Expansion  
        push edx                                                            
        LEA edx,  @@@@mode_zp+edi                    ; 66 ZEROPAGE          
        push edx                                                            
        LEA edx,  @@@@mode_zp+edi                    ; 65 ZEROPAGE
        push edx
        LEA edx,  @@@@mode_implied+edi               ; 64 Future Expansion  
        push edx
        LEA edx,  @@@@mode_implied+edi               ; 63 Future Expansion  
        push edx                                                            
        LEA edx,  @@@@mode_implied+edi               ; 62 Future Expansion  
        push edx
        LEA edx,  @@@@mode_ind_x+edi                 ; 61 (INDIRECT, X)     
        push edx                                                            
        LEA edx,  @@@@mode_ind_x+edi                 ; 60 IMPLIED           
        push edx                                                            
        LEA edx,  @@@@mode_implied+edi               ; 5F Future Expansion  
        push edx                                                            
        LEA edx,  @@@@mode_absolute_x+edi            ; 5E ABSOLUTE,X
        push edx
        LEA edx,  @@@@mode_absolute_x+edi            ; 5D ABSOLUTE,X
        push edx                                                            
        LEA edx,  @@@@mode_implied+edi               ; 5C Future Expansion
        push edx
        LEA edx,  @@@@mode_implied+edi               ; 5B Future Expansion  
        push edx
        LEA edx,  @@@@mode_implied+edi               ; 5A Future Expansion  
        push edx                                                            
        LEA edx,  @@@@mode_absolute_y+edi            ; 59 ABSOLUTE,Y
        push edx
        LEA edx,  @@@@mode_implied+edi               ; 58 IMPLIED           
        push edx                                                            
        LEA edx,  @@@@mode_implied+edi               ; 57 Future Expansion  
        push edx
        LEA edx,  @@@@mode_zp_x+edi                  ; 56 ZEROPAGE,X        
        push edx                                                            
        LEA edx,  @@@@mode_zp_x+edi                  ; 55 ZEROPAGE,X        
        push edx                                                            
        LEA edx,  @@@@mode_implied+edi               ; 54 Future Expansion
        push edx
        LEA edx,  @@@@mode_implied+edi               ; 53 Future Expansion  
        push edx                                                            
        LEA edx,  @@@@mode_implied+edi               ; 52 Future Expansion  
        push edx                                                            
        LEA edx,  @@@@mode_ind_y+edi                 ; 51 (IND),Y           
        push edx
        LEA edx,  @@@@mode_relative+edi              ; 50 RELATIVE          
        push edx                                                            
        LEA edx,  @@@@mode_implied+edi               ; 4F Future Expansion  
        push edx                                                            
        LEA edx,  @@@@mode_absolute+edi              ; 4E Absolute          
        push edx                                                            
        LEA edx,  @@@@mode_absolute+edi              ; 4D Absolute          
        push edx
        LEA edx,  @@@@mode_absolute2+edi             ; 4C Absolute
        push edx                                                            
        LEA edx,  @@@@mode_implied+edi               ; 4B Future Expansion
        push edx
        LEA edx,  @@@@mode_accumulator+edi           ; 4A ACCUMULATOR       
        push edx
        LEA edx,  @@@@mode_immediate+edi             ; 49 immediate         
        push edx                                                            
        LEA edx,  @@@@mode_implied+edi               ; 48 IMPLIED
        push edx
        LEA edx,  @@@@mode_implied+edi               ; 47 Future Expansion  
        push edx                                                            
        LEA edx,  @@@@mode_zp+edi                    ; 46 zero page         
        push edx                                                            
        LEA edx,  @@@@mode_zp+edi                    ; 45 zero page         
        push edx                                                            
        LEA edx,  @@@@mode_implied+edi               ; 44 Future Expansion  
        push edx                                                            
        LEA edx,  @@@@mode_implied+edi               ; 43 Future Expansion
        push edx
        LEA edx,  @@@@mode_implied+edi               ; 42 Future Expansion  
        push edx                                                            
        LEA edx,  @@@@mode_ind_x+edi                 ; 41 (INDIRECT, X)     
        push edx                                                            
        LEA edx,  @@@@mode_implied+edi               ; 40 IMPLIED           
        push edx
        LEA edx,  @@@@mode_implied+edi               ; 3F Future Expansion  
        push edx                                                            
        LEA edx,  @@@@mode_absolute_x+edi            ; 3E ABSOLUTE,X        
        push edx                                                            
        LEA edx,  @@@@mode_absolute_x+edi            ; 3D ABSOLUTE,X        
        push edx                                                            
        LEA edx,  @@@@mode_implied+edi               ; 3C Future Expansion  
        push edx
        LEA edx,  @@@@mode_implied+edi               ; 3B Future Expansion
        push edx                                                            
        LEA edx,  @@@@mode_implied+edi               ; 3A Future Expansion
        push edx
        LEA edx,  @@@@mode_absolute_y+edi            ; 39 ABSOLUTE,Y
        push edx
        LEA edx,  @@@@mode_implied+edi               ; 38 IMPLIED
        push edx                                                            
        LEA edx,  @@@@mode_implied+edi               ; 37 Future Expansion
        push edx
        LEA edx,  @@@@mode_zp_x+edi                  ; 36 ZEROPAGE,X        
        push edx                                                            
        LEA edx,  @@@@mode_zp_x+edi                  ; 35 ZEROPAGE,X        
        push edx                                                            
        LEA edx,  @@@@mode_implied+edi               ; 34 Future Expansion  
        push edx                                                            
        LEA edx,  @@@@mode_implied+edi               ; 33 Future Expansion  
        push edx                                                            
        LEA edx,  @@@@mode_implied+edi               ; 32 Future Expansion
        push edx
        LEA edx,  @@@@mode_ind_x+edi                 ; 31 (INDIRECT, X)     
        push edx                                                            
        LEA edx,  @@@@mode_relative+edi              ; 30 RELATIVE          
        push edx                                                            
        LEA edx,  @@@@mode_implied+edi               ; 2F Future Expansion  
        push edx
        LEA edx,  @@@@mode_absolute+edi              ; 2E ABSOLUTE          
        push edx                                                            
        LEA edx,  @@@@mode_absolute+edi              ; 2D ABSOLUTE          
        push edx                                                            
        LEA edx,  @@@@mode_absolute+edi              ; 2C ABSOLUTE          
        push edx                                                            
        LEA edx,  @@@@mode_implied+edi               ; 2B Future Expansion  
        push edx
        LEA edx,  @@@@mode_accumulator+edi           ; 0A ACCUMULATOR
        push edx                                                            
        LEA edx,  @@@@mode_immediate+edi             ; 29 immediate
        push edx
        LEA edx,  @@@@mode_implied+edi               ; 28 IMPLIED           
        push edx
        LEA edx,  @@@@mode_implied+edi               ; 27 Future Expansion  
        push edx                                                            
        LEA edx,  @@@@mode_zp+edi                    ; 26 zero page
        push edx
        LEA edx,  @@@@mode_zp+edi                    ; 25 zero page         
        push edx                                                            
        LEA edx,  @@@@mode_zp+edi                    ; 24 zero page         
        push edx                                                            
        LEA edx,  @@@@mode_implied+edi               ; 23 Future Expansion  
        push edx                                                            
        LEA edx,  @@@@mode_implied+edi               ; 22 Future Expansion  
        push edx                                                            
        LEA edx,  @@@@mode_ind_x+edi                 ; 21 (INDIRECT, X)
        push edx
        LEA edx,  @@@@mode_absolute+edi              ; 20 Future Expansion  
        push edx                                                            
        LEA edx,  @@@@mode_implied+edi               ; 1F Future Expansion  
        push edx                                                            
        LEA edx,  @@@@mode_absolute_y+edi            ; 1E ABSOLUTE,Y        
        push edx
        LEA edx,  @@@@mode_absolute_x+edi            ; 1D ABSOLUTE,X        
        push edx                                                            
        LEA edx,  @@@@mode_implied+edi               ; 1C Future Expansion  
        push edx                                                            
        LEA edx,  @@@@mode_implied+edi               ; 1B Future Expansion  
        push edx                                                            
        LEA edx,  @@@@mode_implied+edi               ; 1A Future Expansion  
        push edx
        LEA edx,  @@@@mode_absolute_y+edi            ; 19 ABSOLUTE,Y
        push edx                                                            
        LEA edx,  @@@@mode_implied+edi               ; 18 CLC
        push edx
        LEA edx,  @@@@mode_implied+edi               ; 17 Future Expansion  
        push edx
        LEA edx,  @@@@mode_zp_x+edi                  ; 16 ZEROPAGE,X        
        push edx                                                            
        LEA edx,  @@@@mode_zp_x+edi                  ; 15 ZEROPAGE,X
        push edx
        LEA edx,  @@@@mode_implied+edi               ; 14 Future Expansion  
        push edx                                                            
        LEA edx,  @@@@mode_implied+edi               ; 13 Future Expansion  
        push edx                                                            
        LEA edx,  @@@@mode_implied+edi               ; 12 Future Expansion  
        push edx                                                            
        LEA edx,  @@@@mode_ind_y+edi                 ; 11 (IND),Y           
        push edx                                                            
        LEA edx,  @@@@mode_relative+edi              ; 10 RELATIVE
        push edx
        LEA edx,  @@@@mode_implied+edi               ; 0F Future Expansion  
        push edx                                                            
        LEA edx,  @@@@mode_absolute+edi              ; 0E ABSOLUTE          
        push edx                                                            
        LEA edx,  @@@@mode_absolute+edi              ; 0D ABSOLUTE          
        push edx
        LEA edx,  @@@@mode_implied+edi               ; 0C Future Expansion  
        push edx                                                            
        LEA edx,  @@@@mode_implied+edi               ; 0B Future Expansion  
        push edx                                                            
        LEA edx,  @@@@mode_accumulator+edi           ; 0A ACCUMULATOR       
        push edx                                                            
        LEA edx,  @@@@mode_immediate+edi             ; 09 immediate         
        push edx
        LEA edx,  @@@@mode_implied+edi               ; 08 IMPLIED
        push edx                                                            
        LEA edx,  @@@@mode_implied+edi               ; 07 Future Expansion
        push edx
        LEA edx,  @@@@mode_zp+edi                    ; 06 zero page         
        push edx
        LEA edx,  @@@@mode_zp+edi                    ; 05 zero page         
        push edx                                                            
        LEA edx,  @@@@mode_implied+edi               ; 04 Future Expansion
        push edx
        LEA edx,  @@@@mode_implied+edi               ; 03 Future Expansion
        push edx
        LEA edx,  @@@@mode_implied+edi               ; 02 Future Expansion
        push edx
        LEA edx,  @@@@mode_ind_x+edi                 ; 01 (INDIRECT, X)
        push edx
        LEA edx,  @@@@mode_implied+edi               ; 00 IMPLIED
        push edx

@@GetReadOPCODE:
;-------------------------------------------
;              Get The OPCODE #
;-------------------------------------------
        xor ebx,ebx                                ;\__sorry optimization freaks!
        xor eax,eax                                ;/
        mov WORD PTR bx,[ebp.PCount]               ; Gets th PC value
        mov dWORD PTR esi,[ebp.code_buffer]        ;
        add esi,ebx                                ; ajust our relative position in 6502_RAM
        lodsb                                      ; AL holds th opcode #
;        ----------------------------------------
;                   Emulate the opcode
;        ----------------------------------------
        call [esp].VM_TABLE_SIZE+(eax*4)           ; and index it to fit in our table (0 based)
;        ----------------------------------------
;                        Ajust the PC
;        ----------------------------------------
        mov bx,[ebp.PCount]
        inc bx
        mov [ebp.PCount],bx
        call GetVMState
        jmp @@GetReadOPCODE
;        ----------------------------------------
;                  Terminates the Emulation
;        ----------------------------------------
@@@__endEMU:
        add esp,(CPU6502_STACK_SIZE+(2*VM_TABLE_SIZE))              ; sick isn`t it ?
        popa
        ret



; *************************************************************************
; *                  THE 6502CPU ADDRESSING MODES                         *
; *************************************************************************


; ****************************************************************
;   IMPLIED ADDRESSING
; ****************************************************************
; ****************************************************************

@@@@mode_indirect:
       pusha
       push 0
       push OFFSET MSG_IND
       push OFFSET MSG_IND
       push 0
       call MessageBox
       xor eax,eax
;   Updates the PC register
       xor ebx,ebx
       mov bx, [ebp.PCount]
       inc bx
       inc bx
       mov [ebp.PCount],bx
;   esi points to VM_RAM+current_opcode+1
       xor eax,eax
       lodsw                                       ; little andian, the WORD come fliped
       mov ebx,[ebp.code_buffer]                   ; Get the address of VM`s memmory
       add ebx,eax                                 ; Index it to te absolute addr passed
;   Get the contents given address
       mov dword ptr [ebp.temp1],ebx
       popa
       ret

; ****************************************************************
;   IMPLIED ADDRESSING
; ****************************************************************
;  Since the operand is implied this mode only waste x86 cicles
;  It is not nescessary to be here, once i could just do a  "sub
;  esp 4" instruction to keep the integrity of the table, and do
;  not call this routine, but the sturcture would not be complete
;  in my point of view, without an addressing mode.
;  So, i decided to keep it here, and waste a few bytes a cicles
;  and preserve the architeture structure...
; ****************************************************************

@@@@mode_implied:
       push 0
       push OFFSET MSG_IMP
       push OFFSET MSG_IMP
       push 0
       call MessageBox
       ret

; *****************************************************************
;  IMMEDIATE ADDRESSING
; *****************************************************************
;******************************************************************
@@@@mode_immediate:
        pusha
        push 0
        push OFFSET MSG_IMM
        push OFFSET MSG_IMM
        push 0
        call MessageBox
;   Updates the PC register
        xor ebx,ebx
        inc [ebp.PCount]
;   esi points to VM_RAM+current_opcode+1
        mov dword ptr [ebp.temp1],esi               ; saves the immediate address
        popa
        ret

; ******************************************************************
;  ZERO-PAGE ADDRESSING
; ******************************************************************
; ******************************************************************
@@@@mode_zp:
        pusha
        push 0
        push OFFSET MSG_ZP
        push OFFSET MSG_ZP
        push 0
        call MessageBox
;   Updates the PC register
        xor ebx,ebx
        inc [ebp.PCount]
;   esi points to VM_RAM+current_opcode+1
        xor ebx,ebx
        mov BYTE PTR bl,[esi]                       ; Gets the ZP immediate address
        add ebx,[ebp.code_buffer]                   ; from the begginning of VM`s memory
        mov dword ptr [ebp.temp1],ebx               ; Save its address
        popa
        ret


; ******************************************************************
; ZERO PAGE X ADDRESSING
; ******************************************************************
; ******************************************************************
@@@@mode_zp_x:
        pusha
        push 0
        push OFFSET MSG_INDX
        push OFFSET MSG_INDX
        push 0
        call MessageBox
;   Updates the PC register
        xor ebx,ebx
        inc [ebp.PCount]
;   esi points to VM_RAM+current_opcode+1
        xor ebx,ebx
        xor eax,eax
        mov BYTE PTR bl,[esi]                       ; Gets the ZP immediate address
        mov BYTE PTR al,[ebp.reg_X]                 ; The X contents
        add ebx,eax                                 ; # + X
;   WRAP AROUND
        and ebx,000Fh
        add ebx,[ebp.code_buffer]                   ; from the begginning of VM`s memory
        mov dword ptr [ebp.temp1],ebx               ; Save its address
        popa
        ret

; ******************************************************************
; ZERO PAGE Y ADDRESSING
; ******************************************************************
; This routine stores pointer to the VMmemmory position equals to
; the next byte + the indexY register Value
; ******************************************************************
@@@@mode_zp_y:
        pusha
        push 0
        push OFFSET MSG_INDX
        push OFFSET MSG_INDX
        push 0
        call MessageBox
;   Updates the PC register
        xor ebx,ebx
        mov bx, [ebp.PCount]
        inc bx
        mov [ebp.PCount],bx
        inc [ebp.PCount]
;   esi points to VM_RAM+current_opcode+1
        xor ebx,ebx
        xor eax,eax
        mov BYTE PTR bl,[esi]                       ; Gets the ZP immediate address
        mov BYTE PTR al,[ebp.reg_Y]                 ; The X contents
        add ebx,eax                                 ; # + Y
;    WRAP AROUND
        and ebx,000Fh
        add ebx,[ebp.code_buffer]                   ; from the begginning of VM`s memory
        mov dword ptr [ebp.temp1],ebx               ; Save its address
        popa
        ret

; ******************************************************************
;      ACCUMULATOR
; ******************************************************************
; This routine stores a pointer to the structure area on memory (x86)
; reserved to the accumulator register
; ******************************************************************
@@@@mode_accumulator:
        pusha
        push 0
        push OFFSET MSG_ACM
        push OFFSET MSG_ACM
        push 0
        call MessageBox
        mov dword ptr [ebp.temp1],ebp               ; Save A (address}
        popa
        ret

; ******************************************************************
;        ABSOLUTE
; ******************************************************************
; This reoutine stores a pointer tho the VMmemmory pointed by the
; the following two bytes after the OPCODE byte
; ******************************************************************
@@@@mode_absolute:
        pusha
        push 0
        push OFFSET MSG_ABS
        push OFFSET MSG_ABS
        push 0
        call MessageBox
        xor eax,eax
;   Updates the PC register
        xor ebx,ebx
;        mov bx, [ebp.PCount]
;        inc bx
;        inc bx
;        mov [ebp.PCount],bx
        inc [ebp.PCount]
        inc [ebp.PCount]
;   esi points to VM_RAM+current_opcode+1
        lodsw                                       ; little andian, the WORD come fliped
        mov ebx,[ebp.code_buffer]                   ; Get the address of VM`s memmory
        add ebx,eax                                 ; Index it to te absolute addr passed
        mov dword ptr [ebp.temp1],ebx
        popa
        ret

; ******************************************************************
;        ABSOLUTE2
; ******************************************************************
; This reoutine stores a pointer to the following two bytes after
; the OPCODE byte, This second instance is used only by the JMP
; instruction. coz it needs the immediate bytes value and not
; it's contents...
; ******************************************************************
@@@@mode_absolute2:
        pusha
        push 0
        push OFFSET MSG_ABS
        push OFFSET MSG_ABS
        push 0
        call MessageBox
        xor eax,eax
;   Updates the PC register
        xor ebx,ebx
;        mov bx, [ebp.PCount]
;        inc bx
;        inc bx
;        mov WORD PTR [ebp.PCount],bx
        inc [ebp.PCount]
        inc [ebp.PCount]
;   esi points to VM_RAM+current_opcode+1
;        lodsw                                         ; little andian, the WORD come fliped
        mov eax,esi
        inc esi
        inc esi
        mov dword ptr [ebp.temp1],eax                  ; Save the immediate 2 bytes
        popa
        ret

; ******************************************************************
;        ABSOLUTE Y
; ******************************************************************
; This reoutine stores a pointer tho the VMmemmory pointer by the
; the following two bytes after the OPCODE byte + the Y Contents
; ******************************************************************
@@@@mode_absolute_y:
        pusha
        push 0
        push OFFSET MSG_ABS
        push OFFSET MSG_ABS
        push 0
        call MessageBox
        xor eax,eax
;   Updates the PC register
        xor ebx,ebx
;        mov bx, [ebp.PCount]
;        inc bx
;        inc bx
;        mov [ebp.PCount],bx
        inc [ebp.PCount]
        inc [ebp.PCount]
;   esi points to VM_RAM+current_opcode+1
        lodsw                                       ; little andian, the WORD come fliped
        mov ebx,[ebp.code_buffer]                   ; Get the address of VM`s mrmmory
        add ebx,eax                                 ; Index it to te absolute addr passed
;   Gets the Y content
        xor edx,edx
        mov BYTE PTR dl,[ebp.reg_Y]
        add ebx,edx
        mov dword ptr [ebp.temp1],ebx
        popa
        ret


; ******************************************************************
;        ABSOLUTE X
; ******************************************************************
; This reoutine stores a pointer tho the VMmemmory pointer by the
; the following two bytes after the OPCODE byte + the X Contents
; ******************************************************************
@@@@mode_absolute_x:
        pusha
        push 0
        push OFFSET MSG_ABS
        push OFFSET MSG_ABS
        push 0
        call MessageBox
        xor eax,eax
;   Updates the PC register
        xor ebx,ebx
;        mov bx, [ebp.PCount]
;        inc bx
;        inc bx
;        mov [ebp.PCount],bx
        inc [ebp.PCount]
        inc [ebp.PCount]
;   esi points to VM_RAM+current_opcode+1
        lodsw                                       ; little andian, the WORD come fliped
        mov ebx,[ebp.code_buffer]                   ; Get the address of VM`s mrmmory
        add ebx,eax                                 ; Index it to te absolute addr passed
;   Gets the X content
        xor edx,edx
        mov BYTE PTR dl,[ebp.reg_X]
        add ebx,edx
        mov dword ptr [ebp.temp1],ebx
        popa
        ret



; ******************************************************************
;        RELATIVE
; ******************************************************************
; This address mode does %NOT% stores the address inside
; the VM structure, regardless the other AModes, this one
; stores the value of bytes to move from the NEXT instruction
; Iknow, it`s a crap at the momment, but, let it be!
; ******************************************************************
@@@@mode_relative:
        pusha
        push 0
        push OFFSET MSG_REL
        push OFFSET MSG_REL
        push 0
        call MessageBox
;   Updates the PC register
        xor eax,eax
        xor ebx,ebx
;        mov bx,[ebp.PCount]
;        inc bx
;        mov [ebp.PCount],bx
        inc [ebp.PCount]
;   esi points to current opcode + 1
        lodsb                                       ; AL holds the operand and BX holds the current VM addres
        inc ax                                      ; relative to the nest instruction start address
        add bx,ax                                   ;
        and ax,1000000000000000b
        jns @@@@mode_relative_no_ajust              ; No need to subtract !
        sub bx,0FFh
@@@@mode_relative_no_ajust:
        mov dword ptr [ebp.temp1],ebx               ; save it !
        popa
        ret
; ******************************************************************
;        Indexed Indirect (ind,X)
; ******************************************************************
; This is addressed by adding the content o X register to the next
; byte following the instruction. This value is a pointer to the low
; byte of the operand address. So, yes, its a pointer to a pointer!
; sick isn't it ? 
;                 **************************************************
;           NOTE: *       THERE IS -=<[!NO!]>=- WRAP AROUND        *
; ******************************************************************
@@@@mode_ind_x:
        pusha
        push 0
        push offset MSG_INDX
        push offset MSG_INDX
        push 0
        call MessageBox
;  Ajust the PCount register
;        mov WORD PTR bx, [ebp.PCount]
;        inc bx
;        mov WORD PTR [ebp.PCount],bx
        inc [ebp.PCount]
; Get The operand and Adds to X register
        xor eax,eax
        xor ebx,ebx
        lodsb
        mov BYTE PTR bl, [ebp.reg_X]
        add eax,ebx
; Now index it into the ZERO-PAGE to get
; the operand address
        mov ebx,[ebp.code_buffer]
        push ebx
        add ebx,eax                               ; ebx points to the low part of the address
        xor eax,eax
        mov BYTE PTR al,[ebx]                     ; retrive the low part first
        mov BYTE PTR ah,[ebx+1]                   ; then the high part
; index it into the memmory
        pop ebx
        add eax,ebx
; Here, eax holds the address of the operand
        mov DWORD PTR [ebp.temp1], eax
        popa
        ret
; ******************************************************************
;        Indirect Indexed (ind),Y
; ******************************************************************
; ******************************************************************
@@@@mode_ind_y:
        pusha
        push 0
        push offset MSG_INDY
        push offset MSG_INDY
        push 0
        call MessageBox
;  Ajust the PCount register
;        mov WORD PTR bx, [ebp.PCount]
;        inc bx
;        mov WORD PTR [ebp.PCount],bx
        inc [ebp.PCount]
;  Retrive the next byte
        xor eax,eax
        lodsb
        mov ebx, [ebp.code_buffer]
        push ebx                                  ; will be used again later
        add ebx,eax                               ; ebx points to the low part of the pointer
; Get the pointer contents
        xor eax,eax
        mov BYTE PTR al,[ebx]                     ; retrive the low part first
        mov BYTE PTR ah,[ebx+1]                   ; then the high part
; Get the Y register value
        xor ecx,ecx
        mov BYTE PTR cl, [ebp.reg_Y]
        pop ebx
        add ebx,ecx
        mov DWORD PTR [ebp.temp1],  ebx
        popa
        ret
; **********************


; #%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#
; #%              HERE IS THE REAL EMULATION ROUTINES ENTRYPOINT                 %#
; #%                 these are the x86 translated instructions                   %#
; #%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#

; #%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#
; #% AND        ( bitwise AND )                                                  #%
; #% Afected Bits S Z                                                            #%
; #%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#
@@@@x86_AND:
        pusha
        ; Get The addressing mode
        call [esp+(eax*4)+32+4]

        push 0
        push OFFSET MSG_AND
        push OFFSET MSG_AND
        push 0
        call MessageBox
        mov byte ptr dl, [ebp.reg_Flag]
        and dl,01111101b                            ; clear bits 1-7
        mov ah,[ebp.reg_A]
        mov DWORD PTR ebx,[ebp.temp1]
        ; Gets the data address
        mov BYTE PTR al,[ebx]
        and al,ah
        pushfd
        pushfd
        ; Saves It!
        mov [ebp.reg_A],al
;       Handle ZERO Flag
        pop eax
        and al,01000000b
        shr al,5
        or dl,al
;       Handle SIGN flag
        pop eax
        and al,10000000b
        or dl,al
;       Saves the new flags state
        mov BYTE PTR [ebp.reg_Flag],dl
@@@@@x86_AND_end:
        popa
        ret

; #%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#
;  BCC          Branch on Carry Clear
;   no flags affected
; #%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#
@@@@x86_BCC:
        pusha
;       Get The Addressing Mode
        call [esp+(eax*4)+32+4]
        push 0
        push OFFSET MSG_BCC
        push OFFSET MSG_BCC
        push 0
        call MessageBox
;       Check the zero flag
        mov BYTE PTR al,[ebp.reg_Flag]
        rcl al,1
;       IF CARY DO NOT BRANCH
        jc @@@@x86_BCC_NOT_TAKEN
;       ELSE BRANCH
        mov WORD PTR ebx,[ebp.temp1]
        dec bx
        jmp @@@@x86_BCC_END
@@@@x86_BCC_NOT_TAKEN:
        mov WORD PTR bx, [ebp.PCount]
        inc bx
@@@@x86_BCC_END:
        mov WORD PTR [ebp.PCount],bx
        popa
        ret

; #%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#
;  BCC          Branch on Carry SET
;   no flags affected
; #%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#
@@@@x86_BCS:
        pusha
;       Get The Addressing Mode
        call [esp+(eax*4)+32+4]
        push 0
        push OFFSET MSG_BCS
        push OFFSET MSG_BCS
        push 0
        call MessageBox
;       Check the zero flag
        mov BYTE PTR al,[ebp.reg_Flag]
        rcl al,1
;       IF CARY DO NOT BRANCH
        jnc @@@@x86_BCS_NOT_TAKEN
;       ELSE BRANCH
        mov WORD PTR ebx,[ebp.temp1]
        dec bx
        jmp @@@@x86_BCS_END
@@@@x86_BCS_NOT_TAKEN:
        mov WORD PTR bx, [ebp.PCount]
        inc bx
@@@@x86_BCS_END:
        mov WORD PTR [ebp.PCount],bx
        popa
        ret

; #%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#
;  BIT      Test bits in memory with accumulator
;   A /\ M, M7 -> N, M6 -> V
; #%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#
@@@@x86_BIT:
        pusha
        ; Get The addressing mode
        call [esp+(eax*4)+32+4]
        push 0
        push OFFSET MSG_BIT
        push OFFSET MSG_BIT
        push 0
        call MessageBox
        xor eax,eax
        mov byte ptr dl, [ebp.reg_Flag]
        and dl,01111001b                            ; clear bits 1-6-7
        mov ah,[ebp.reg_A]
        ; Gets the data address
        mov DWORD PTR ebx,[ebp.temp1]
        mov BYTE PTR al,[ebx]
        AND al,ah
;       Handle ZERO Flag
        and al,01000000b
        shr al,5
        or dl,al
;       Now set the bits 6 and 7 equals to M6 and M7
        and ah,11000000b                            ; Keep only the 6 and 7 bits
        or dl,ah                                    ; put M7 and M6 there
;       Updates the flag register
        mov byte ptr[ebp.reg_Flag],dl
        popa
        ret

; #%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#
; * BRK        ( Break )
; Initiates a software interrupt
; #%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#
@@@@x86_BRK:
        pusha
        ; Get The addressing mode
        call [esp+(eax*4)+32+4]
        ; !
        popa
        ret

; #%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#
;  CPX                  CPX Compare Memory and Index X                   CPX
;                                                        N Z C I D V
;  Operation:  X - M                                     / / / _ _ _
; #%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#
@@@@x86_CPX:
        pusha
        ; Get The addressing mode
        call [esp+(eax*4)+32+4]
        push 0
        push OFFSET MSG_CPX
        push OFFSET MSG_CPX
        push 0
        call MessageBox
        mov BYTE ptr al, [ebp.reg_X]                ; Y register
        ; Get the data to compare against
        mov DWORD ptr ebx, [ebp.temp1]              ; address of data to compare against
        mov BYTE ptr bl,[ebx]                       ; data
        ; Get the Flags Register
        mov BYTE ptr dl, [ebp.reg_Flag]             ; Flags
        and dl,00111110b                            ; clear bits 0,1 and 7
        sub al,bl                                   ; compare
        pushfd
        pushfd
        pushfd
;       Handle CARRY flag
        pop eax
        and al,1                                    ; al holds the VM CF state
        or dl,al
;       Handle ZERO Flag
        pop eax
        and al,01000000b
        shr al,5
        or dl,al
;       Handle SIGN flag
        pop eax
        and al,10000000b
        or dl,al
;       Saves the new flags state
        mov BYTE PTR [ebp.reg_Flag],dl
        popa
        ret

; #%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#
;    CPY                  CPY Compare memory and index Y                   CPY
;                                                        N Z C I D V  (7,1,0)
;  Operation:  Y - M                                     / / / _ _ _                                 (Ref: 7.9)
; #%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#
@@@@x86_CPY:
        pusha
        ; Get The addressing mode
        call [esp+(eax*4)+32+4]
        push 0
        push OFFSET MSG_CPY
        push OFFSET MSG_CPY
        push 0
        call MessageBox
        mov BYTE ptr al, [ebp.reg_Y]                ; Y register
        ; Get the data to compare against
        mov DWORD ptr ebx, [ebp.temp1]              ; address of data to compare against
        mov BYTE ptr bl,[ebx]                       ; data
        ; Get the Flags Register
        mov BYTE ptr dl, [ebp.reg_Flag]             ; Flags
        and dl,00111110b                            ; clear bits 0,1 and 7
        sub al,bl                                   ; compare
        pushfd
        pushfd
        pushfd
;       Handle CARRY flag
        pop eax
        and al,1                                    ; al holds the VM CF state
        or dl,al
;       Handle ZERO Flag
        pop eax
        and al,01000000b
        shr al,5
        or dl,al
;       Handle SIGN flag
        pop eax
        and al,10000000b
        or dl,al
;       Saves the new flags state
        mov BYTE PTR [ebp.reg_Flag],dl
        popa
        ret
; #%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#
;  CMP                CMP Compare memory and accumulator                 CMP
;  Operation:  A - M                                     N Z C I D V
;                                                        / / / _ _ _     (7,1,0)
; #%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#
@@@@x86_CMP:
        pusha
        ; Get The addressing mode
        call [esp+(eax*4)+32+4]
        push 0
        push OFFSET MSG_CMP
        push OFFSET MSG_CMP
        push 0
        call MessageBox
        mov BYTE ptr al, [ebp.reg_A]                ; A register
        ; Get the data to compare against
        mov DWORD ptr ebx, [ebp.temp1]              ; address of data to compare against
        mov BYTE ptr bl,[ebx]                       ; data
        ; Get the Flags Register
        mov BYTE ptr dl, [ebp.reg_Flag]             ; Flags
        and dl,01111100b                            ; clear bits 0,1 and 7
        sub al,bl                                   ; compare
        pushfd
        pushfd
        pushfd
;       Handle CARRY flag
        pop eax
        and al,1                                    ; al holds the VM CF state
        or dl,al
;       Handle ZERO Flag
        pop eax
        and al,01000000b
        shr al,5
        or dl,al
;       Handle SIGN flag
        pop eax
        and al,10000000b
        or dl,al
;       Saves the new flags state
        mov BYTE PTR [ebp.reg_Flag],dl
        popa
        ret
; #%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#
;DEC                   DEC Decrement memory by one                     DEC
;  Operation:  M - 1 -> M                                N Z C I D V   (7,1)
;                                                        / / _ _ _ _
; #%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#
@@@@x86_DEC:
        pusha
        ; Get The addressing mode
        call [esp+(eax*4)+32+4]
        push 0
        push OFFSET MSG_DEC
        push OFFSET MSG_DEC
        push 0
        call MessageBox
        mov DWORD ptr ebx,[ebp.temp1]
        mov BYTE ptr al,[ebx]
        mov BYTE ptr dl, [ebp.reg_Flag]
        and dl,01111101b                            ; clear bits 0-6
        dec al                                      ; Decrements the memmory content
        pushfd
        pushfd
        mov BYTE ptr [ebx], al                      ; Saves it at the same address
;       Handle ZERO Flag
        pop eax
        and al,01000000b
        shr al,5
        or dl,al
;       Handle SIGN flag
        pop eax
        and al,10000000b
        or dl,al
;       Saves the new flags state
        mov BYTE PTR [ebp.reg_Flag],dl
        popa
        ret
; #%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#
; EOR            EOR "Exclusive-Or" memory with accumulator             EOR
;  Operation:  A EOR M -> A                              N Z C I D V
;                                                        / / _ _ _ _
; #%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#
@@@@x86_EOR:
        pusha
        ; Get The addressing mode
        call [esp+(eax*4)+32+4]

        push 0
        push OFFSET MSG_EOR
        push OFFSET MSG_EOR
        push 0
        call MessageBox
        mov byte ptr dl, [ebp.reg_Flag]
        and dl,01111101b                            ; clear bits 0-6
        mov ah,[ebp.reg_A]
        mov DWORD PTR ebx,[ebp.temp1]
        ; Gets the data address
        mov BYTE PTR al,[ebx]
        XOR al,ah
        pushfd
        pushfd
        ; Saves It!
        mov [ebp.reg_A],al
;       Handle ZERO Flag
        pop eax
        and al,01000000b
        shr al,5
        or dl,al
;       Handle SIGN flag
        pop eax
        and al,10000000b
        or dl,al
;       Saves the new flags state
        mov BYTE PTR [ebp.reg_Flag],dl
@@@@@x86_EOR_end:
        popa
        ret
; #%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#
;  INC                    INC Increment memory by one                    INC
;                                                        N Z C I D V
;  Operation:  M + 1 -> M                                / / _ _ _ _
; #%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#
@@@@x86_INC:
        pusha
        ; Get The addressing mode
        call [esp+(eax*4)+32+4]
        push 0
        push OFFSET MSG_INC
        push OFFSET MSG_INC
        push 0
        call MessageBox
        mov DWORD ptr ebx,[ebp.temp1]
        mov BYTE ptr al,[ebx]
        mov BYTE ptr dl, [ebp.reg_Flag]
        and dl,01111101b                            ; clear bits 0-6
        inc al                                      ; Increments the memmory content
        pushfd
        pushfd
        mov BYTE ptr [ebx], al                      ; Saves it at the same address
;       Handle ZERO Flag
        pop eax
        and al,01000000b
        shr al,5
        or dl,al
;       Handle SIGN flag
        pop eax
        and al,10000000b
        or dl,al
;       Saves the new flags state
        mov BYTE PTR [ebp.reg_Flag],dl
        popa
        ret



; #%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#
;  JSR          JSR Jump to new location saving return address           JSR
;  Operation:  PC + 2 toS, (PC + 1) -> PCL               N Z C I D V
;                          (PC + 2) -> PCH               _ _ _ _ _ _
; #%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#
@@@@x86_JSR:
       pusha
       push eax
       push 0
       push OFFSET MSG_JSR
       push OFFSET MSG_JSR
       push 0
       call MessageBox
; now get the stack pointer and save stuffs there
       lea eax,[ebp.code_buffer.STACK_]
       xor ebx,ebx
       mov bl,[ebp.reg_SP]
       add eax,ebx
       dec eax
; Saves the return addr (it must be done before the addressing
; mode routine changes the PC value )
       mov bx,[ebp.PCount]
       inc bx
       inc bx
       mov WORD PTR [eax],bx

       ; Get The addressing mode
       pop eax
       call [esp+(eax*4)+32+4]

; Get the sub-routine address -1 and put it on PC
       xor ebx,ebx
       xor ecx,ecx
       mov dword ptr eax,[ebp.temp1]
;       mov word ptr cx,[ebp.PCount]
       mov ebx,[ebp.code_buffer]
       cmp eax,ebx
       jg @@@@x86_JSR_NOT_XCHG
       xchg ax,bx
@@@@x86_JSR_NOT_XCHG:
       sub ax,bx
       mov WORD PTR [ebp.PCount],ax
       popa
       ret

; #%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#
;NOP                         NOP No operation                          NOP
;                                                        N Z C I D V
;  Operation:  No Operation (2 cycles)                   _ _ _ _ _ _
; #%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#
@@@@x86_NOP:
        pusha
        nop
        popa
        ret

; #%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#
; * ORA  ( Logical Or with Accumulator )
; * Performs a bit-bit OR operation between A and a Memory value                                       *
; * Modified Flags  1-7
; #%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#
@@@@x86_ORA:
        pusha
        ; Get The addressing mode
        call [esp+(eax*4)+32+4]
        push 0
        push OFFSET MSG_ORA
        push OFFSET MSG_ORA
        push 0
        call MessageBox
        mov byte ptr dl, [ebp.reg_Flag]
        and dl,01111101b                            ; clear bits 1-7
        mov ah,[ebp.reg_A]
        mov DWORD PTR ebx,[ebp.temp1]
        ; Gets the data address
        mov BYTE PTR al,[ebx]
        or al,ah
        pushfd
        pushfd
        ; Saves It!
        mov [ebp.reg_A],al
;       Handle ZERO Flag
        pop eax
        and al,01000000b
        shr al,5
        or dl,al
;       Handle SIGN flag
        pop eax
        and al,10000000b
        or dl,al
;       Saves the new flags state
        mov BYTE PTR [ebp.reg_Flag],dl
@@@@@x86_ORA_end:
        popa
        ret


; #%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#
; * ASL (Aritimetic Shift Left)
; * Shifts left the operand by 1 bit, The bit shiftesd fills the carry flag,and
; * the leftmost bit is clean             C <-|7.6.5.4.3.2.1.0|<-0
; * Modified Flags: 0,1,7
; #%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#
@@@@x86_ASL:
        ; Get The addressing mode
        pusha
        call [esp+(eax*4)+32+4]
        push 0
        push OFFSET MSG_ASL
        push OFFSET MSG_ASL
        push 0
        call MessageBox
        xor ecx,ecx
        xor eax,eax
        inc al                                          ; to clean the Z flag
        mov byte ptr dl, [ebp.reg_Flag]                 ; Get the VM flags
        and dl,1111100b                                 ; Cleans flags 0 - 1 - 7
        mov DWORD PTR ebx,ebp.[temp1]                   ; Gets the data address
        mov BYTE PTR cl,[ebx]                           ; Gets the data
        ; The instuction itself!
        sal cl,00000001b                                ; all bits left, first to CF
        pushf
        pushf
        pushf
        AND cl,0FEh                                     ; The last bit becomes 0
        mov BYTE PTR [ebx],cl
;       Handle CARRY flag
        pop eax
        and al,1                                        ; al holds the VM CF state
        or dl,al
;       Handle ZERO Flag
        pop eax
        and al,01000000b
        shr al,5
        or dl,al
;       Handle SIGN flag
        pop eax
        and al,10000000b
        or dl,al

;        xor ebx,ebx
;        popf
;        adc bh,0
;        shl bh,7
;        or dl,bh

;       Saves the new flags state
        mov BYTE PTR [ebp.reg_Flag],dl
        popa
        ret

; #%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#
;  BPL                     BPL Branch on result plus                     BPL
;  Operation:  Branch on N = 0                           N Z C I D V
;                                                       _ _ _ _ _ _
; #%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#
@@@@x86_BPL:
        pusha
;       Get The Addressing Mode
        call [esp+(eax*4)+32+4]
        push 0
        push OFFSET MSG_BPL
        push OFFSET MSG_BPL
        push 0
        call MessageBox
;       Check the zero flag
        mov BYTE PTR al,[ebp.reg_Flag]
        rcl al,1
;       IF CARY DO NOT BRANCH
        jc @@@@x86_BPL_NOT_TAKEN
;       ELSE BRANCH
        mov WORD PTR ebx,[ebp.temp1]
        dec bx
        jmp @@@@x86_BPL_END
@@@@x86_BPL_NOT_TAKEN:
        mov WORD PTR bx, [ebp.PCount]
        inc bx
@@@@x86_BPL_END:
        mov WORD PTR [ebp.PCount],bx
        popa
        ret
; #%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#
;  BVC                   BVC Branch on overflow clear                    BVC
;  Operation:  Branch on V = 0                           N Z C I D V
;                                                        _ _ _ _ _ _
; #%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#
@@@@x86_BVC:
        pusha
;       Get The Addressing Mode
        call [esp+(eax*4)+32+4]
        push 0
        push OFFSET MSG_BVC
        push OFFSET MSG_BVC
        push 0
        call MessageBox
;       Check the zero flag
        mov BYTE PTR al,[ebp.reg_Flag]
        rcr al,7
;       IF *NOT* CARY DO BRANCH
        jc @@@@x86_BVC_NOT_TAKEN
;       ELSE BRANCH
        mov WORD PTR ebx,[ebp.temp1]
        dec bx
        jmp @@@@x86_BVC_END
@@@@x86_BVC_NOT_TAKEN:
        mov WORD PTR bx, [ebp.PCount]
        inc bx
@@@@x86_BVC_END:
        mov WORD PTR [ebp.PCount],bx
        popa
        ret
;2713-5546
;91276815

; #%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#
;  BMI                    BMI Branch on result minus                     BMI
;  Operation:  Branch on N = 1                           N Z C I D V
;                                                        _ _ _ _ _ _
; #%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#
@@@@x86_BMI:
        pusha
;       Get The Addressing Mode
        call [esp+(eax*4)+32+4]
        push 0
        push OFFSET MSG_BMI
        push OFFSET MSG_BMI
        push 0
        call MessageBox
;       Check the zero flag
        mov BYTE PTR al,[ebp.reg_Flag]
        rcl al,1
;       IF *NOT* CARY DO NOT BRANCH
        jnc @@@@x86_BMI_NOT_TAKEN
;       ELSE BRANCH
        mov WORD PTR ebx,[ebp.temp1]
        dec bx
        jmp @@@@x86_BMI_END
@@@@x86_BMI_NOT_TAKEN:
        mov WORD PTR bx, [ebp.PCount]
        inc bx
@@@@x86_BMI_END:
        mov WORD PTR [ebp.PCount],bx
        popa
        ret
; #%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#
;  BEQ                    BEQ Branch on result zero                      BEQ
;                                                        N Z C I D V
;  Operation:  Branch on Z = 1                           _ _ _ _ _ _
; #%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#
@@@@x86_BEQ:
        pusha
;       Get The Addressing Mode
        call [esp+(eax*4)+32+4]
        push 0
        push OFFSET MSG_BEQ
        push OFFSET MSG_BEQ
        push 0
        call MessageBox
;       Check the zero flag ( zero flag says if its equal or not)
        mov BYTE PTR al,[ebp.reg_Flag]
        rcl al,1
;       IF CARY DO NOT BRANCH
        jnc @@@@x86_BEQ_NOT_TAKEN
;       ELSE BRANCH
        mov WORD PTR ebx,[ebp.temp1]
        dec bx
        jmp @@@@x86_BEQ_END
@@@@x86_BEQ_NOT_TAKEN:
        mov WORD PTR bx, [ebp.PCount]
        inc bx
@@@@x86_BEQ_END:
        mov WORD PTR [ebp.PCount],bx
        popa
        ret


; #%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#
;  BNE                   BNE Branch on result not zero                   BNE
;  Operation:  Branch on Z = 0                           N Z C I D V
;                                                        _ _ _ _ _ _
; #%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#
@@@@x86_BNE:
        pusha
;       Get The Addressing Mode
        call [esp+(eax*4)+32+4]
        push 0
        push OFFSET MSG_BNE
        push OFFSET MSG_BNE
        push 0
        call MessageBox
;       Check the zero flag ( zero flag says if its equal or not)
        mov BYTE PTR al,[ebp.reg_Flag]
        rcl al,1
;       IF CARY DO NOT BRANCH
        jc @@@@x86_BNE_NOT_TAKEN
;       ELSE BRANCH
        mov WORD PTR ebx,[ebp.temp1]
        dec bx
        jmp @@@@x86_BNE_END
@@@@x86_BNE_NOT_TAKEN:
        mov WORD PTR bx, [ebp.PCount]
        inc bx
@@@@x86_BNE_END:
        mov WORD PTR [ebp.PCount],bx
        popa
        ret

; #%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#
;  CLI                  CLI Clear interrupt disable bit                  CLI
;  Operation: 0 -> I                                     N Z C I D V
;                                                        _ _ _ 0 _ _
; #%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#
@@@@x86_CLI:
        pusha
        push 0
        push offset MSG_CLI
        push offset MSG_CLI
        push 0
        call MessageBox
;        mov BYTE PTR al,[ebp.reg_Flag]
;        and al,11111011b
;        mov BYTE PTR [ebp.reg_Flag],al
        and [ebp.reg_Flag], 11111011b
        popa
        ret

; #%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#
;  CLC                       CLC Clear carry flag                        CLC
;  Operation:  0 -> C                                    N Z C I D V
;                                                        _ _ 0 _ _ _
; #%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#
@@@@x86_CLC:
        pusha
        push 0
        push offset MSG_CLC
        push offset MSG_CLC
        push 0
        call MessageBox
;        mov BYTE PTR al,[ebp.reg_Flag]
;        and al,11111110b
;        mov BYTE PTR [ebp.reg_Flag],al
        and [ebp.reg_Flag],11111110b
        popa
        ret
; #%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#
;  CLV                      CLV Clear overflow flag                      CLV
;  Operation: 0 -> V                                     N Z C I D V
;                                                        _ _ _ _ _ 0
; #%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#
@@@@x86_CLV:
        pusha
        push 0
        push offset MSG_CLV
        push offset MSG_CLV
        push 0
        call MessageBox
;        mov BYTE PTR al,[ebp.reg_Flag]
;        and al,10111111b
;        mov BYTE PTR [ebp.reg_Flag],al
        and [ebp.reg_Flag],10111111b
        popa
        ret

; #%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#
;    CLD                      CLD Clear decimal mode                       CLD
;  Operation:  0 -> D                                    N A C I D V       (3)
;                                                        _ _ _ _ 0 _
; #%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#
@@@@x86_CLD:
        pusha
        push 0
        push offset MSG_CLD
        push offset MSG_CLD
        push 0
        call MessageBox
;        mov BYTE PTR al,[ebp.reg_Flag]
;        and al,11110111b
;        mov BYTE PTR [ebp.reg_Flag],al
        and [ebp.reg_Flag],11110111b
        popa
        ret

; #%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#
;  DEY    DEY Decrement index Y by one
;  Modifyed flags 1,7
; #%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#
@@@@x86_DEY:
        pusha
        push 0
        push offset MSG_DEY
        push offset MSG_DEY
        push 0
        call MessageBox
        mov BYTE PTR al,[ebp.reg_Y]
        mov BYTE PTR dl,[ebp.reg_Flag]
;       clear the affected flags
        and dl,01111101b
        dec al
        pushf
        pushf
        mov BYTE PTR [ebp.reg_Y],al
;       Handle ZERO Flag
        pop eax
        and al,01000000b
        shr al,5
        or dl,al
;       Handle SIGN flag
        pop eax
        and al,10000000b
        or dl,al
;       Update the flags
        mov BYTE PTR [ebp.reg_Flag],dl
        popa
        ret

; #%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#
;  DEX    DEX Decrement index X by one
;  Modifyed flags 1,7
; #%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#
@@@@x86_DEX:
        pusha
        push 0
        push offset MSG_DEX
        push offset MSG_DEX
        push 0
        call MessageBox
;        mov BYTE PTR al,[ebp.reg_X]
        mov BYTE PTR dl,[ebp.reg_Flag]
;       clear the affected flags
        and dl,01111101b
;        dec al
        dec [ebp.reg_X]
        pushf
        pushf
        mov BYTE PTR [ebp.reg_Y],al
;       Handle ZERO Flag
        pop eax
        and al,01000000b
        shr al,5
        or dl,al
;       Handle SIGN flag
        pop eax
        and al,10000000b
        or dl,al
;       Update the flags
        mov BYTE PTR [ebp.reg_Flag],dl
        popa
        ret

; #%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#
;  JMP                     JMP Jump to new location                      JMP
;  Operation:  (PC + 1) -> PCL                           N Z C I D V
;              (PC + 2) -> PCH   (Ref: 4.0.2)            _ _ _ _ _ _
; #%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#
@@@@x86_JMP:
        pusha
; Get the addressing mode
        call [esp+(eax*4)+32+4]
        push 0
        push OFFSET MSG_JMP
        push OFFSET MSG_JMP
        push 0
        call MessageBox
        xor eax,eax
        mov DWORD PTR ebx, [ebp.temp1]
        mov WORD PTR ax, [ebx]
        dec ax
        mov WORD PTR [ebp.PCount], ax
        popa
        ret

; #%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#
;  INX                    INX Increment Index X by one                   INX
;                                                        N Z C I D V    (7,1)
;  Operation:  X + 1 -> X                                / / _ _ _ _
; #%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#
@@@@x86_INX:
        pusha
        ; Get The addressing mode
        call [esp+(eax*4)+32+4]
        push 0
        push OFFSET MSG_INX
        push OFFSET MSG_INX
        push 0
        call MessageBox
        mov BYTE ptr dl, [ebp.reg_Flag]
        and dl,01111101b                            ; clear bits 7,1
        inc [ebp.reg_X]
        pushfd
        pushfd
;       Handle ZERO Flag
        pop eax
        and al,01000000b
        shr al,5
        or dl,al
;       Handle SIGN flag
        pop eax
        and al,10000000b
        or dl,al
;       Saves the new flags state
        mov BYTE PTR [ebp.reg_Flag],dl
        popa
        ret


; #%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#
;  INY                    INY Increment Index Y by one                   INY
;                                                        N Z C I D V    (7,1)
;  Operation:  Y + 1 -> Y                                / / _ _ _ _
; #%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#
@@@@x86_INY:
        pusha
        ; Get The addressing mode
        call [esp+(eax*4)+32+4]
        push 0
        push OFFSET MSG_INY
        push OFFSET MSG_INY
        push 0
        call MessageBox
        mov BYTE ptr dl, [ebp.reg_Flag]
        and dl,01111101b                            ; clear bits 7,1
        inc [ebp.reg_Y]
        pushfd
        pushfd
;       Handle ZERO Flag
        pop eax
        and al,01000000b
        shr al,5
        or dl,al
;       Handle SIGN flag
        pop eax
        and al,10000000b
        or dl,al
;       Saves the new flags state
        mov BYTE PTR [ebp.reg_Flag],dl
        popa
        ret

; #%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#
; PHP                 PHP Push processor status on stack                PHP
;  Operation:  P to S                                     N Z C I D V
;                                                         _ _ _ _ _ _
; #%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#
@@@@x86_PHP:
        pusha
        ; Get The addressing mode
        call [esp+(eax*4)+32+4]
        push 0
        push OFFSET MSG_PHP
        push OFFSET MSG_PHP
        push 0
        call MessageBox
        xor eax,eax                                 ; to clean the ZERO flag
        inc al
        mov byte ptr al,[ebp.reg_SP]
        mov byte ptr bl,[ebp.reg_Flag]
        test al,al
        jnz @@@@x86_PHP_enough_stack_space
        mov al,0FFh
        mov BYTE ptr [ebp.reg_SP],al                ; if SP = 0 the next addr is 0FFFFh
        jmp @@@@x86_PHP_save
@@@@x86_PHP_enough_stack_space:
        dec al
        mov byte ptr [ebp.reg_SP],al
@@@@x86_PHP_save:
        mov edx,[ebp.code_buffer]                   ; ebx = address of VM`s memory
        add edx,eax
        mov byte ptr [edx.STACK_],bl                ; saves onto the stack
        popa
        ret

; #%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#
;  PHA                   PHA Push accumulator on stack                   PHA
;
;  Operation:  A toS                                     N Z C I D V
;                                                        _ _ _ _ _ _
; #%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#
@@@@x86_PHA:
        pusha
        call [esp+(eax*4)+32+4]
        push 0
        push OFFSET MSG_PHA
        push OFFSET MSG_PHA
        push 0
        call MessageBox
;       Get the relative position of 6502 stack
        xor eax,eax
        xor ebx,ebx
        xor edx,edx
        mov BYTE PTR dl, [ebp.reg_SP]
;       And index it on the main memmory + stack start + stack pointer
        mov ebx,[ebp.code_buffer]                   ; ebx = address of VM`s memory
        add ebx, edx                                ; Now ebx points to @6502SP
        mov BYTE PTR al,[ebp.reg_A]
        mov BYTE PTR [ebx.STACK_],al
;       Updates the Stack pointer
        dec dl
        mov BYTE PTR [ebp.reg_SP],dl
        popa
        ret
; #%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#
;  PLA                 PLA Pull accumulator from stack                   PLA
;  Operation:  A fromS                                   N Z C I D V
;                                                        _ _ _ _ _ _
; #%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#
@@@@x86_PLA:
        pusha
        call [esp+(eax*4)+32+4]
        push 0
        push OFFSET MSG_PLA
        push OFFSET MSG_PLA
        push 0
        call MessageBox
;       Get the relative position of 6502 stack
        xor eax,eax
        xor ebx,ebx
        xor edx,edx
        mov BYTE PTR dl, [ebp.reg_SP]
inc dl
;       And index it on the main memmory + stack start + stack pointer
        mov ebx,[ebp.code_buffer]                   ; ebx = address of VM`s memory
        add ebx, edx                                ; Now ebx points to @6502SP
        mov BYTE PTR al,[ebx.STACK_]
        mov BYTE PTR [ebp.reg_A],al
;       Updates the Stack pointer
;        inc dl
        mov BYTE PTR [ebp.reg_SP],dl
        popa
        ret
; #%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#
;  PLP               PLP Pull processor status from stack                PLA
;  Operation:  P fromS                                   N Z C I D V
;                                                         From Stack
; #%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#
@@@@x86_PLP:
        pusha
        ; Get The addressing mode
        call [esp+(eax*4)+32+4]
        push 0
        push OFFSET MSG_PLP
        push OFFSET MSG_PLP
        push 0
        call MessageBox
        xor eax,eax
        mov byte ptr al,[ebp.reg_SP]
        mov byte ptr bl,[ebp.reg_Flag]
        mov edx,[ebp.code_buffer]                   ; ebx = address of VM`s memory
        add edx,eax
        mov byte ptr bl, [edx.STACK_]               ; saves onto the stack
        mov byte ptr [ebp.reg_Flag],bl
        inc al
        mov byte ptr [ebp.reg_SP],al                ; increments the stack pointer
        popa
        ret

; #%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#
; * ROL Rotate a bit left with cary
;               +------------------------------+
;               |         M or A               |
;               |   +-+-+-+-+-+-+-+-+    +-+   |
;  Operation:   +-< |7|6|5|4|3|2|1|0| <- |C| <-+
;                   +-+-+-+-+-+-+-+-+    +-+
; Flags affected:   S Z C
; #%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#
@@@@x86_ROL:
        pusha
        ; Get The addressing mode
        call [esp+(eax*4)+32+4]
        push 0
        push OFFSET MSG_ROL
        push OFFSET MSG_ROL
        push 0
        call MessageBox
; Get the flags and clean the affected ones
        mov byte ptr dl,[ebp.reg_Flag]
        mov dh,dl
        and dl,00111110b                            ; clean 7 - 6 - 0
; Get the operand
        xor eax,eax
        xor ecx,ecx
        mov DWORD PTR ebx, [ebp.temp1]
        mov BYTE PTR al,[ebx]                       ; at this point AL holds the operand
; AL = OPERAND _ DL = FLAGS (DH too)
; All bits to left
        shl al,1
        and dh,00000001b                            ; Get only the carry bit
; now sets the current carry value to bit 7
        or al,dh
        pushf
        pushf
        mov BYTE PTR [ebx], al                      ; Saves the result
; Updates the carry flag here!
        mov dh,al
        and dh,10000000b                            ; keep only the bit 7
        or dl,dh                                    ; updates the carry bit
; Handle the ZERO flag
        pop eax
        and al,01000000b
        shr al,5
        or dl,al
; Handle the SIGN flag
        pop eax
        and al,10000000b
        or dl,al
        mov BYTE PTR [ebp.reg_Flag],dl              ; Updates the flag register
        popa
        ret

; #%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#
;*   ROR ROTATE RIGHT
;              +------------------------------+
;               |                              |
;               |   +-+    +-+-+-+-+-+-+-+-+   |
;  Operation:   +-> |C| -> |7|6|5|4|3|2|1|0| >-+         N Z C I D V
;                   +-+    +-+-+-+-+-+-+-+-+             / / / _ _ _
; #%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#
@@@@x86_ROR:
        pusha
        ; Get The addressing mode
        call [esp+(eax*4)+32+4]
        push 0
        push OFFSET MSG_ROR
        push OFFSET MSG_ROR
        push 0
        call MessageBox
; Get the flags and clean the affected ones
        mov byte ptr dl,[ebp.reg_Flag]
        mov dh,dl
        and dl,00111110b                            ; clean 7 - 6 - 0
; Get the operand
        xor eax,eax
        xor ecx,ecx
        mov DWORD PTR ebx, [ebp.temp1]
        mov BYTE PTR al,[ebx]                       ; at this point AL holds the operand
; AL = OPERAND _ DL = FLAGS (DH too)
        shl dh,7                                    ; transfer bit 0 to 7, clear all the others
; All bits to right
        shr al,1
; now sets the current carry value to bit 0
        or al,dh
        pushf
        pushf
        mov BYTE PTR [ebx], al                      ; Saves the result
; Updates the carry flag here!
        mov dh,al
        and dh,00000001b                            ; keep only the bit 0
        or dl,dh                                    ; updates the carry bit
; Handle the ZERO flag
        pop eax
        and al,01000000b
        shr al,5
        or dl,al
; Handle the SIGN flag
        pop eax
        and al,10000000b
        or dl,al
        mov BYTE PTR [ebp.reg_Flag],dl              ; Updates the flag register
        popa
        ret

; #%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#
;  STA                  STA Store accumulator in memory                  STA
;  Operation:  A -> M                                    N Z C I D V
;                                                        _ _ _ _ _ _
; #%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#
@@@@x86_STA:
        pusha
        ; Get The addressing mode
        call [esp+(eax*4)+32+4]
        push 0
        push OFFSET MSG_STA
        push OFFSET MSG_STA
        push 0
        call MessageBox
;  Get the address to store reg_A value
        mov ebx, DWORD PTR [ebp.temp1]
        mov BYTE PTR al,[ebp.reg_A]
        mov BYTE PTR [ebx],al
        popa
        ret

; #%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#
;  STY                    STY Store index Y in memory                    STY
;  Operation: Y -> M                                     N Z C I D V
;                                                        _ _ _ _ _ _
; #%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#
@@@@x86_STY:
        pusha
        ; Get The addressing mode
        call [esp+(eax*4)+32+4]
        push 0
        push OFFSET MSG_STY
        push OFFSET MSG_STY
        push 0
        call MessageBox
;  Get the address to store reg_Y value
        mov ebx, DWORD PTR [ebp.temp1]
        mov BYTE PTR al,[ebp.reg_Y]
        mov BYTE PTR [ebx],al
        popa
        ret

; #%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#
;  STX                    STX Store index X in memory                    STX
;  Operation: X -> M                                     N Z C I D V
;                                                        _ _ _ _ _ _
; #%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#
@@@@x86_STX:
        pusha
        ; Get The addressing mode
        call [esp+(eax*4)+32+4]
        push 0
        push OFFSET MSG_STX
        push OFFSET MSG_STX
        push 0
        call MessageBox
;  Get the address to store reg_X value
        mov ebx, DWORD PTR [ebp.temp1]
        mov BYTE PTR al,[ebp.reg_X]
        mov BYTE PTR [ebx],al
        popa
        ret

; #%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#
; * ADC                  Operation:  A + M + C -> A, C
; * this is the decimal mode status flag. When set, and an Add with
; * Id Decimal flag is 1 the source values are treated as valid BCD numbers
; * (0x00-0x99 = 0-99 ) numbers. The result generated is also a BCD number.
; * Flags modifyed   S Z C V
; #%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#
; |-----------------------------|
; | BCD NÃO IMPLEMENTADO AINDA  |
; |-----------------------------|
 @@@@x86_ADC:
        pusha
        ; Get The addressing mode
        call [esp+(eax*4)+32+4]
        push 0
        push OFFSET MSG_ADC
        push OFFSET MSG_ADC
        push 0
        call MessageBox
; Start Cleanning the flags
        xor eax,eax
        xor edx,edx
        xor ebx,ebx
        mov BYTE PTR dl, [ebp.reg_Flag]
        and dl,00111100b                            ; Clean flags 7 6 1 0
        mov BYTE PTR al, [ebp.reg_A]
      	mov DWORD PTR ebx, [ebp.temp1]
	mov BYTE PTR bl, [ebx]
;  Check if Decimal Mode is On
        push dx
        rcl dl,5
        jc @@@@@x86_ADC_BCD_CONVERT
; Se a flag D estiver OFF
        clc
        pop dx                                      ; Salva dl em dh pra uso futuro
        mov dh,dl
        rcr dl,1                                    ; faz da CF (x86) = 6502 CF
; SOMA REG_A + OPERANDO + CARRY FLAG
        adc al,bl
        pushf
        pushf
        pushf
        jmp @@@@@x86_ADC_HANDLE_FLAGS
; Se a flag D estiver ON
@@@@@x86_ADC_BCD_CONVERT:
        ;MESMA COISA DE CIMA PORME EM BCD
        ; LEMBRAR DE FAZER OS PROPRIOS PUSHF`s de flags
@@@@@x86_ADC_HANDLE_FLAGS:
;       Handle CARRY flag
        pop eax
        and al,1                                    ; al holds the VM CF state
        or dl,al                                    ; copy x86 CF to 6502 CF
;       Handle ZERO Flag
        pop eax
        and al,01000000b
        shr al,5
        or dl,al
;       Handle SIGN flag
        pop eax
        and al,10000000b
        or dl,al
;       Handle OVERFLOW flag
;        popf
        popa
        ret

; #%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#
;  RTS                    RTS Return from subroutine                     RTS
;                                                        N Z C I D V
;  Operation:  PC fromS, PC + 1 -> PC                    _ _ _ _ _ _
; #%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#
@@@@x86_RTS:
 ;================
 ;== INCOMPLETA ==
 ;================
ret

; #%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#
; SEI                 SEI Set interrupt disable status                  SED
;                                                        N Z C I D V
;  Operation:  1 -> I                                    _ _ _ 1 _ _
; #%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#
@@@@x86_SEI:
        pusha
        call [esp+(eax*4)+32+4]
        push 0
        push OFFSET MSG_SEI
        push OFFSET MSG_SEI
        push 0
        call MessageBox
        mov BYTE PTR dl,[ebp.reg_Flag]
        or dl,00100100b
        mov BYTE PTR [ebp.reg_Flag],dl
        popa
        ret
; #%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#
; LSR          LSR Shift right one bit (memory or accumulator)          LSR
;                   +-+-+-+-+-+-+-+-+
;  Operation:  0 -> |7|6|5|4|3|2|1|0| -> C               N Z C I D V
;                   +-+-+-+-+-+-+-+-+                    0 / / _ _ _
; #%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#
@@@@x86_LSR:
        ; Get The addressing mode
        pusha
        call [esp+(eax*4)+32+4]
        push 0
        push OFFSET MSG_ASL
        push OFFSET MSG_ASL
        push 0
        call MessageBox
        xor ecx,ecx
        xor eax,eax
        inc al                                          ; to clean the Z flag
        mov byte ptr dl, [ebp.reg_Flag]                 ; Get the VM flags
        and dl,1111100b                                 ; Cleans flags 0 - 1 - 7
        mov DWORD PTR ebx,ebp.[temp1]                   ; Gets the data address
        mov BYTE PTR cl,[ebx]                           ; Gets the data
        ; The instuction itself!
        sar cl,00000001b                                ; all bits right, first to CF
        pushf
        pushf
        AND cl,0EFh                                     ; The First bit becomes 0
        mov BYTE PTR [ebx],cl
;       Handle CARRY flag
        pop eax
        and al,1                                        ; al holds the VM CF state
        or dl,al
;       Handle ZERO Flag
        pop eax
        and al,01000000b
        shr al,5
        or dl,al
;       Saves the new flags state
        mov BYTE PTR [ebp.reg_Flag],dl
        popa
        ret

; #%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#
;  BVS                    BVS Branch on overflow set                     BVS
;  Operation:  Branch on V = 1                           N Z C I D V
;                                                        _ _ _ _ _ _
; #%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#
@@@@x86_BVS:
        pusha
;       Get The Addressing Mode
        call [esp+(eax*4)+32+4]
        push 0
        push OFFSET MSG_BVS
        push OFFSET MSG_BVS
        push 0
        call MessageBox
;       Check the zero flag
        mov BYTE PTR al,[ebp.reg_Flag]
        rcr al,7
;       IF CARY DO BRANCH
        jnc @@@@x86_BVS_NOT_TAKEN
;       ELSE BRANCH
        mov WORD PTR ebx,[ebp.temp1]
        dec bx
        jmp @@@@x86_BVS_END
@@@@x86_BVS_NOT_TAKEN:
        mov WORD PTR bx, [ebp.PCount]
        inc bx
@@@@x86_BVS_END:
        mov WORD PTR [ebp.PCount],bx
        popa
        ret

; #%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#
; RTI                    RTI Return from interrupt                      RTI
;                                                        N Z C I D V
;  Operation:  P fromS PC fromS                           From Stack
; #%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#
@@@@x86_RTI:
        pusha
        ; NOT IMPLEMENTED YET
        popa
        ret

; #%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#
; TXA                TXA Transfer index X to accumulator                TXA
;                                                        N Z C I D V
;  Operation:  X -> A                                    / / _ _ _ _
; #%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#
@@@@x86_TXA:
        pusha
;        call [esp+(eax*4)+32+4]
        push 0
        push OFFSET MSG_TXA
        push OFFSET MSG_TXA
        push 0
        call MessageBox
        mov BYTE PTR al,[ebp.reg_X]
        mov BYTE PTR dl,[ebp.reg_Flag]
;       clear the modifyed flags
        and dl,01111101b
;       Get modifyed flags
        add al,0
        pushf
        pushf
        mov BYTE PTR [ebp.reg_A],al
;       Handle ZERO Flag
        pop eax
        and al,01000000b
        shr al,5
        or dl,al
;       Handle SIGN flag
        pop eax
        and al,10000000b
        or dl,al
;       Update the flags
        mov BYTE PTR [ebp.reg_Flag],dl
        popa
        ret

; #%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#
; TAY                TAY Transfer accumulator to index Y                TAY
;  Operation:  A -> Y                                    N Z C I D V
;                                                        / / _ _ _ _
; #%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#
@@@@x86_TAY:
        pusha
;        call [esp+(eax*4)+32+4]
        push 0
        push OFFSET MSG_TAY
        push OFFSET MSG_TAY
        push 0
        call MessageBox
        mov BYTE PTR al,[ebp.reg_A]
        mov BYTE PTR dl,[ebp.reg_Flag]
;       clear the modifyed flags
        and dl,01111101b
;       Get modifyed flags
        add al,0
        pushf
        pushf
        mov BYTE PTR [ebp.reg_Y],al
;       Handle ZERO Flag
        pop eax
        and al,01000000b
        shr al,5
        or dl,al
;       Handle SIGN flag
        pop eax
        and al,10000000b
        or dl,al
;       Update the flags
        mov BYTE PTR [ebp.reg_Flag],dl
        popa
        ret

; #%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#
;  TAX                TAX Transfer accumulator to index X                TAX
;  Operation:  A -> X                                    N Z C I D V
;                                                        / / _ _ _ _
; #%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#
@@@@x86_TAX:
        pusha
;        call [esp+(eax*4)+32+4]
        push 0
        push OFFSET MSG_TAX
        push OFFSET MSG_TAX
        push 0
        call MessageBox
        mov BYTE PTR al,[ebp.reg_A]
        mov BYTE PTR dl,[ebp.reg_Flag]
;       clear the modifyed flags
        and dl,01111101b
;       Get modifyed flags
        add al,0
        pushf
        pushf
        mov BYTE PTR [ebp.reg_X],al
;       Handle ZERO Flag
        pop eax
        and al,01000000b
        shr al,5
        or dl,al
;       Handle SIGN flag
        pop eax
        and al,10000000b
        or dl,al
;       Update the flags
        mov BYTE PTR [ebp.reg_Flag],dl
        popa
        ret


; #%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#
; TYA                TYA Transfer index Y to accumulator                TYA
;  Operation:  Y -> A                                    N Z C I D V
;                                                        / / _ _ _ _
; #%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#
@@@@x86_TYA:
        pusha
;        call [esp+(eax*4)+32+4]
        push 0
        push OFFSET MSG_TYA
        push OFFSET MSG_TYA
        push 0
        call MessageBox
        mov BYTE PTR al,[ebp.reg_Y]
        mov BYTE PTR dl,[ebp.reg_Flag]
;       clear the modifyed flags
        and dl,01111101b
;       Get modifyed flags
        add al,0
        pushf
        pushf
        mov BYTE PTR [ebp.reg_A],al
;       Handle ZERO Flag
        pop eax
        and al,01000000b
        shr al,5
        or dl,al
;       Handle SIGN flag
        pop eax
        and al,10000000b
        or dl,al
;       Update the flags
        mov BYTE PTR [ebp.reg_Flag],dl
        popa
        ret
; #%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#
; TSX              TSX Transfer stack pointer to index X                TSX
;  Operation:  S -> X                                    N Z C I D V                                                        
;                                                        / / _ _ _ _
; #%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#
@@@@x86_TSX:
        pusha
;        call [esp+(eax*4)+32+4]
        push 0
        push OFFSET MSG_TSX
        push OFFSET MSG_TSX
        push 0
        call MessageBox
        mov BYTE PTR al,[ebp.reg_SP]
        mov BYTE PTR dl,[ebp.reg_Flag]
;       clear the modifyed flags
        and dl,01111101b
;       Get modifyed flags
        add al,0
        pushf
        pushf
        mov BYTE PTR [ebp.reg_X],al
;       Handle ZERO Flag
        pop eax
        and al,01000000b
        shr al,5
        or dl,al
;       Handle SIGN flag
        pop eax
        and al,10000000b
        or dl,al
;       Update the flags
        mov BYTE PTR [ebp.reg_Flag],dl
        popa
        ret

; #%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#
;  TXS              TXS Transfer index X to stack pointer                TXS
;                                                        N Z C I D V
;  Operation:  X -> S                                    _ _ _ _ _ _
; #%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#
@@@@x86_TXS:
        pusha
;        call [esp+(eax*4)+32+4]
        push 0
        push OFFSET MSG_TXS
        push OFFSET MSG_TXS
        push 0
        call MessageBox
        mov BYTE PTR al,[ebp.reg_X]
        mov BYTE PTR [ebp.reg_SP],al
        popa
        ret

; #%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#
; LDY                   LDY Load index Y with memory                    LDY
;                                                        N Z C I D V
;  Operation:  M -> Y                                    / / _ _ _ _
; #%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#
@@@@x86_LDY:
        pusha
        call [esp+(eax*4)+32+4]
        push 0
        push OFFSET MSG_LDY
        push OFFSET MSG_LDY
        push 0
        call MessageBox
        mov BYTE PTR dl,[ebp.reg_Flag]
;       ; Get new Y value
        mov DWORD PTR ebx,[ebp.temp1]
        mov BYTE PTR al,[ebx]
;       clear the modifyed flags
        and dl,01111101b
;       Get modifyed flags
        add al,0
        pushf
        pushf
        mov BYTE PTR [ebp.reg_Y],al
;       Handle ZERO Flag
        pop eax
        and al,01000000b
        shr al,5
        or dl,al
;       Handle SIGN flag
        pop eax
        and al,10000000b
        or dl,al
;       Update the flags
        mov BYTE PTR [ebp.reg_Flag],dl
        popa
        ret

; #%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#
;  LDA      Load Accumulator with memory
; affected flags (7,1)
; #%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#
@@@@x86_LDA:
        pusha
        call [esp+(eax*4)+32+4]
        push 0
        push OFFSET MSG_LDA
        push OFFSET MSG_LDA
        push 0
        call MessageBox
        mov BYTE PTR dl,[ebp.reg_Flag]
;       ; Get new Y value
        mov DWORD PTR ebx,[ebp.temp1]
        mov BYTE PTR al,[ebx]
;       clear the modifyed flags
        and dl,01111101b
;       Get modifyed flags
        add al,0
        pushf
        pushf
        mov BYTE PTR [ebp.reg_A],al
;       Handle ZERO Flag
        pop eax
        and al,01000000b
        shr al,5
        or dl,al
;       Handle SIGN flag
        pop eax
        and al,10000000b
        or dl,al
;       Update the flags
        mov BYTE PTR [ebp.reg_Flag],dl
        popa
        ret
; #%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#
;  LDX  Load index X with memory
; affected flags (7,1)
; #%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#
@@@@x86_LDX:
        pusha
        call [esp+(eax*4)+32+4]
        push 0
        push OFFSET MSG_LDX
        push OFFSET MSG_LDX
        push 0
        call MessageBox
        mov BYTE PTR dl,[ebp.reg_Flag]
;       ; Get new Y value
        mov DWORD PTR ebx,[ebp.temp1]
        mov BYTE PTR al,[ebx]
;       clear the modifyed flags
        and dl,01111101b
;       Get modifyed flags
        add al,0
        pushf
        pushf
        mov BYTE PTR [ebp.reg_X],al
;       Handle ZERO Flag
        pop eax
        and al,01000000b
        shr al,5
        or dl,al
;       Handle SIGN flag
        pop eax
        and al,10000000b
        or dl,al
;       Update the flags
        mov BYTE PTR [ebp.reg_Flag],dl
        popa
        ret
; #%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#
;       SED                       SED Set decimal mode                        SED
;                                                        N Z C I D V
;  Operation:  1 -> D                                    _ _ _ _ 1 _
; #%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#
@@@@x86_SED:
        pusha
        ; Get The addressing mode
        call [esp+(eax*4)+32+4]
        push 0
        push OFFSET MSG_SEC
        push OFFSET MSG_SEC
        push 0
        call MessageBox
;       Set the carry flag
        mov byte ptr dl,[ebp.reg_Flag]
        or dl,00001000b
;       Updates the flag register
        mov       byte ptr [ebp.reg_Flag], dl
        popa
        ret

; #%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#
;  SEC                        SEC Set carry flag                         SEC
;  Operation:  1 -> C                                    N Z C I D V
;                                                        _ _ 1 _ _ _
; #%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#
@@@@x86_SEC:
        pusha
        ; Get The addressing mode
        call [esp+(eax*4)+32+4]
        push 0
        push OFFSET MSG_SEC
        push OFFSET MSG_SEC
        push 0
        call MessageBox
;       Set the carry flag
        mov byte ptr dl,[ebp.reg_Flag]
        or dl,00000001b
;       Updates the flag register
        mov       byte ptr [ebp.reg_Flag], dl
        popa
        ret

; #%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#
;SBC          SBC Subtract memory from accumulator with borrow         SBC
;                      -
;  Operation:  A - M - C -> A                            N Z C I D V
;         -                                              / / / _ _ /
;    Note:C = Borrow    INCOMPLETO INCOMPLETO INCOMPLETO INCOMPLETO INCOMPLETO
; #%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#
@@@@x86_SBC:
        pusha
        popa
        ret

; #%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#
; * The Virtual Machine branches to this point if an invalid instruction
; * is being pointed by the actual IP register.
; * such situation causes the VM to halt its execution and exit
; #%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#
@@@@InvalidPCODE:
@@@@x86_FE:
        push 0
        push OFFSET MSG_INV
        push OFFSET MSG_INV
        push 0
        call MessageBox
        add esp,4                                   ; just to remove the RET address
        jmp @@@__endEMU

; ***************************************************
;    Displays a message containning the VM status
; ***************************************************
GetVMState:
        pusha
        xor eax,eax
        xor ebx,ebx
        xor ecx,ecx
        xor edx,edx
        
        mov BYTE PTR al, [ebp.reg_Flag]
        mov cx,8
        lea ebx,[flag_data]
analize_Flags:
        rcl al,1
        jnc ClearedBit
        mov BYTE PTR [ebx],"1"
        jmp NextBit
ClearedBit:
        mov BYTE PTR [ebx],"0"
NextBit:
        inc ebx
        loop analize_Flags
;  PUSHING params onto the stack
        mov WORD PTR ax, [ebp.PCount]
        push eax
;  Clear the high part in case it`ve been modifyed
        xor eax,eax
        mov BYTE PTR al, [ebp.reg_SP]
        push eax

        mov BYTE PTR al, [ebp.reg_Flag]
        push eax

        sub ebx,8
        push ebx

        mov BYTE PTR al, [ebp.reg_Y]
        push eax
        mov BYTE PTR al, [ebp.reg_X]
        push eax
        mov BYTE PTR al, [ebp.reg_A]
        push eax
        push offset szFmt
        push offset buffer
        call _wsprintfA
        
        push offset buffer
        call OutputDebugString

        push NULL
        push offset written
        push fmtstrsz
        push offset buffer
        push DWORD PTR [ebp.stateOut]
        call WriteFile
; This stupid function does not pop the arguments of the stack
; so I`ll need to pop`em off there
        add esp,36
        popa
        ret

; ***************************************************
; * This function Sets or cleans a bit specified by *
; * al. If ah=0 it cleans the bit otherwise it sets *
; ***************************************************
setbits:
        pusha
        mov dl,[ebp.reg_Flag]
        mov cl,al
; Configure a bit mask
        mov bl,1
        shl bl,cl
; Should i set, ou clean the bit ?
        test ah,ah
        jz CleanIt
SetsIt:
        or dl,bl
        jmp endbitset
CleanIt:
        xor bl,0FFh                                 ; Natureza louca do XOR :p
        and dl,bl
;       keep the bit 5 set
endbitset:
        or dl,00100000b
        mov BYTE PTR [ebp.reg_Flag],dl
        popa
        ret
