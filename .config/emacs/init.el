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

;; Display line numbers
(global-display-line-numbers-mode)
(setq display-line-numbers 'relative)

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

;; Friendship with Vi ended; now Meow is my best friend
(use-package meow
  :config
  (setq meow-cheatsheet-layout meow-cheatsheet-layout-qwerty)
  ;; How is this not recommended?
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
   '("v"   . magit-status)
   '("r"   . counsel-rg)
   '("e"   . flyspell-correct-wrapper)
   '("a"   . org-agenda)
   '("i"   . erc-connect)
   '("SPC" . reload-init-file)
   ;; Shortcuts
   '("b"   . "C-x C-b")
   '("f"   . "C-x C-f")
   '("s"   . "C-x C-s")
   '("d"   . "C-x x g"))
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
   '(";" . meow-reverse)
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
   '("X"  . meow-goto-line)
   '("y"  . meow-save)
   '("Y"  . meow-sync-grab)
   '("z"  . meow-pop-selection)
   '("'"  . repeat)
   '("/"  . comment-dwim)
   '("\\" . undo-redo)
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

;; Modern on-the-fly syntax checking
(use-package flycheck
  :init (global-flycheck-mode))

;; Complete Anything
(use-package company
  :config
  (setq company-format-margin-function nil))

;; Counsel, Ivy and Swiper
(use-package counsel
  :config
  (setq ivy-use-virtual-buffers t)
  :bind
  ("M-x"     . 'counsel-M-x)
  :init
  (ivy-mode 1))

(use-package ivy-rich
  :after counsel
  :init
  (ivy-rich-mode 1))

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
(use-package lsp-ui
  :after lsp-mode
  :init
  (setq lsp-ui-doc-show-with-cursor nil)
  :commands lsp-ui-mode)
(use-package lsp-ivy
  :after lsp-mode
  :bind
  ("C-c C-l C-s" . lsp-ivy-workspace-symbol)
  :commands lsp-ivy-workspace-symbol)

;; Rust
(use-package rust-mode
  :defer t
  :config
  (setq rust-format-on-save t))

;; Markdown
(use-package markdown-mode
  :hook (markdown-mode . auto-fill-mode))

;; Org
(use-package org
  :init
  (setq org-agenda-files '("~/Dropbox/Organic")
        org-startup-indented t
        org-hide-emphasis-markers t
        org-src-tab-acts-natively t
        org-hide-leading-stars t
        org-pretty-entities t
        org-odd-levels-only t
        org-todo-keywords '((sequence "SOMEDAY" "TODO" "NEXT" "ON-HOLD" "IN-PROGRESS" "|" "DONE" "CANCELED"))
        org-log-done 'time)
  :hook (org-mode . auto-fill-mode)
  :config
  (visual-line-mode))

(use-package org-superstar
  :after org
  :config
  :hook (org-mode . org-superstar-mode))

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

;; Ace window
(use-package ace-window
  :bind
  ("M-o" . ace-window))

(use-package lispy
  :hook (emacs-lisp-mode . (lambda () (lispy-mode 1))))

;; Flyspell
(use-package flyspell-correct
  :hook ((org-mode      . flyspell-mode)
         ;;(prog-mode     . flyspell-mode)
         (markdown-mode . flyspell-mode)))

(use-package flyspell-correct-ivy
  :after flyspell-correct)

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
(global-set-key (kbd "C-s") 'swiper)
(global-set-key (kbd "C-r") 'swiper-backward)
(global-set-key (kbd "C-x C-b") 'switch-to-buffer)
(global-set-key (kbd "C-x b") 'list-buffers)

;;; init.el ends here
