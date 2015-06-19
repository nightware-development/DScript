grammar DScript;

options
{
	language = Java;
}

ID  :	('a'..'z'|'A'..'Z'|'_') ('a'..'z'|'A'..'Z'|'0'..'9'|'_')*
    ;

INT :	'0'..'9'+
    ;

FLOAT
    :   ('0'..'9')+ '.' ('0'..'9')* EXPONENT?
    |   '.' ('0'..'9')+ EXPONENT?
    |   ('0'..'9')+ EXPONENT
    ;

COMMENT
    :   '//' ~('\n'|'\r')* '\r'? '\n' {channel=HIDDEN;}
    |   '/*'  '*/' {channel=HIDDEN;}
    ;

WS  :   ( ' '
        | '\t'
        | '\r'
        | '\n'
        ) {channel=HIDDEN;}
    ;

STRING
    :  '"' ( ESC_SEQ | ~('\\'|'"') )* '"'
    ;

CHAR:  '\'' ( ESC_SEQ | ~('\''|'\\') ) '\''
    ;

fragment
EXPONENT : ('e'|'E') ('+'|'-')? ('0'..'9')+ ;

fragment
HEX_DIGIT : ('0'..'9'|'a'..'f'|'A'..'F') ;

fragment
ESC_SEQ
    :   '\\' ('b'|'t'|'n'|'f'|'r'|'\"'|'\''|'\\')
    |   UNICODE_ESC
    |   OCTAL_ESC
    ;

fragment
OCTAL_ESC
    :   '\\' ('0'..'3') ('0'..'7') ('0'..'7')
    |   '\\' ('0'..'7') ('0'..'7')
    |   '\\' ('0'..'7')
    ;

fragment
UNICODE_ESC
    :   '\\' 'u' HEX_DIGIT HEX_DIGIT HEX_DIGIT HEX_DIGIT
    ;
    
FUNCTION:	'function';
PUBLIC	:'public';
PRIVATE :	'private';
SCOPE: PUBLIC|PRIVATE;
TYPE:	'int'
|	'string'	
|	'boolean'
|	'float'
|	'array'
;

BOOL:
	'true'
	|'false'
	|'0'
	|'1'
	;

PARAM	: 'var' ID ':' TYPE 
	| 'constant' ID	':' TYPE
	| ID
	;
	
PARAMS
	: PARAM 
	|PARAM (',' PARAM)*
	;
	
FUNCTION_DECLARE 
	:	SCOPE FUNCTION ID '(' PARAMS ')'
	;
	
VAR_DECLARE
	:	'var' ID ':' TYPE ';'
	|	'var' ID ';'
	;
	
FUNCTION_CALL
	:	ID '(' PARAMS ')'
	;
	
ARRAY_DECLARE:
	'array' ID ';'
	;
	
ARRAY_ASSIGN:
	'array' ID '[' INT ']' '=' (INT|STRING|FLOAT|CHAR|ID) ';'
	;
	
ARRAY_MULTIASSIGN:
	'array' ID '[' INT (',' INT)+ ']' '=' (INT|STRING|FLOAT|CHAR|ID (',' (INT|STRING|FLOAT|CHAR|ID))+) ';'
	;
	
VAR_ASSIGN
	: VAR_DECLARE '=' (INT|STRING|FLOAT|CHAR) ';'
	| VAR_DECLARE '=' 'new' FUNCTION_CALL ';'
	| ID '=' (INT|STRING|FLOAT|CHAR) ';'
	| ID '=' 'new' FUNCTION_CALL ';'
	;
	
CONSTANT_DECLARE:
	'constant' ID ':' TYPE ';'
	| 'constant' ID ';'
	;
	
CONSTANT_ASSIGN
	: CONSTANT_DECLARE '=' (INT|STRING|FLOAT|CHAR) ';'
	| CONSTANT_DECLARE '=' 'new' FUNCTION_CALL ';'
	| ID '=' (INT|STRING|FLOAT|CHAR) ';'
	| ID '=' 'new' FUNCTION_CALL ';' 
	;
	
