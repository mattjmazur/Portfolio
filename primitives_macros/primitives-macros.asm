TITLE String Primitives and Macros     (Primitives-Macros.asm)

; AUTHOR:		Matthew Mazur        
;
; DESCRIPTION: 
;
;				-Asks the user for 10 integer values
;				-validates the user-input value as an integer
;				-converts each user-input into a SDWORD and stores them into memory as an array
;				-converts each value of the SDWORD array into a string and displays this back to the user
;				-calculates the sum and average of the user-entered integers and displays this back to the user
;

INCLUDE Irvine32.inc

; ---------------------------------------------------------------------------------
; NAME:				mGetString
;
; FUNCTION:			prompts user for input and stores input as a string to memory
;
; RECEIVES:
;
;					*REGISTERS*:
;						EDX, ECX, EAX
;			
;					*PARAMETERS*:
;						userPrompt		(reference)
;						BUFFER			(constant)
;						userInputSize	(reference)
;						userInput		(reference) 
;
; RETURNS: 
;
;						userInputSize	(updated with length of user-input)
;						userInput		(updated with user-input string)
;		
; ---------------------------------------------------------------------------------

mGetString MACRO userPrompt:REQ, BUFFER:REQ, userInputSize:REQ, userInput:REQ

		PUSH	EDX
		PUSH	ECX
		PUSH	EAX

		MOV		EDX, userPrompt
		CALL	WriteString
		MOV		EDX, userInput
		MOV		ECX, BUFFER
		CALL	ReadString
		MOV		EDX, userInputSize
		MOV		[EDX], EAX

		POP		EAX
		POP		ECX
		POP		EDX

ENDM

; ---------------------------------------------------------------------------------
; NAME:				mDisplayString
;
; FUNCTION:			prints a string stored at a specified memory location
;
; RECEIVES:
;					*REGISTERS*:
;						EDX
;
;					*PARAMETERS:
;						displayString	(reference)
;
; ---------------------------------------------------------------------------------

mDisplayString	MACRO	displayString:REQ

		PUSH	EDX

		MOV		EDX, displayString
		CALL	WriteString
		CALL	Crlf

		POP		EDX

ENDM

		MAX_INPUT_SIZE		=	12
		BUFFER				=	20
		NUM_USER_INPUTS		=	10
		HEX_NUM_0			=	30h
		HEX_NUM_9			=	39h
		HEX_TO_DEC			=	30h

.data
		endMessage			BYTE	"Thanks for playing!",0
		sumMessage			BYTE	"The sum of the numbers is: ",0
		avgMessage			BYTE	"The truncated average is: ",0
		displayMessage		BYTE	"You entered the following numbers:",13,10,0
		errorMessage		BYTE	"ERROR: You did not enter a signed number or your number was too big.",0
		programHeader		BYTE	"String Primitives and Macros",13,10,"Written By: Matthew Mazur",13,10,13,10,0
		programInstructions	BYTE	"Please provide 10 signed decimal integers.",13,10,"Each number needs to be small enough to fit inside a 32-bit register.",13,10,"After you have finished inputting the raw numbers I will display a list of the integers, their sum, ",13,10,"and their average value.",13,10,13,10,0
		userPrompt			BYTE	"Please enter a signed number: ",0
		tryAgain			BYTE	"Please try again: ",0
		positiveSign		BYTE	"+",0
		negSign				BYTE	"-",0
		userArrIndex		DWORD	0
		userInputSize		DWORD	?
		userArr				SDWORD	10 DUP(0)
		userArrType			DWORD	TYPE userArr
		newArrValue			SDWORD	?
		userInput			BYTE	?
		displayString		BYTE	?
		memorySDWORD		SDWORD	?
		sum					SDWORD	?
		average				SDWORD	?

.code
main PROC

		;display header and instructions to user
		mDisplayString	OFFSET programHeader
		mDisplayString	OFFSET programInstructions

		;set loop-counter to number of user-inputs
		MOV			ECX, NUM_USER_INPUTS

