; A simple cipher

TITLE CIPHER
.MODEL SMALL
.STACK 100H


.DATA
Mode_ DB 0 ; 0 = Decode, 1 = Encode
ModePrompt_ DB "[E]ncode/[D]ecode: $"
ModePromptError_ DB "Invalid input!$"
InputPrompt_ DB "Input: $"
Input_ DB 51,0,52 dup("$") ; Init input variable with max size of 50
InputValue_ DB 0 ; Stores current character's value
InputValueLast_ DB 0 ; Stores last character's value


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
		
		MOV AH, 8 ; Configure to take char input
		INT 21H ; Output -> AL
		
		CMP AL, 'E' ; if (AL == 'E') --> PM_Encode
		JZ PM_Encode
		CMP AL, 'e' ; if (AL == 'e') --> PM_Encode
		JZ PM_Encode
		
		CMP AL, 'D' ; if (AL == 'D') --> PM_Decode
		JZ PM_Decode
		CMP AL, 'd' ; if (AL == 'd') --> PM_Decode
		JZ PM_Decode
		
		CALL Print_NewLine
		
		MOV AH, 9 ; Configure to display string
		LEA DX, ModePromptError_ ; Configure offset
		INT 21H
		
		CALL Print_NewLine
		
		JMP Prompt_Mode ; Prompt user again
		
	
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
		JMP Exit
	
	Exit: ; exit to DOS
		MOV AX, 4C00H
		INT 21H
	
MAIN ENDP
END MAIN