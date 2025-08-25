;;; vc.el --- Version control configuration -*- no-byte-compile: t; lexical-binding: t; -*-
;;; Commentary:
;;; Code:

(use-package magit
  :bind ("C-x g" . magit-status)
  :config (setopt magit-format-file-function #'magit-format-file-nerd-icons))

(use-package git-link
  :ensure (:host github :repo "sshaw/git-link")
  :bind
  ("C-c g l" . git-link)
  ("C-c g c" . git-link-commit)
  ("C-c g h" . git-link-homepage)
  ("C-c g p" . git-link-compare)
  :custom
  (git-link-open-in-browser t)
  (git-link-default-branch "main")
  :config
  ;; Custom git-link-compare function to support GitHub compare
  (setq git-link-compare-remote-alist '(("github" git-link-compare-github)))
  (defun git-link-compare-github (hostname dirname branch)
    (format "https://%s/%s/compare/%s" hostname dirname branch))
  (defun git-link-compare (remote)
    "Compare the current branch with the remote main branch.
Create a URL representing the comparison of the current
buffer's GitHub/Bitbucket/GitLab/... branch with the main
branch of REMOTE.  The URL will be added to the kill ring.

With a prefix argument prompt for the remote's name.
Defaults to \"origin\"."
    (interactive (list (git-link--select-remote)))
    (let* (handler remote-info (remote-url (git-link--remote-url remote)) (branch (git-link--current-branch)))
      (if (null remote-url)
        (message "Remote `%s' not found" remote)
        (if (null branch)
          (message "Current branch not found")
          (setq remote-info (git-link--parse-remote remote-url)
            handler (git-link--handler git-link-compare-remote-alist (car remote-info)))
          (cond ((null (car remote-info))
                  (message "Remote `%s' contains an unsupported URL" remote))
            ((not (functionp handler))
              (message "No handler for %s" (car remote-info)))
            ((git-link--new
               (funcall handler
                 (car remote-info)
                 (cadr remote-info)
                 branch)))))))))

(provide 'vc-conf)
;;; vc.el ends here
