; #make_bin# 
; #LOAD_SEGMENT=FFFFh#
; #LOAD_OFFSET=0000h#

; #CS=0000h#
; #IP=0000h#

; #DS=0000h#
; #ES=0000h#

; #SS=0000h#
; #SP=FFFEh#

; #AX=0000h#
; #BX=0000h#
; #CX=0000h#
; #DX=0000h#
; #SI=0000h#
; #DI=0000h#
; #BP=0000h#
.MODEL TINY
.DATA

;8253 USED TO GENERATE CLOCK FOR ADC
CNT0 EQU 20H
CREG EQU 26H

;8255(1)  INITIALISE
PORT1A EQU 00H 	;CONTROLLING THE LCD
PORT1B EQU 02H 	;INPUT TO LCD
PORT1C EQU 04H 	;UPPER - ROW
		              	;LOWER - COLUMN
CREG1 EQU 06H

;8255(2) USED FOR ADC, ALARM AND SWITCH

PORT2A EQU 10H 	;INPUT TO DI DEVICE
PORT2B EQU 12H 	;ADC
PORT2C EQU 14H 	;PC1 - SOC OF ADC
;PC2 - ALARM
;PC3 - ADDC OF ADC (USED FOR SELECTING THE ;FIRST INPUT CHANNEL OF ADC)
;PC5 - EOC OF ADC
CREG2 EQU 16H

; TABLE_K DB 0EEH,0EDH,0EBH,0E7H,0DEH,0DDH,0DBH,0D7H,0BEH,0BDH,0BBH,0B7H,7EH,7DH,7BH,77H
DAT2 DB 3 DUP(" ");
T DB 30H,31H
.CODE
.STARTUP

MOV AL,00010110B ;INITIALIZING 8253
OUT CREG,AL
MOV AL,5
OUT CNT0,AL

MOV AL,10001000B ;INITIALIZING 8255(1)
OUT CREG1,AL
CALL DELAY_2MS

MOV AL,10001010B ;INITIALIZING 8255(2)
OUT CREG2,AL
CALL DELAY_2MS


KX1: IN AL,PORT1C
AND AL,80H
CMP AL,80H
JNZ KX1 

MOV AL,20H
OUT PORT2A,AL

MOV AL,06H	;GIVE ADC	
OUT CREG2,AL

MOV AL,00H	;GIVE ALE
OUT CREG2,AL

MOV AL,02H	;GIVE SOC
OUT CREG2,AL

MOV AL,01H
OUT CREG2,AL

MOV AL,03H
OUT CREG2,AL

MOV AL,02H	;GIVE SOC
OUT CREG2,AL	

MOV AL,00H	;GIVE ALE
OUT CREG2,AL
  
LOOP2:
IN AL,PORT2C
CALL DELAY_2MS
AND AL,20H ;CHECK FOR EOC    
CMP AL,20H
JNZ LOOP2
CALL DELAY_2MS

MOV AL,10001010B ;INITIALIZING 8255(2)
OUT CREG2,AL
IN AL,PORT2B ; Al contains the voltage value at an end of 2200 ohm resistor
				;NOTE that ADC gives us the integer x as output if the read voltage is x * least count
				;least count here is (5-0)/256 = 19.5312
NOT AL 		;To get the voltage drop we subtract Al from 256 (equivalent to doing NOT AL)
			;AL HAS THE VOLTAGE DROP ACROSS THE RESISTOR
CALL HFE
CALL FUNC 
CALL ALARM

 
.EXIT

ALARM PROC NEAR
CMP AL,50   
JNB Z2
MOV AL,05H
OUT CREG2,AL

CALL DELAY_2S

MOV AL,04H
OUT CREG2,AL  
Z2:
MOV CX,10
Z3:
CALL DELAY_2S
LOOP Z3          
CALL DELAY_2S
RET
ALARM ENDP
  
