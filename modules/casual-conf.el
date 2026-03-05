;;; casual-conf.el --- Casual transient menu configuration -*- no-byte-compile: t; lexical-binding: t; -*-
;;; Commentary:
;;; Code:

(use-package casual
  :ensure t)

;; EditKit - global editing menus
;; C-c SPC chosen so meow's SPC SPC leader shortcut opens it in normal mode
(use-package casual-editkit
  :ensure nil
  :after casual
  :bind
  (("C-c SPC" . casual-editkit-main-tmenu)
    ("C-c w" . casual-editkit-windows-tmenu)
    ("C-c r" . casual-editkit-rectangle-tmenu)
    ("C-c R" . casual-editkit-registers-tmenu)
    ("C-c p" . casual-editkit-project-tmenu)))

;; Dired
(use-package casual-dired
  :ensure nil
  :after (casual dired)
  :bind
  (:map dired-mode-map
    ("C-o" . casual-dired-tmenu)
    ("s" . casual-dired-sort-by-tmenu)
    ("/" . casual-dired-search-replace-tmenu)))

;; IBuffer
(use-package casual-ibuffer
  :ensure nil
  :after (casual ibuffer)
  :bind
  (:map ibuffer-mode-map
    ("C-o" . casual-ibuffer-tmenu)
    ("F" . casual-ibuffer-filter-tmenu)
    ("s" . casual-ibuffer-sortby-tmenu)
    ("{" . ibuffer-backwards-next-marked)
    ("}" . ibuffer-forward-next-marked)
    ("[" . ibuffer-backward-filter-group)
    ("]" . ibuffer-forward-filter-group)
    ("$" . ibuffer-toggle-filter-group))
  :hook
  (ibuffer-mode . hl-line-mode)
  (ibuffer-mode . ibuffer-auto-mode))

;; Info
(use-package casual-info
  :ensure nil
  :after (casual info)
  :bind
  (:map Info-mode-map
    ("C-o" . casual-info-tmenu)
    ("M-[" . Info-history-back)
    ("M-]" . Info-history-forward)
    ("p" . casual-info-browse-backward-paragraph)
    ("n" . casual-info-browse-forward-paragraph)
    ("h" . Info-prev)
    ("j" . Info-next-reference)
    ("k" . Info-prev-reference)
    ("l" . Info-next)
    ("/" . Info-search)
    ("B" . bookmark-set))
  :hook
  (Info-mode . hl-line-mode)
  (Info-mode . scroll-lock-mode))

;; Calc
(use-package casual-calc
  :ensure nil
  :after (casual calc)
  :bind
  (:map calc-mode-map
    ("C-o" . casual-calc-tmenu))
  (:map calc-alg-map
    ("C-o" . casual-calc-tmenu)))

;; Org
(use-package casual-org
  :ensure nil
  :after (casual org)
  :bind
  (:map org-mode-map
    ("M-m" . casual-org-tmenu))
  (:map org-table-fedit-map
    ("M-m" . casual-org-table-fedit-tmenu)))

;; Agenda
(use-package casual-agenda
  :ensure nil
  :after (casual org-agenda)
  :bind
  (:map org-agenda-mode-map
    ("C-o" . casual-agenda-tmenu)
    ("M-j" . org-agenda-clock-goto)
    ("J" . bookmark-jump)))

;; Calendar
(use-package casual-calendar
  :ensure nil
  :after (casual calendar)
  :bind
  (:map calendar-mode-map
    ("C-o" . casual-calendar)))

