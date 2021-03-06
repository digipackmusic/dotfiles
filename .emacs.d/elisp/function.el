;;; This file is function.el
;;; It provides functionality modifications for Emacs.
;;; Created by Luke English <luke@ljenglish.net>

;; SLIME
(require 'slime-autoloads)
(setq inferior-lisp-program "/usr/bin/sbcl")
(setq slime-contribs '(slime-fancy))

;; Interactively Do Things
(require 'ido)
(ido-mode t)

;; Browse-kill-ring
(require 'browse-kill-ring)
(global-set-key "\M-y" 'browse-kill-ring)

;; Smart parens
(require 'smartparens-config)
(add-hook 'prog-mode-hook #'smartparens-mode)
(add-hook 'emacs-lisp-mode-hook #'smartparens-mode)

;; Aggressive indent mode
(global-aggressive-indent-mode 1)
(add-to-list 'aggressive-indent-excluded-modes 'html-mode)
(add-to-list 'aggressive-indent-excluded-modes 'text-mode)
(add-to-list 'aggressive-indent-excluded-modes 'scala-mode)
(add-to-list 'aggressive-indent-excluded-modes 'sbt-mode)

;; Code folding; uses Origami
(require 'origami)
(global-origami-mode 1)

;; Use electric buffer list as default buffer menu
(global-set-key (kbd "C-x C-b") 'electric-buffer-list)

;; ENSIME
(use-package ensime
  :ensure t
  :pin melpa-stable
  :init
  (setq ensime-startup-notification nil))

;; Emacs Speaks Statistics
(require 'ess-site)