HFE PROC NEAR ; hfe is AL * 19.5312 *10^-3/ (2200 * 0.1*10^-4) which is approx. AL * 39/44
MOV BL,	39d		;2DH
MUL BL   
MOV BL,	44d		;033H
DIV BL
MOV AH,00H

RET
HFE ENDP
             
        
FUNC PROC NEAR
PUSH AX
MOV AL,38H
CALL COMNDWRT
CALL DELAY
CALL DELAY
CALL DELAY
MOV AL,0EH
CALL COMNDWRT

MOV AL, 01  ;CLEAR LCD
CALL COMNDWRT
CALL DELAY
CALL DELAY

POP AX
PUSH AX
LEA DI,DAT2
MOV BX,100D
MOV DX,0
DIV BX
ADD AL,30H
CALL DATWRIT ;ISSUE IT TO LCD
CALL DELAY
CALL DELAY       
MOV AX,DX
MOV BX,10D 
MOV DX,0
DIV BX
ADD AL,30H
CALL DATWRIT
CALL DELAY
CALL DELAY
MOV AX,DX 
MOV DX,0
ADD AL,30H
CALL DATWRIT   
CALL DELAY
CALL DELAY
POP AX

RET
FUNC ENDP

COMNDWRT PROC ;THIS PROCEDURE WRITES COMMANDS TO LCD
OUT PORT1B, AL  ;SEND THE CODE TO PORT A
MOV AL, 00000100B ;RS=0,R/W=0,E=1 FOR H-TO-L PULSE
OUT PORT1A, AL
NOP
NOP	
MOV AL, 00000000B ;RS=0,R/W=0,E=0 FOR H-TO-L PULSE
OUT PORT1A, AL
RET
COMNDWRT ENDP

DATWRIT PROC NEAR
	PUSH DX  ;SAVE DX 
	MOV DX,PORT1B  ;DX=PORT A ADDRESS
	OUT DX, AL ;ISSUE THE CHAR TO LCD
	MOV AL, 00000101B ;RS=1, R/W=0, E=1 FOR H-TO-L PULSE
	MOV DX, PORT1A ;PORT B ADDRESS
	OUT DX, AL  ;MAKE ENABLE HIGH
	MOV AL, 00000001B ;RS=1,R/W=0 AND E=0 FOR H-TO-L PULSE
	OUT DX, AL
	POP DX
	RET
DATWRIT ENDP ;WRITING ON THE LCD ENDS

DELAY_2MS PROC NEAR
MOV CX,100
HER: NOP
 LOOP HER
RET
DELAY_2MS ENDP

;DELAY IN THE CIRCUIT HERE THE DELAY OF 20 MILLISECOND IS PRODUCED
DELAY PROC
	MOV CX, 1325 ;1325*15.085 USEC = 20 MSEC
	W1: 
		NOP
		NOP
		NOP
		NOP
		NOP
	LOOP W1
	RET
DELAY ENDP 

DELAY_2S PROC
	MOV CX, 33125D 
	W2: 
		NOP
		NOP
		NOP
		NOP
		NOP
	LOOP W2
		MOV CX, 33125D 
	W3: 
		NOP
		NOP
		NOP
		NOP
		NOP
	LOOP W3
		MOV CX, 33125D 
	W4: 
		NOP
		NOP
		NOP
		NOP
		NOP
	LOOP W4
		MOV CX, 33125D 
	W5: 
		NOP
		NOP
		NOP
		NOP
		NOP
	LOOP W5
	RET
DELAY_2S ENDP
END

; read the V from the +ve end of current source and use it to calculate current 
; use AL*50/(BL*11) where AL has the voltage drop acreoss 2200 ohm resistor and 
; BL has the voltage at the positive end of current source
; replace the consecutive NOP strings in DELAY_2S by call to DELAY 4 times
; understand the interfacing of all the components
; use only realizable components as much as possible(since you'll print it as it is)
; jumble up the components here and there
; take different transistor and different voltage value at current source
; make report making sure that all the required headings are present(address map, etc.)