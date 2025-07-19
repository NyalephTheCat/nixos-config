{ config, pkgs, ... }:

{
  programs.emacs = {
    enable = true;
    package = pkgs.emacs; # Use the pgtk version for better Wayland support

    extraPackages = epkgs: with epkgs; [
      # Evil mode (vim-like keybindings)
      evil
      evil-collection
      evil-commentary
      evil-surround
      evil-indent-plus

      # Theme and appearance
      doom-themes
      doom-modeline
      all-the-icons
      rainbow-delimiters
      highlight-indent-guides

      # Org-mode enhancements
      org-modern
      org-roam
      org-bullets
      org-superstar
      toc-org

      # Completion and navigation
      vertico
      orderless
      marginalia
      consult
      embark
      embark-consult
      which-key

      # File management
      projectile
      treemacs
      treemacs-evil
      treemacs-projectile

      # Programming support
      magit
      company
      flycheck
      lsp-mode
      lsp-ui
      yasnippet
      yasnippet-snippets

      # Language modes
      nix-mode
      rust-mode
      python-mode
      typescript-mode
      web-mode
      markdown-mode
      yaml-mode
      json-mode

      # Utilities
      exec-path-from-shell
      diminish
      use-package
    ];

    extraConfig = ''
      ;; Use-package for clean configuration
      (require 'use-package)
      (setq use-package-always-ensure nil) ; We manage packages through Nix

      ;; Basic settings
      (setq inhibit-startup-message t)
      (setq ring-bell-function 'ignore)
      (setq make-backup-files nil)
      (setq auto-save-default nil)
      (setq create-lockfiles nil)
      (global-auto-revert-mode 1)
      (setq global-auto-revert-non-file-buffers t)

      ;; UI improvements
      (tool-bar-mode -1)
      (menu-bar-mode -1)
      (scroll-bar-mode -1)
      (global-display-line-numbers-mode 1)
      (setq display-line-numbers-type 'relative)
      (column-number-mode 1)
      (show-paren-mode 1)

      ;; Font settings
      (set-face-attribute 'default nil :font "JetBrains Mono" :height 110)
      (set-face-attribute 'fixed-pitch nil :font "JetBrains Mono" :height 110)
      (set-face-attribute 'variable-pitch nil :font "Noto Sans" :height 110)

      ;; Theme configuration
      (use-package doom-themes
        :config
        (setq doom-themes-enable-bold t
              doom-themes-enable-italic t)
        (load-theme 'doom-one t)
        (doom-themes-visual-bell-config)
        (doom-themes-org-config))

      ;; Doom modeline
      (use-package doom-modeline
        :hook (after-init . doom-modeline-mode)
        :config
        (setq doom-modeline-height 25
              doom-modeline-bar-width 3
              doom-modeline-icon t
              doom-modeline-major-mode-icon t
              doom-modeline-buffer-file-name-style 'truncate-upto-project))

      ;; All the icons (required for doom-modeline)
      (use-package all-the-icons)

      ;; Evil mode configuration
      (use-package evil
        :init
        (setq evil-want-integration t)
        (setq evil-want-keybinding nil)
        (setq evil-want-C-u-scroll t)
        (setq evil-want-C-i-jump nil)
        :config
        (evil-mode 1)
        (define-key evil-insert-state-map (kbd "C-g") 'evil-normal-state)
        (define-key evil-insert-state-map (kbd "C-h") 'evil-delete-backward-char-and-join)
        ;; Use visual line motions even outside of visual-line-mode buffers
        (evil-global-set-key 'motion "j" 'evil-next-visual-line)
        (evil-global-set-key 'motion "k" 'evil-previous-visual-line)
        (evil-set-initial-state 'messages-buffer-mode 'normal)
        (evil-set-initial-state 'dashboard-mode 'normal))

      ;; Evil collection for better evil integration
      (use-package evil-collection
        :after evil
        :config
        (evil-collection-init))

      ;; Evil commentary for commenting
      (use-package evil-commentary
        :after evil
        :config
        (evil-commentary-mode))

      ;; Evil surround for surrounding text objects
      (use-package evil-surround
        :after evil
        :config
        (global-evil-surround-mode 1))

      ;; Org-mode configuration
      (use-package org
        :hook ((org-mode . visual-line-mode)
               (org-mode . org-indent-mode))
        :config
        (setq org-ellipsis " ▾"
              org-hide-emphasis-markers t
              org-src-fontify-natively t
              org-src-tab-acts-natively t
              org-edit-src-content-indentation 0
              org-hide-block-startup nil
              org-src-preserve-indentation nil
              org-startup-folded 'content
              org-cycle-separator-lines 2)
        
        ;; Agenda files
        (setq org-agenda-files '("~/Documents/org/"))
        
        ;; Keywords
        (setq org-todo-keywords
              '((sequence "TODO(t)" "NEXT(n)" "PROG(p)" "INTR(i)" "DONE(d)" "KILL(k)")))
        
        ;; Capture templates
        (setq org-capture-templates
              '(("t" "Todo" entry (file+headline "~/Documents/org/inbox.org" "Tasks")
                 "* TODO %?\n  %i\n  %a")
                ("n" "Note" entry (file+headline "~/Documents/org/notes.org" "Notes")
                 "* %?\nEntered on %U\n  %i\n  %a"))))

      ;; Org modern for better appearance
      (use-package org-modern
        :hook ((org-mode . org-modern-mode)
               (org-agenda-finalize . org-modern-agenda)))

      ;; Org bullets/superstar for better bullets
      (use-package org-superstar
        :hook (org-mode . org-superstar-mode)
        :config
        (setq org-superstar-remove-leading-stars t
              org-superstar-headline-bullets-list '("◉" "○" "●" "○" "●" "○" "●")))

      ;; Completion framework
      (use-package vertico
        :init
        (vertico-mode)
        :config
        (setq vertico-cycle t))

      (use-package orderless
        :init
        (setq completion-styles '(orderless basic)
              completion-category-defaults nil
              completion-category-overrides '((file (styles partial-completion)))))

      (use-package marginalia
        :after vertico
        :init
        (marginalia-mode))

      (use-package consult
        :bind (("C-s" . consult-line)
               ("C-x b" . consult-buffer)
               ("C-x 4 b" . consult-buffer-other-window)
               ("C-x 5 b" . consult-buffer-other-frame)
               ("M-y" . consult-yank-pop)))

      ;; Which-key for command discovery
      (use-package which-key
        :init (which-key-mode)
        :diminish which-key-mode
        :config
        (setq which-key-idle-delay 0.3))

      ;; Company for completion
      (use-package company
        :hook (after-init . global-company-mode)
        :config
        (setq company-minimum-prefix-length 1
              company-idle-delay 0.0))

      ;; Magit for Git
      (use-package magit
        :bind ("C-x g" . magit-status))

      ;; Projectile for project management
      (use-package projectile
        :init (projectile-mode +1)
        :bind (:map projectile-mode-map
                    ("s-p" . projectile-command-map)
                    ("C-c p" . projectile-command-map)))

      ;; Rainbow delimiters
      (use-package rainbow-delimiters
        :hook (prog-mode . rainbow-delimiters-mode))

      ;; Highlight indent guides
      (use-package highlight-indent-guides
        :hook (prog-mode . highlight-indent-guides-mode)
        :config
        (setq highlight-indent-guides-method 'character
              highlight-indent-guides-character ?\|))

      ;; Language modes
      (use-package nix-mode
        :mode "\\.nix\\'")

      (use-package rust-mode
        :mode "\\.rs\\'")

      (use-package markdown-mode
        :mode ("\\.md\\'" . markdown-mode))

      ;; Exec path from shell for proper PATH
      (use-package exec-path-from-shell
        :if (memq window-system '(mac ns x))
        :config
        (exec-path-from-shell-initialize))

      ;; Custom keybindings
      (global-set-key (kbd "C-x C-b") 'consult-buffer)
      (global-set-key (kbd "M-x") 'execute-extended-command)

      ;; Evil leader key setup
      (with-eval-after-load 'evil
        (define-key evil-normal-state-map (kbd "SPC") nil)
        (define-key evil-normal-state-map (kbd "SPC f f") 'find-file)
        (define-key evil-normal-state-map (kbd "SPC f s") 'save-buffer)
        (define-key evil-normal-state-map (kbd "SPC b b") 'consult-buffer)
        (define-key evil-normal-state-map (kbd "SPC b k") 'kill-buffer)
        (define-key evil-normal-state-map (kbd "SPC w s") 'split-window-below)
        (define-key evil-normal-state-map (kbd "SPC w v") 'split-window-right)
        (define-key evil-normal-state-map (kbd "SPC w d") 'delete-window)
        (define-key evil-normal-state-map (kbd "SPC g s") 'magit-status)
        (define-key evil-normal-state-map (kbd "SPC p f") 'projectile-find-file)
        (define-key evil-normal-state-map (kbd "SPC p p") 'projectile-switch-project)
        (define-key evil-normal-state-map (kbd "SPC o a") 'org-agenda)
        (define-key evil-normal-state-map (kbd "SPC o c") 'org-capture))

      ;; Make sure directories exist
      (make-directory "~/Documents/org" t)
    '';
  };
}