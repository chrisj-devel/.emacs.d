(use-package auth-source-1password
  :hook (after-init . auth-source-1password-enable)
  ;; :custom (auth-source-1password-construct-secret-reference 'my/construct-secret-reference)
  :config
  (defun my/construct-secret-reference (_backend _type host user _port)
    "For reference, see `auth-source-1password-construct-secret-reference'.
     This function is a custom implementation that replaces the caret (^)
     character with a space for forge compatibility."
    (let ((processed-user (replace-regexp-in-string "\\^" " " user)))
      (mapconcat #'identity (list auth-source-1password-vault host processed-user) "/"))))
