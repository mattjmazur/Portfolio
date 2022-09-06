TITLE String Primitives and Macros     (Primitives-Macros.asm)

; Author: Matthew Mazur
; Last Modified: 8/12/22
; OSU email address: mazurma@oregonstate.edu
; Course number/section:   CS271 Section 400
; Project Number: 6                Due Date: 8/12/22
; Description: Asks the user for 10 integer values, validates the user-input, converts the user-input values into SDWORDS, then back
;				to an array of string values. Then calculates the sum and average of the user-entered numbers and displays them to the user.

INCLUDE Irvine32.inc

; ---------------------------------------------------------------------------------
; Name: mGetString
;
;		Prompts user for input and stores input as a string to memory
;
; Preconditions: none
;
; Receives:
;		*registers*:
;			
;			EDX, ECX, EAX
;			
;		*parameters*:
;
;			userPrompt		(reference)
;			maxStrLen		(max length of input string, value)
;			userInputSize	(reference)
;			userInput		(reference) 
;
; returns: 
;
;			userInputSize		(updated with length of user-input)
;			userInput			(updated with user-input string)
;		
; ---------------------------------------------------------------------------------

mGetString MACRO userPrompt:REQ, maxStrLen:REQ, userInputSize:REQ, userInput:REQ

		PUSH	EDX
		PUSH	ECX
		PUSH	EAX

		MOV		EDX, userPrompt
		CALL	WriteString
		MOV		EDX, userInput
		MOV		ECX, maxStrLen
		CALL	ReadString
		MOV		EDX, userInputSize
		MOV		[EDX], EAX

		POP		EAX
		POP		ECX
		POP		EDX

ENDM

; ---------------------------------------------------------------------------------
; Name: mDisplayString
;
;		Prints a string stored at a specified memory location
;
; Preconditions: none
;
; Receives:
;		
;		EDX
;		displayString (reference to string to display)
;
; returns: none
;
; ---------------------------------------------------------------------------------

mDisplayString	MACRO	displayString:REQ

		PUSH	EDX

		MOV		EDX, displayString
		CALL	WriteString
		CALL	Crlf

		POP		EDX

ENDM

		SDWORD_MAX_VAL		=	2147483647
		SDWORD_MIN_VAL		=	-2147483648
		MAX_USER_INPUT		=	13			;max input is 11
		TOO_BIG_INPUT_SIZE	=	12
		NUM_USER_INPUTS		=	10
		HEX_NUM_0			=	30h
		HEX_NUM_9			=	39h
		NUM_1				=	1
		NUM_10				=	10
		HEX_TO_DEC			=	30h
		ZERO				=	0
		ONE					=	1 


.data
		endMessage			BYTE	"Thanks for playing!",0
		sumMessage			BYTE	"The sum of the numbers is: ",0
		avgMessage			BYTE	"The truncated average is: ",0
		displayMessage		BYTE	"You entered the following numbers:",13,10,0
		userArrIndex		DWORD	0
		positiveSign		BYTE	"+",0
		negSign				BYTE	"-",0
		tryAgain			BYTE	"Please try again: ",0
		errorMessage		BYTE	"ERROR: You did not enter a signed number or your number was too big.",0
		programHeader		BYTE	"Project 6: String Primitives and Macros",13,10,"Written By: Matthew Mazur",13,10,13,10,0
		programInstructions	BYTE	"Please provide 10 signed decimal integers.",13,10,"Each number needs to be small enough to fit inside a 32-bit register.",13,10,"After you have finished inputting the raw numbers I will display a list of the integers, their sum, ",13,10,"and their average value.",13,10,13,10,0
		userPrompt			BYTE	"Please enter a signed number: ",0
		userInputSize		DWORD	?
		userArr				SDWORD	10 DUP(0)
		userInput			BYTE	13 DUP(0)
		userArrType			DWORD	TYPE userArr
		newArrValue			SDWORD	?

.code
main PROC

		;display programHeader
		PUSH		OFFSET programInstructions
		PUSH		OFFSET programHeader
		CALL		DisplayHeader

		;set loop-counter to NUM_USER_INPUTS 
		MOV			ECX, NUM_USER_INPUTS

