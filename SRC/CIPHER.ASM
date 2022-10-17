; /----------
;  Encoding: UTF-8
;  License: MIT
;  Original Author: Blake Siviour
;  Year: 2022
;  Project: Index Shift Cipher
;  Project Summary: A simple cipher written in assembly that runs on MASM
; \----------

TITLE IndexShiftCipher
.MODEL SMALL
.STACK 100H


.DATA
VersionText_ DB "1.1.0$"
Mode_ DB 0 ; 0 = Decode, 1 = Encode
ModePrompt_ DB "[E]ncode/[D]ecode/[A]bout: $"
ModePromptError_ DB "Invalid input!$"
InputPrompt_ DB "Input: $"
Input_ DB 51,0,52 dup("$") ; Init input variable with max size of 50
InputValue_ DB 0 ; Stores current character's value
InputValueLast_ DB 0 ; Stores last character's value
DecodeInvalidError_ DB "Failed: invalid characters were present!$"
AboutTextA_ DB "Index Shift Cipher$"
AboutTextB_ DB "Version: $"
AboutTextC_ DB "Author: Blake Siviour$"
AboutTextD_ DB "Source: https://github.com/SiviourBla/IndexShiftCipher$"


.CODE
Print_NewLine PROC NEAR ; Print dos newline
	MOV AH, 2 ; Configure to display char
	MOV DL, 13 ; Set char to CR
	INT 21h
	MOV DL, 10 ; Set char to LF
	INT 21h
	RET 0
Print_NewLine ENDP

