(deftheme carbonfox
  "Carbonfox theme, based on the Nightfox color palette.")

(let ((bg "#161616")
      (fg "#f2f4f8")
      (black "#282828")
      (red "#ee5396")
      (green "#25be6a")
      (yellow "#08bdba")
      (blue "#78a9ff")
      (magenta "#be95ff")
      (cyan "#33b1ff")
      (white "#dfdfe0")
      (bright-black "#484848")
      (bright-red "#f16da6")
      (bright-green "#46c880")
      (bright-yellow "#2dc7c4")
      (bright-blue "#8cb6ff")
      (bright-magenta "#c8a5ff")
      (bright-cyan "#52bdff")
      (bright-white "#e4e4e5"))

  (custom-theme-set-faces
   'carbonfox

   ;; Basic text
   `(default ((t (:foreground ,fg :background ,bg))))
   `(cursor ((t (:background ,fg))))
   `(fringe ((t (:background ,bg))))

   ;; Line numbers
   `(line-number ((t (:foreground ,bright-black
                                   :background ,bg))))
   `(line-number-current-line
     ((t (:foreground ,fg
                      :background ,bg
                      :weight bold))))

   ;; Selection
   `(region ((t (:foreground ,fg :background "#2a2a2a"))))

   ;; Syntax
   `(font-lock-comment-face
     ((t (:foreground ,bright-black))))
   `(font-lock-string-face
     ((t (:foreground ,green))))
   `(font-lock-keyword-face
     ((t (:foreground ,magenta))))
   `(font-lock-function-name-face
     ((t (:foreground ,blue))))
   `(font-lock-variable-name-face
     ((t (:foreground ,cyan))))
   `(font-lock-type-face
     ((t (:foreground ,yellow))))
   `(font-lock-constant-face
     ((t (:foreground ,bright-blue))))
   `(font-lock-builtin-face
     ((t (:foreground ,bright-magenta))))

   ;; Org
   `(org-level-1 ((t (:foreground ,blue :weight bold))))
   `(org-level-2 ((t (:foreground ,magenta :weight bold))))
   `(org-level-3 ((t (:foreground ,cyan :weight bold))))
   `(org-level-4 ((t (:foreground ,green :weight bold))))
   `(org-level-5 ((t (:foreground ,yellow :weight bold))))

   `(org-code ((t (:foreground ,green :background ,black))))
   `(org-verbatim ((t (:foreground ,cyan :background ,black))))
   `(org-block ((t (:background ,black))))
   `(org-block-begin-line
     ((t (:foreground ,bright-black :background ,black))))
   `(org-block-end-line
     ((t (:foreground ,bright-black :background ,black))))

   ;; Mode line
   `(mode-line
     ((t (:foreground ,fg :background ,black :box nil))))
   `(mode-line-inactive
     ((t (:foreground ,bright-black :background ,bg :box nil))))

   ;; Minibuffer
   `(minibuffer-prompt
     ((t (:foreground ,blue :weight bold))))

   ;; Search
   `(isearch
     ((t (:foreground ,bg :background ,yellow :weight bold))))
   `(lazy-highlight
     ((t (:foreground ,fg :background ,black))))

   ;; Errors / warnings
   `(error ((t (:foreground ,red :weight bold))))
   `(warning ((t (:foreground ,yellow :weight bold))))
   `(success ((t (:foreground ,green :weight bold)))))

  ;; Terminal colors
  (custom-theme-set-variables
   'carbonfox
   `(ansi-color-names-vector
     ,(vector black red green yellow blue magenta cyan white))
   `(ansi-color-bright-names-vector
     ,(vector bright-black bright-red bright-green bright-yellow
              bright-blue bright-magenta bright-cyan bright-white))))

(provide-theme 'carbonfox)

;; Disable the previously active theme when hot-swapping.
(mapc #'disable-theme custom-enabled-themes)

;; Enable Carbonfox.
(enable-theme 'carbonfox)