_callReadVal:
		;loop through ReadVal 'NUM_USER_INPUTS' times, with resultant array of SDWORDs in userArr
		PUSH	OFFSET positiveSign
		PUSH	OFFSET newArrValue
		PUSH	OFFSET userArrType
		PUSH	OFFSET userArrIndex
		PUSH	NUM_10
		PUSH	OFFSET negSign
		PUSH	OFFSET userArr
		PUSH	OFFSET tryAgain
		PUSH	OFFSET errorMessage
		PUSH	OFFSET userPrompt
		PUSH	OFFSET userInputSize
		PUSH	OFFSET userInput
		CALL	ReadVal	
		LOOP	_callReadVal

		;set loop-counter to NUM_USER_INPUTS
		MOV		ECX, NUM_USER_INPUTS
		;add whitespace
		CALL	Crlf

_callWriteVal:
		;loop through WriteVal 'NUM_USER_INPUTS' times, displaying the SDWORD as a string of ASCII characters for each pass
		PUSH	OFFSET userArrType
		PUSH	OFFSET displayMessage
		PUSH	OFFSET userArr

		CALL	WriteVal
		LOOP	_callWriteVal

		;calculate and display sum and average of userArr values
		PUSH	OFFSET sumMessage
		PUSH	OFFSET avgMessage
		PUSH	OFFSET userArrType
		PUSH	OFFSET userArr
		CALL	Average

		;display endMessage
		PUSH	OFFSET endMessage
		CALL	FinalMessage

	Invoke ExitProcess,0	

main ENDP

; --------------------------------------------------------------------------------- 
; Name: DisplayHeader
;  
;		Displays program header
; 
; Preconditions: none
;
; Postconditions: none
;
; Receives: 
;		
;		*registers*:		
;			
;			EDX, EBP
;		
;		*pushed on stack*
;
;			programHeader		(reference) 
;			programInstructions (reference)
;		
; Returns: none
; --------------------------------------------------------------------------------- 

DisplayHeader PROC	USES EBP EDX

	;assign static stack-frame pointer
	MOV		EBP, ESP

	;display programHeader
	MOV		EDX, [EBP+12]
	CALL	WriteString
	MOV		EDX, [EBP+16]
	CALL	WriteString

	;return to calling-procedure
	RET		8

displayHeader ENDP

; --------------------------------------------------------------------------------- 
; Name: ReadVal
;  
;		Uses mGetString to get a user input, validates that input can be read as a SDWORD,
;		continues to prompt user until a valid string is entered, then converts this string to a 
;		SDWORD and saves to userArr
;
; Preconditions: none
; 
; Postconditions: none
;
; Receives: 
;		
;		*registers*:		
;
;			EBP, EDX, ESI, EBX, EDI, EAX, ECX
;
;		*constants, not pushed to stack*
;			
;			HEX_TO_DEC
;			MAX_USER_INPUT	
;			NUM_USER_INPUTS
;			NUM_1			
;			HEX_NUM_0		
;			HEX_NUM_9
;			TOO_BIG_INPUT_SIZE
;			ZERO
;			ONE
;		
;		*pushed on stack*
;
;			positiveSign		(reference)	[EBP+52]
;			newArrValue			(reference)	[EBP+48]
;			userArrType			(reference) [EBP+44]
;			userArrIndex		(reference) [EBP+40]
;			NUM_10				(constant, pushed on stack as value) [EBP+36]
;			negSign				(reference)	[EBP+32]
;			userArr				(reference) [EBP+28]
;			tryAgain			(reference) [EBP+24]
;			errorMessage		(reference) [EBP+20]
;			userPrompt			(reference) [EBP+16]
;			userInputSize		(reference) [EBP+12]
;			userInput			(reference) [EBP+8]
;		
; Returns: 
;
;			userArr				(contains new value at index passed by stack)
;			userArrIndex		(incremented to the next index of userArray to be populated)
; --------------------------------------------------------------------------------- 

ReadVal		PROC	USES EDX ESI EBX EDI EAX ECX

			LOCAL	isNeg:BYTE

		JMP			_callmGetString

_error:	
		;clear registers 
		MOV			EDX, 0
		MOV			ESI, 0
		MOV			EBX, 0
		MOV			EDI, 0
		MOV			EAX, 0
		MOV			ECX, 0

		;displays errorMessage, then calls mGetString with tryAgain as the user-prompt
		MOV			EDX, [EBP+20]
		CALL		WriteString
		CALL		Crlf

		mGetString	[EBP+24], MAX_USER_INPUT, [EBP+12], [EBP+8]

		JMP			_validateLength

_callmGetString:
		;call mGetString
		mGetString	[EBP+16], MAX_USER_INPUT, [EBP+12], [EBP+8]

