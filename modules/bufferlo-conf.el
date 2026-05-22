;;; bufferlo-conf.el --- Per-tab buffer isolation -*- no-byte-compile: t; lexical-binding: t; -*-
;;; Commentary:
;; Additive layer on top of otpp-conf: otpp creates one tab per project,
;; bufferlo makes each tab's buffer list genuinely isolated.  Load it
;; alongside otpp-conf, not instead of it.
;;; Code:

(use-package bufferlo
  :after project
  :hook (elpaca-after-init . bufferlo-mode)
  :bind
  ([remap switch-to-buffer] . bufferlo-switch-to-buffer)
  ([remap ibuffer] . bufferlo-ibuffer))

;; Make plain `consult-buffer' default to this tab's buffers.  bufferlo
;; ships no consult source, only predicates, so build one.  The built-in
;; all-buffers source stays reachable under its `b' narrow key.
(with-eval-after-load 'consult
  (defvar my/consult-source-bufferlo-local-buffers
    `(:name "Local Buffers"
      :narrow ?l
      :category buffer
      :face consult-buffer
      :history buffer-name-history
      :state ,#'consult--buffer-state
      :default t
      :items ,(lambda ()
                (consult--buffer-query
                 :predicate #'bufferlo-local-buffer-p
                 :sort 'visibility
                 :as #'buffer-name)))
    "Consult buffer source restricted to bufferlo tab-local buffers.")
  (consult-customize consult--source-buffer :narrow ?b :default nil)
  (add-to-list 'consult-buffer-sources
               'my/consult-source-bufferlo-local-buffers))

(provide 'bufferlo-conf)
;;; bufferlo-conf.el ends here
