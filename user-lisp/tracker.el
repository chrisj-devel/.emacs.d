;;; tracker.el --- Install and check the org ticket tracker -*- lexical-binding: t; -*-
;;; Commentary:
;; The tracker contract and its agent skills are config, not repo content:
;; `my/tracker-install' copies them into a repo, `my/tracker-validate' sweeps
;; the dependency graph.  org-edna only resolves a finder when a state changes,
;; so nothing else checks the whole graph.
;;; Code:

(require 'org)
(require 'project)
(require 'seq)

(declare-function org-edna-finder/olp "org-edna")

(defvar my/session-tickets-subdir)

(defconst my/tracker-source-directory
  (expand-file-name "tracker" user-emacs-directory)
  "Directory holding the portable contract and skill sources.")

(defconst my/tracker-agents-subdir "docs/agents"
  "Directory under a repo root holding agent-facing documentation.")

(defconst my/tracker-skills-subdir ".agents/skills"
  "Canonical skill directory under a repo root; .claude/skills links to it.")

;;; Install

(defun my/tracker--copy (source target force)
  "Copy SOURCE to TARGET.  Return a symbol describing what happened.
An existing TARGET is only overwritten when FORCE."
  (make-directory (file-name-directory target) t)
  (cond ((not (file-exists-p target))
         (copy-file source target)
         'written)
        ((equal (with-temp-buffer (insert-file-contents source) (buffer-string))
                (with-temp-buffer (insert-file-contents target) (buffer-string)))
         'unchanged)
        (force (copy-file source target t) 'replaced)
        (t 'differs)))

(defun my/tracker--link-claude-skills (root)
  "Point .claude/skills at `my/tracker-skills-subdir' under ROOT.
Links the whole directory when .claude/skills is free, and each installed
skill individually when it already exists with other content."
  (let ((claude (expand-file-name ".claude/skills" root))
        (agents (expand-file-name my/tracker-skills-subdir root)))
    (cond ((file-symlink-p claude) 'unchanged)
          ((not (file-exists-p claude))
           (make-directory (file-name-directory claude) t)
           (make-symbolic-link "../.agents/skills" claude)
           'linked)
          (t
           (dolist (skill (directory-files agents nil "\\`[^.]"))
             (let ((link (expand-file-name skill claude)))
               (unless (file-exists-p link)
                 (make-symbolic-link (concat "../../.agents/skills/" skill) link))))
           'linked-each))))

(defun my/tracker-install (root &optional force)
  "Install the tracker contract and skills into ROOT.
Generated files are left alone when they differ locally unless FORCE (the
prefix argument) is set; tracker.local.md is never overwritten."
  (interactive (list (funcall project-prompter) current-prefix-arg))
  (let* ((agents (expand-file-name my/tracker-agents-subdir root))
         (skills (expand-file-name my/tracker-skills-subdir root))
         (report nil))
    (make-directory (expand-file-name my/session-tickets-subdir root) t)
    (push (cons "issue-tracker.md"
                (my/tracker--copy
                 (expand-file-name "issue-tracker.md" my/tracker-source-directory)
                 (expand-file-name "issue-tracker.md" agents)
                 force))
          report)
    ;; Never force: this file belongs to the repo.
    (push (cons "tracker.local.md"
                (my/tracker--copy
                 (expand-file-name "tracker.local.md" my/tracker-source-directory)
                 (expand-file-name "tracker.local.md" agents)
                 nil))
          report)
    (dolist (skill (directory-files
                    (expand-file-name "skills" my/tracker-source-directory)
                    nil "\\`[^.]"))
      (push (cons skill
                  (my/tracker--copy
                   (expand-file-name (concat "skills/" skill "/SKILL.md")
                                     my/tracker-source-directory)
                   (expand-file-name (concat skill "/SKILL.md") skills)
                   force))
            report))
    (push (cons ".claude/skills" (my/tracker--link-claude-skills root)) report)
    (setq report (nreverse report))
    (message "tracker: %s"
             (mapconcat (lambda (r) (format "%s %s" (cdr r) (car r)))
                        (seq-remove (lambda (r) (eq (cdr r) 'unchanged)) report)
                        ", "))
    (when (seq-find (lambda (r) (eq (cdr r) 'differs)) report)
      (message "tracker: some generated files differ locally; C-u to overwrite"))
    report))

;;; Validate

(defun my/tracker--finders (value)
  "Parse olp finders out of a BLOCKER property VALUE as (FILE . HEADING)."
  (let ((start 0) (out nil))
    (while (string-match "olp(\"\\([^\"]+\\)\" *\"\\([^\"]+\\)\")" value start)
      (push (cons (match-string 1 value) (match-string 2 value)) out)
      (setq start (match-end 0)))
    (nreverse out)))

(defun my/tracker--headings (file)
  "Heading texts in FILE, without keyword, priority or tags."
  (when (file-exists-p file)
    (with-current-buffer (find-file-noselect file)
      (org-map-entries (lambda () (org-get-heading t t t t))))))

(defun my/tracker--graph (dir)
  "Adjacency alist for the tracker in DIR, keyed \"file::heading\"."
  (let ((graph nil))
    (dolist (file (directory-files dir t "\\`[^.].*\\.org\\'") graph)
      (with-current-buffer (find-file-noselect file)
        (dolist (entry (org-map-entries
                        (lambda ()
                          (cons (org-get-heading t t t t)
                                (org-entry-get nil "BLOCKER")))))
          (when (cdr entry)
            (push (cons (format "%s::%s" (file-name-nondirectory file) (car entry))
                        (mapcar (lambda (f) (format "%s::%s" (car f) (cdr f)))
                                (my/tracker--finders (cdr entry))))
                  graph)))))))

(defun my/tracker--cycles (graph)
  "Return node keys participating in a cycle in GRAPH."
  (let ((state (make-hash-table :test 'equal)) (found nil))
    (letrec ((walk
              (lambda (node trail)
                (pcase (gethash node state)
                  ('done nil)
                  ('open (setq found (append found (member node (reverse trail)))))
                  (_ (puthash node 'open state)
                     (dolist (next (cdr (assoc node graph)))
                       (funcall walk next (cons node trail)))
                     (puthash node 'done state))))))
      (dolist (node (mapcar #'car graph))
        (funcall walk node nil)))
    (seq-uniq found)))

(defun my/tracker-validate (&optional root)
  "Report unresolvable BLOCKER edges and dependency cycles under ROOT."
  (interactive (list (funcall project-prompter)))
  (let* ((dir (expand-file-name my/session-tickets-subdir root))
         (graph (my/tracker--graph dir))
         (problems nil))
    (dolist (node graph)
      (dolist (target (cdr node))
        (let* ((parts (split-string target "::"))
               ;; Rejoin: a heading may itself contain "::".
               (heading (string-join (cdr parts) "::"))
               (headings (my/tracker--headings
                          (expand-file-name (car parts) dir)))
               (matches (seq-count (lambda (h) (equal h heading)) headings)))
          (cond ((zerop matches)
                 (push (format "%s -> %s (unresolvable)" (car node) target)
                       problems))
                ((> matches 1)
                 ;; org-edna refuses an ambiguous path, but only when a state
                 ;; change tries to follow it.
                 (push (format "%s -> %s (ambiguous: %d headings match)"
                               (car node) target matches)
                       problems))))))
    (dolist (node (my/tracker--cycles graph))
      (push (format "%s (in a cycle)" node) problems))
    (setq problems (nreverse problems))
    (if problems
        (with-current-buffer (get-buffer-create "*tracker-validate*")
          (erase-buffer)
          (insert (format "%d problem(s) in %s\n\n" (length problems) dir))
          (dolist (p problems) (insert p "\n"))
          (display-buffer (current-buffer)))
      (message "tracker: %d edge(s) across %d heading(s), all resolvable"
               (apply #'+ (mapcar (lambda (n) (length (cdr n))) graph))
               (length graph)))
    problems))

(provide 'tracker)
;;; tracker.el ends here