_validateLength:
		;set loop-counter to length of userInput
		MOV			EDI, [EBP+12]
		MOV			ECX, [EDI]

		;check if length of user input is less than or equal to the max length, also check if it is 0
		MOV			EDI, TOO_BIG_INPUT_SIZE
		MOV			ESI, [EBP+12]	;userInputSize in ESI
		CMP			EDI, [ESI]
		JE			_error
		MOV			EDI, ZERO
		CMP			EDI, [ESI]
		JE			_error

		;if the length is 1 we check that it is a integer
		CMP			EDI, ONE
		JE			_oneEntry
		JMP			_validateNeg

_oneEntry:
		;set ESI to first character of userInput
		MOV			ESI, [EBP+8]
		LODSB

		;check if value in AL is between HEX_NUM_0 and HEX_NUM_9, if it is then the value is valid and we loop to the next character in userInput
		CMP			AL, HEX_NUM_0
		JL			_error
		CMP			AL, HEX_NUM_9
		JG			_error

_validateNeg:
		;set ESI to first character of userInput
		MOV			ESI, [EBP+8]	
		LODSB					;least-significant byte of user string is put into AL

		;check if least-significant byte of userInput is a negative sign, if it is set isNeg to NUM_1
		MOV			EDX, [EBP+32]	;address of negSign in edx
		CMP			AL, [EDX]		;compare first character of userInput to negSign
		JNE			_checkPositiveSign
		MOV			isNeg, NUM_1
		LOOP		_nextByte		;loop to ESI to point ESI to next character in userInput

_checkPositiveSign:
		;address of positiveSign in EDX
		MOV			EDX, [EBP+52]
		CMP			AL, [EDX]		;compare first character of userInput to positiveSign
		JNE			_checkIsDigit
		LOOP		_nextByte		;loop to _nextByte to point ESI to next character in userInput

_nextByte:
		;next-byte is put in AL, ESI is decremented
		LODSB

_checkIsDigit:
		;check if value in AL is between HEX_NUM_0 and HEX_NUM_9, if it is then the value is valid and we loop to the next character in userInput
		CMP			AL, HEX_NUM_0
		JL			_error
		CMP			AL, HEX_NUM_9
		JG			_error
		LOOP		_nextByte

_validated:
		;at this point userInput has been validated, so we store the string as it's numerical value

		;set loop-counter to length of userInput
		MOV			EDI, [EBP+12]
		MOV			ECX, [EDI]

		;set EAX to 0 and EBX to 0, which will be used to accumulate the numerical value of userInput
		MOV			EAX, 0
		MOV			EBX, 0

		;set ESI to address of first character of userInput
		MOV			ESI, [EBP+8]

		;check if the userInput was negative, if so increment ESI to next element in the userInput
		CMP			isNeg, NUM_1
		JNE			_convertToNum
		INC			ESI			
		LOOP		_convertToNum

_convertToNum:
		;move current element of userInput into BL
		MOV			BL, [ESI]	

		;point ESI to next character in userInput
		INC			ESI			

		;subtract 30 from BL to get integer value of character
		SUB			BL, HEX_TO_DEC		

		;multiply current value in EAX by 10 and add to EBX
		MUL			DWORD PTR [EBP+36]
		ADD			EBX, EAX

		;we put our accumulated value in EAX to be multiplied by 10 during the next loop
		MOV			EAX, EBX
		LOOP		_convertToNum

		MOV			EDI, [EBP+48]	;address of newArrValue in EDI
		MOV			[EDI], EAX

		;if the entered value was negative we convert EAX to negative
		CMP			isNeg, NUM_1
		JNE			_writeToArr
		NEG			SDWORD PTR [EDI]

_writeToArr:
		MOV			ESI, [EDI]		;SDWORD to be added to array in ESI
		MOV			EBX, [EBP+28]	;address of index 0 of userArr into EBX
		MOV			EDI, [EBP+40]	;address of userArrIndex in EDI
		ADD			EBX, [EDI]		;add userArrIndex to point to correct index of userArr
		MOV			ECX, ESI
		MOV			[EBX], ECX		;move new SDWORD into correct index of userArr
		MOV			EDI, [EBP+44]	;move address of userArrType to EDI
		MOV			EDI, [EDI]
		MOV			EDX, [EBP+40]	;address of userArrIndex in EDX
		ADD			[EDX], EDI		;add userArrType to userArrIndex

		MOV			isNeg, 0		;set isNeg to 0 for next input

		RET			48

ReadVal ENDP

