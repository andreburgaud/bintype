; $Id: color.lsp 552 2009-08-06 23:27:15Z andre $

(context 'color)

(import "kernel32.dll" "GetStdHandle")
(import "kernel32.dll" "SetConsoleTextAttribute")
(import "kernel32.dll" "GetConsoleScreenBufferInfo")

;; winbase.h
(constant 'STD_INPUT_HANDLE  -10)
(constant 'STD_OUTPUT_HANDLE -11)
(constant 'STD_ERROR_HANDLE  -12)

;; wincon.h
(constant 'FOREGROUND_BLACK     0x0000)
(constant 'FOREGROUND_BLUE      0x0001)
(constant 'FOREGROUND_GREEN     0x0002)
(constant 'FOREGROUND_CYAN      0x0003)
(constant 'FOREGROUND_RED       0x0004)
(constant 'FOREGROUND_MAGENTA   0x0005)
(constant 'FOREGROUND_YELLOW    0x0006)
(constant 'FOREGROUND_GREY      0x0007)
(constant 'FOREGROUND_INTENSITY 0x0008) ; foreground color is intensified.

(constant 'BACKGROUND_BLACK     0x0000)
(constant 'BACKGROUND_BLUE      0x0010)
(constant 'BACKGROUND_GREEN     0x0020)
(constant 'BACKGROUND_CYAN      0x0030)
(constant 'BACKGROUND_RED       0x0040)
(constant 'BACKGROUND_MAGENTA   0x0050)
(constant 'BACKGROUND_YELLOW    0x0060)
(constant 'BACKGROUND_GREY      0x0070)
(constant 'BACKGROUND_INTENSITY 0x0080) ; background color is intensified.

(define (get-std-handle handle)
  (GetStdHandle handle))

(define (get-std-output-handle)
  (get-std-handle STD_OUTPUT_HANDLE))

;; Console Screen Buffer Info (CSBI) structure
; typedef struct _COORD {
;     SHORT X;
;     SHORT Y;
; } COORD, *PCOORD;

; typedef struct _SMALL_RECT {
;     SHORT Left;
;     SHORT Top;
;     SHORT Right;
;     SHORT Bottom;
; } SMALL_RECT, *PSMALL_RECT;

; typedef struct _CONSOLE_SCREEN_BUFFER_INFO {
;     COORD dwSize;
;     COORD dwCursorPosition;
;     WORD  wAttributes;
;     SMALL_RECT srWindow;
;     COORD dwMaximumWindowSize;
; } CONSOLE_SCREEN_BUFFER_INFO, *PCONSOLE_SCREEN_BUFFER_INFO;

(constant 'SIZEOF_CBSI 22)
(constant 'WATTRIBUTE_OFS 4)
(define (unpack-cbsi data)
  (unpack "u u u u u u u u u u u" data))

; 4 is the offset of wAttributes in the structure
(define (get-text-attr)
  (setq cbsi (dup "\000" SIZEOF_CBSI))
  (GetConsoleScreenBufferInfo (get-std-output-handle) cbsi)
  ((unpack-cbsi cbsi) WATTRIBUTE_OFS))

(define (color:color colors-attr)
  (SetConsoleTextAttribute (get-std-output-handle) colors-attr))

(setq default_colors (get-text-attr))
(setq default_bg (& default_colors 0x0070))
(setq default_fg (& default_colors 0x0007))
; Foreground same as background. Used to input password.
(setq password_fg (>> default_bg 4))

;; Helper functions
(define (default-colors)
  (color default_colors))

(define (password-color)
  (color hidden_fg))

(define (print-color color-attr msg)
    (color color-attr)
    (print msg)
    (color:default-colors))

(define (println-color color-attr msg)
    (color color-attr)
    (println msg)
    (color:default-colors))

(constant 'RED (| color:FOREGROUND_RED color:FOREGROUND_INTENSITY))
(define (println-err msg)
  (println-color RED msg))

(define (println-ok msg)
  (println-color FOREGROUND_GREEN msg))

(constant 'YELLOW (| color:FOREGROUND_YELLOW color:FOREGROUND_INTENSITY))
(define (println-info msg)
  (println-color YELLOW msg))

(define (print-intense msg)
  (print-color YELLOW msg))