_callReadVal:
		;collect and validate user-input, then store each value to memory as an array named 'userArr'
		PUSH	OFFSET positiveSign
		PUSH	OFFSET newArrValue
		PUSH	OFFSET userArrType
		PUSH	OFFSET userArrIndex
		PUSH	OFFSET negSign
		PUSH	OFFSET userArr
		PUSH	OFFSET tryAgain
		PUSH	OFFSET errorMessage
		PUSH	OFFSET userPrompt
		PUSH	OFFSET userInputSize
		PUSH	OFFSET userInput
		CALL	ReadVal	
		LOOP	_callReadVal

		;set loop-counter to number of user-inputs and display 'displayMessage' to user
		CALL	Crlf
		MOV		ECX, NUM_USER_INPUTS
		mDisplayString	OFFSET displayMessage

		;point EAX to the first element of 'userArr'
		PUSH	EAX
		MOV		EAX, OFFSET userArr

_callWriteVal:
		;convert element of 'userArr' into an array of ASCII characters and display to the user
		PUSH	OFFSET displayString
		PUSH	OFFSET negSign
		PUSH	EAX
		CALL	WriteVal

		;increment EAX to point to next element of 'userArr' and loop to _callWriteVal to display the next element
		ADD		EAX, 4
		LOOP	_callWriteVal
		POP		EAX
		CALL	Crlf

		;calculate sum and average and store them in memory
		PUSH	OFFSET average
		PUSH	OFFSET sum
		PUSH	OFFSET userArrType
		PUSH	OFFSET userArr
		CALL	SumAverage

		;display sum
		mDisplayString	OFFSET sumMessage
		CALL	Crlf
		PUSH	OFFSET displayString
		PUSH	OFFSET negSign
		PUSH	OFFSET sum
		CALL	WriteVal
		CALL	Crlf

		;display average
		mDisplayString	OFFSET avgMessage
		CALL	Crlf
		PUSH	OFFSET displayString
		PUSH	OFFSET negSign
		PUSH	OFFSET average
		CALL	WriteVal
		CALL	Crlf

		;display 'endMessage'
		mDisplayString	OFFSET endMessage

	Invoke ExitProcess,0	

main ENDP

; --------------------------------------------------------------------------------- 
; NAME:					ReadVal
;  
; FUNCTION:				uses mGetString to get a user input, validates that the input is an integer,
;						then converts this string to a SDWORD and saves to 'userArr'
;
; RECEIVES: 
;		
;						*REGISTERS*:		
;							EBP, EDX, ESI, EBX, EDI, EAX, ECX
;
;						*CONSTANTS* (not pushed on stack):
;							HEX_TO_DEC
;							NUM_USER_INPUTS		
;							HEX_NUM_0		
;							HEX_NUM_9
;							MAX_INPUT_SIZE
;		
;						*PUSHED ON STACK*
;							positiveSign		(reference)	[EBP+48]
;							newArrValue			(reference)	[EBP+44]
;							userArrType			(reference) [EBP+40]
;							userArrIndex		(reference) [EBP+36]
;							negSign				(reference)	[EBP+32]
;							userArr				(reference) [EBP+28]
;							tryAgain			(reference) [EBP+24]
;							errorMessage		(reference) [EBP+20]
;							userPrompt			(reference) [EBP+16]
;							userInputSize		(reference) [EBP+12]
;							userInput			(reference) [EBP+8]
;		
; RETURNS: 
;
;							userArr				(contains new value at index passed by stack)
;							userArrIndex		(incremented to the next index of userArray to be populated)
; --------------------------------------------------------------------------------- 

ReadVal		PROC	USES EDX ESI EBX EDI EAX ECX

			LOCAL	isNeg:BYTE, isPos:BYTE

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
		mGetString	[EBP+24], BUFFER, [EBP+12], [EBP+8]
		JMP			_validateLength

_callmGetString:
		;call mGetString
		mGetString	[EBP+16], BUFFER, [EBP+12], [EBP+8]

