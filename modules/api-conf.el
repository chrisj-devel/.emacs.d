;;; api-conf.el --- API related configuration -*- no-byte-compile: t; lexical-binding: t; -*-
;;; Commentary:
;;; Code:
(use-package verb
  :after org
  :bind
  (:map verb-response-body-mode-map
    ("q" . verb-kill-response-buffer-and-window))
  :config
  ;; `verb-command-map' is a keymap variable, not a command, so it has to be
  ;; bound as a value here. Through `:bind' use-package autoloads it as a
  ;; function, and pressing the prefix fails with "failed to define".
  (keymap-set org-mode-map "C-c C-r" verb-command-map))

(defun my/open-verb-file ()
  "Open this project's Verb file, kept in ~/.claude/scratch/<project>/verb/.
With no file there yet, visit <project>.org so one can be started."
  (interactive)
  (require 'project)
  (let* ((name (file-name-nondirectory
                 (directory-file-name (project-root (project-current t)))))
          (dir (expand-file-name (concat "~/.claude/scratch/" name "/verb/")))
          (files (file-expand-wildcards (concat dir "*.org"))))
    (find-file (cond ((cdr files) (completing-read "Verb file: " files nil t))
                 (files (car files))
                 (t (concat dir name ".org"))))))

;; Bound globally rather than through the `verb' block above: that one is
;; `:after org', so its keys only exist once an Org buffer has been opened —
;; too late for the command whose job is to open one.
(keymap-global-set "C-c v" #'my/open-verb-file)

(provide 'api-conf)
;;; api-conf.el ends here
