;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;                      .         .                                                               
;; 8 8888888888            ,8.       ,8.                   .8.           ,o888888o.       d888888o.   
;; 8 8888                 ,888.     ,888.                 .888.         8888     `88.   .`8888:' `88. 
;; 8 8888                .`8888.   .`8888.               :88888.     ,8 8888       `8.  8.`8888.   Y8 
;; 8 8888               ,8.`8888. ,8.`8888.             . `88888.    88 8888            `8.`8888.     
;; 8 888888888888      ,8'8.`8888,8^8.`8888.           .8. `88888.   88 8888             `8.`8888.    
;; 8 8888             ,8' `8.`8888' `8.`8888.         .8`8. `88888.  88 8888              `8.`8888.   
;; 8 8888            ,8'   `8.`88'   `8.`8888.       .8' `8. `88888. 88 8888               `8.`8888.  
;; 8 8888           ,8'     `8.`'     `8.`8888.     .8'   `8. `88888.`8 8888       .8' 8b   `8.`8888. 
;; 8 8888          ,8'       `8        `8.`8888.   .888888888. `88888.  8888     ,88'  `8b.  ;8.`8888 
;; 8 888888888888 ,8'         `         `8.`8888. .8'       `8. `88888.  `8888888P'     `Y8888P ,88P' 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Remove unwanted UI
(setq inhibit-startup-screen t)
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(blink-cursor-mode -1)

;; Open in my org file directory for convenience
(setq default-directory "~/Documents")

(require 'package)
(setq package-archives
      '(("gnu"    . "https://elpa.gnu.org/packages/")
	("nongnu" . "https://elpa.nongnu.org/nongnu/")
	("melpa"  . "https://melpa.org/packages/")))
(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))

(dolist (package '(evil evil-org org-superstar catppuccin-theme))
  (unless (package-installed-p package)
    (package-install package)))

;; Vim is better
(require 'evil)
(evil-mode 1)

(setq org-startup-indented t)
(setq org-hide-leading-stars t)
(require 'org-superstar)
(setq org-superstar-headline-bullets-list
      '("◉" "○" "●" "◆" "◇"))
(add-hook 'org-mode-hook #'org-superstar-mode)

(require 'evil-org)
(evil-org-set-key-theme)
(add-hook 'org-mode-hook #'evil-org-mode)

(setq vc-follow-symlinks t)

;; Relative line numbers
(setq display-line-numbers-type 'relative)
(global-display-line-numbers-mode)

;; Theme
(load-file "~/.config/emacs/theme.el")
(set-face-attribute 'default nil
		    :font "JetBrainsMono Nerd Font"
		    :height 110)

(require 'server)
(server-start)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages nil))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
