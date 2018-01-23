;; Binary type (32bit, 64bit...) of an executable file on Windows (does not work for DLL)

(load "color.lsp")

;; Constants
(constant 'APP-VERSION "1.0.0")
(constant 'APP-URL     "https://www.burgaud.com")

(println)

(define (get-margin str (width 80))
  (+ (/ (- width (length str)) 2) (length str)))

(define (app-header)
  (setq title (string "Bintype " APP-VERSION))
  (setq copyright "Copyright (C) 2018 Burgaud.com")
  (setq author "Andre Burgaud")
  (color:println-ok (format (string "%" (get-margin title) "s") title))
  (color:println-ok (format (string "%" (get-margin copyright) "s") copyright))
  (color:println-ok (format (string "%" (get-margin author) "s") author)))

(define (usage)
  (color:println-info "Usage:")
  (println "  bintype <executable_name>")
  (println)
  (println "  Example: bintype newlisp.exe")
  (println "  Note   : Does not work for DLLs"))

(app-header)
(println)

;; Command line parameters
;; When built as a standalone script, (main-args 1) is the first parameter.
;; When executed via the interpreter (newlisp bintype.lsp), (main-args 1) is the script (bintype.lsp)
(if (= (main-args 0) "bintype")
  (setq i 1)
  (setq i 2))

(setq app-name (main-args i)) ; executable name

(unless (> (length app-name) 0)
  (begin
    (usage)
    (exit)))

(if-not (file? app-name)
  (begin
    (color:println-err (append "Error: File " app-name " does not exist."))
    (exit)))

;; http://msdn.microsoft.com/en-us/library/ms679360(v=vs.85).aspx
;; DWORD WINAPI GetLastError(void);
(import "kernel32.dll" "GetLastError")
(define (w32-get-last-error)
  (GetLastError))

;; http://msdn.microsoft.com/en-us/library/aa364819%28VS.85%29.aspx
;;BOOL WINAPI GetBinaryType(
;;  __in   LPCTSTR lpApplicationName,
;;  __out  LPDWORD lpBinaryType
;;);
;; GetBinaryType returns 1 if success, otherwise 0
;; http://msdn.microsoft.com/en-us/library/ms681382(v=vs.85).aspx
;; ERROR_BAD_EXE_FORMAT 193 (0xC1) returned by GetLastError if file is a DLL
(import "kernel32.dll" "GetBinaryTypeA")
(define (w32-get-binary-type file-name)
  (setq lpBinaryType 0)
  (if (= (GetBinaryTypeA file-name (address lpBinaryType)) 0) (
    (begin
      (setq error (w32-get-last-error))
      (if (= error 193)
        (throw (format "Error: File %s is a DLL" file-name))
        (throw (format "Error: Could not process file %s (error %d)" file-name error))))))
  lpBinaryType)

(define (get-bin-type file-name)
  (setq lst-bin-type '(
    "32-bit Windows-based application"
    "MS-DOS-based application"
    "16-bit Windows-based application"
    "PIF file that executes an MS-DOS-based application"
    "POSIX-based application"
    "16-bit OS/2-based application"
    "64-bit Windows-based application"))
  (lst-bin-type (w32-get-binary-type file-name)))

(catch (get-bin-type app-name) 'res)
(if (starts-with res "Error:")
  (color:println-err res)
  begin (
    (color:print-intense app-name)
    (println ": " res)))

;; (if-not 
;;   (catch (println (format "%s: %s" app-name (get-bin-type app-name))) 'error)
;;   ;(color:println-err ((parse error "\n") 0)))
;;   (color:println-err error ))

(exit)
