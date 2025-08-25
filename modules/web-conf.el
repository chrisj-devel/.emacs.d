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

(provide 'web-conf)

;;; web-conf.el ends here
