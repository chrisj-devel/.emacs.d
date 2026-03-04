;;; web-conf.el --- summary -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(use-package web-mode
  :mode
  ("\\.phtml\\'"
    "\\.php\\'"
    "\\.tpl\\'"
    "\\.[agj]sp\\'"
    "\\.as[cp]x\\'"
    "\\.erb\\'"
    "\\.mustache\\'"
    "\\.djhtml\\'"
    "\\.html?\\'"
    "\\.eex\\'"
    "\\.leex\\'"))

(use-package jest-test-mode
  :defines jest-test-mode-map
  :hook (js-ts-mode tsx-ts-mode js-mode typescript-mode typescript-tsx-mode typescript-ts-mode)
  :bind (:map jest-test-mode-map
          ("C-c , a" . jest-test-run-all-tests)
          ("C-c , v" . jest-test-run)
          ("C-c , r" . jest-test-rerun-test)
          ("C-c , s" . jest-test-run-at-point)
          ("C-c , d v" . jest-test-debug)
          ("C-c , d r" . jest-test-debug-rerun-test)
          ("C-c , d s" . jest-test-debug-run-at-point))
  :custom (jest-test-options '("--color" "--silent"))
  :init/el-patch
  ;; Patch to remove --node-arg from jest-test-npx-options which has been removed
  (defmacro jest-test-with-debug-flags (form)
    "Execute FORM with debugger flags set."
    (declare (indent 0))
    `(let ((jest-test-options (seq-concatenate 'list jest-test-options (list "--runInBand") ))
            (jest-test-npx-options (seq-concatenate 'list jest-test-npx-options (list "inspect"))))
       ,form)))

(use-package css-mode
  :ensure nil
  :mode "\\.s?[ca]ss"
  :custom (css-indent-offset 2))

(use-package emmet-mode
  :init/el-patch
  (defvar emmet-jsx-major-modes
    '(rjsx-mode
       typescript-tsx-mode
       tsx-ts-mode
       js-jsx-mode
       js2-jsx-mode
       jsx-mode
       js-mode)
    "Which modes to check before using jsx class expansion"))

(provide 'web-conf)

;;; web-conf.el ends here
