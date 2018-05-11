;;; This file is .emacs
;;; Created by Luke English <luke@ljenglish.net>

;; MELPA
(setq package-archives '(("gnu" . "https://elpa.gnu.org/packages/")
                         ("melpa" . "https://melpa.org/packages/")
			 ("org" . "http://orgmode.org/elpa/")
			 ("melpa-stable" . "http://stable.melpa.org/packages/"))
      package-archive-priorities '(("melpa-stable" . 1)))
;; Added by Package.el.  This must come before configurations of
;; installed packages.  Don't delete this line.  If you don't want it,
;; just comment it out by adding a semicolon to the start of the line.
;; You may delete these explanatory comments.
(package-initialize)
(when (not package-archive-contents)
  (package-refresh-contents)
  (package-install 'use-package))
(require 'use-package)


;; Modularity

(add-to-list 'load-path "~/.emacs.d/elisp/")
(load-library "style")
(load-library "iosevka")
(load-library "function")
(load-library "my-erc")
(load-library "my-org")

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(jdee-jdk (quote ("1.8")))
 '(jdee-jdk-registry (quote (("1.8" . "/usr/lib64/jvm/jdk1.8.0_162"))))
 '(jdee-server-dir "~/.jars")
 '(package-selected-packages
   (quote
    (ng2-mode ess ess-R-data-view ess-smart-equals jdee toml-mode cargo rust-mode use-package ensime w3m fancy-battery erc-image org base16-theme color-theme origami ## s aggressive-indent smartparens browse-kill-ring rainbow-delimiters slime))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
