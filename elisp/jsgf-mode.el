;; Header

;;; jsgf-mode --- Summary

;;; Commentary:

;;; Code:
(defvar jsgf-mode-hook nil)

(defgroup jsgf nil
  "JSGF mode."
  :group 'jsgf-mode
  :prefix "jsgf-")

(defcustom jsgf-mode-map (let ((map (make-sparse-keymap)))
                           (define-key map "\C-j" 'newline-and-indent)
                           map)
  "Keymap for `jsgf-mode'."
  :group 'jsgf-mode
  :type 'list)

(defcustom jsgf-tab-width 4
  "Default amount of indentation spaces."
  :type 'integer
  :group 'jsgf-mode)

(defconst jsgf-keywords '("import" "grammar" "JSGF")
  "Keywords for syntax highlighting.")

(defconst jsgf-constants '("public")
  "Constants for syntax highlighting.")

;;
;; Indentation
;;


  (defun jsgf-goto-last-relevant-indent-sign ()
    "There might be multiple indent signs in one row like the following example:

    public <test> = /1/ foo

  This function jumps to the first of those from the beginning of the line.  In
  the example above, this would be the equal sign."
    (search-backward-regexp jsgf-indent-regex)
    (beginning-of-line)
    (search-forward-regexp jsgf-indent-regex)
    (left-char))

  (defmacro jsgf-def-was-last-sign-p (sign character)
    "Defines a function named JSGF-<SIGN>-WAS-LAST-SIGN-P.

  This function returns a predicate if the last relevant sign was a CHARACTER and
  nothing followed inside that line."
    `(defun ,(intern (format "jsgf-%s-was-last-sign-p" sign)) ()
       ,(format "Checks if the last sign was \"%s\" only followed by an empty string." sign)
       (save-excursion
         (search-backward-regexp jsgf-indent-regex)
         (if (char-equal (char-after) ,character)
             (progn
               (forward-char)
               (skip-syntax-forward "-")
               (= (point-at-eol) (point)))
           nil))))

  (defmacro jsgf-def-was-last-p (sign character)
    "Defines a function named JSGF-<SIGN>-WAS-LAST-P.

  This function returns a predicate if the last relevant sign was a CHARACTER."
    `(defun ,(intern (format "jsgf-%s-was-last-p" sign)) ()
       ,(format "Checks if the last sign was an %s sign." sign)
       (let ((last-sign-p (save-excursion
                            (jsgf-goto-last-relevant-indent-sign)
                            (and (char-equal (char-after) ,character))))
             (is-first-sign (save-excursion
                              (jsgf-goto-last-relevant-indent-sign)
                              (skip-syntax-backward "-")
                              (= (point-at-bol) (point)))))
         (and last-sign-p is-first-sign))))

  (jsgf-def-was-last-sign-p equal ?=)
  (jsgf-def-was-last-sign-p semicolon ?\;)

  (jsgf-def-was-last-p equal ?=)
  (jsgf-def-was-last-p pipe ?|)
  (jsgf-def-was-last-p slash ?/)

  (defun jsgf-had-equal-sign-p ()
    "Check if the last sign was a equal sign."
    (save-excursion
      (jsgf-goto-last-relevant-indent-sign)
      (char-equal (char-after) ?=)))

  (defun this-line-starts-with-slash-p ()
    "Return predicate if this line beginns with a \"/\"-sign."
    (save-excursion
      (beginning-of-line)
      (looking-at "^[ \t]+/")))

  (defun jsgf-non-empty-line-between-here-and-equal-p ()
    "Check if there is something between this and the last line with an equal sign."
    (let ((current-line-number (line-number-at-pos))
          (equal-sign-line-number (save-excursion
                                    (jsgf-goto-last-relevant-indent-sign)
                                    (line-number-at-pos))))
      (< 0 (- current-line-number equal-sign-line-number 1))))

  (defun jsgf-last-line-was-normal-p ()
    "Check if the former line does not start with a special sign."
    (save-excursion
      (forward-line -1)
      (beginning-of-line-text)
      (and (not (char-equal (char-after) ?=))
           (not (char-equal (char-after) ?|))
           (not (char-equal (char-after) ?\;))
           (not (char-equal (char-after) ?/)))))

  (defun last-was-not-a-comment-p ()
    "Return not-nil if the last relevant sign is not a comment."
    (save-excursion
      (jsgf-goto-last-relevant-indent-sign)
      (beginning-of-line)
      (not (looking-at "^[ \t]+//"))))

  (defun jsgf-same-indentation-as-before ()
    "Return indentation of the last sign."
    (save-excursion
      (forward-line -1)
      (beginning-of-line-text)
      (current-column)))

  (defun jsgf-same-indentation-as-equal-sign ()
    "Return indentation of the last sign."
    (save-excursion
      (jsgf-goto-last-relevant-indent-sign)
      (current-column)))

  (defun jsgf-indent-line ()
    "Indent current line of Jsgf code."
    (interactive)
    (let ((savep (> (current-column) (current-indentation)))
          (indent (condition-case nil (max (jsgf-calculate-indentation) 0)
                    (error 0))))
      (if savep
          (save-excursion (indent-line-to indent))
        (indent-line-to indent))))

  (defun jsgf-find-ruledef-indent ()
    "Rules of indentation:

  - if the line before ended with a semicolon, indent to zero
  - if the line before had an equal sign:
    - if the line is empty after the equal sign
      - add use JSGF-TAB-WIDTH + 2 if it start with a \"/[\d]+/\" construct
    - use JSGF-TAB-WIDTH otherwise
      - otherwise, indent to the same level as the equal sign the line before
  - if the previous line started with slash and is not a comment, take that
    minus 2
  - if the previous line started with slash and it is a comment, indent as
    before
  - if the previous line had a pipe, align to the pipe before
  - if no other rule applies, the indentation is zero"
    (cond ((jsgf-semicolon-was-last-sign-p) 0)

          ((jsgf-had-equal-sign-p) (cond ((jsgf-non-empty-line-between-here-and-equal-p) (- (jsgf-same-indentation-as-before) 2))
                                         ((jsgf-equal-was-last-sign-p) (+ jsgf-tab-width 2))
                                         (t (jsgf-same-indentation-as-equal-sign))))

          ((jsgf-last-line-was-normal-p) (- (jsgf-same-indentation-as-before) 2))

          ((jsgf-slash-was-last-p) (- (jsgf-same-indentation-as-before) 2))

          ((jsgf-pipe-was-last-p) (- (jsgf-same-indentation-as-before) 2))

          (t 0)))


  (defun jsgf-calculate-indentation ()
    "Return the column to which the current line should be indented."
    (if (bobp) 0 ;; beginning of buffer
      (let ((jsgf-indent-found nil) cur-indent)
        (beginning-of-line)
        (jsgf-find-ruledef-indent))))


  ;;;###autoload
  (add-to-list 'auto-mode-alist '("\\.jsgf\\'" . jsgf-mode))

  ;;;###autoload
  (define-derived-mode jsgf-mode prog-mode "Jsgf"
    "A major mode for editing Jsgf files."
    :syntax-table jsgf-mode-syntax-table
    (setq-local comment-start "// ")
    (setq-local comment-start-skip "\\(//+\\|/\\*+\\)\\s *")
    (setq font-lock-defaults '((jsgf-font-lock-defaults)))
    (setq-local indent-line-function 'jsgf-indent-line))

  (provide 'jsgf-mode)
  ;;; jsgf-mode.el ends here.

;; Syntax Highlighting

(defconst jsgf-font-lock-defaults '(("grammar \\(\\sw+\\)" . (1 font-lock-function-name-face))
                                    ("\\(<[^>]+>\\)\\s-*=" . (1 font-lock-function-name-face))
                                    ("\\(<[^>]+>\\){[^}]+}\\s-*=" . (1 font-lock-function-name-face))
                                    ("\\$\\(\\sw+\\)" . (1 font-lock-variable-name-face))
                                    ("<[^>]+>" . font-lock-type-face)
                                    ("\\(\\sw+\\):\\([^,}]\\)" . (1 font-lock-builtin-face))
                                    ("\\(\\sw+\\):\\([^,}]+\\)" . (2 font-lock-doc-face))
                                    ("import\\|grammar\\|JSGF" . font-lock-keyword-face)
                                    ("public" . font-lock-constant-face)))

(defconst jsgf-mode-syntax-table (let ((st (make-syntax-table)))
                                   (modify-syntax-entry ?_ "w" st)
                                   (modify-syntax-entry ?/ ". 124b" st)
                                   (modify-syntax-entry ?* ". 23" st)
                                   (modify-syntax-entry ?\n "> b" st)
                                   st)
  "Syntax table for `jsgf-mode'.")

(defconst jsgf-indent-regex ";\\|=\\||\\|/"
  "Regex used to identify indentation relevant symbols.

  The indentation is based on the idea that nothing needs to be indented except
  lines that either start with or be preceeded by a semicolon, an equal sign, a
  pipe, or a slash.  This variable should store a regex for those signs.")

;; Indentation

;;
;; Indentation
;;

(defun jsgf-goto-last-relevant-indent-sign ()
  "There might be multiple indent signs in one row like the following example:

    public <test> = /1/ foo

  This function jumps to the first of those from the beginning of the line.  In
  the example above, this would be the equal sign."
  (search-backward-regexp jsgf-indent-regex)
  (beginning-of-line)
  (search-forward-regexp jsgf-indent-regex)
  (left-char))

(defmacro jsgf-def-was-last-sign-p (sign character)
  "Defines a function named JSGF-<SIGN>-WAS-LAST-SIGN-P.

  This function returns a predicate if the last relevant sign was a CHARACTER and
  nothing followed inside that line."
  `(defun ,(intern (format "jsgf-%s-was-last-sign-p" sign)) ()
     ,(format "Checks if the last sign was \"%s\" only followed by an empty string." sign)
     (save-excursion
       (search-backward-regexp jsgf-indent-regex)
       (if (char-equal (char-after) ,character)
           (progn
             (forward-char)
             (skip-syntax-forward "-")
             (= (point-at-eol) (point)))
         nil))))

(defmacro jsgf-def-was-last-p (sign character)
  "Defines a function named JSGF-<SIGN>-WAS-LAST-P.

  This function returns a predicate if the last relevant sign was a CHARACTER."
  `(defun ,(intern (format "jsgf-%s-was-last-p" sign)) ()
     ,(format "Checks if the last sign was an %s sign." sign)
     (let ((last-sign-p (save-excursion
                          (jsgf-goto-last-relevant-indent-sign)
                          (and (char-equal (char-after) ,character))))
           (is-first-sign (save-excursion
                            (jsgf-goto-last-relevant-indent-sign)
                            (skip-syntax-backward "-")
                            (= (point-at-bol) (point)))))
       (and last-sign-p is-first-sign))))

(jsgf-def-was-last-sign-p equal ?=)
(jsgf-def-was-last-sign-p semicolon ?\;)

(jsgf-def-was-last-p equal ?=)
(jsgf-def-was-last-p pipe ?|)
(jsgf-def-was-last-p slash ?/)

(defun jsgf-had-equal-sign-p ()
  "Check if the last sign was a equal sign."
  (save-excursion
    (jsgf-goto-last-relevant-indent-sign)
    (char-equal (char-after) ?=)))

(defun this-line-starts-with-slash-p ()
  "Return predicate if this line beginns with a \"/\"-sign."
  (save-excursion
    (beginning-of-line)
    (looking-at "^[ \t]+/")))

(defun jsgf-non-empty-line-between-here-and-equal-p ()
  "Check if there is something between this and the last line with an equal sign."
  (let ((current-line-number (line-number-at-pos))
        (equal-sign-line-number (save-excursion
                                  (jsgf-goto-last-relevant-indent-sign)
                                  (line-number-at-pos))))
    (< 0 (- current-line-number equal-sign-line-number 1))))

(defun jsgf-last-line-was-normal-p ()
  "Check if the former line does not start with a special sign."
  (save-excursion
    (forward-line -1)
    (beginning-of-line-text)
      (and (not (char-equal (char-after) ?=))
           (not (char-equal (char-after) ?|))
           (not (char-equal (char-after) ?\;))
           (not (char-equal (char-after) ?/)))))

(defun last-was-not-a-comment-p ()
  "Return not-nil if the last relevant sign is not a comment."
  (save-excursion
    (jsgf-goto-last-relevant-indent-sign)
    (beginning-of-line)
    (not (looking-at "^[ \t]+//"))))

(defun jsgf-same-indentation-as-before ()
  "Return indentation of the last sign."
  (save-excursion
    (forward-line -1)
    (beginning-of-line-text)
    (current-column)))

(defun jsgf-same-indentation-as-equal-sign ()
  "Return indentation of the last sign."
  (save-excursion
    (jsgf-goto-last-relevant-indent-sign)
    (current-column)))

(defun jsgf-indent-line ()
  "Indent current line of Jsgf code."
  (interactive)
  (let ((savep (> (current-column) (current-indentation)))
        (indent (condition-case nil (max (jsgf-calculate-indentation) 0)
                  (error 0))))
    (if savep
        (save-excursion (indent-line-to indent))
      (indent-line-to indent))))

(defun jsgf-find-ruledef-indent ()
  "Rules of indentation:

  - if the line before ended with a semicolon, indent to zero
  - if the line before had an equal sign:
    - if the line is empty after the equal sign
      - add use JSGF-TAB-WIDTH + 2 if it start with a \"/[\d]+/\" construct
    - use JSGF-TAB-WIDTH otherwise
      - otherwise, indent to the same level as the equal sign the line before
  - if the previous line started with slash and is not a comment, take that
    minus 2
  - if the previous line started with slash and it is a comment, indent as
    before
  - if the previous line had a pipe, align to the pipe before
  - if no other rule applies, the indentation is zero"
  (cond ((jsgf-semicolon-was-last-sign-p) 0)
        ((jsgf-had-equal-sign-p) (cond ((jsgf-non-empty-line-between-here-and-equal-p) (- (jsgf-same-indentation-as-before) 2))
                                       ((jsgf-equal-was-last-sign-p) (+ jsgf-tab-width 2))
                                       (t (jsgf-same-indentation-as-equal-sign))))
        ((jsgf-last-line-was-normal-p) (- (jsgf-same-indentation-as-before) 2))
        ((jsgf-slash-was-last-p) (- (jsgf-same-indentation-as-before) 2))
        ((jsgf-pipe-was-last-p) (- (jsgf-same-indentation-as-before) 2))
        (t 0)))

(defun jsgf-calculate-indentation ()
  "Return the column to which the current line should be indented."
  (if (bobp) 0 ;; beginning of buffer
    (let ((jsgf-indent-found nil) cur-indent)
      (beginning-of-line)
      (jsgf-find-ruledef-indent))))

;; Closing

;;;###autoload
(define-derived-mode jsgf-mode prog-mode "Jsgf"
  "A major mode for editing Jsgf files."
  :syntax-table jsgf-mode-syntax-table
  (setq-local comment-start "// ")
  (setq-local comment-start-skip "\\(//+\\|/\\*+\\)\\s *")
  (setq font-lock-defaults '((jsgf-font-lock-defaults)))
  (setq-local indent-line-function 'jsgf-indent-line))

(provide 'jsgf-mode)
;;; jsgf-mode.el ends here.