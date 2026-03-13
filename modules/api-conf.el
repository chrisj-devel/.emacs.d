;;; api-conf.el --- API related configuration -*- no-byte-compile: t; lexical-binding: t; -*-
;;; Commentary:
;;; Code:
(use-package verb
  :after org
  :bind
  (:map org-mode-map ("C-c C-r" . verb-command-map))
  (:map verb-response-body-mode-map
    ("q" . verb-kill-response-buffer-and-window))
  :config
  (add-to-list 'display-buffer-alist
    '("\\*HTTP Response"
       (display-buffer-reuse-mode-window display-buffer-pop-up-window)
       (mode . verb-response-body-mode)
       (reusable-frames . visible))))

(provide 'api-conf)
;;; api-conf.el ends here
