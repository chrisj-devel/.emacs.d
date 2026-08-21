;;; api-conf.el --- API related configuration -*- no-byte-compile: t; lexical-binding: t; -*-
;;; Commentary:
;;; Code:
(defun my/verb-copy-exchange ()
  "Copy this response buffer's request and response to the kill ring.
The request is written as a curl command; the response keeps its status
line, headers and body."
  (interactive)
  (unless verb-response-body-mode
    (user-error "%s" "This buffer is not showing an HTTP response"))
  (kill-new (concat (verb--export-to-curl
                      (oref verb-http-response request) t t)
              "\n\n"
              (verb-response-to-string verb-http-response (current-buffer))))
  (message "Request and response copied"))

(use-package verb
  :after org
  :bind
  (:map verb-response-body-mode-map
    ("q" . verb-kill-response-buffer-and-window)
    ("C-c C-r M-w" . my/verb-copy-exchange))
  :config
  ;; Show response buffers to the right of the window that sent the request.
  (add-to-list 'display-buffer-alist
    '("\\`\\*HTTP Response"
       display-buffer-in-direction
       (direction . right)
       (window-height . nil)))

  ;; `verb-command-map' is a keymap variable, not a command, so it has to be
  ;; bound as a value here. Through `:bind' use-package autoloads it as a
  ;; function, and pressing the prefix fails with "failed to define".
  (keymap-set org-mode-map "C-c C-r" verb-command-map))

(provide 'api-conf)
;;; api-conf.el ends here