; --------------------------------------------------------------------------------- 
; Name: WriteVal
;  
;		Converts an array of numeric SDWORD values to a string of ASCII characters representing their values,
;		and displays the output to the user using mDisplayString
; 
; Preconditions: 
;		
;		userArr has an array of SWORD values
; 
; Postconditions:
;		
;		none
;
; Receives: 
;		*registers*:
;		
;			EDX ESI EBX EDI EAX ECX
;
;		*constants, not pushed to stack*:
;			
;			NUM_USER_INPUTS
;
;		*pushed to stack*:
;
;			newArrValue			(reference) [EBP+20]
;			userArrType			(reference) [EBP+16]
;			displayMessage		(reference)	[EBP+12]
;			userArr				(reference) [EBP+8]
;
;
;		
; Returns: 
; --------------------------------------------------------------------------------- 

WriteVal	PROC	USES EDX ESI EBX EDI EAX ECX
		
		LOCAL	isNeg:BYTE

		;clear registers 
		MOV			EDX, 0
		MOV			ESI, 0
		MOV			EBX, 0
		MOV			EDI, 0
		MOV			EAX, 0
		MOV			ECX, 0

		;display displayMessage
		MOV			EDX, [EBP+12]
		CALL		WriteString
		CALL		Crlf

		;set direction flag to decrement
		;STD

		;for first index EAX is NUM_USER_INPUTS - 1 
		MOV			EAX, NUM_USER_INPUTS
		DEC			EAX
		JMP			_displayIndex

		;decrement EAX by userArrType
		MOV			ESI, [EBP+16]
		MOV			ESI, [ESI]
		SUB			EAX, ESI

_displayIndex:
		;set EAX to value of current byte
		MOV			EAX, userArr[EAX]

		;add 30 to convert to ASCII
		ADD			EAX, 30d


		;set EDX to address of newArrValue
		MOV			EDX, [EBP+20]
		;MOV			

		;add 30 to get the decimal value
		ADD			ESI, 30d




		RET			12

WriteVal ENDP

; --------------------------------------------------------------------------------- 
; Name: Average
;  
;		Loops through the array of SDWORDS and calculates the sum and the truncated average. Then displays these values to the
;		user.
;
; Preconditions: 
;		
;		userArray is populated with SDWORD values
;
; 
; Postconditions: none
;
; Receives: 
;		
;		*registers*:		
;
;			EBP, EDX, ESI, EBX, EDI, EAX, ECX
;
;		*constants, not pushed to stack*
;
;			MAX_USER_INPUT	
;			NUM_USER_INPUTS
;		
;		*pushed on stack*
;
;			sumMessage			(reference) [EBP+20]
;			avgMessage			(reference) [EBP+16]
;			userArrType			(reference) [EBP+12]
;			userArr				(reference) [EBP+8]
;		
; Returns: 
;
;			none
;
; --------------------------------------------------------------------------------- 
Average		PROC	USES EDX ESI EBX EDI EAX ECX

			LOCAL	sum:SDWORD

			;set ECX to NUM_USER_INPUTS
			MOV		ECX, NUM_USER_INPUTS

			;set ESI to value of userArrType
			MOV		ESI, [EBP+12]
			MOV		ESI, [ESI]

			;set EBX EAX to 0
			MOV		EBX, 0
			MOV		EAX, 0

_addVal:
			;set first value of userArr into EAX
			ADD		EAX, userArr[EBX]

			;increment EBX to next value in userArr
			ADD		EBX, ESI
			LOOP	_addVal

			;display the sum
			MOV		EDX, [EBP+20]
			CALL	WriteString
			CALL	WriteInt
			CALL	Crlf

			;divide sum by NUM_USER_INPUTS to get the truncated average
			MOV		ESI, NUM_USER_INPUTS
			CDQ
			IDIV	ESI

			;display the ave
			MOV		EDX, [EBP+16]
			CALL	WriteString
			CALL	WriteInt
			CALL	Crlf

			RET		16



Average		ENDP

; --------------------------------------------------------------------------------- 
; Name: FinalMessage
;  
;		Displays the endMessage
;
; Preconditions: none
; 
; Postconditions: none
;
; Receives: 
;		
;		*registers*:		
;
;			EDX
;		
;		*pushed on stack*
;
;			endMessage			(reference) [EBP+8]
;		
; Returns: 
;
;			none
;
; --------------------------------------------------------------------------------- 

FinalMessage		PROC USES EDX

	;assign static stack-frame pointer
	MOV		EBP, ESP

	;display endMessage
	MOV		EDX, [EBP+8]
	CALL	WriteString

	RET		4

FinalMessage	ENDP


END main
