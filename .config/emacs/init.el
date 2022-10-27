;;; init.el --- fuzzypixelz's Emacs Configuration  -*- lexical-binding: t; -*-

;; Copyright (c) 2022 Mahmoud Mazouz
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

;; MELPA
(require 'package)
(setq package-archives
      '(("GNU ELPA"     . "https://elpa.gnu.org/packages/")
        ("MELPA"        . "https://melpa.org/packages/"))
      package-archive-priorities
      '(("MELPA"        . 42)
        ("GNU ELPA"     . 0)))
(package-initialize)

;; Reloading
(defun reload-init-file ()
  "Reload init.el without restarting Emacs."
  (interactive)
  (load user-init-file))

;; Keep my text compact and tidy
(setq-default fill-column 80)

;; Performance
(setq gc-cons-threshold (* 100 1000 1000))
(setq read-process-output-max (* 1024 1024))

;; Go away
(defalias 'yes-or-no-p 'y-or-n-p)

;; Set user info
(setq user-full-name    "Mahmoud Mazouz"
      user-mail-address "mazouz.mahmoud@outlook.com")

;; Remove UI cruft
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(setq inhibit-splash-screen t)
(setq inhibit-startup-message t)
(setq inhibit-compacting-font-caches t)

;; Customize the scratch buffer message
(setq initial-scratch-message ";; Scratch Buffer Go Brrr")

