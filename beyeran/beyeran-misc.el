
;;
;; file: beyeran-misc.el
;;

;;;;;;;; general stuff ;;;;;;;
(require 'cl)

(tool-bar-mode 0)
(menu-bar-mode 0)
(scroll-bar-mode 0)
(show-paren-mode 1)
(setq inhibit-spalsh-screen nil)

(sys-diversification 
 (custom-set-faces
  '(default ((t (:inherit nil :stipple nil :background "#000000" :foreground "#a6a6a6" :inverse-video nil 
                          :box nil :strike-through nil :overline nil :underline nil :slant normal :weight normal 
                          :height 90 :width normal :foundry "xos4" :family "dina"))))))

(setq inihibit-startup-echo-area-message "André")
(setq inhibit-startup-screen t)
(setq initial-scratch-message nil)

;; Alt as Meta for Mac (german keyboard layout fix)

(sys-diversification
 ()
 (progn
   (setq mac-command-modifier 'meta
         mac-option-modifier 'none
         default-input-method "MacOSX")))

(require 'color-theme)

(require 'color-hellraiser)
(color-theme-initialize)
(color-hellraiser)


(setq color-theme-is-global t)

;;;; cursor ;;;;
(setq-default cursor-type 'box)
(setq messages-buffer-max-lines 400)
(setq blink-cursor-delay 0.2)
(setq blink-cursor-interval 0.3)

;;;;;;;; general variables ;;;;;;

(define-key global-map (kbd "C-c f") 'find-function)
(setq-default tab-width 4)

;;;; comments ;;;;
(setf comment-style 'indent)

(add-hook 'emacs-lisp-mode-hook #'imenu-add-menubar-index)
(global-set-key [mouse-3] 'mouse-popup-menubar-stuff)

;;;; time ;;;;
(display-time)
(setf display-time-day-and-date nil)
(setf display-time-24hr-format t)

;;;; timestamp ;;;;
(defvar iso-date-format "%Y-%m-%dT%H:%M:%S:z"
  "Format string for ISO dates.")

(defun iso-timestamp (&optional time)
  (format-time-sting iso-date-format
                     (or time (current-time))))

(defun insert-iso-timestamp ()
  (interactive)
  (insert (iso-timestamp)))

(defun iso-timestamp-sexp (&optional time)
  (parse-time-string (iso-timestamp)))

(require 'time-stamp)
(add-hook 'before-save-hook 'time-stamp)
(setf time-stamp-active t)

(defun lorem ()
  "Insert a lorem ipsum."
  (interactive)
  (insert "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do "
          "eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim"
          "ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut "
          "aliquip ex ea commodo consequat. Duis aute irure dolor in "
          "reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla "
          "pariatur. Excepteur sint occaecat cupidatat non proident, sunt in "
          "culpa qui officia deserunt mollit anim id est laborum."))

;;;; Custom Functions ;;;;
(defun html-umlaute ()
  "replaces iso-umlaute with html-umlaute"
  (interactive)
  (let ((case-fold-search nil))
    (save-excursion
      (goto-char (point-min))
      (while (re-search-forward
              (mapconcat '(lambda (x) (car x)) *html-entities* "\\|")
              nil t)
        (replace-match (cdr (assoc (match-string 0) *html-entities*)))))))

;;;; Variables ;;;;
(setf *html-entities*
  '(("Ä" . "&Auml;")
    ("ä" . "&auml;")
    ("Ö" . "&Ouml;")
    ("ö" . "&ouml;")
    ("Ü" . "&Uuml;")
    ("ü" . "&Uuml;")
    ("ß" . "&szling;")))

(defmacro defshrink (system space)
  `(defun ,system ()
     (interactive)
     (shrink-window ,space)))

(defshrink massive-shrink-darwin 20)
(defshrink massive-shrink-linux 14)
(defshrink massive-shrink-win 25)

(global-set-key (kbd "C-x C-q")
                (sys-diversification
                 'massive-shrink-linux
                 'massive-shrink-darwin))

(setq *filestamp-seperator* "-")
(setq *filestamp-seperator-repetition* 46)

(setq *filestamp-user-name* "André Beyer")
(setq *filestamp-user-email* "beyeran@gmail.com")

(defun filestamp-make-seperator (times)
  (if (= 0 times)
      ""
    (concat *filestamp-seperator* (filestamp-make-seperator (- times 1)))))

(setq *filestamp-seperator-builded* (filestamp-make-seperator *filestamp-seperator-repetition*))

(defun filestamp-header-finished (comment-sign)
  (concat comment-sign *filestamp-seperator-builded* "\n"
          comment-sign " file: " "\n"
          comment-sign " author: " *filestamp-user-name* " <" *filestamp-user-email* ">" "\n"
          comment-sign " Time-stamp: <>" "\n"
          comment-sign *filestamp-seperator-builded* "\n"))

(setq filestamp-auto-insert-alist '((("\\.\\(tex\\|sty\\|cls\\)\\'" . "LaTeX Comment") .
                                     (insert (filestamp-header-finished "%")))
                                    (("\\.\\(lisp\\|lsp\\)\\'" . "Lisp Comment") .
                                     (insert (filestamp-header-finished ";;")))
                                    (("\\.\\(hs\\)\\'" . "Haskell Comment") .
                                     (insert (filestamp-header-finished "--")))
                                    (("\\.\\(rb\\|irb\\)\\'" . "Ruby Comment") .
                                     (insert (filestamp-header-finished "##")))
                                    (("\\.\\(sh\\|zsh\\)\\'" . "Shell Comment") .
                                     (insert (filestamp-header-finished "##")))))

(defun filestamp-insert ()
  (interactive)
  (insert (filestamp-header-finished ";;")))

(add-hook 'write-file-hooks 'time-stamp)
(add-hook 'find-file-hooks 'auto-insert)

(provide 'beyeran-misc)
