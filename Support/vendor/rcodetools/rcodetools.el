;;; rcodetools.el -- annotation / accurate completion / browsing documentation

;;; Copyright (c) 2006 rubikitch <rubikitch@ruby-lang.org>
;;;
;;; Use and distribution subject to the terms of the Ruby license.

(defvar xmpfilter-command-name "ruby -S xmpfilter --dev"
  "The xmpfilter command name.")
(defvar rct-doc-command-name "ruby -S rct-doc --dev"
  "The rct-doc command name.")
(defvar rct-complete-command-name "ruby -S rct-complete --dev"
  "The rct-complete command name.")
(defvar rct-option-history nil)                ;internal
(defvar rct-option-local nil)     ;internal
(make-variable-buffer-local 'rct-option-local)

(defadvice comment-dwim (around rct-hack activate)
  "If comment-dwim is successively called, add => mark."
  (if (and (eq major-mode 'ruby-mode)
           (eq last-command 'comment-dwim)
           ;; TODO =>check
           )
      (insert "=>")
    ad-do-it))
;; To remove this advice.
;; (progn (ad-disable-advice 'comment-dwim 'around 'rct-hack) (ad-update 'comment-dwim)) 

(defun rct-current-line ()
  "Return the vertical position of point..."
  (+ (count-lines (point-min) (point))
     (if (= (current-column) 0) 1 0)))

(defun rct-save-position (proc)
  "Evaluate proc with saving current-line/current-column/window-start."
  (let ((line (rct-current-line))
        (col  (current-column))
        (wstart (window-start)))
    (funcall proc)
    (goto-char (point-min))
    (forward-line (1- line))
    (move-to-column col)
    (set-window-start (selected-window) wstart)))

(defun rct-interactive ()
  "All the rcodetools-related commands with prefix args read rcodetools' common option. And store option into buffer-local variable."
  (list
   (let ((option (or rct-option-local "")))
     (if current-prefix-arg
         (setq rct-option-local
               (read-from-minibuffer "rcodetools option: " option nil nil 'rct-option-history))
       option))))  

(defun xmp (&optional option)
  "Run xmpfilter for annotation/test/spec on whole buffer.
See also `rct-interactive'. "
  (interactive (rct-interactive))
  (rct-save-position
   (lambda () (shell-command-on-region (point-min) (point-max) (xmpfilter-command option) t t))))

(defun xmpfilter-command (&optional option)
  "The xmpfilter command line, DWIM."
  (setq option (or option ""))
  (cond ((save-excursion
           (goto-char 1)
           (search-forward "< Test::Unit::TestCase" nil t))
         (format "%s --unittest %s" xmpfilter-command-name option))
        ((save-excursion
           (goto-char 1)
           (re-search-forward "^context.+do$" nil t))
         (format "%s --spec %s" xmpfilter-command-name option))
        (t
         (format "%s %s" xmpfilter-command-name option))))

;;;; Completion
(defvar rct-method-completion-table nil) ;internal
(defvar rct-complete-symbol-function 'rct-complete-symbol--normal
  "Function to use rct-complete-symbol.")
;; (setq rct-complete-symbol-function 'rct-complete-symbol--icicles)

(defun rct-complete-symbol (&optional option)
  "Perform ruby method and class completion on the text around point.
This command only calls a function according to `rct-complete-symbol-function'.
See also `rct-interactive', `rct-complete-symbol--normal', and `rct-complete-symbol--icicles'."
  (interactive (rct-interactive))
  (call-interactively rct-complete-symbol-function))

(defun rct-complete-symbol--normal (&optional option)
  "Perform ruby method and class completion on the text around point.
See also `rct-interactive'."
  (interactive (rct-interactive))
  (let ((end (point)) beg
	pattern alist
	completion)
    (setq completion (rct-try-completion)) ; set also pattern / completion
    (save-excursion
      (search-backward pattern)
      (setq beg (point)))
    (cond ((eq completion t)            ;sole completion
           (message "%s" "Sole completion"))
	  ((null completion)            ;no completions
	   (message "Can't find completion for \"%s\"" pattern)
	   (ding))
	  ((not (string= pattern completion)) ;partial completion
           (delete-region beg end)      ;delete word
	   (insert completion)
           (message ""))
	  (t
	   (message "Making completion list...")
	   (with-output-to-temp-buffer "*Completions*"
	     (display-completion-list
	      (all-completions pattern alist)))
	   (message "Making completion list...%s" "done")))))

;; (define-key ruby-mode-map "\M-\C-i" 'rct-complete-symbol)

(defun rct-exec-and-eval (command opt)
  "Execute rct-complete/rct-doc and evaluate the output."
  (let ((eval-buffer  (get-buffer-create " *rct-eval*")))
    ;; copy to temporary buffer to do completion at non-EOL.
    (shell-command-on-region
     (point-min) (point-max)
     (format "%s %s %s --line=%d --column=%d"
             command opt (or rct-option-local "")
             (rct-current-line) (current-column))
     eval-buffer)
    (message "")
    (eval (with-current-buffer eval-buffer
            (goto-char 1)
            (read (current-buffer))))))

(defun rct-try-completion ()
  "Evaluate the output of rct-complete."
  (rct-exec-and-eval rct-complete-command-name "--completion-emacs"))

;;;; TAGS or Ri
(autoload 'ri "ri-ruby" nil t)
(defvar rct-find-tag-if-available t
  "If non-nil and the method location is in TAGS, go to the location instead of show documentation.")
(defun rct-ri (&optional option)
  "Browse Ri document at the point.
If `rct-find-tag-if-available' is non-nil, search the definition using TAGS.

See also `rct-interactive'. "
  (interactive (rct-interactive))
  (rct-exec-and-eval
   rct-doc-command-name
   (concat "--ri-emacs --use-method-analyzer "
           (if (buffer-file-name)
               (concat "--filename=" (buffer-file-name))
             ""))))

(defun rct-find-tag-or-ri (fullname)
  (if (not rct-find-tag-if-available)
      (ri fullname)
    (condition-case err
        (let ()
          (visit-tags-table-buffer)
          (find-tag-in-order (concat "::" fullname) 'search-forward '(tag-exact-match-p) nil  "containing" t))
      (error
       (ri fullname)))))

(provide 'rcodetools)
