;;; This file is style.el
;;; It contains customisations for the visual look and feel of Emacs.
;;; Created by Luke English <luke@ljenglish.net>

;; Hide splash screen
(setq inhibit-startup-message t)
(setq initial-scratch-message nil)

;; Window decorations
(toggle-scroll-bar -1)
(tool-bar-mode -1)


;; Battery display
(fancy-battery-mode 1)

;; Font
(add-to-list 'default-frame-alist '(font . "Iosevka-14"))
(set-face-attribute 'default t :font "Iosevka-14")

;; Color theme + transparency
(load-theme 'base16-monokai t)
(set-frame-parameter (selected-frame) 'alpha '(90 . 90))
(add-to-list 'default-frame-alist '(alpha . (90 . 90)))

;; Rainbow delimiters
(add-hook 'prog-mode-hook #'rainbow-delimiters-mode)

;; Org font
(add-hook 'org-mode-hook 'turn-on-font-lock)

;; Linum mode
(global-linum-mode 1)