;; Display line numbers
;; (global-display-line-numbers-mode)
;; (setq display-line-numbers 'relative)

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
(require-theme 'peace-theme)
(load-theme 'peace t)

;; Flash the modeline instead of beeping
(setq visible-bell nil
      ring-bell-function 'flash-mode-line)

(defun flash-mode-line ()
  "Flash the modeline."
  (invert-face 'mode-line)
  (run-with-timer 0.1 nil #'invert-face 'mode-line))

;; Misc
(use-package emacs
  :init
  ;; Vertico commands are hidden in normal buffers.
  (setq read-extended-command-predicate
        #'command-completion-default-include-p)
  ;; Enable recursive minibuffers
  (setq enable-recursive-minibuffers t))

;; Delimeters for the lazy
(defvar whitelisted-electic-pair-modes '(prog-mode))

(defun inhibit-electric-pair-mode (_)
  "Leave me alone, argument CHAR is not used."
  (not (member major-mode whitelisted-electic-pair-modes)))

(use-package electric
  :config
  (defvar electric-pair-inhibit-predicate #'inhibit-electric-pair-mode)
  (electric-pair-mode 1))

;; Free persistent undo history
(use-package undo-tree
  :init
  (setq undo-tree-auto-save-history t)
  (setq undo-tree-history-directory-alist '(("." . "~/.config/emacs/undo")))
  :config
  (global-undo-tree-mode))

;; Friendship with Vi ended; now Meow is my best friend
(use-package meow
  :config
  (declare-function meow-motion-overwrite-define-key "meow")
  (declare-function meow-leader-define-key           "meow")
  (declare-function meow-normal-define-key           "meow")
  (setq meow-cheatsheet-layout meow-cheatsheet-layout-qwerty)
  ;; Why is this not recommended?
  (setq meow-use-clipboard t)
  (meow-motion-overwrite-define-key
   '("j" . meow-next)
   '("k" . meow-prev)
   '("<escape>" . ignore))
  (meow-leader-define-key
   ;; SPC j/k will run the original command in MOTION state.
   '("j" . "H-j")
   '("k" . "H-k")
   ;; Use SPC (0-9) for digit arguments.
   '("1"   . meow-digit-argument)
   '("2"   . meow-digit-argument)
   '("3"   . meow-digit-argument)
   '("4"   . meow-digit-argument)
   '("5"   . meow-digit-argument)
   '("6"   . meow-digit-argument)
   '("7"   . meow-digit-argument)
   '("8"   . meow-digit-argument)
   '("9"   . meow-digit-argument)
   '("0"   . meow-digit-argument)
   ;; Quick launchers
   '("K"   . meow-kmacro-lines)
   '("u"   . undo-tree-redo)
   '("v"   . magit-status)
   '("w"   . other-window)
   '("W"   . delete-other-windows)
   '("e"   . consult-flycheck)
   '("E"   . flyspell-correct-wrapper)
   '("a"   . org-agenda)
   '("G"   . consult-ripgrep)
   '("i"   . consult-imenu)
   '("I"   . consult-imenu-multi)
   '("b"   . consult-buffer)
   '("B"   . consult-buffer-other-window)
   '("o"   . consult-outline)
   '("t"   . consult-theme)
   '("l"   . consult-line)
   '("p"   . consult-yank-pop)
   '("r"   . consult-register)
   '("R"   . consult-register-store)
   '("M"   . consult-bookmark)
   '("k"   . kill-buffer)
   '("f"   . find-file)
   '("F"   . find-file-other-window)
   '("s"   . save-buffer)
   '("S"   . save-some-buffers)
   '("d"   . consult-dir)
   '("SPC" . reload-init-file))
  (meow-normal-define-key
   '("0"  . meow-expand-0)
   '("9"  . meow-expand-9)
   '("8"  . meow-expand-8)
   '("7"  . meow-expand-7)
   '("6"  . meow-expand-6)
   '("5"  . meow-expand-5)
   '("4"  . meow-expand-4)
   '("3"  . meow-expand-3)
   '("2"  . meow-expand-2)
   '("1"  . meow-expand-1)
   '("-"  . negative-argument)
   '(";"  . meow-reverse)
   '(","  . meow-inner-of-thing)
   '("."  . meow-bounds-of-thing)
   '("["  . meow-beginning-of-thing)
   '("]"  . meow-end-of-thing)
   '("a"  . meow-append)
   '("A"  . meow-open-below)
   '("b"  . meow-back-word)
   '("B"  . meow-back-symbol)
   '("c"  . meow-change)
   '("d"  . meow-delete)
   '("D"  . meow-backward-delete)
   '("e"  . meow-next-word)
   '("E"  . meow-next-symbol)
   '("f"  . meow-find)
   '("g"  . meow-cancel-selection)
   '("G"  . meow-grab)
   '("h"  . meow-left)
   '("H"  . meow-left-expand)
   '("i"  . meow-insert)
   '("I"  . meow-open-above)
   '("j"  . meow-next)
   '("J"  . meow-next-expand)
   '("k"  . meow-prev)
   '("K"  . meow-prev-expand)
   '("l"  . meow-right)
   '("L"  . meow-right-expand)
   '("m"  . meow-join)
   '("n"  . meow-search)
   '("o"  . meow-block)
   '("O"  . meow-to-block)
   '("p"  . meow-yank)
   '("q"  . meow-quit)
   '("r"  . meow-replace)
   '("R"  . meow-swap-grab)
   '("s"  . meow-kill)
   '("t"  . meow-till)
   '("u"  . meow-undo)
   '("U"  . meow-undo-in-selection)
   '("v"  . meow-visit)
   '("w"  . meow-mark-word)
   '("W"  . meow-mark-symbol)
   '("x"  . meow-line)
   '("X"  . consult-goto-line)
   '("y"  . meow-save)
   '("Y"  . meow-sync-grab)
   '("z"  . meow-pop-selection)
   '("'"  . repeat)
   '("<escape>" . ignore))

  (meow-global-mode 1))

;; Display ^L page breaks as tidy horizontal lines
(use-package page-break-lines
  :config
  (global-page-break-lines-mode))

;; Manage and navigate projects in Emacs easily
(use-package projectile
  :config
  (projectile-mode 1))

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
  :init
  (setq doom-modeline-height 30)
  :config
  (doom-modeline-mode 1))

;; All the themes!
(use-package ef-themes)

;; Vertico
(use-package vertico
  :init
  (vertico-mode)
  (vertico-mouse-mode)
  ;; Different scroll margin
  (setq vertico-scroll-margin 8)
  ;; Show more candidates
  (setq vertico-count 16)
  ;; Grow and shrink the Vertico minibuffer
  (setq vertico-resize nil)
  ;; Optionally enable cycling for `vertico-next' and `vertico-previous'.
  (setq vertico-cycle t)
  :config
  (define-key vertico-map (kbd "?") #'which-key-show-major-mode)
  (define-key vertico-map (kbd "M-RET") #'minibuffer-force-complete-and-exit)
  (define-key vertico-map (kbd "C-q") #'vertico-quick-insert))

;; Persist history over Emacs restarts. Vertico sorts by history position.
(use-package savehist
  :init
  (savehist-mode))

;; Use the Orderless completion style
(use-package orderless
  :init
  ;; Configure a custom style dispatcher (see the Consult wiki)
  ;; (setq orderless-style-dispatchers '(+orderless-dispatch)
  ;;       orderless-component-separator #'orderless-escapable-split-on-space)
  (setq completion-styles '(orderless basic)
        completion-category-defaults nil
        completion-category-overrides '((file (styles partial-completion)))))

;; Enable rich annotations using the Marginalia package
(use-package marginalia
  ;; The :init configuration is always executed (Not lazy!)
  :init
  ;; Must be in the :init section of use-package such that the mode gets
  ;; enabled right away. Note that this forces loading the package.
  (marginalia-mode))

;; Consult, completion framework
(use-package consult
  ;; Enable automatic preview at point in the *Completions* buffer. This is
  ;; relevant when you use the default completion UI.
  :hook (completion-list-mode . consult-preview-at-point-mode)
  ;; The :init configuration is always executed (Not lazy)
  :init
  ;; Optionally configure the register formatting. This improves the register
  ;; preview for `consult-register', `consult-register-load',
  ;; `consult-register-store' and the Emacs built-ins.
  (setq register-preview-delay 0.5
        register-preview-function #'consult-register-format)
  ;; Optionally tweak the register preview window.
  ;; This adds thin lines, sorting and hides the mode line of the window.
  (advice-add #'register-preview :override #'consult-register-window)
  ;; Use Consult to select xref locations with preview
  (defvar xref-show-xrefs-function #'consult-xref)
  (defvar xref-show-definitions-function #'consult-xref))

;; Switch directories
(use-package consult-dir)

;; Embark
(use-package embark
  :bind
  (("C-." . embark-act)         ;; pick some comfortable binding
   ("C-;" . embark-dwim)        ;; good alternative: M-.
   ("C-h B" . embark-bindings)) ;; alternative for `describe-bindings'
  :init
  ;; Optionally replace the key help with a completing-read interface
  (setq prefix-help-command #'embark-prefix-help-command)
  ;; I cannot believe this is not the default!
  (setq embark-verbose-indicator-display-action
        '(display-buffer-at-bottom
          (window-height . fit-window-to-buffer)))
  :config
  ;; Hide the mode line of the Embark live/completions buffers
  (add-to-list 'display-buffer-alist
               '("\\`\\*Embark Collect \\(Live\\|Completions\\)\\*"
                 nil
                 (window-parameters (mode-line-format . none)))))

;; Consult users will also want the embark-consult package.
(use-package embark-consult
  :after (embark consult)
  :demand t ; only necessary if you have the hook below
  ;; if you want to have consult previews as you move around an
  ;; auto-updating embark collect buffer
  :hook
  (embark-collect-mode . consult-preview-at-point-mode))

;; Pretty TODO?
(use-package hl-todo
  :hook (prog-mode . hl-todo-mode))

;; Modern on-the-fly syntax checking
(use-package flycheck
  :init (global-flycheck-mode))

(use-package consult-flycheck)

;; Completion Overlay Region Function
(use-package corfu
  ;; Optional customizations
  ;; :custom
  ;; (corfu-cycle t)                ;; Enable cycling for `corfu-next/previous'
  ;; (corfu-auto t)                 ;; Enable auto completion
  ;; (corfu-separator ?\s)          ;; Orderless field separator
  ;; (corfu-quit-at-boundary nil)   ;; Never quit at completion boundary
  ;; (corfu-quit-no-match nil)      ;; Never quit, even if there is no match
  ;; (corfu-preview-current nil)    ;; Disable current candidate preview
  ;; (corfu-preselect-first nil)    ;; Disable candidate preselection
  ;; (corfu-on-exact-match nil)     ;; Configure handling of exact matches
  ;; (corfu-echo-documentation nil) ;; Disable documentation in the echo area
  ;; (corfu-scroll-margin 5)        ;; Use scroll margin

  ;; Enable Corfu only for certain modes.
  ;; :hook ((prog-mode . corfu-mode)
  ;;        (shell-mode . corfu-mode)
  ;;        (eshell-mode . corfu-mode))

  ;; Recommended: Enable Corfu globally.
  ;; This is recommended since Dabbrev can be used globally (M-/).
  ;; See also `corfu-excluded-modes'.
  :init
  (global-corfu-mode))

;; A few more useful configurations...
(use-package emacs
  :init
  ;; TAB cycle if there are only few candidates
  (setq completion-cycle-threshold 3)

  ;; Emacs 28: Hide commands in M-x which do not apply to the current mode.
  ;; Corfu commands are hidden, since they are not supposed to be used via M-x.
  ;; (setq read-extended-command-predicate
  ;;       #'command-completion-default-include-p)

  ;; Enable indentation+completion using the TAB key.
  ;; `completion-at-point' is often bound to M-TAB.
  (setq tab-always-indent 'complete))

;; Which Key?
(use-package which-key
  :config
  (which-key-mode))

;; Magit
(use-package magit)

;; LSP
(use-package lsp-mode
  :init
  (setq lsp-keymap-prefix "C-c C-l")
  (setq lsp-headerline-breadcrumb-enable nil)
  :hook ((rust-mode   . lsp)
         (zig-mode    . lsp)
         (c-mode      . lsp)
         (c++-mode    . lsp)
         (lsp-mode    . lsp-enable-which-key-integration))
  :commands lsp)

(use-package lsp-ui)

;; Rust
(use-package rust-mode
  :defer t
  :config
  (setq rust-format-on-save t))

(use-package ob-rust
  :defer t)

;; Markdown
(use-package markdown-mode
  :hook (markdown-mode . auto-fill-mode))

;; Org
(use-package org
  :init
  (declare-function org-todo "org")
  (setq org-agenda-files '("~/Dropbox/Organic")
        org-startup-indented t
        org-hide-emphasis-markers t
        org-src-tab-acts-natively t
        org-hide-leading-stars t
        org-pretty-entities t
        org-odd-levels-only t
        org-todo-keywords '((sequence "SOMEDAY" "TODO" "IN-PROGRESS" "ON-HOLD" "|" "DONE" "CANCELED"))
        org-log-done 'time)
  (defun org-todo-done ()
    "Close a TODO item with a timestamp."
    (interactive)
    (org-todo "DONE"))
  :bind ("C-c M-t" . org-todo-done)
  :hook (org-mode . auto-fill-mode)
  :config
  (visual-line-mode))

(use-package org-superstar
  :after org
  :hook (org-mode . org-superstar-mode))

;; Seriously?
(use-package mixed-pitch
  :hook (text-mode . mixed-pitch-mode))

;; Zig
(use-package zig-mode
  :defer t)

;; Python
(use-package python-mode
  :defer t)
(use-package lsp-pyright
  :defer t
  :hook (python-mode . (lambda ()
                          (require 'lsp-pyright)
                          (lsp))))
;; Nix
(use-package nix-mode
  :defer t)

;; F#
(use-package fsharp-mode
  :defer t)

;; GLSL
(use-package glsl-mode
  :defer t)

;; Spelling

(use-package ispell
  :init
  ;; Configure `LANG`, otherwise ispell.el cannot find a 'default
  ;; dictionary' even though multiple dictionaries will be configured
  ;; in next line.
  (setenv "LANG" "en_US.UTF-8")
  (setq ispell-program-name "hunspell")
  (setq ispell-dictionary "fr_FR,en_US")
  ;; ispell-set-spellchecker-params has to be called
  ;; before ispell-hunspell-add-multi-dic will work
  (ispell-set-spellchecker-params)
  (ispell-hunspell-add-multi-dic "fr_FR,en_US"))

;; Flyspell
(use-package flyspell-correct
  :hook ((org-mode      . flyspell-mode)
         (prog-mode     . flyspell-prog-mode)
         (markdown-mode . flyspell-mode)))

;; ERC
(defvar erc-prompt (lambda () (concat "[" (buffer-name) "]")))
(defvar erc-fill-function 'erc-fill-static)
(defvar erc-fill-static-center 20)
(defvar erc-rename-buffers t)
(defvar erc-interpret-mirc-color t)

(defun erc-connect ()
  "Connect to LiberaChat."
  (interactive)
  (erc-tls :server "irc.libera.chat" :port 6697
           :nick "fuzzypixelz"
           :password (read-passwd "Password: ")))

;; Dial it down!
(setq gc-cons-threshold (* 100 1000))

;; UTF-8 everywhere
(prefer-coding-system       'utf-8)
(set-default-coding-systems 'utf-8)
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)

;; Other keybindings
;;; init.el ends here