FUNCTION_BLOCK
	:	FUNCTION_DECLARE '{' (FUNCTION_CALL|VAR_DECLARE|VAR_ASSIGN|CONSTANT_DECLARE|CONSTANT_ASSIGN|ARRAY_DECLARE|ARRAY_ASSIGN|ARRAY_MULTIASSIGN)+ '}'
	;
	
CLASS_BODY:
	FUNCTION_BLOCK
	;

CLASS
:	'class' ID '{' CLASS_BODY '}'
	;
	

tokens:
{
	//operators
	PLUS = '+';
	MINUS = '-';
	DIVIDE = '/';
	MULTIPLY = '*';
	ASSIGN = '=';	//4=5-1;
	ISEQUAL = '==';	//if this is equal to that
	LSHIFT = '<<'; //both bitwise operators, LSHIFT and RSHIFT, included for cryptography purposes
	RSHIFT = '>>';
	DBLPLUS = '++'; //incremental iteration
	DBLMINUS = '--'; //decremental iteration
	LESSOREQUAL = '<=';
	GREATOREQUAL = '>=';
	NOTEQUAL = '!=';
	LOGICALNOT = '!'; //Example: instead of "if(keyPressed == false)" or "if(keyPressed != true)" you could simply write "if(!keyPressed)"
	LOGICALOR = '||';
	LOGICALAND = '&&';
	BITWISEOR = '|';
	BITWISEAND = '&';
	XOR = '?';
	TYPESPEC = ':'; //Example - "public var keyPressed:boolean;"
	
	//punctuation
	DOT = '.';
	LPAREN = '(';
	RPAREN = ')';
	SEMICOLON = ';';
	LBRACE = '{';
	RBRACE = '}';
	LBRACKET = '[';
	RBRACKET = ']';
	
	//keywords
	CLASS = 'class'; //classes can be public or private
	FUNCTION = 'function';
	PUBLIC = 'public'; //can be accessed by any class
	PRIVATE = 'private'; //only accessible within its own class
	INTERFACE = 'interface'; //essentially, a collection of empty prototype functions, see comment for 'prototype' keyword
	EXTENDS = 'extends'; //class>class heirarchy, example: public class SomeClass extends ThatClass
	IMPLEMENTS = 'implements'; //interface>class heirarchy, example: public class SomeClass implements SomeInterface 
	VAR = 'var'; //variable keyword, inspired by ActionScript 3.0
	CONSTANT = 'constant'; //constant keyword, also inspired by AS 3.0
	SUPER = 'super'; //instead of writing "ParentClass.parentFunction()", simply write "super.parentFunction()"
	RETURN = 'return'; //return can be a type (usually boolean or int, such as "return 0;"), or function. Example: return Error(ErrMsg:string); 
	VOID = 'void'; //empty return type...also syntax should be "public function someFunction(args):void" and not "void public function someFunction(args)"
	TRUE = 'true'; //boolean 'true', can also be represented by 1
	FALSE = 'false'; //boolean 'false', can also be represented by 0
	NEW = 'new'; //create a new instance of a class, i.e. "public var rect:Rectangle = new Rectangle(sizeX, sizeY)"
	IF = 'if'; //if-conditional
	ELSE = 'else';
	WHILE = 'while'; //unlike other languages, there is grammatical "do" command, instead the "do" is implied
	FOR = 'for'; //the seemingly universal for-loop
	PROTOTYPE = 'prototype'; //Same as "abstract" in other languages, i.e. "prototype function someFunction(args_1...args_N);"
	REST = "...rest"; //this is what would be used in the case of a function which could take an undetermined amount of arguments, however one or two arguments must be specified. Example: public function Draw(x:int, y:int, ...rest)
	ENUM = "enum"; //Usage: public enum Color {color1, color2...colorN};
};
