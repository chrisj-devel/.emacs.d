;;; casual-eglot.el --- Casual transient menu for Eglot -*- lexical-binding: t; -*-
;;; Commentary:
;; A Casual-style transient menu for eglot-managed buffers.
;; Bind `casual-eglot-tmenu' in your eglot keymap of choice.
;;; Code:

(require 'transient)
(require 'eglot)
(require 'xref)
(require 'casual-lib)

;;;###autoload (autoload 'casual-eglot-tmenu "casual-eglot" nil t)
(transient-define-prefix casual-eglot-tmenu ()
  "Casual transient menu for Eglot LSP actions."
  [:description
   (lambda () (format "Eglot: %s" (buffer-name)))

   ["Navigate"
    ("." "Find Definition" xref-find-definitions)
    (">" "Definition Other Window" xref-find-definitions-other-window)
    ("r" "Find References" xref-find-references)
    ("a" "Find Apropos" xref-find-apropos)
    ("D" "Find Declaration" eglot-find-declaration)
    ("i" "Find Implementation" eglot-find-implementation)
    ("T" "Find Type Definition" eglot-find-typeDefinition)]

   ["History"
    ("[" "Go Back" xref-go-back :transient t)
    ("]" "Go Forward" xref-go-forward :transient t)]

   ["Refactor"
    ("R" "Rename" eglot-rename)
    ("f" "Format Buffer" eglot-format-buffer)
    ("x" "Replace References" xref-find-references-and-replace)
    ("c" "Code Actions" eglot-code-actions)]]

  [["Server"
    ("s" "Shutdown" eglot-shutdown)
    ("S" "Shutdown All" eglot-shutdown-all)
    ("!" "Reconnect" eglot-reconnect)
    ("E" "Events Buffer" eglot-events-buffer)
    ("e" "Stderr Buffer" eglot-stderr-buffer)]

   ["Hints"
    ("h" "Momentary Inlay Hints" eglot-momentary-inlay-hints)]]

  [:class transient-row
   (casual-lib-quit-one)
   ("RET" "Done" transient-quit-all)
   (casual-lib-quit-all)])

(provide 'casual-eglot)
;;; casual-eglot.el ends here
