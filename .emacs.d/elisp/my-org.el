(require 'ox-latex)
;; (require 'org-bibtex)
(require 'ox-bibtex) 

;; Default org bindings
(unless (boundp 'org-latex-classes)
  (setq org-latex-classes nil))
(add-to-list 'org-latex-classes
	     '("article"
	       "\\documentclass{article}"
	       ("\\section{%s}" . "\\section*{%s}")
	       ("\\subsection{%s}" . "\\subsection*{%s}")))

;; PDF exports?
(setq org-latex-pdf-process '("texi2dvi -p -b -V %f"))
