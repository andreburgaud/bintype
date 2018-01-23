;; Build an executable from a given newLISP script

(load "color.lsp")

(constant 'MAIN-EXE     "bintype.exe")
(constant 'MAIN-LSP     "bintype.lsp")
(constant 'TEMP-LSP     "temp.lsp")
(constant 'NEWLISP-EXE  "newlisp.exe")

(define (newlisp-missing)
  (color:println-err "newLISP was not found in PATH")
  (color:println-err "You need to install newLISP from http://www.newlisp.org")
  (exit))

;; Validate presence of newLISP
(setq newlisp-cmd (append NEWLISP-EXE " -v"))
(setq res (! newlisp-cmd))
(if-not
  (= 0 res) (newlisp-missing)
  (color:println-ok "Good: newLISP was found in PATH!"))

;; Clean up empty lines or comments
(define (process-line line out-file)
  (and
    (not (starts-with line ";"))
    (> (length (trim line)) 0)
    (write-line out-file line)))

;; Write the module content.
;; Assume that no loads are in the module contents
;; to avoid addition of duplicate modules
(define (write-module module out-file , in-file)
  (set 'in-file (open module "read"))
  (while (read-line in-file)
    (process-line (current-line) out-file))
  (write-line out-file "(context MAIN)")
  (close in-file))

;; Read the MAIN-LSP
;; replace all the load call by the content of each module
;; terminate each module with (context MAIN)
;; remove all comments and empty lines
(define (combine-sources main-file temp-file , in-file out-file)
  (set 'out-file (open temp-file "write"))
  (set 'in-file (open main-file "read"))
  (while (read-line in-file)
    (if (!= (regex "(load \"(.*)\")" (current-line)) nil)
      (write-module ($ 2) out-file)
      (process-line (current-line) out-file)))
  (close in-file)
  (close out-file))

(println "Building " MAIN-EXE "...")
(if (file? MAIN-EXE) (delete-file MAIN-EXE))
(if (file? TEMP-LSP) (delete-file TEMP-LSP))
(combine-sources MAIN-LSP TEMP-LSP)
(setq cmd (append NEWLISP-EXE " -x " TEMP-LSP " " MAIN-EXE))
(setq res (! cmd))
(if-not
  (= 0 res)
    (color:println-err "An error occurred during the build.")
    (color:println-ok "The build was successful!"))
(exit)
