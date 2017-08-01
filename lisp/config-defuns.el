;;; config-defuns.el --- custom functions, macros and advices -*- lexical-binding: t; byte-compile-warnings: (not free-vars unresolved) -*-
;;; Commentary:
;;; Code:

(require 's)

(defmacro my/save-kill-ring (&rest body)
  "Save `kill-ring' and restore it after executing BODY."
  `(let ((orig-kill-ring kill-ring)
         (orig-kill-ring-yank-pointer kill-ring-yank-pointer))
     (unwind-protect
         ,@body)
     (setq kill-ring orig-kill-ring
           kill-ring-yank-pointer orig-kill-ring-yank-pointer)))

(defun my/region-or-current-word ()
  "Return region if active else current word."
  (if (region-active-p)
      (buffer-substring (region-beginning) (region-end))
    (current-word)))

;;;###autoload
(defun my/cleanup-buffer ()
  "Perform a bunch of operations on the whitespace content of a buffer."
  (interactive)
  (delete-trailing-whitespace)
  (indent-region (point-min) (point-max)))

;;;###autoload
(defun my/filter-buffer ()
  "Run shell command on buffer and replace it with the output."
  (interactive)
  (let ((prev-point (point)))
    (call-process-region (point-min) (point-max) shell-file-name t t nil shell-command-switch
                         (read-shell-command "Shell command on buffer: "))
    (goto-char prev-point)))

;;;###autoload
(defun my/open-line-below (n)
  "Go to end of line, then insert N newlines and indent."
  (interactive "*p")
  (end-of-line)
  (newline n t)
  (indent-according-to-mode))

;;;###autoload
(defun my/open-line-above (n)
  "Go to end of line, then insert N newlines and indent."
  (interactive "*p")
  (beginning-of-line)
  (newline n t)
  (forward-line (- n))
  (indent-according-to-mode))

;;;###autoload
(defun my/diff-current-buffer-with-file ()
  "View the differences between current buffer and its associated file."
  (interactive)
  (if (buffer-modified-p)
      (diff-buffer-with-file (current-buffer))
    (message "Buffer not modified")))

;;;###autoload
(defun my/revert-buffer-no-confirmation ()
  "Invoke `revert-buffer' without the confirmation."
  (interactive)
  (revert-buffer nil t t)
  (message "Reverted buffer %s" buffer-file-name))

;;;###autoload
(defun my/kill-buffer-other-window ()
  "Kill buffer in other window."
  (interactive)
  (kill-buffer (window-buffer (next-window))))

;;;###autoload
(defun my/swiper-region-or-current-word ()
  "Run swiper on region or current word."
  (interactive)
  (swiper (my/region-or-current-word)))

;;;###autoload
(defun my/counsel-rg (&optional initial-directory)
  "Run `counsel-rg' in working directory or in INITIAL-DIRECTORY if non-nil."
  (interactive)
  (counsel-rg (my/region-or-current-word) (or initial-directory default-directory)))

;;;###autoload
(defun my/counsel-projectile-rg ()
  "Run `counsel-rg' in the PROJECT-ROOT."
  (interactive)
  (my/counsel-rg (projectile-project-root)))

;;;###autoload
(defun my/eval-and-replace ()
  "Replace the preceding sexp with its value."
  (interactive)
  (let ((original-point (point)))
    (let ((eval-expression-print-length nil)
          (eval-expression-print-level nil))
      (eval-last-sexp t))
    (let ((distance (- (point) original-point)))
      (backward-char distance)
      (backward-kill-sexp)
      (forward-char distance))))

;;;###autoload
(defun my/balance-windows (&rest _args)
  "Call `balance-windows' while ignoring ARGS."
  (balance-windows))

;;;###autoload
(defun my/indent-yanked-region (&rest _args)
  "Indent region in major modes that don't mind indentation, ignoring ARGS."
  (if (and
       (derived-mode-p 'prog-mode)
       (not (member major-mode '(python-mode ruby-mode makefile-mode))))
      (let ((mark-even-if-inactive transient-mark-mode))
        (indent-region (region-beginning) (region-end) nil))))

;;;###autoload
(defun my/colorize-compilation-buffer ()
  "Colorize complication buffer."
  (when (eq major-mode 'compilation-mode)
    (ansi-color-apply-on-region compilation-filter-start (point-max))))

;;;###autoload
(defun my/rotate-windows ()
  "Rotate your windows."
  (interactive)
  (if (not (> (count-windows) 1))
      (message "You can't rotate a single window!")
    (let ((i 1)
          (numWindows (count-windows)))
      (while  (< i numWindows)
        (let* (
               (w1 (elt (window-list) i))
               (w2 (elt (window-list) (+ (% i numWindows) 1)))

               (b1 (window-buffer w1))
               (b2 (window-buffer w2))

               (s1 (window-start w1))
               (s2 (window-start w2))
               )
          (set-window-buffer w1  b2)
          (set-window-buffer w2 b1)
          (set-window-start w1 s2)
          (set-window-start w2 s1)
          (setq i (1+ i)))))))

;;;###autoload
(defun my/toggle-comment-line-or-region ()
  "Toggle comment on line if no region is active, or comment region."
  (interactive)
  (let (beg end)
    (if (region-active-p)
        (setq beg (region-beginning) end (region-end))
      (setq beg (line-beginning-position) end (line-end-position)))
    (comment-or-uncomment-region beg end)))

;;;###autoload
(defun my/increment-number-at-point (n)
  "Increment number at point by N."
  (interactive "p")
  (let* ((bounds (bounds-of-thing-at-point 'word))
         (start (car bounds))
         (end (cdr bounds))
         (str (buffer-substring start end))
         (new-num (number-to-string (+ n (string-to-number str)))))
    (delete-region start end)
    (insert (if (s-starts-with? "0" str) (s-pad-left (length str) "0" new-num) new-num))))

;;;###autoload
(defun my/decrement-number-at-point (n)
  "Decrement number at point by N."
  (interactive "p")
  (my/increment-number-at-point (- n)))

;;;###autoload
(defun my/goto-line-with-feedback ()
  "Show line numbers temporarily, while prompting for the line number input."
  (interactive)
  (unwind-protect
      (progn
        (linum-mode 1)
        (let ((current-prefix-arg (read-number "Goto line: ")))
          (call-interactively 'goto-line)))
    (linum-mode -1)))

;;;###autoload
(defun my/projectile-disable-remove-current-project (orig-fun &rest args)
  "Call ORIG-FUN with ARGS while replacing projectile--remove-current-project with identity function."
  (cl-letf (((symbol-function 'projectile--remove-current-project) #'identity))
    (apply orig-fun args)))

;;;###autoload
(defun my/narrow-or-widen-dwim (p)
  "Widen if buffer is narrowed, narrow-dwim otherwise.
Dwim means: region, org-src-block, org-subtree, or
defun, whichever applies first.  Narrowing to
org-src-block actually calls `org-edit-src-code'.

With prefix P, don't widen, just narrow even if buffer
is already narrowed.

Taken from http://endlessparentheses.com/emacs-narrow-or-widen-dwim.html"
  (interactive "P")
  (cond ((and (buffer-narrowed-p) (not p)) (widen))
        ((region-active-p) (narrow-to-region (region-beginning) (region-end)))
        (t (narrow-to-defun))))

;;;###autoload
(defun my/git-messenger-show-with-magit ()
  "Use magit to show the commit of git-messenger."
  (interactive)
  (magit-show-commit git-messenger:last-commit-id)
  (git-messenger:popup-close))

;;;###autoload
(defun my/git-messenger-link-commit ()
  "Get a link to the commit of git-messenger."
  (interactive)
  (cl-letf (((symbol-function 'word-at-point) (lambda () git-messenger:last-commit-id)))
    (call-interactively 'git-link-commit))
  (git-messenger:popup-close))

;;;###autoload
(defun my/git-link-homepage-in-browser ()
  "Open the repository homepage in the browser."
  (interactive)
  (let ((git-link-open-in-browser t))
    (ignore git-link-open-in-browser)
    (call-interactively 'git-link-homepage)))

;;;###autoload
(defun my/show-buffer-file-name ()
  "Show the full path to the current file in the minibuffer."
  (interactive)
  (let ((file-name (buffer-file-name)))
    (if file-name
        (progn
          (message file-name)
          (kill-new file-name))
      (error "Buffer not visiting a file"))))

;;;###autoload
(defun my/indent-line-or-region ()
  "Indent region if it is active, otherwise indent line."
  (interactive)
  (if (region-active-p)
      (let ((start (save-excursion
                     (goto-char (region-beginning))
                     (line-beginning-position))))
        (indent-region start (region-end))
        (setq deactivate-mark nil))
    (indent-according-to-mode)))

;; C++ auto insert

;;;###autoload
(defun my/get-current-class ()
  "Return name of enclosing class."
  (save-excursion
    (search-backward "class" nil t)
    (forward-word 2)
    (backward-word)
    (current-word)))

;;;###autoload
(defun my/insert-default-ctor ()
  "Insert default constructor."
  (interactive)
  (insert (my/get-current-class) "() = default;"))

;;;###autoload
(defun my/insert-virtual-dtor ()
  "Insert virtual destructor."
  (interactive)
  (insert "virtual ~" (my/get-current-class) "() = default;"))

;;;###autoload
(defun my/insert-copy-ctor ()
  "Insert copy constructor."
  (interactive)
  (let ((current-class (my/get-current-class)))
    (insert current-class "(const " current-class " &) = default;")))

;;;###autoload
(defun my/insert-copy-assignment-operator ()
  "Insert copy assignment operator."
  (interactive)
  (let ((current-class (my/get-current-class)))
    (insert current-class " & operator=(const " current-class " &) = default;")))

;;;###autoload
(defun my/insert-move-ctor ()
  "Insert move constructor."
  (interactive)
  (let ((current-class (my/get-current-class)))
    (insert current-class "(" current-class " &&) = default;")))

;;;###autoload
(defun my/insert-move-assignment-operator ()
  "Insert move assignment operator."
  (interactive)
  (let ((current-class (my/get-current-class)))
    (insert current-class " & operator=(" current-class " &&) = default;")))

;;;###autoload
(defun my/insert-all-special ()
  "Insert all special methods."
  (interactive)
  (my/insert-copy-ctor)
  (newline-and-indent)
  (my/insert-copy-assignment-operator)
  (newline-and-indent)
  (my/insert-move-ctor)
  (newline-and-indent)
  (my/insert-move-assignment-operator)
  (newline-and-indent)
  )

;;;###autoload
(defun my/find-user-init-file ()
  "Run `find-file' on `user-init-file'."
  (interactive)
  (find-file user-init-file))

;;;###autoload
(defun my/scroll-up (n)
  "Scroll up N lines."
  (interactive "p")
  (scroll-up n))
;;;###autoload
(defun my/scroll-down (n)
  "Scroll down N lines."
  (interactive "p")
  (scroll-down n))
;;;###autoload
(defun my/scroll-other-window-up (n)
  "Scroll other window up N lines."
  (interactive "p")
  (scroll-other-window n))
;;;###autoload
(defun my/scroll-other-window-down (n)
  "Scroll other window down N lines."
  (interactive "p")
  (scroll-other-window (- n)))

(defun my/py-isort-buffer ()
  "Wrap `py-isort-buffer' with `my/save-kill-ring'."
  (interactive)
  (my/save-kill-ring
   (py-isort-buffer)))

;;;###autoload
(defun my/python-insert-import ()
  "Move current line, which should be an import statement, to the beginning of the file and run isort."
  (interactive)
  (save-excursion
    (let ((import-string (delete-and-extract-region (line-beginning-position) (line-end-position))))
      (delete-char -1)
      (goto-char (point-min))
      (while (or (not (looking-at "$")) (python-syntax-comment-or-string-p))
        (forward-line))
      (insert import-string)
      (indent-region (line-beginning-position) (line-end-position))
      (my/py-isort-buffer))))

;;;###autoload
(defun my/turn-on-anaconda-mode ()
  "Turn on Anaconda mode and Anaconda eldoc mode."
  (anaconda-mode 1)
  (anaconda-eldoc-mode 1))

;; hooks

;;;###autoload
(defun my/org-mode-hook ()
  "."
  (make-local-variable 'show-paren-mode)
  (setq show-paren-mode nil)
  (flyspell-mode 1))

;;;###autoload
(defun my/prog-mode-hook ()
  "."
  (rainbow-delimiters-mode 1)
  (setq show-trailing-whitespace t)
  (font-lock-add-keywords
   nil
   '(("\\<\\(FIXME\\|TODO\\|XXX\\|BUG\\)\\>" 1 font-lock-warning-face t))))

;;;###autoload
(defun my/c-mode-common-hook ()
  "."
  (setq comment-start "/*"
        comment-end "*/")
  (c-set-offset 'innamespace 0))

;;;###autoload
(defun my/ibuffer-mode-hook ()
  "."
  (ibuffer-switch-to-saved-filter-groups "default"))

;;;###autoload
(defun my/markdown-mode-hook ()
  "."
  (auto-fill-mode 1)
  (refill-mode 1))

;;;###autoload
(defun my/pyvenv-activate ()
  "."
  (if (bound-and-true-p pyvenv-activate)
      (pyvenv-activate pyvenv-activate)))

;;;###autoload
(defun my/company-anaconda-setup ()
  "."
  (make-local-variable 'company-backends)
  (push 'company-anaconda company-backends))

;;;###autoload
(defun my/projectile-kill-buffers ()
  "Kill all buffers from current project."
  (interactive)
  (mapc 'kill-buffer (-remove 'buffer-base-buffer (projectile-project-buffers))))

;;;###autoload
(defun my/pylint-ignore-errors-at-point ()
  "Add a pylint ignore comment for the error on the current line."
  (interactive)
  (let* ((errs (flycheck-overlay-errors-in (line-beginning-position) (line-end-position)))
         (ids (delete-dups (-map 'flycheck-error-id errs))))
    (when (> (length ids) 0)
      (save-excursion
        (comment-indent)
        (insert "pylint: disable="
                (s-join ", " ids))))))

(provide 'config-defuns)

;;; config-defuns.el ends here
