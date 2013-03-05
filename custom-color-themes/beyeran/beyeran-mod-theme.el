(deftheme beyeran-mod
  "Created 2012-09-10.")

(custom-theme-set-faces
 'beyeran-mod
 '(cursor ((t (:background "#353535"))))
 '(fixed-pitch ((t (:family "Droid Sans Mono"))))
 '(variable-pitch ((t (:family "Sans Serif"))))
 '(escape-glyph ((t (:foreground "#a9a9a9"))))
 '(minibuffer-prompt ((t (:foreground "#a9a9a9"))))
 '(highlight ((t (:background "#707070"))))
 '(region ((t (:background "#656565"))))
 '(shadow ((t (:foreground "#454545"))))
 '(secondary-selection ((t (:background "#c4c4c4"))))
 '(trailing-whitespace ((t (:background "#870000"))))
 '(font-lock-builtin-face ((t (:foreground "#f9f9f9" :weight bold))))
 '(font-lock-comment-delimiter-face ((default (:inherit (font-lock-comment-face)))))
 '(font-lock-comment-face ((t (:foreground "#555555"))))
 '(font-lock-constant-face ((t (:foreground "#c4c4c4"))))
 '(font-lock-doc-face ((t (:inherit font-lock-builtin-face))))
 '(font-lock-function-name-face ((t (:foreground "#ffffff"))))
 '(font-lock-keyword-face ((t (:foreground "#bbbbee" :weight bold))))
 '(font-lock-negation-char-face ((t nil)))
 '(font-lock-preprocessor-face ((t (:inherit (font-lock-builtin-face)))))
 '(font-lock-regexp-grouping-backslash ((t (:inherit (bold)))))
 '(font-lock-regexp-grouping-construct ((t (:inherit (bold)))))
 '(font-lock-string-face ((t (:foreground "#bbbbee"))))
 '(font-lock-type-face ((t (:foreground "#dedede" :weight bold))))
 '(font-lock-variable-name-face ((t (:foreground "IndianRed3" :weight bold))))
 '(font-lock-warning-face ((t (:inherit default))))
 '(button ((t (:inherit font-lock-variable-name-face))))
 '(link ((t (:inherit font-lock-variable-name-face :underline t))))
 '(link-visited ((t (:inherit font-lock-variable-name-face))))
 '(fringe ((((class color) (background light)) (:background "grey95")) (((class color) (background dark)) (:background "grey10")) (t (:background "gray"))))
 '(header-line ((default (:inherit (mode-line))) (((type tty)) (:underline t :inverse-video nil)) (((class color grayscale) (background light)) (:box nil :foreground "grey20" :background "grey90")) (((class color grayscale) (background dark)) (:box nil :foreground "grey90" :background "grey20")) (((class mono) (background light)) (:underline t :box nil :inverse-video nil :foreground "black" :background "white")) (((class mono) (background dark)) (:underline t :box nil :inverse-video nil :foreground "white" :background "black"))))
 '(tooltip ((((class color)) (:inherit (variable-pitch) :foreground "black" :background "lightyellow")) (t (:inherit (variable-pitch)))))
 '(mode-line ((((class color) (min-colors 88)) (:foreground "#d3d3d3" :background "#030303" :box (:line-width -1 :color nil :style released-button))) (t (:inverse-video t))))
 '(mode-line-buffer-id ((t (:weight normal))))
 '(mode-line-emphasis ((t (:weight normal))))
 '(mode-line-highlight ((((class color) (min-colors 88)) (:box (:line-width 2 :color "#303030" :style released-button))) (t (:inherit (highlight)))))
 '(mode-line-inactive ((default (:inherit (mode-line))) (((class color) (min-colors 88) (background light)) (:background "grey90" :foreground "grey20" :box (:line-width -1 :color "grey75" :style nil) :weight light)) (((class color) (min-colors 88) (background dark)) (:background "grey30" :foreground "grey80" :box (:line-width -1 :color "grey40" :style nil) :weight light))))
 '(isearch ((((class color) (min-colors 88) (background light)) (:foreground "lightskyblue1" :background "magenta3")) (((class color) (min-colors 88) (background dark)) (:foreground "brown4" :background "palevioletred2")) (((class color) (min-colors 16)) (:foreground "cyan1" :background "magenta4")) (((class color) (min-colors 8)) (:foreground "cyan1" :background "magenta4")) (t (:inverse-video t))))
 '(isearch-fail ((((class color) (min-colors 88) (background light)) (:background "RosyBrown1")) (((class color) (min-colors 88) (background dark)) (:background "red4")) (((class color) (min-colors 16)) (:background "red")) (((class color) (min-colors 8)) (:background "red")) (((class color grayscale)) (:foreground "grey")) (t (:inverse-video t))))
 '(lazy-highlight ((((class color) (min-colors 88) (background light)) (:background "paleturquoise")) (((class color) (min-colors 88) (background dark)) (:background "paleturquoise4")) (((class color) (min-colors 16)) (:background "turquoise3")) (((class color) (min-colors 8)) (:background "turquoise3")) (t (:underline t))))
 '(match ((((class color) (min-colors 88) (background light)) (:background "yellow1")) (((class color) (min-colors 88) (background dark)) (:background "RoyalBlue3")) (((class color) (min-colors 8) (background light)) (:foreground "black" :background "yellow")) (((class color) (min-colors 8) (background dark)) (:foreground "white" :background "blue")) (((type tty) (class mono)) (:inverse-video t)) (t (:background "gray"))))
 '(next-error ((t (:inherit (region)))))
 '(query-replace ((t (:inherit (isearch)))))
 '(default ((t (:inherit nil :stipple nil :background "#131313" :foreground "#454545" :inverse-video nil :box nil :strike-through nil :overline nil :underline nil :slant normal :weight normal :height 82 :width normal :foundry "unknown" :family "Droid Sans Mono")))))

(provide-theme 'beyeran-mod)