MAIN PROC
	; Initialise data
		MOV AX, @DATA
		MOV DS, AX
	
	Prompt_Mode: ; Prompt user for mode
		MOV AH, 9 ; Configure to display string
		LEA DX, ModePrompt_ ; Configure offset
		INT 21H
		
		MOV AH, 1 ; Configure to take char input
		INT 21H ; Output -> AL
		
		CMP AL, 'E' ; if (AL == 'E') --> PM_Encode
		JZ PM_Encode
		CMP AL, 'e' ; if (AL == 'e') --> PM_Encode
		JZ PM_Encode
		
		CMP AL, 'D' ; if (AL == 'D') --> PM_Decode
		JZ PM_Decode
		CMP AL, 'd' ; if (AL == 'd') --> PM_Decode
		JZ PM_Decode
		
		CMP AL, 'A' ; if (AL == 'A') --> Display_About
		JZ Display_About
		CMP AL, 'a' ; if (AL == 'a') --> Display_About
		JZ Display_About
		
		CALL Print_NewLine
		
		MOV AH, 9 ; Configure to display string
		LEA DX, ModePromptError_ ; Configure offset
		INT 21H
		
		CALL Print_NewLine
		
		JMP Prompt_Mode ; Prompt user again
		
	Display_About: ; Display info about the program and exit
		CALL Print_NewLine
		
		MOV AH, 9 ; Configure to display string
		LEA DX, AboutTextA_ ; Configure offset
		INT 21H ; Print text
		
		CALL Print_NewLine
		
		MOV AH, 9 ; Configure to display string
		LEA DX, AboutTextB_ ; Configure offset
		INT 21H ; Print text
		
		LEA DX, VersionText_ ; Configure offset
		INT 21H ; Print text
		
		CALL Print_NewLine
		
		MOV AH, 9 ; Configure to display string
		LEA DX, AboutTextC_ ; Configure offset
		INT 21H ; Print text
		
		CALL Print_NewLine
		
		MOV AH, 9 ; Configure to display string
		LEA DX, AboutTextD_ ; Configure offset
		INT 21H ; Print text
		
		JMP Exit
	
	PM_Encode: ; Set Mode_ to Encode/1
		MOV Mode_, 1
	
	PM_Decode: ; Mode_ is already set to 0, so this is just used to skip PM_Encode
	
	CALL Print_NewLine
	
	; Prompt user for input to encode/decode
		MOV AH, 9 ; Configure to display string
		LEA DX, InputPrompt_ ; Configure offset
		INT 21H
		
		MOV AH, 10 ; Configure to take string input
		LEA DX, Input_ ; Configure offset
		INT 21H ; Output -> Input_
		
		MOV DL, Input_[1] ; For some reason, I can't directly assign Input_[1] to CX.		
		
		CMP DL, 0 ; if (Input_[1] == 0) --> PM_Decode (aka prompt the user again)
		JZ PM_Decode
		
		CALL Print_NewLine
		
		CMP Mode_, 1 ; if (Mode_ == 1) --> Main_Encode
		JZ Main_Encode
		JMP Main_Decode ; else --> Main_Decode
	
	Main_Encode:
		MOV AH, 9 ; Configure to display string
		LEA DX, Input_+2 ; Configure offset
		INT 21H
		
		CALL Print_NewLine
		
		MOV DL, Input_[1]
		MOV CX, DL ; CX = Number of loops
		MOV BX, 2 ; Set BX to 2 (the actual beginning)
		
		MOV DH, 0 ; Stores last character's value
		
		EncodeLoop:
			MOV DL, Input_[BX] ; Get current char
			MOV InputValue_, DL ; Update current value to eliminate any risks associated with DL getting overwritten
			
			CMP InputValue_, 'A' ; if (DL < 'A') --> Encode_Char_Invalid
			JC Encode_Char_Invalid
			CMP InputValue_, '[' ; if (DL < '[') --> Encode_Char_Valid ('[' is the char after 'Z')
			JC Encode_Char_Valid
			
			CMP InputValue_, 'a' ; if (DL < 'a') --> Encode_Char_Invalid
			JC Encode_Char_Invalid
			CMP InputValue_, '{' ; if (DL < '{') --> Encode_Char_ToUpper ('{' is the char after 'z')
			JC Encode_Char_ToUpper
			
			JMP Encode_Char_Invalid ; Otherwise char must be above z and thus invalid
			
			Encode_Char_Invalid:
				MOV InputValue_, '@' ; Set char to '@' (just before A)
				JMP Encode_Char_Valid
			
			Encode_Char_ToUpper:
				SUB InputValue_, 32 ; Lowercase alphabet is 32 higher than upper
				JMP Encode_Char_Valid
			
			Encode_Char_Valid:
				SUB InputValue_, '@' ; '@' is zero, 'A' is one, 'B' is two, etc
				MOV DL, InputValueLast_ ; Add value of last char
				ADD InputValue_, DL
				
				CMP InputValue_, 27 ; if InputValue_ has gone past Z --> Encode_Char_Cycle
				JNC Encode_Char_Cycle
				JMP Encode_Char_NoCycle
				
				Encode_Char_Cycle: ; Loop back to '@' when 'Z' is passed 
					SUB InputValue_, 27
				
				Encode_Char_NoCycle: 
				
				MOV DL, InputValue_ ; Update InputValueLast_
				MOV InputValueLast_, DL
				ADD DL, '@' ; Add '@' back to DL
				
				INT 21h ; Display encoded char
			
			INC BX ; Move to next char
			LOOP EncodeLoop
		
		JMP Exit
	
	Main_Decode:
		MOV AH, 9 ; Configure to display string
		LEA DX, Input_+2 ; Configure offset
		INT 21H
		
		CALL Print_NewLine
		
		MOV DL, Input_[1]
		MOV CX, DL ; CX = Number of loops
		MOV BX, 2 ; Set BX to 2 (the actual beginning)
		
		MOV DH, 0 ; Stores last character's value
		
		DecodeLoop:
			MOV DL, Input_[BX] ; Get current char
			MOV InputValue_, DL ; Update current value to eliminate any risks associated with DL getting overwritten
			
			; Not enough room to keep this inside the loop
			; CMP InputValue_, ' ' ; Replace space with '@'
			; JNZ Decode_Char_No_Space ; Skip if not space
			; MOV InputValue_, '@'
			; Decode_Char_No_Space:
			
			CMP InputValue_, '@' ; if (DL < '@') --> Decode_Char_Invalid
			JC Decode_Char_Invalid
			CMP InputValue_, '[' ; if (DL < '[') --> Decode_Char_Valid ('[' is the char after 'Z')
			JC Decode_Char_Valid
			
			CMP InputValue_, 'a' ; if (DL < 'a') --> Decode_Char_Invalid
			JC Decode_Char_Invalid
			CMP InputValue_, '{' ; if (DL < '{') --> Decode_Char_ToUpper ('{' is the char after 'z')
			JC Decode_Char_ToUpper
			
			JMP Decode_Char_Invalid ; Otherwise char must be above z and thus invalid
			
			Decode_Char_Invalid:
				CALL Print_NewLine
				
				MOV AH, 9 ; Configure to display string
				LEA DX, DecodeInvalidError_ ; Configure offset
				INT 21H ; Display an error message
				
				JMP Exit ; And then exit
			
			Decode_Char_ToUpper:
				SUB InputValue_, 32 ; Lowercase alphabet is 32 higher than upper
				JMP Decode_Char_Valid
			
			Decode_Char_Valid:
				SUB InputValue_, '@' ; '@' is zero, 'A' is one, 'B' is two, etc
				MOV DL, InputValue_ ; Assign InputValue_ to DL
				
				CMP DL, InputValueLast_
				JC Decode_Char_Cycle_Up ; if InputValue_ is less than InputValueLast_ --> Decode_Char_Cycle_Up
				JMP Decode_Char_Cycle_Up_End ; else skip Decode_Char_Cycle_Up
				
				Decode_Char_Cycle_Up: ; Cycle InputValue_ through an alphabet in a loop
					ADD DL, 27
					
					CMP DL, InputValueLast_
					JC Decode_Char_Cycle_Up ; if InputValue_ is less than InputValueLast_ --> Decode_Char_Cycle_Up (cycle again)
				
				Decode_Char_Cycle_Up_End:
				
				MOV InputValue_, DL ; Save current value before it is converted into a displayable character
				SUB DL, InputValueLast_ ; Get difference between the last and current character
				ADD DL, '@' ; Add '@' Back
				
				CMP DL, '@' ; Replace '@' with space
				JNZ Decode_Char_No_At ; Skip if not '@'
				MOV DL, ' '
				Decode_Char_No_At:
				
				INT 21h ; Display decoded char
				
				MOV DL, InputValue_ ; Update InputValueLast_
				MOV InputValueLast_, DL
			
			INC BX ; Move to next char
			LOOP DecodeLoop
		
		JMP Exit
	
	Exit: ; exit to DOS
		MOV AX, 4C00H
		INT 21H
	
MAIN ENDP
END MAIN