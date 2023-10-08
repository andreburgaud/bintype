;; Binary type (32bit, 64bit...) of an executable file on Windows (does not work for DLL)

(load "color.lsp")

;; Constants
(constant 'APP-NAME    "bintype")
(constant 'APP-VERSION "1.3.0")
(constant 'APP-URL     "https://www.burgaud.com")

(define (get-margin str (width 80))
  (+ (/ (- width (length str)) 2) (length str)))

(define (app-header)
  (setq title (string APP-NAME " " APP-VERSION))
  (setq copyright "Copyright (C) 2018-2023 Burgaud.com")
  (setq author "Andre Burgaud")
  (color:println-ok (format (string "%" (get-margin title) "s") title))
  (color:println-ok (format (string "%" (get-margin copyright) "s") copyright))
  (color:println-ok (format (string "%" (get-margin author) "s") author)))

(define (usage)
  (app-header)
  (color:println-info "USAGE:")
  (println "  " APP-NAME " [FLAGS] <executable>")
  (println)
  (color:println-info "FLAGS:")
  (println "  --help      Display this help")
  (println "  --version   Show application version")
  (println)
  (color:println-info "EXAMPLES:")
  (println "  " APP-NAME " newlisp.exe")
  (println "  Note   : Does not work for DLLs"))

(define (version)
  (color:println-info (string APP-NAME " " APP-VERSION)))

;; Command line parameters
;; When built as a standalone script, (main-args 1) is the first parameter.
;; When executed via the interpreter (newlisp bintype.lsp), (main-args 1) is the script (bintype.lsp)
(if (ends-with (main-args 0) "bintype|bintype.exe" 1)
  (setq i 1)
  (setq i 2))

(setq app-name (main-args i)) ; executable name

(unless (> (length app-name) 0)
  (begin
    (usage)
    (exit 1)))

;; -h does not work when the runtime is embedded (exe) as with -h
;; newlisp does not initiate anything (no init.lsp) and goes straight to its usage
(if-not (nil? (find app-name '("--help")))
  (begin
    (usage)
    (exit)))

(if-not (nil? (find app-name '("--version")))
  (begin
    (version)
    (exit)))

(if (starts-with app-name "-")
  (begin
    (color:println-err (string "Unexpected option " app-name ". Try " APP-NAME " --help."))
    (exit 1)))

(app-header)
(println)

(if-not (file? app-name)
  (begin
    (color:print-intense app-name)
    (print ": ")
    (color:println-err "file not found.")
    (exit 1)))

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
      (setq err (w32-get-last-error))
      (if (= err 193)
        (throw (list "DLL" err)))
      (if err
        (throw (list "ERR" err))
        (throw (list "ERR" "not executable, or unexepcted error"))))))
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

(color:print-intense app-name)
(print ": ")
(catch (get-bin-type app-name) 'res)
(set 'err (match '("ERR" ?) res))
(if err
  (color:println-err (err 0)))
(set 'dll (match '("DLL" ?) res))
(if dll
  (println (format (string APP-NAME " version " APP-VERSION " can't process DLL's (error %d)") (dll 0)))
  (println res))

(exit)