;; Bookmarks
(use-package casual-bookmarks
  :ensure nil
  :after (casual bookmark)
  :config
  (require 'casual-bookmarks)
  (easy-menu-add-item global-map '(menu-bar)
    casual-bookmarks-main-menu
    "Tools")
  :bind
  (:map bookmark-bmenu-mode-map
    ("C-o" . casual-bookmarks-tmenu)
    ("J" . bookmark-jump))
  :hook
  (bookmark-bmenu-mode . hl-line-mode)
  :custom
  (bookmark-save-flag 1))

;; I-Search
(use-package casual-isearch
  :ensure nil
  :after (casual)
  :bind
  (:map isearch-mode-map
    ("C-o" . casual-isearch-tmenu)))

;; Help
(use-package casual-help
  :ensure nil
  :after (casual help-mode)
  :bind
  (:map help-mode-map
    ("C-o" . casual-help-tmenu)
    ("M-[" . help-go-back)
    ("M-]" . help-go-forward)
    ("p" . casual-lib-browse-backward-paragraph)
    ("n" . casual-lib-browse-forward-paragraph)
    ("P" . help-goto-previous-page)
    ("N" . help-goto-next-page)
    ("j" . forward-button)
    ("k" . backward-button)))

;; Eshell
(use-package casual-eshell
  :ensure nil
  :after (casual eshell)
  :bind
  (:map eshell-mode-map
    ("C-o" . casual-eshell-tmenu)))

;; Emacs Lisp
(use-package casual-elisp
  :ensure nil
  :after (casual)
  :bind
  (:map emacs-lisp-mode-map
    ("M-m" . casual-elisp-tmenu)))

;; Ediff
(use-package casual-ediff
  :ensure nil
  :after (casual ediff)
  :config
  (casual-ediff-install)
  (add-hook 'ediff-keymap-setup-hook
    (lambda ()
      (keymap-set ediff-mode-map "C-o" #'casual-ediff-tmenu)))
  :custom
  (ediff-keep-variants nil)
  (ediff-window-setup-function 'ediff-setup-windows-plain)
  (ediff-split-window-function 'split-window-horizontally))

;; EWW
(use-package casual-eww
  :ensure nil
  :after (casual eww)
  :bind
  (:map eww-mode-map
    ("C-o" . casual-eww-tmenu)
    ("C-c C-o" . eww-browse-with-external-browser)
    ("j" . shr-next-link)
    ("k" . shr-previous-link)
    ("[" . eww-previous-url)
    ("]" . eww-next-url)
    ("M-]" . eww-forward-url)
    ("M-[" . eww-back-url)
    ("n" . casual-lib-browse-forward-paragraph)
    ("p" . casual-lib-browse-backward-paragraph)
    ("P" . casual-eww-backward-paragraph-link)
    ("N" . casual-eww-forward-paragraph-link)
    ("M-l" . eww))
  (:map eww-bookmark-mode-map
    ("C-o" . casual-eww-bookmarks-tmenu)
    ("p" . previous-line)
    ("n" . next-line)))

;; Image
(use-package casual-image
  :ensure nil
  :after (casual image-mode)
  :bind
  (:map image-mode-map
    ("C-o" . casual-image-tmenu)))

;; RE-Builder
(use-package casual-re-builder
  :ensure nil
  :after (casual re-builder)
  :bind
  (:map reb-mode-map
    ("C-o" . casual-re-builder-tmenu))
  (:map reb-lisp-mode-map
    ("C-o" . casual-re-builder-tmenu)))

;; Compile
(use-package casual-compile
  :ensure nil
  :after (casual compile)
  :bind
  (:map compilation-mode-map
    ("C-o" . casual-compile-tmenu)
    ("k" . compilation-previous-error)
    ("j" . compilation-next-error)
    ("o" . compilation-display-error)
    ("[" . compilation-previous-file)
    ("]" . compilation-next-file))
  (:map grep-mode-map
    ("C-o" . casual-compile-tmenu)
    ("k" . compilation-previous-error)
    ("j" . compilation-next-error)
    ("o" . compilation-display-error)
    ("[" . compilation-previous-file)
    ("]" . compilation-next-file)))

;; Man
(use-package casual-man
  :ensure nil
  :after (casual man)
  :bind
  (:map Man-mode-map
    ("C-o" . casual-man-tmenu)
    ("n" . casual-lib-browse-forward-paragraph)
    ("p" . casual-lib-browse-backward-paragraph)
    ("[" . Man-previous-section)
    ("]" . Man-next-section)
    ("j" . next-line)
    ("k" . previous-line)
    ("K" . Man-kill)
    ("o" . casual-man-occur-options)))

;; Make
(use-package casual-make
  :ensure nil
  :after (casual make-mode)
  :bind
  (:map makefile-mode-map
    ("M-m" . casual-make-tmenu)))

;; CSV
(use-package casual-csv
  :ensure nil
  :after (casual csv-mode)
  :bind
  (:map csv-mode-map
    ("M-m" . casual-csv-tmenu))
  :hook
  (csv-mode . (lambda ()
                (visual-line-mode -1)
                (toggle-truncate-lines 1)))
  (csv-mode . csv-guess-set-separator)
  (csv-mode . csv-align-mode))

;; CSS
(use-package casual-css
  :ensure nil
  :after (casual css-mode)
  :bind
  (:map css-mode-map
    ("M-m" . casual-css-tmenu)))

;; HTML
(use-package casual-html
  :ensure nil
  :after (casual sgml-mode)
  :bind
  (:map html-mode-map
    ("M-m" . casual-html-tmenu)
    ("C-c m" . casual-html-tags-tmenu)))

;; BibTeX
(use-package casual-bibtex
  :ensure nil
  :after (casual bibtex)
  :bind
  (:map bibtex-mode-map
    ("M-m" . casual-bibtex-tmenu)
    ("<TAB>" . bibtex-next-field)
    ("<backtab>" . previous-line)
    ("C-n" . bibtex-next-field)
    ("M-n" . bibtex-next-entry)
    ("M-p" . bibtex-previous-entry)
    ("<prior>" . bibtex-previous-entry)
    ("<next>" . bibtex-next-entry)
    ("C-c C-o" . bibtex-url)
    ("C-c C-c" . casual-bibtex-fill-and-clean))
  :hook
  (bibtex-mode . hl-line-mode))

;; Eglot
(use-package casual-eglot
  :ensure nil
  :after (casual eglot)
  :bind
  (:map eglot-mode-map
    ("M-m" . casual-eglot-tmenu)))

(provide 'casual-conf)
;;; casual-conf.el ends here
