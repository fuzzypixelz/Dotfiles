;;; init.el --- fuzzypixelz's Emacs Configuration  -*- lexical-binding: t; -*-

;; Copyright (c) 2023 Mahmoud Mazouz
;;
;; Permission is hereby granted, free of charge, to any person obtaining a copy
;; of this software and associated documentation files (the "Software"), to deal
;; in the Software without restriction, including without limitation the rights
;; to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
;; copies of the Software, and to permit persons to whom the Software is
;; furnished to do so, subject to the following conditions:
;;
;; The above copyright notice and this permission notice shall be included in all
;; copies or substantial portions of the Software.
;;
;; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
;; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
;; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
;; AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
;; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
;; OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
;; SOFTWARE.

;;; Commentary:

;; This program tries to reduce complexity that I have to manage;
;; it makes liberal use of well-known packages, as long as they come
;; with sane defaults and don't require extensive configuration.

;;; Code:

;; Uncomment this to profile start-up
;; (setq use-package-compute-statistics t)

;; Performance
(setq gc-cons-threshold (* 100 1000 1000))
(setq read-process-output-max (* 1024 1024))

;; MELPA
(require 'package)
(setq package-archives
      '(("GNU ELPA"     . "https://elpa.gnu.org/packages/")
        ("MELPA"        . "https://melpa.org/packages/"))
      package-archive-priorities
      '(("MELPA"        . 42)
        ("GNU ELPA"     . 0)))
(package-initialize)

;; Go away
(defalias 'yes-or-no-p 'y-or-n-p)

;; Set user info
(setq user-full-name    "Mahmoud Mazouz"
      user-mail-address "hello@fuzzypixelz.com")

;; Remove UI cruft
(menu-bar-mode 1)
(context-menu-mode 1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(tooltip-mode -1)
(setq inhibit-splash-screen t)
(setq inhibit-startup-message t)
(setq inhibit-compacting-font-caches t)
(pixel-scroll-precision-mode)

;; Keep my text compact and tidy
(setq-default fill-column 80)

;; Customize the scratch buffer message
(setq initial-scratch-message ";; Scratch Buffer Go Brrr")

;; Custom shenanigans
(setq custom-file (locate-user-emacs-file "custom.el"))
(when (file-exists-p custom-file)
  (load custom-file))

;; A configuration macro for simplifying your .emacs
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t)
(setq use-package-verbose t)

(use-package diredfl
  :config
  (diredfl-global-mode))

(use-package move-text
  :config
  (move-text-default-bindings))