_validateLength:
		;set loop-counter to length of userInput
		MOV			EDI, [EBP+12]
		MOV			ECX, [EDI]

		;check if length of user input is less than or equal to the max length, also check if it is 0
		MOV			EDI, MAX_INPUT_SIZE
		MOV			ESI, [EBP+12]	
		CMP			EDI, [ESI]
		JL			_error
		MOV			EDI, 0
		CMP			EDI, [ESI]
		JE			_error

		;if the length is 1 we check that it is a integer
		MOV			EDI, 1
		CMP			EDI, [ESI]
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
		MOV			isNeg, 1
		LOOP		_nextByte		;loop to ESI to point ESI to next character in userInput

_checkPositiveSign:
		;address of positiveSign in EDX
		MOV			EDX, [EBP+48]
		CMP			AL, [EDX]		;compare first character of userInput to positiveSign
		JNE			_checkIsDigit
		MOV			isPos, 1
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

		;set EAX to 0, which will be used to accumulate the numerical value of userInput
		MOV			EAX, 0

		;set ESI to address of first character of userInput
		MOV			ESI, [EBP+8]

		;check if the userInput has a negative or positive sign, if so decrement loop counter 
		CMP			isNeg, 1
		JE			_inc
		CMP			isPos, 1
		JE			_inc
		JMP			_convertToNum

_inc:
		INC			ESI			
		LOOP		_convertToNum

_convertToNum:
		
		;convert userInput to SDWORD
		CMP			EBX, EBX		;clear overflow flag and EBX
		MOV			EBX, 0
		MOV			BL, [ESI]		;move current element of userInput into BL
		INC			ESI				;point ESI to next character in userInput
		SUB			BL, HEX_TO_DEC	;subtract 30 from BL to get integer value of character

		;multiply current value in EAX by 10 and add to EBX
		;error is raised if overflow has occured, i.e. user entered too big or too small of a value to represent as a SDWORD
		MOV			EDX, 10
		IMUL		EDX
		JO			_error
		ADD			EBX, EAX
		JO			_error

		;we put our accumulated value in EAX to be multiplied by 10 during the next loop
		MOV			EAX, EBX
		LOOP		_convertToNum
		MOV			EDI, [EBP+44]	;address of newArrValue in EDI
		MOV			[EDI], EAX

		;if the entered value was negative we convert EAX to negative
		CMP			isNeg, 1
		JNE			_writeToArr
		NEG			SDWORD PTR [EDI]

_writeToArr:
		;save the SDWORD in userArr
		MOV			ESI, [EDI]		;SDWORD to be added to array in ESI
		MOV			EBX, [EBP+28]	;address of index 0 of userArr into EBX
		MOV			EDI, [EBP+36]	;address of userArrIndex in EDI
		ADD			EBX, [EDI]		;add userArrIndex to point to correct index of userArr
		MOV			ECX, ESI
		MOV			[EBX], ECX		;move new SDWORD into correct index of userArr
		MOV			EDI, [EBP+40]	;move address of userArrType to EDI
		MOV			EDI, [EDI]
		MOV			EDX, [EBP+36]	;address of userArrIndex in EDX
		ADD			[EDX], EDI		;add userArrType to userArrIndex
		MOV			isNeg, 0		;set isNeg and isPos to 0 for next input
		MOV			isPos, 0

		RET			44
ReadVal ENDP

; --------------------------------------------------------------------------------- 
; NAME:			WriteVal
;  
; FUNCTION:		Converts a numeric SDWORD value to a string of ASCII characters representing their values,
;				and displays the string to the user using mDisplayString
;
; RECEIVES: 
;
;				*REGISTERS*:
;					EDX ESI EBX EDI EAX ECX
;
;				*PUSHED TO STACK*:
;					displayString		(reference) [EBP+16]
;					negSign				(reference) [EBP+12]
;					SDWORD				(reference) [EBP+8]		*this is the address of the SDWORD that should be converted to ASCII and displayed
; --------------------------------------------------------------------------------- 

