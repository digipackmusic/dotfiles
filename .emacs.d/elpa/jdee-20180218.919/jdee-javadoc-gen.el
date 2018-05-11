;;; jdee-javadoc-gen.el -- Javadoc builder

;; Author: Sergey A Klibanov <sakliban@cs.wustl.edu>
;; Maintainer: Paul Landes <landes <at> mailc dt net>, Sergey A Klibanov
;; Keywords: java, tools

;; Copyright (C) 2000, 2001, 2002, 2003, 2004, 2005 Paul Kinnucan.
;; Copyright (C) 2009 by Paul Landes

;; This file is not part of Emacs

;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License as
;; published by the Free Software Foundation; either version 2, or (at
;; your option) any later version.

;; This program is distributed in the hope that it will be useful, but
;; WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;; General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program; see the file COPYING.  If not, write to
;; the Free Software Foundation, Inc., 59 Temple Place - Suite 330,
;; Boston, MA 02111-1307, USA.

;;; Commentary:

;;; Code:

(require 'cl-lib)
(require 'efc)
(require 'jdee-classpath)
(require 'jdee-compile)
(require 'jdee-files)
(require 'jdee-help)

;; FIXME: refactor
(declare-function jdee-cygpath "jdee-cygwin" (path &optional direction))
(declare-function jdee-get-jdk-dir "jdee-jdk-manager" ())

(defgroup jdee-javadoc nil
  "Javadoc template generator"
  :group 'jdee
  :prefix "jdee-javadoc-")

(defcustom jdee-javadoc-display-doc t
  "*Display the documentation generated by the `jdee-javadoc-make' command. ."
  :group 'jdee-javadoc
  :type 'boolean)

(defcustom jdee-javadoc-gen-detail-switch (list "-protected")
  "Specifies what access level switch to use.
  -public will show only public classes and members
  -protected will show protected and public classes and members
  -package will show package, protected, and public classes and members
  -private will show all classes and members"
  :group 'jdee-javadoc
  :type '(list
	  (radio-button-choice
	   :format "%t \n%v"
	   :tag "Select the detail level switch you want:"
	   (const "-public")
	   (const "-protected")
	   (const "-package")
	   (const "-private"))))

(defcustom jdee-javadoc-gen-packages nil
  "Specifies which packages or files javadoc should be run on.
"
  :group 'jdee-javadoc
  :type '(repeat (string :tag "Path")))

(defcustom jdee-javadoc-gen-destination-directory "JavaDoc"
  "Specifies the directory where javadoc will put the generated files.
The path may start with a tilde (~) or period (.) and may include
environment variables. The JDEE replaces a ~ with your home directory.
If `jdee-resolve-relative-paths-p' is nonnil, the JDEE replaces the
. with the path of the current project file. The JDEE replaces each
instance of an environment variable with its value before inserting it
into the javadoc command line."
  :group 'jdee-javadoc
  :type 'string)

(defcustom jdee-javadoc-gen-link-URL nil
  "Specifies what URL's to link the generated files to.
   For more information, look at the -link option of the javadoc tool."
  :group 'jdee-javadoc
  :type '(repeat (string :tag "URL")))

(defcustom jdee-javadoc-gen-link-online nil
  "Specifies whether or not to use jdee-javadoc-gen-link-URL."
  :group 'jdee-javadoc
  :type 'boolean)

(defcustom jdee-javadoc-gen-link-offline nil
  "Specifies URLs to link to and the local path to the directory holding the package-list for each URL.
   The second argument can be a URL (http: or file:). If it is a relative file name, it is relative to the directory
   from which javadoc is run."
  :group 'jdee-javadoc
  :type '(repeat
	  (cons :tag "Remote URL and directory holding package-list for that URL"
		(string :tag "URL")
		(string :tag "Path"))))

(defcustom jdee-javadoc-gen-group nil
  "Specifies groups of packages with a group heading and package pattern.
   The heading is usually a string like Extension Packages. The pattern is
   any package name or wildcard matching that name. You can specify several
   packages by separating the package names by a semicolon."
  :group 'jdee-javadoc
  :type '(repeat
	  (cons :tag "Package group name and contents"
		(string :tag "Heading")
		(string :tag "Package Pattern"))))

(defcustom jdee-javadoc-gen-doc-title ""
  "Specifies the title to be placed near the top of the overview summary file."
  :group 'jdee-javadoc
  :type 'string)

(defcustom jdee-javadoc-gen-window-title ""
  "Specifies what should be placed in the HTML <title> tag.
   Quotations inside the title should be escaped."
  :group 'jdee-javadoc
  :type 'string)

(defcustom jdee-javadoc-gen-overview ""
  "Specifies where to get an alternate overview-summary.html.
   The path is relative to the sourcepath."
  :group 'jdee-javadoc
  :type 'string)

(defcustom jdee-javadoc-gen-doclet ""
  "Specifies the class file that starts an alternate doclet
   to generate the html files. This path is relative to docletpath"
  :group 'jdee-javadoc
  :type 'string)

(defcustom jdee-javadoc-gen-docletpath nil
  "Specifies the path in which the doclet should be searched for."
  :group 'jdee-javadoc
  :type '(repeat (string :tag "Path")))

(defcustom jdee-javadoc-gen-header ""
  "Specifies what html code should be placed at the top of each output file."
  :group 'jdee-javadoc
  :type 'string)

(defcustom jdee-javadoc-gen-footer ""
  "Specifies what html code should be placed at the bottom of each output file."
  :group 'jdee-javadoc
  :type 'string)

(defcustom jdee-javadoc-gen-bottom ""
  "Specifies what text or html code should be placed at the bottom
   below the navigation bar."
  :group 'jdee-javadoc
  :type 'string)

(defcustom jdee-javadoc-gen-helpfile ""
  "Specifies the help file to be used for the Help link in the Navigation bar."
  :group 'jdee-javadoc
  :type 'string)

(defcustom jdee-javadoc-gen-stylesheetfile ""
  "Specifies the path to an alternate HTML stylesheet file."
  :group 'jdee-javadoc
  :type 'string)

(defcustom jdee-javadoc-gen-split-index nil
  "Specifies whether or not the index should be split alphabetically
   one file per letter."
  :group 'jdee-javadoc
  :type 'boolean)

(defcustom jdee-javadoc-gen-use nil
  "Specifies whether or not to create \"Use\" pages"
  :group 'jdee-javadoc
  :type 'boolean)

(defcustom jdee-javadoc-gen-author t
  "Specifies whether or not to use @author tags"
  :group 'jdee-javadoc
  :type 'boolean)

(defcustom jdee-javadoc-gen-version t
  "Specifies whether or not to use @version tags"
  :group 'jdee-javadoc
  :type 'boolean)

(defcustom jdee-javadoc-gen-serialwarn nil
  "Specifies whether or not to generate compile-time errors for missed @serial tags"
  :group 'jdee-javadoc
  :type 'boolean)

(defcustom jdee-javadoc-gen-nodeprecated nil
  "Specifies whether or not to remove all references to deprecated code"
  :group 'jdee-javadoc
  :type 'boolean)

(defcustom jdee-javadoc-gen-nodeprecatedlist nil
  "Specifies whether or not to remove references to deprecated code
   from the navigation bar, but not the rest of the documents."
  :group 'jdee-javadoc
  :type 'boolean)

(defcustom jdee-javadoc-gen-notree nil
  "Specifies whether or not to omit generating the class/interface hierarchy."
  :group 'jdee-javadoc
  :type 'boolean)

(defcustom jdee-javadoc-gen-noindex nil
  "Specifies whether or not to omit generating the index."
  :group 'jdee-javadoc
  :type 'boolean)

(defcustom jdee-javadoc-gen-nohelp nil
  "Specifies whether or not to omit the HELP link in the navigation bar of each page."
  :group 'jdee-javadoc
  :type 'boolean)

(defcustom jdee-javadoc-gen-nonavbar nil
  "Specifies whether or not to omit generating the navigation bar at the top of each page."
  :group 'jdee-javadoc
  :type 'boolean)

(defcustom jdee-javadoc-gen-verbose nil
  "Specifies whether or not javadoc should be verbose about what it is doing."
  :group 'jdee-javadoc
  :type 'boolean)


(defcustom jdee-javadoc-gen-args nil
  "Specifies any other arguments that you want to pass to javadoc."
  :group 'jdee-javadoc
  :type '(repeat (string :tag "Argument")))

(defclass jdee-javadoc-maker (efc-compiler)
  ((make-packages-p  :initarg :make-packages-p
		     :type boolean
		     :initform t
		     :documentation "Nonnil generates doc for packages."))
  "Class of Javadoc generators.")

(defmethod initialize-instance ((this jdee-javadoc-maker) &rest fields)
  "Initialize the Javadoc generator."

  (oset this name "javadoc")

  (oset
   this
   comp-finish-fcn
   (lambda (buf msg)
     (message msg)
     (if (and
	  jdee-javadoc-display-doc
	  (string-match "finished" msg))
	 (browse-url-of-file
	  (expand-file-name
	   "index.html"
	   (jdee-normalize-path
	    jdee-javadoc-gen-destination-directory
	    'jdee-javadoc-gen-destination-directory))))))

  (oset
   this
   exec-path
   (jdee-cygpath (expand-file-name "bin/javadoc" (jdee-get-jdk-dir)) t)))

(defmethod get-args ((this jdee-javadoc-maker))
  "Get the arguments to pass to the javadoc process as specified
by the jdee-javadoc-gen variables."
  (let* ((destination-directory
	  (jdee-normalize-path
	   jdee-javadoc-gen-destination-directory
	   'jdee-javadoc-gen-destination-directory))
	 (args
	  (list
	   "-d" destination-directory
	   (car jdee-javadoc-gen-detail-switch))))

    (if (not (file-exists-p destination-directory))
	(make-directory destination-directory))

    ;;Insert online links
    (if jdee-javadoc-gen-link-online
	(setq args
	      (append
	       args
	       (cl-mapcan
		(lambda (link)  (list "-link" link))
		jdee-javadoc-gen-link-URL))))

    ;;Insert offline links
    (if jdee-javadoc-gen-link-offline
	(setq args
	      (append
	       args
	       (cl-mapcan
		(lambda (link)
		  (list "-linkoffline" (car  link) (cdr link)))
		jdee-javadoc-gen-link-offline))))

    ;;Insert -group
    (if jdee-javadoc-gen-group
	(setq args
	      (append
	       args
	       (cl-mapcan
		(lambda (group)
		  (list "-group" (car group) (cdr group)))
		jdee-javadoc-gen-group))))


     ;; Insert classpath
    (if jdee-global-classpath
	(setq args
	      (append
	       args
	       (list
		"-classpath"
		(jdee-build-classpath
		 (jdee-get-global-classpath)
		 'jdee-global-classpath)))))


    ;; Insert sourcepath
    (if jdee-sourcepath
	(setq args
	      (append
	       args
	       (list
		"-sourcepath"
		(jdee-build-classpath
		 (jdee-expand-wildcards-and-normalize jdee-sourcepath 'jdee-sourcepath))))))


    ;; Insert bootclasspath
    (if jdee-compile-option-bootclasspath
	(setq args
	      (append
	       args
	       (list
		"-bootclasspath"
	       (jdee-build-classpath
		jdee-compile-option-bootclasspath
		'jdee-compile-option-bootclasspath)))))

    ;; Insert extdirs
    (if jdee-compile-option-extdirs
	(setq args
	      (append
	       args
	       (list
		"-extdirs"
	       (jdee-build-classpath
		jdee-compile-option-extdirs
		'jdee-compile-option-extdirs)))))

    ;; Insert windowtitle
    (if (not (equal "" jdee-javadoc-gen-window-title))
	(setq args
	      (append
	       args
	       (list
		"-windowtitle"
		jdee-javadoc-gen-window-title))))

    ;; Insert doctitle
    (if (not (equal "" jdee-javadoc-gen-doc-title))
	(setq args
	      (append
	       args
	       (list
		"-doctitle"
		jdee-javadoc-gen-doc-title))))

    ;; Insert header
    (if (not (equal "" jdee-javadoc-gen-header))
	(setq args
	      (append
	       args
	       (list
		"-header"
		jdee-javadoc-gen-header))))

    ;; Insert footer
    (if (not (equal "" jdee-javadoc-gen-footer))
	(setq args
	      (append
	       args
	       (list
		"-footer"
		jdee-javadoc-gen-footer))))

    ;; Insert bottom
    (if (not (equal "" jdee-javadoc-gen-bottom))
	(setq args
	      (append
	       args
	       (list
		"-bottom"
		jdee-javadoc-gen-bottom))))

    ;; Insert helpfile
    (if (not (equal "" jdee-javadoc-gen-helpfile))
	(setq args
	      (append
	       args
	       (list
	       "-helpfile"
	       (jdee-normalize-path 'jdee-javadoc-gen-helpfile)))))

    ;; Insert stylesheet
    (if (not (equal "" jdee-javadoc-gen-stylesheetfile))
	(setq args
	      (append
	       args
	       (list
		"-stylesheetfile"
		(jdee-normalize-path 'jdee-javadoc-gen-stylesheetfile)))))

    ;; Insert -overview
    (if (not (equal "" jdee-javadoc-gen-overview))
	(setq args
	      (append
	       args
	       (list
		"-overview"
		jdee-javadoc-gen-overview))))

    ;; Insert -doclet
    (if (not (equal "" jdee-javadoc-gen-doclet))
	(setq args
	      (append
	       args
	       (list
		"-doclet"
		jdee-javadoc-gen-doclet))))

    ;; Insert -docletpath
    (if jdee-javadoc-gen-docletpath
	(setq args
	      (append
	       args
	       (list
		"-docletpath"
	       (jdee-build-classpath
		jdee-javadoc-gen-docletpath
		'jdee-javadoc-gen-docletpath)))))

    ;; Inser -use
    (if jdee-javadoc-gen-use
	(setq args
	      (append
	       args
	       (list "-use"))))

    ;;Insert -author
    (if jdee-javadoc-gen-author
	(setq args
	      (append
	       args
	       (list "-author"))))

    ;;Insert -version
    (if jdee-javadoc-gen-version
	(setq args
	      (append
	       args
	       (list "-version"))))

    ;;Insert -splitindex
    (if jdee-javadoc-gen-split-index
	(setq args
	      (append
	       args
	       (list "-splitindex"))))

    ;;Insert -nodeprecated
    (if jdee-javadoc-gen-nodeprecated
	(setq args
	      (append
	       args
	       (list "-nodeprecated"))))

    ;;Insert -nodeprecatedlist
    (if jdee-javadoc-gen-nodeprecatedlist
	(setq args
	      (append
	       args
	       (list "-nodeprecatedlist"))))

    ;;Insert -notree
    (if jdee-javadoc-gen-notree
	(setq args
	      (append
	       args
	       (list "-notree"))))

    ;;Insert -noindex
    (if jdee-javadoc-gen-noindex
	(setq args
	      (append
	       args
	       (list "-noindex"))))

    ;;Insert -nohelp
    (if jdee-javadoc-gen-nohelp
	(setq args
	      (append
	       args
	       (list "-nohelp"))))

    ;;Insert -nonavbar
    (if jdee-javadoc-gen-nonavbar
	(setq args
	      (append
	       args
	       (list "-nonavbar"))))

    ;;Insert -serialwarn
    (if jdee-javadoc-gen-serialwarn
	(setq args
	      (append
	       args
	       (list  "-serialwarn"))))

    ;;Insert -verbose
    (if jdee-javadoc-gen-verbose
	(setq args
	      (append
	       args
	       (list  "-verbose"))))

    ;;Insert other tags
    (if jdee-javadoc-gen-args
	(setq args
	      (append
	       args
	       jdee-javadoc-gen-args)))

    ;;Insert packages/files
    (if (and (oref this make-packages-p) jdee-javadoc-gen-packages)
	(setq args
	      (append
	       args
	       (mapcar
		(lambda (packagename) packagename)
		jdee-javadoc-gen-packages)))
      (setq
       args
       (append args (list (buffer-file-name)))))))


;;;###autoload
(defun jdee-javadoc-make-internal (&optional make-packages-p)
  "Generates javadoc for the current project if MAKE-PACKAGES-P
and `jdee-javadoc-gen-packages' are nonnil; otherwise, make doc
for the current buffer. This command runs the
currently selected javadoc's program to generate the documentation.
It uses `jdee-get-jdk-dir' to determine the location of
the currentlyh selected JDK. The variable `jdee-global-classpath' specifies
the javadoc -classpath argument. The variable `jdee-sourcepath'
specifies the javadoc  -sourcepath argument. You can specify all
other javadoc options via JDE customization variables. To specify the
options, select Project->Options->Javadoc from the JDE menu. Use
`jdee-javadoc-gen-packages' to specify the packages, classes, or source
files for which you want to generate javadoc. If this variable is nil,
this command generates javadoc for the Java source file in the current
buffer. If `jdee-javadoc-display-doc' is nonnil, this command displays
the generated documentation in a browser."
  (save-some-buffers)
  (let ((generator
	 (jdee-javadoc-maker
	  "javadoc generator"
	  :make-packages-p make-packages-p)))
    (exec generator)))



;;;###autoload
(defun jdee-javadoc-make ()
  "Generates javadoc for the current project. This command runs the
currently selected JDK's javadoc program to generate the documentation.
It uses `jdee-get-jdk-dir' to determine the location of the currently
selected JDK. The variable `jdee-global-classpath' specifies the javadoc
-classpath argument. The variable `jdee-sourcepath'
specifies the javadoc  -sourcepath argument. You can specify all
other javadoc options via JDE customization variables. To specify the
options, select Project->Options->Javadoc from the JDE menu. Use
`jdee-javadoc-gen-packages' to specify the packages, classes, or source
files for which you want to generate javadoc. If this variable is nil,
this command generates javadoc for the Java source file in the current
buffer. If `jdee-javadoc-display-doc' is nonnil, this command displays
the generated documentation in a browser."
  (interactive)
  (jdee-javadoc-make-internal t))

;;;###autoload
(defun jdee-javadoc-make-buffer ()
  "Generates javadoc for the current buffer. This command runs the
currently selected JDK's javadoc program to generate the
documentation. It uses `jdee-get-jdk-dir' to determine the location of the currently
selected JDK.  The variable `jdee-global-classpath' specifies the
javadoc -classpath argument. The variable `jdee-sourcepath' specifies
the javadoc -sourcepath argument. You can specify all other javadoc
options via JDE customization variables. To specify the options,
select Project->Options->Javadoc from the JDE menu. Use
`jdee-javadoc-make' to generate doc for the files and packages
specified by `jdee-javadoc-gen-packages'. If `jdee-javadoc-display-doc'
is nonnil, this command displays the generated documentation in a
browser."
  (interactive)
  (jdee-javadoc-make-internal))

(defun jdee-javadoc-browse-tool-doc ()
  "Displays the documentation for the javadoc tool in a browser."
  (interactive)
  (let* ((jdk-url (jdee-jdhelper-jdk-url jdee-jdhelper-singleton))
	 (javadoc-url
	  (concat
	   (substring jdk-url 0 (string-match "index" jdk-url))
	   (if (eq system-type 'windows-nt) "tooldocs/windows/" "tooldocs/solaris/")
	   "javadoc.html")))
    (browse-url javadoc-url)))


(provide 'jdee-javadoc-gen)

;;; jdee-javadoc-gen.el ends here
