(add-to-list 'custom-theme-load-path "~/.emacs.d/packages/tomorrow-theme/GNU Emacs")

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(auto-revert-verbose nil)
 '(blink-cursor-mode t)
 '(c-basic-offset 4)
 '(c-default-style "bsd")
 '(cua-enable-cua-keys nil)
 '(cua-mode t nil (cua-base))
 '(custom-enabled-themes (quote (tomorrow-night-bright)))
 '(custom-safe-themes (quote ("5ee12d8250b0952deefc88814cf0672327d7ee70b16344372db9460e9a0e3ffc" default)))
 '(dabbrev-case-replace nil)
 '(default-frame-alist (quote ((font . "Ubuntu Mono 12"))))
 '(desktop-save-mode t)
 '(diff-switches "-u")
 '(dired-isearch-filenames t)
 '(ediff-split-window-function (quote split-window-horizontally))
 '(electric-layout-mode t)
 '(fill-column 80)
 '(flyspell-auto-correct-binding [(control 39)])
 '(frame-background-mode (quote dark))
 '(global-auto-revert-mode t)
 '(global-auto-revert-non-file-buffers t)
 '(global-ede-mode t)
 '(global-visual-line-mode t)
 '(history-length 500)
 '(ibuffer-expert t)
 '(ibuffer-formats (quote ((mark modified read-only " " (name 25 25 :left :elide) " " (size 6 -1 :right) " " (mode 10 10 :left :elide) " " (filename-and-process -1 60 :left :elide)) (mark " " (name 30 -1) " " filename))))
 '(ibuffer-show-empty-filter-groups nil)
 '(ido-enable-flex-matching t)
 '(ido-everywhere t)
 '(ido-max-prospects 128)
 '(ido-mode (quote both) nil (ido))
 '(indent-tabs-mode nil)
 '(indicate-empty-lines t)
 '(inhibit-startup-echo-area-message (user-login-name))
 '(inhibit-startup-screen t)
 '(initial-scratch-message nil)
 '(kill-whole-line t)
 '(lazy-highlight-initial-delay 0)
 '(mouse-wheel-progressive-speed nil)
 '(org-replace-disputed-keys t)
 '(package-archives (quote (("gnu" . "http://elpa.gnu.org/packages/") ("melpa" . "http://melpa.milkbox.net/packages/"))))
 '(recentf-max-saved-items 1000)
 '(recentf-mode t)
 '(save-place t nil (saveplace))
 '(scroll-bar-mode nil)
 '(scroll-conservatively 10000)
 '(scroll-margin 5)
 '(scroll-preserve-screen-position t)
 '(semantic-default-submodes (quote (global-semantic-stickyfunc-mode global-semantic-idle-scheduler-mode global-semanticdb-minor-mode)))
 '(show-paren-delay 0)
 '(show-paren-mode t)
 '(show-paren-style (quote expression))
 '(tab-width 4)
 '(tool-bar-mode nil)
 '(uniquify-buffer-name-style (quote post-forward) nil (uniquify))
 '(uniquify-separator ":")
 '(winner-mode t nil (winner)))

(setq ido-ignore-buffers `("^\\*.*\\*$" . ,ido-ignore-buffers))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