WriteVal	PROC	USES EDX ESI EDI EAX ECX
		
		LOCAL	isNeg:BYTE

		;clear registers 
		MOV			EDX, 0
		MOV			ESI, 0
		MOV			EDI, 0
		MOV			EAX, 0
		MOV			ECX, 0

		;address of 'displayString' in EDI
		MOV			EDI, [EBP+16]

		;value of 'SDWORD' into EAX
		MOV			EAX, [EBP+8]
		MOV			EAX, [EAX]

		;10 will be divisor, put this in ESI
		MOV			ESI, 10

		;ECX will be the counter of the digits in 'SDWORD'
		MOV			ECX, 0
		
		;if 'SDWORD' is negative set 'isNeg' to 1
		TEST		EAX, EAX
		JNS			_divide
		MOV			isNeg, 1
		NEG			EAX

_divide:
		;increment number of digits counted
		INC			ECX			

		CDQ
		IDIV		ESI

		;remainder is pushed to stack
		PUSH		EDX
		MOV			EDX, 0

		;if quotient is not 0, we jump to divide and keep dividing
		CMP			EAX, 0
		JE			_done
		JMP			_divide

_done:
		CMP			isNeg, 1
		JNE			_display
		
		;add 'negSign' to 'displayString'
		MOV			EDX, 0
		MOV			EAX, [EBP+12]
		MOV			DL, [EAX]
		MOV			[EDI], EDX
		INC			EDI

_display:
		POP			ESI
		ADD			ESI, HEX_TO_DEC
		MOV			[EDI], ESI
		INC			EDI
		LOOP		_display

		;add a 0-terminator to 'displayString'
		MOV			ESI, 0
		MOV			[EDI], ESI

		mDisplayString	[EBP+16]

		;revert isNeg to 0
		MOV			isNeg,0

		RET			12
WriteVal ENDP

; --------------------------------------------------------------------------------- 
; NAME:			SumAverage
;  
; FUNCTION:		Loops through the array of SDWORDS and calculates the sum and the truncated average. Stores the sum and average to memory.
;
; PRE-CONDITIONS: 
;		
;				-userArray is populated with SDWORD values
;
; RECEIVES: 
;		
;				*REGISTERS*:		
;					EBP, EDX, ESI, EBX, EDI, EAX, ECX
;
;				*CONSTANTS (not pushed to stack)*
;					MAX_INPUT_SIZE	
;					NUM_USER_INPUTS
;		
;				*PUSHED TO STACK*
;					average				(reference)	[EBP+44]
;					sum					(reference)	[EBP+40]
;					userArrType			(reference) [EBP+36]
;					userArr				(reference) [EBP+32]
;
; RETURNS:		
;				sum		(populated with the sum of the numbers in userArr)
;				average (populated with the average of the numbers in userArr)
;		
; --------------------------------------------------------------------------------- 

SumAverage	PROC	USES EBP EDX ESI EBX EDI EAX ECX

			;assign static stack-frame pointer
			MOV		EBP, ESP

			;set ECX to NUM_USER_INPUTS
			MOV		ECX, NUM_USER_INPUTS

			;set ESI to value of userArrType
			MOV		ESI, [EBP+36]
			MOV		ESI, [ESI]

			;address of first element of userArr in EDX
			MOV		EDX, [EBP+32]

			;set EBX EAX to 0
			MOV		EBX, 0
			MOV		EAX, 0

_addVal:
			;set value of userArr into EAX
			ADD		EAX, [EDX]

			;increment EDX to next value in userArr
			ADD		EDX, ESI
			LOOP	_addVal

			;store sum
			MOV		EBX, [EBP+40]
			MOV		[EBX], EAX

			;divide sum by NUM_USER_INPUTS to get the truncated average
			MOV		ESI, NUM_USER_INPUTS
			CDQ
			IDIV	ESI

			;store the truncated average
			MOV		EBX, [EBP+44]
			MOV		[EBX], EAX

			RET		20

SumAverage		ENDP

END main
