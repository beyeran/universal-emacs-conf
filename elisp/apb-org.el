;; General


(defun apb/org-latex-yas ()
  "Activate org and LaTeX yas expansion in org-mode buffers."
  (yas-minor-mode)
  (yas-activate-extra-mode 'latex-mode))

(add-hook 'org-mode-hook #'apb/org-latex-yas)

;; Modes for writing


(use-package writegood-mode
  :ensure t
  :after org
  :config
  (custom-theme-set-faces
   'user
   `(writegood-weasels-face ((t (:foreground "#ff0000"))))
   `(writegood-passive-voice-face ((t (:foreground "#ff0000"))))
   `(writegood-duplicates-face ((t (:foreground "#ff0000"))))))

(use-package visual-fill-column
  :ensure t
  :after org
  :hook ((visual-line-mode . visual-fill-column-mode)
         (org-mode . visual-line-mode))
  :diminish auto-fill-mode
  :straight (:host github :repo "joostkremers/visual-fill-column"))

(setq visual-fill-column-width 120)

(use-package writeroom-mode
  :ensure t
  :after org
  :straight (:host github :repo "joostkremers/writeroom-mode"))

(use-package pdf-continuous-scroll-mode
  :ensure t
  :after org-noter
  :straight (:host github :repo "dalanicolai/pdf-continuous-scroll-mode.el")
  :hook (pdf-view-mode . pdf-continuous-scroll-mode))

;; Roam

;;   This is just a test to see if it will be useful. More notes on it or deletion to come.


(defvar *roam-directory* "~/projects/braindump/org"
  "Local directory for storing roam related files.")

(defun apb/org-auto-load-hook ()
  (org-babel-execute-buffer))

(defvar *apb/literature-directory*
  (expand-file-name "literature" *roam-directory*)
  "Directory for storing literature notes. A literature note it a note
with a referance in the bibliographic file.")

(unless (file-directory-p *apb/literature-directory*)
  (make-directory *apb/literature-directory*))

(defvar *apb/bibliographic-file*
  (expand-file-name "bibliography.bib" *apb/literature-directory*)
  "Path to the bibliographic file - prerequisit for literature notes.")

(defun apb/org-id-update-org-roam-files ()
  "Update Org-ID locations for all Org-roam files."
  (interactive)
  (org-id-update-id-locations (org-roam--list-all-files)))

(defun apb/org-id-update-id-current-file ()
  "Scan the current buffer for Org-ID locations and update  them."
  (interactive)
  (org-id-update-id-locations (list (buffer-file-name (current-buffer)))))

(use-package org-roam
  :ensure t
  :straight (:host github :repo "org-roam/org-roam")
  :hook
  ((after-init . org-roam-mode)
   (org-mode . apb/org-auto-load-hook))
  :init
  (when (not (file-directory-p *roam-directory*))
    (make-directory *roam-directory*))
  (on-mac
   (setq org-roam-graph-viewer "/Applications/Firefox.app/Contents/MacOS/firefox"))
  :config
  (require 'org-roam-protocol)

  (setq org-roam-mode-sections
        (list #'org-roam-backlinks-insert-section
              #'org-roam-reflinks-insert-section
              #'org-roam-unlinked-references-insert-section)
        org-confirm-babel-evaluate nil
        org-roam-index-file "index.org"
        org-roam-directory *roam-directory*
        org-startup-with-latex-preview t)

  ;; (defun apb/org-roam-insert ()
  ;;   "TODO"
  ;;   (interactive)
  ;;   (let ((description (read-string "Description: ")))
  ;;     (org-roam-insert nil nil nil description "id")))
  :bind (:map org-roam-mode-map
              (("C-c n i" . org-roam-insert)
               ("C-c n t" . org-roam-tag-add)
               ("C-c n f" . org-roam-find-file)
               ("C-c n b" . org-roam-switch-to-buffer))))

(use-package org-ref
  :after (org org-roam)
  :ensure t
  :config
  (setq org-ref-completion-library 'org-ref-helm-cite
        org-ref-default-bibliography (list *apb/bibliographic-file*)
        bibtex-completion-bibliography *apb/bibliographic-file*
        org-ref-note-title-format (concat "* NOTES %y - %t\n "
                                          ":PROPERTIES:\n  "
                                          ":Custom_ID: %k\n  "
                                          ":NOTER_DOCUMENT: %F\n "
                                          ":ROAM_KEY: cite:%k\n  "
                                          ":AUTHOR: %9a\n  "
                                          ":JOURNAL: %j\n  "
                                          ":YEAR: %y\n  "
                                          ":VOLUME: %v\n  "
                                          ":PAGES: %p\n  "
                                          ":DOI: %D\n  "
                                          ":URL: %U\n "
                                          ":END:\n\n")
        org-ref-notes-directory *apb/literature-directory*
        org-ref-notes-function 'orb-edit-notes))

(use-package org-roam-bibtex
  :after (org org-roam)
  :straight (:host github :repo "org-roam/org-roam-bibtex")
  :hook (org-roam-mode . org-roam-bibtex-mode)
  :bind (("C-c n a" . orb-note-actions))
  :config
  (setq orb-preformat-keywords '("=key=" "title" "url" "file" "author-or-editor" "keywords")
        orb-templates '(("r" "ref" plain (function org-roam-capture--get-point) ""
                         :file-name "literature/${slug}"
                         :head "#+TITLE: ${=key=}: ${title}
#+ROAM_KEY: ${ref}

* ${title}
  :PROPERTIES:
  :Custom_ID: ${=key=}
  :AUTHOR: ${author-or-editor}
  :END:

"
                         :unnarrowed t))))

(use-package company-org-roam
  :ensure t
  :after (org org-roam)
  :straight (:host github :repo "org-roam/company-org-roam")
  :config
  (push 'company-org-roam company-backends)
  (setq org-roam-completion-everywhere t)
  :bind (("C-n" . company-select-next)
         ("C-t" . company-select-previous)))

(use-package deft
  :ensure t
  :after (org org-roam)
  :bind ("C-c n d" . deft)
  :custom
  (deft-recursive t)
  (deft-use-filter-string-for-filename t)
  (deft-default-extension)
  (deft-directory *roam-directory*))

(use-package org-roam-server
  :ensure t
  :after (org org-roam)
  :config
  (setq org-roam-server-host "127.0.0.1"
        org-roam-server-port 8080
        org-roam-server-authenticate nil
        org-roam-server-export-inline-images t
        org-roam-server-files nil
        org-roam-server-served-file-extensions '("pdf")
        org-roam-server-network-poll t
        org-roam-server-network-arrows nil
        org-roam-server-network-label-truncate t
        org-roam-server-network-label-truncate-lenght 60
        org-roam-server-network-label-wram-length 20))

(defun apb/get-all-org-links-in-file ()
  """TODO"""
  (interactive)
  (org-element-map (org-element-parse-buffer) 'link
    (lambda (link) (string= (org-element-property :type link) "file")
      (org-element-property :path link))))

;; Anki


(use-package anki-editor
  :after org
  :straight (:host github :repo "louietan/anki-editor")
  :bind (:map org-mode-map
              ("<f12>" . anki-editor-cloze-region-auto-incr)
              ("<f11>" . anki-editor-cloze-region-dont-incr)
              ("<f10>" . anki-editor-reset-cloze-number)
              ("<f9>"  . anki-editor-push-tree))
  :hook (org-capture-after-finalize . anki-editor-reset-cloze-number) ; Reset cloze-number after each capture.
  :config
  (setq anki-editor-create-decks t ;; Allow anki-editor to create a new deck if it doesn't exist
        anki-editor-org-tags-as-anki-tags t
        anki-editor-break-consecutive-braces-in-latex t)

  (defun anki-editor-cloze-region-auto-incr (&optional arg)
    "Cloze region without hint and increase card number."
    (interactive)
    (anki-editor-cloze-region my-anki-editor-cloze-number "")
    (setq my-anki-editor-cloze-number (1+ my-anki-editor-cloze-number))
    (forward-sexp))

  (defun anki-editor-cloze-region-dont-incr (&optional arg)
    "Cloze region without hint using the previous card number."
    (interactive)
    (anki-editor-cloze-region (1- my-anki-editor-cloze-number) "")
    (forward-sexp))

  (defun anki-editor-reset-cloze-number (&optional arg)
    "Reset cloze number to ARG or 1"
    (interactive)
    (setq my-anki-editor-cloze-number (or arg 1)))

  (defun anki-editor-push-tree ()
    "Push all notes under a tree."
    (interactive)
    (anki-editor-push-notes '(4))
    (anki-editor-reset-cloze-number))
  ;; Initialize
  (anki-editor-reset-cloze-number))

;; Mind Maps


(use-package org-mind-map
  :init
  (require 'ox-org)
  :ensure t
  :config
  (setq org-mind-map-engine "dot"))

;; Latex


(setq org-latex-pdf-process '("xelatex -shell-escape %f"))

(when (eq system-type 'darwin)
  (setq org-latex-pdf-process '("/Library/TeX/texbin/xelatex -quiet -shell-escape %f")))

(setq org-latex-listings 'minted)



;; Please see the `form` =latex-mode= snippet to understand more of the workflow:


(defun apb/org-mode-hook ()
  (setq-local yas-buffer-local-condition
              '(not (org-in-src-block-p t))))

(eval-after-load 'org
  (progn
    (add-hook 'org-mode-hook #'apb/org-mode-hook)
    (add-hook 'org-babel-after-execute-hook #'org-redisplay-inline-images)))

;; Latex Export Template


(with-eval-after-load 'ox-latex
  (add-to-list 'org-latex-classes
               '("article"
                 "% -------------------
% Packages
% -------------------
\\documentclass[11pt,a4paper]{article}
\\usepackage[utf8x]{inputenc}
\\usepackage[T1]{fontenc}
\\usepackage{mathptmx} % Use Times Font


\\usepackage[pdftex]{graphicx} % Required for including pictures
\\usepackage[german]{babel}
\\usepackage[pdftex,linkcolor=black,pdfborder={0 0 0}]{hyperref} % Format links for pdf
\\usepackage{calc} % To reset the counter in the document after title page
\\usepackage{enumitem} % Includes lists

\\frenchspacing % No double spacing between sentences
\\linespread{1.2} % Set linespace
\\usepackage[a4paper, lmargin=0.1666\\paperwidth, rmargin=0.1666\\paperwidth, tmargin=0.1111\\paperheight, bmargin=0.1111\\paperheight]{geometry} %margins

\\usepackage[all]{nowidow} % Tries to remove widows
\\usepackage[protrusion=true,expansion=true]{microtype} % Improves typography, load after fontpackage is selected
"
                 ("\\section{%s}" . "\\section*{%s}")
                 ("\\subsection{%s}" . "\\subsection*{%s}")
                 ("\\subsubsection{%s}" . "\\subsubsection*{%s}")
                 ("\\paragraph{%s}" . "\\paragraph*{%s}")
                 ("\\subparagraph{%s}" . "\\subparagraph*{%s}")))

  (add-to-list 'org-latex-classes
               '("exercise"
                 "\\documentclass{tufte-handout}

\\usepackage[ngerman, english]{babel}

\\setmainfont{Adobe Garamond Pro}
\\setsansfont{Adobe Caslon Pro}
\\setmonofont{FiraCode Nerd Font Mono}

\\usepackage{geometry}
\\usepackage{amsmath}
\\usepackage{amssymb}
\\PassOptionsToPackage{normalem}{ulem}
\\usepackage{ulem}
\\usepackage{amsthm}
\\usepackage{polynom}
\\usepackage{mathtools}

\\pagestyle{empty}
\\setlength\\parskip{0.5em}
"
                 ("\\section{%s}" . "\\section*{%s}")
                 ("\\subsection{%s}" . "\\subsection*{%s}")
                 ("\\subsubsection{%s}" . "\\subsubsection*{%s}")
                 ("\\paragraph{%s}" . "\\paragraph*{%s}")
                 ("\\subparagraph{%s}" . "\\subparagraph*{%s}"))))

;; Blog

;;    I'd really wanted to use a native org-mode blog engine. There are several, I know, but none of theme seems to have nice themes for exporting. I'm not a designer. I want something done and just write my text in org-mode. I haven't found a solution to this. Since Hugo has nice themes and seems to be very widepsread, I've used that.


(use-package ox-hugo
  :ensure t
  :after ox)

;; General Babel And Loading

;;    Even though I'm very sparingly commenting, I like the idea.


(use-package ox-pandoc
  :ensure t
  :config
  ;; default options for all output formats
  (setq org-pandoc-options '((standalone . t)))
  ;; cancel above settings only for 'docx' format
  (setq org-pandoc-options-for-docx '((standalone . nil)))
  ;; special settings for beamer-pdf and latex-pdf exporters
  (setq org-pandoc-options-for-beamer-pdf '((pdf-engine . "xelatex")))
  (setq org-pandoc-options-for-latex-pdf '((pdf-engine . "xelatex")))
  ;; special extensions for markdown_github output
  (setq org-pandoc-format-extensions '(markdown_github+pipe_tables+raw_html)))

(use-package org
  :config
  (org-babel-do-load-languages 'org-babel-load-languages
                               '((shell      . t)
                                 (java       . t)
                                 (latex      . t)
                                 (ditaa      . t)
                                 (emacs-lisp . t)
                                 (plantuml   . t)
                                 (dot        . t)
                                 (python     . t))))

;; Looks

;;   Bullets


(use-package org-bullets
  :ensure t
  :custom
  (org-bullets-bullet-list '("◉" "☯" "○" "☯" "✸" "☯" "✿" "☯" "✜" "☯" "◆" "☯" "▶"))
  (org-ellipsis "⤵")
  :hook (org-mode . org-bullets-mode))



;; Hiding those emphasis markers, like /foo/ or =baz=.


(setq org-hide-emphasis-markers t)



;; For viewing files with LaTeX natively hide the blocks and display everything when opening. More or less required to have a "native" text document feel when using =org-roam=:


(add-hook 'org-mode-hook 'org-hide-block-toggle-all)

(use-package org-fragtog
  :ensure t
  :after org
  :custom
  (org-format-latex-options (plist-put org-format-latex-options :scale 1.2))
  :init
  (add-hook 'org-mode-hook 'org-fragtog-mode))



;; Diverse other eyecandy. After that, you normal =org-file= should look more like an actuall word processor. Thanks internet!


(setq-default prettify-symbols-alist '(("#+BEGIN_SRC" . "†")
                                       ("#+END_SRC" . "†")
                                       ("#+begin_src" . "†")
                                       ("#+end_src" . "†")
                                       (">=" . "≥")
                                       ("=>" . "⇨")))
(setq prettify-symbols-unprettify-at-point 'right-edge)
(add-hook 'org-mode-hook 'prettify-symbols-mode)

;; Closing


(provide 'apb-org)