;; Display line numbers
(use-package display-line-numbers
  :config
  (setq display-line-numbers 'relative)
  :hook prog-mode)

;; Save backup files in the system's temp dir
(setq backup-directory-alist
      `((".*" . ,temporary-file-directory)))
(setq auto-save-file-name-transforms
      `((".*" ,temporary-file-directory t)))

;; Save cursor location per file
(save-place-mode 1)

;; Tabs and spaces
(setq-default tab-width 2)
(setq-default indent-tabs-mode nil)

;; Set the theme
;; (require-theme 'peace-theme)
;; (load-theme 'peace t)
(add-to-list 'default-frame-alist
             '(font . "Iosevka-14"))

;; Flash the modeline instead of beeping
(setq visible-bell nil
      ring-bell-function 'flash-mode-line)

(defun flash-mode-line ()
  "Flash the modeline."
  (invert-face 'mode-line)
  (run-with-timer 0.1 nil #'invert-face 'mode-line))

;; Delimeters for the lazy
(defvar whitelisted-electic-pair-modes '(prog-mode))

(defun inhibit-electric-pair-mode (_)
  "Leave me alone, argument CHAR is not used."
  (not (member major-mode whitelisted-electic-pair-modes)))

;; Free persistent undo history
(use-package undo-tree
  :init
  (setq undo-tree-auto-save-history t)
  (setq undo-tree-history-directory-alist '(("." . "~/.config/emacs/undo")))
  :config
  (global-undo-tree-mode))

;; Display ^L page breaks as tidy horizontal lines
(use-package page-break-lines
  :config
  (global-page-break-lines-mode))

;; Manage and navigate projects in Emacs easily
(use-package projectile
  :config
  (projectile-mode 1)
  :bind
  (:map projectile-mode-map ("C-x p" . projectile-command-map)))

;; A better *help* buffer
(use-package helpful
  :bind
  ("C-h f"   . helpful-callable)
  ("C-h v"   . helpful-variable)
  ("C-h k"   . helpful-key)
  ("C-h C"   . helpful-command)
  ("C-h F"   . helpful-function)
  ("C-c C-d" . helpful-at-point))

;; A library for inserting Developer icons
(use-package all-the-icons
  :if (display-graphic-p))

;; A startup screen extracted from Spacemacs
(use-package dashboard
  :init
  (setq dashboard-startup-banner 'logo)
  (setq dashboard-center-content t)
  (setq dashboard-banner-logo-title "Eight Megabytes and Constantly Swapping")
  (setq dashboard-items '((agenda . 10)
                          (recents  . 5)))
  :config
  (dashboard-setup-startup-hook))

;; Steal DOOM's modeline
(use-package doom-modeline
  :config
  (doom-modeline-mode 1))

;; All the themes!
(use-package ef-themes)

;; Vertico
(use-package vertico
  :config
  (vertico-mode)
  (vertico-mouse-mode))

;; Persist history over Emacs restarts. Vertico sorts by history position.
(use-package savehist
  :init
  (savehist-mode))

;; Use the Orderless completion style
(use-package orderless
  :custom
  (completion-styles '(orderless basic))
  (completion-category-overrides '((file (styles basic partial-completion)))))

;; Enable rich annotations using the Marginalia package
(use-package marginalia
  :init
  (marginalia-mode))

;; Consult, completion framework
(use-package consult
  :bind (;; C-c bindings (mode-specific-map)
         ("C-c h"     . consult-history)
         ("C-c x"     . consult-mode-command)
         ("C-c m"     . consult-kmacro)
         ;; C-x bindings (ctl-x-map)
         ("C-x M-:"   . consult-complex-command)     ;; orig. repeat-complex-command
         ("C-x b"     . consult-buffer)              ;; orig. switch-to-buffer
         ("C-x 4 b"   . consult-buffer-other-window) ;; orig. switch-to-buffer-other-window
         ("C-x 5 b"   . consult-buffer-other-frame)  ;; orig. switch-to-buffer-other-frame
         ("C-x r b"   . consult-bookmark)            ;; orig. bookmark-jump
         ("C-x p b"   . consult-project-buffer)      ;; orig. project-switch-to-buffer
         ;; Custom M-# bindings for fast register access
         ("M-#"       . consult-register-load)
         ("M-'"       . consult-register-store)      ;; orig. abbrev-prefix-mark (unrelated)
         ("C-M-#"     . consult-register)
         ;; Other custom bindings
         ("M-y"       . consult-yank-pop)            ;; orig. yank-pop
         ("<help> a"  . consult-apropos)             ;; orig. apropos-command
         ;; M-g bindings (goto-map)
         ("M-g e"     . consult-compile-error)
         ("M-g f"     . consult-flycheck)            ;; Alternative: consult-flycheck
         ("M-g g"     . consult-goto-line)           ;; orig. goto-line
         ("M-g M-g"   . consult-goto-line)           ;; orig. goto-line
         ("M-g o"     . consult-outline)             ;; Alternative: consult-org-heading
         ("M-g m"     . consult-mark)
         ("M-g k"     . consult-global-mark)
         ("M-g i"     . consult-imenu)
         ("M-g I"     . consult-imenu-multi)
         ;; M-s bindings (search-map)
         ("M-s d"     . consult-find)
         ("M-s D"     . consult-locate)
         ("M-s g"     . consult-grep)
         ("M-s G"     . consult-git-grep)
         ("M-s r"     . consult-ripgrep)
         ("M-s l"     . consult-line)
         ("M-s L"     . consult-line-multi)
         ("M-s m"     . consult-multi-occur)
         ("M-s k"     . consult-keep-lines)
         ("M-s u"     . consult-focus-lines)
         ;; Isearch integration
         ("M-s e"     . consult-isearch-history)
         :map isearch-mode-map
         ("M-e"       . consult-isearch-history)     ;; orig. isearch-edit-string
         ("M-l"       . consult-line)                ;; needed by consult-line to detect isearch
         ("M-L"       . consult-line-multi)          ;; needed by consult-line to detect isearch
         ;; Minibuffer history
         :map minibuffer-local-map
         ("M-s"       . consult-history)             ;; orig. next-matching-history-element
         ("M-r"       . consult-history))            ;; orig. previous-matching-history-element
  :config
  (autoload 'projectile-project-root "projectile")
  (setq consult-project-function (lambda (_) (with-no-warnings (projectile-project-root)))))

;; Autocomplete directories
(use-package consult-dir
  :bind (("C-x C-d" . consult-dir)
         :map minibuffer-local-completion-map
         ("C-x C-d" . consult-dir)
         ("C-x C-j" . consult-dir-jump-file)))

;; Embark
(use-package embark
  :bind
  (("C-."   . embark-act)         ;; pick some comfortable binding
   ("M-."   . embark-dwim)        ;; good alternative: M-.
   ("C-h B" . embark-bindings))   ;; alternative for `describe-bindings'
  :init
  (setq prefix-help-command #'embark-prefix-help-command))

;; Consult users will also want the embark-consult package.
(use-package embark-consult
  :after (embark consult)
  :hook
  (embark-collect-mode . consult-preview-at-point-mode))

;; Completion Overlay Region Function
(use-package corfu
  :hook prog-mode
  :config
  (global-corfu-mode))

;; Pretty TODO?
(use-package hl-todo
  :hook (prog-mode . hl-todo-mode))

;; Modern on-the-fly syntax checking
(use-package flycheck
  :init (global-flycheck-mode))

(use-package consult-flycheck)

;; Magit
(use-package magit
  :bind
  ("C-c g" . magit-status))

;; Rust
(use-package rust-mode
  :defer t
  :config
  (setq rust-format-on-save t))

;; Markdown
(use-package markdown-mode)

;; Org
(use-package org
  :init
  (setq org-agenda-files '("~/Nextcloud/Organism")
        org-startup-indented t
        org-hide-emphasis-markers t
        org-src-tab-acts-natively t
        org-hide-leading-stars t
        org-pretty-entities t
        org-odd-levels-only t
        org-todo-keywords '((sequence "TODO" "NEXT" "PROG" "HOLD" "|" "DONE" "FAIL"))
        org-log-done 'time)
  :config
  (defun org-close-item ()
    (interactive)
    (org-todo "DONE"))
  (visual-line-mode)
  :bind ("C-c d" . org-close-item))

(use-package org-modern
  :config
  (global-org-modern-mode))

(use-package org-super-agenda
  :config
  (org-super-agenda-mode))

(use-package org-journal
  :init
  ;; Change default prefix key; needs to be set before loading org-journal
  (setq org-journal-prefix-key "C-c j")
  (setq org-journal-file-type 'monthly)
  (setq org-journal-encrypt-journal t)
  ; NOTE: for some reason, `org-journal-new-entry` gets put under `C-c C-j` and
  ; not `C-c j` so we might as well take advantage of that, eh?
  :bind ("C-c j" . org-journal-new-scheduled-entry)
  :config
  (setq org-journal-enable-agenda-integration t)
  (setq org-journal-dir "~/Nextcloud/Organism/Journal/"
        org-journal-date-format "%A, %d %B %Y"))

;; Zig
(use-package zig-mode :defer t)

;; Nix
(use-package nix-mode :defer t)

;; fish
(use-package fish-mode :defer t)

;; Spelling
(use-package ispell
  :commands (ispell-set-spellchecker-params ispell-hunspell-add-multi-dic)
  :init
  ;; Configure `LANG`, otherwise ispell.el cannot find a 'default
  ;; dictionary' even though multiple dictionaries will be configured
  ;; in next line.
  (setenv "LANG" "en_US.UTF-8")
  (setq ispell-program-name "hunspell")
  (setq ispell-dictionary "fr_FR,en_US")
  :config
  ;; `ispell-set-spellchecker-params` has to be called
  ;; before ispell-hunspell-add-multi-dic will work
  (ispell-set-spellchecker-params)
  (ispell-hunspell-add-multi-dic "fr_FR,en_US"))

;; Flyspell
(use-package flyspell
  :hook ((org-mode      . flyspell-mode)
         (prog-mode     . flyspell-prog-mode)
         (markdown-mode . flyspell-mode)))

;; The cooler flyspell
(use-package flyspell-correct
  :after flyspell
  :bind (:map flyspell-mode-map ("C-;" . flyspell-correct-wrapper)))

;; Expand region
(use-package expand-region
  :bind ("C-=" . er/expand-region))

;; Multiple cursors
(use-package multiple-cursors
  :bind (("C-S-c C-S-c" . mc/edit-lines)
         ("C->"         . mc/mark-next-like-this)
         ("C-<"         . mc/mark-previous-like-this)
         ("C-c C-<"     . mc/mark-all-like-this)))

;; Emacs Relay Chat
(defvar erc-prompt (lambda () (concat "[" (buffer-name) "]")))
(defvar erc-fill-function 'erc-fill-static)
(defvar erc-fill-static-center 20)
(defvar erc-rename-buffers t)
(defvar erc-interpret-mirc-color t)

;; Dial it down!
(setq gc-cons-threshold (* 100 1000))

;; UTF-8 everywhere
(prefer-coding-system       'utf-8)
(set-default-coding-systems 'utf-8)
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)

;; macOS things
(setq ns-alternate-modifier 'meta)
(setq ns-right-alternate-modifier 'none)
(setq mouse-wheel-scroll-amount '(1
                                  ((shift) . 5)
                                  ((control))))

(defun fp/set-frame-size-and-position ()
  "Set my preferred frame size and position."
  (interactive)
  (when window-system
    (set-frame-size (selected-frame) 123 43)
    (modify-frame-parameters nil '((user-position . t) (top . 0.5) (left . 0.5)))))

(defun fp/eval-and-replace ()
  "Replace the preceding sexp with its value."
  (interactive)
  (let ((value (eval (elisp--preceding-sexp))))
    (backward-kill-sexp)
    (insert (format "%S" value))))

(defun fp/erc-connect ()
  "Connect to LibraChat."
  (interactive)
  (erc-tls :server "irc.libera.chat" :port 6697
           :nick "fuzzypixelz"
           :password (read-passwd "Password: ")))

(defun fp/reload-init-file ()
  "Reload init.el without restarting Emacs."
  (interactive)
  (load user-init-file))

(defun fp/show-super-agenda ()
  "Display my weekly SUPER agenda ."
  (interactive)
  (let ((org-super-agenda-groups '((:name "📅 Today"
                                          :date today)
                                   (:name "⚠️ Overdue"
                                          :and (:scheduled past :todo "TODO")
                                          :deadline past)
                                   (:name "☠️ Coming deadlines!"
                                          :deadline t)
                                   (:name "⏳ Work in progress ..."
                                          :todo "PROG")
                                   (:name "⏭️ NEXT in line?"
                                          :todo "NEXT")
                                   (:name "🛑 Things on hold"
                                          :todo "HOLD"))))
    (ignore org-super-agenda-groups)
    (org-agenda-list)))

(defun fp/dired-open-file ()
  "Open a Dired filename in the default external program."
  (interactive)
  (when (eq major-mode 'dired-mode)
    (let ((open (pcase system-type
                 (`darwin "open")
                 ((or `gnu `gnu/linux `gnu/kfreebsd) "xdg-open"))))
      (call-process open nil 0 nil (with-no-warnings (dired-get-file-for-visit))))))

(defun fp/backward-kill-line ()
  "Kill line backwards and adjust the indentation."
  (interactive)
  (kill-line 0)
  (indent-according-to-mode))

;; From magnars
(defun fp/rename-buffer-and-file ()
  "Rename the current buffer and the file it is visiting."
  (interactive)
  (let ((name (buffer-name))
        (filename (buffer-file-name)))
    (if (not (and filename (file-exists-p filename)))
        (error "Buffer '%s' is not visiting a file!" name)
      (let ((new-name (read-file-name "New name: " filename)))
        (if (get-buffer new-name)
            (error "A buffer named '%s' already exists!" new-name)
          (rename-file filename new-name 1)
          (rename-buffer new-name)
          (set-visited-file-name new-name)
          (set-buffer-modified-p nil)
          (message "File '%s' successfully renamed to '%s'"
                   name (file-name-nondirectory new-name)))))))

(defun fp/transpose-windows ()
  "Transpose the buffers shown in two windows."
  (interactive)
  (let ((this-win (selected-window))
        (this-buffer (window-buffer)))
    (other-window 1)
    (set-window-buffer this-win (current-buffer))
    (set-window-buffer (selected-window) this-buffer)))

(defun fp/switch-to-recent-buffer ()
  "Switch to previously open buffer."
  (interactive)
  (switch-to-buffer nil))

(defun fp/other-window-or-recent-buffer ()
  "Call `other-window' if more than one window is visible.
Switch to most recent buffer otherwise."
  (interactive)
  (if (one-window-p)
      (switch-to-buffer nil)
    (other-window 1)))

(defun fp/open-line-below ()
  "Open a line under the cursor."
  (interactive)
  (end-of-line)
  (newline)
  (indent-for-tab-command))

(defun fp/open-line-above ()
  "Open a line above the cursor."
  (interactive)
  (beginning-of-line)
  (newline)
  (forward-line -1)
  (indent-for-tab-command))

(defun fp/open-line-between ()
  "Open a line by splitting the current line at point."
  (interactive)
  (newline)
  (save-excursion
    (newline)
    (indent-for-tab-command))
  (indent-for-tab-command))

(defun fp/goto-last-change ()
  "Move the point to where the last change happened."
  (interactive)
  (with-no-warnings
    (undo-tree-undo)
    (undo-tree-redo)))

(defun fp/sync-theme-randomly ()
  "Choose a random ef theme and apply it while respecting the current time."
  (interactive)
  (let* ((dark-themes  '(ef-night
                         ef-bio
                         ef-autumn
                         ef-winter
                         ef-dark
                         ef-duo-dark
                         ef-trio-dark
                         ef-tritanopia-dark
                         ef-deuteranopia-dark))
         (light-themes '(ef-day
                         ef-frost
                         ef-spring
                         ef-summer
                         ef-light
                         ef-duo-light
                         ef-trio-light
                         ef-tritanopia-light
                         ef-deuteranopia-light))
         ;; NOTE: decode-time returns (seconds minutes hour day month year dow dst utcoff)
         (this-hour (nth 2 (decode-time)))
         ;; FIXME: use proper sunrise and sunset times instead of the interval night = [18, 24] U [0, 6]
         (late-hour (or (< this-hour 6) (>= this-hour 18)))
         (themes (if late-hour dark-themes light-themes)))
    (mapc #'disable-theme custom-enabled-themes)
    (load-theme (nth (random (length themes)) themes) :no-confirm)))

(defun fp/yank-quote-from-apple-books ()
  "The macOS Books app add some shenanigans about Copyright to copy-pasted text."
  (interactive)
  (yank)
  (dotimes (_ 6)
    (kill-whole-line)
    (forward-line -1))
  (delete-char 1)
  (move-end-of-line nil)
  (delete-char -1)
  (fill-paragraph))

;; A few more useful configurations ...
;; TODO: bind `duplicate-line` and `duplicate-dwim`
(use-package emacs
  :hook ((org-mode markdown-mode) . auto-fill-mode)
  :bind (("C-c e"   . fp/eval-and-replace)
         ("C-c r"   . fp/reload-init-file)
         ("C-c a"   . fp/show-super-agenda)
         ("C-c t"   . fp/sync-theme-randomly)
         ("C-c f"   . fp/dired-open-file)
         ("C-c k"   . fp/backward-kill-line)
         ("C-c t"   . fp/transpose-windows)
         ("C-c b"   . fp/switch-to-recent-buffer)
         ("C-c o"   . fp/other-window-or-recent-buffer)
         ("C-c p"   . fp/open-line-above)
         ("C-c n"   . fp/open-line-below)
         ("C-c RET" . fp/open-line-between)
         ("C-c l"   . fp/goto-last-change)
         ("C-c s"   . fp/sync-theme-randomly)
         ("C-c c"   . fp/set-frame-size-and-position))
  :config
  (auto-revert-mode)
  (fp/set-frame-size-and-position)
  (fp/sync-theme-randomly))

;;; init.el ends here
