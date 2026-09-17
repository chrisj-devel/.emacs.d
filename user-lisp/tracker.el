;;; tracker.el --- Install and check the org ticket tracker -*- lexical-binding: t; -*-
;;; Commentary:
;; The tracker contract and its agent skills are config, not repo content:
;; `my/tracker-install' copies the contract into a repo's tracker directory and
;; the skills into the repo, `my/tracker-update-all' pushes a contract edit out
;; to every repo already holding one, and
;; `my/tracker-validate' sweeps the dependency graph.  org-edna only resolves a
;; finder when a state changes, so nothing else checks the whole graph.
;;
;; They are copied rather than symlinked into the repo: a link into this
;; directory dangles in a clone, in CI, and for any agent whose sandbox stops
;; at the workspace root, which is precisely where the contract has to be
;; legible.  `my/tracker-update-all' is what pays for the copies.
;;; Code:

(require 'org)
(require 'project)
(require 'seq)

(declare-function org-edna-finder/olp "org-edna")
(declare-function my/session--read-repo "sessions")

(defvar my/session-tickets-subdir)

(defconst my/tracker-source-directory
  (expand-file-name "tracker" user-emacs-directory)
  "Directory holding the portable contract and skill sources.")

(defconst my/tracker-skills-subdir ".agents/skills"
  "Canonical skill directory under a repo root; .claude/skills links to it.")

;;; Install

(defun my/tracker--copy-status (source target force)
  "What copying SOURCE to TARGET would do, as a symbol.
An existing TARGET is only overwritten when FORCE."
  (cond ((not (file-exists-p target)) 'written)
        ((equal (with-temp-buffer (insert-file-contents source) (buffer-string))
                (with-temp-buffer (insert-file-contents target) (buffer-string)))
         'unchanged)
        (force 'replaced)
        (t 'differs)))

(defun my/tracker--copy (source target force &optional check)
  "Copy SOURCE to TARGET.  Return a symbol describing what happened.
With CHECK, decide but write nothing, so a sweep can report without
touching any repo."
  (let ((status (my/tracker--copy-status source target force)))
    (when (and (not check) (memq status '(written replaced)))
      (make-directory (file-name-directory target) t)
      (copy-file source target t))
    status))

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

(defun my/tracker--install (root force check)
  "Install the contract and skills into ROOT, returning a report alist.
FORCE overwrites generated files that differ locally.  With CHECK nothing
is written, created or linked; the report says what would have happened."
  (let* ((tickets (expand-file-name my/session-tickets-subdir root))
         (skills (expand-file-name my/tracker-skills-subdir root))
         (report nil))
    (unless check (make-directory tickets t))
    (push (cons "issue-tracker.md"
                (my/tracker--copy
                 (expand-file-name "issue-tracker.md" my/tracker-source-directory)
                 (expand-file-name "issue-tracker.md" tickets)
                 force check))
          report)
    ;; Never force: this file belongs to the repo.
    (push (cons "tracker.local.md"
                (my/tracker--copy
                 (expand-file-name "tracker.local.md" my/tracker-source-directory)
                 (expand-file-name "tracker.local.md" tickets)
                 nil check))
          report)
    (dolist (skill (directory-files
                    (expand-file-name "skills" my/tracker-source-directory)
                    nil "\\`[^.]"))
      (push (cons skill
                  (my/tracker--copy
                   (expand-file-name (concat "skills/" skill "/SKILL.md")
                                     my/tracker-source-directory)
                   (expand-file-name (concat skill "/SKILL.md") skills)
                   force check))
            report))
    (push (cons ".claude/skills"
                (if check
                    (if (file-symlink-p (expand-file-name ".claude/skills" root))
                        'unchanged
                      'linked)
                  (my/tracker--link-claude-skills root)))
          report)
    (nreverse report)))

;;;###autoload
(defun my/tracker-install (root &optional force)
  "Install the tracker contract and skills into ROOT.
Generated files are left alone when they differ locally unless FORCE (the
prefix argument) is set; tracker.local.md is never overwritten."
  (interactive (list (my/session--read-repo) current-prefix-arg))
  (let ((report (my/tracker--install root force nil)))
    (message "tracker: %s"
             (mapconcat (lambda (r) (format "%s %s" (cdr r) (car r)))
                        (seq-remove (lambda (r) (eq (cdr r) 'unchanged)) report)
                        ", "))
    (when (seq-find (lambda (r) (eq (cdr r) 'differs)) report)
      (message "tracker: some generated files differ locally; C-u to overwrite"))
    report))

;;; Update sweep

(defun my/tracker--repos ()
  "Local known project roots that already have the contract installed."
  (seq-filter (lambda (root)
                (and (not (file-remote-p root))
                     (file-exists-p
                      (expand-file-name
                       (concat my/session-tickets-subdir "/issue-tracker.md")
                       root))))
              (project-known-project-roots)))

;;;###autoload
(defun my/tracker-update-all (&optional check)
  "Reinstall the contract and skills into every repo that already has them.
Generated files are overwritten: they carry a do-not-edit header, so local
divergence is drift rather than customisation.  tracker.local.md belongs to
its repo and is still only ever seeded when missing.  With CHECK (the prefix
argument) report what would change without writing."
  (interactive "P")
  (let* ((repos (my/tracker--repos))
         (rows (delq nil
                     (mapcar
                      (lambda (root)
                        (when-let* ((touched
                                     (seq-filter
                                      (lambda (r)
                                        (memq (cdr r) '(written replaced
                                                        linked linked-each)))
                                      (my/tracker--install root t check))))
                          (cons root touched)))
                      repos))))
    (if (null rows)
        (message "tracker: %d repo(s) up to date" (length repos))
      (with-current-buffer (get-buffer-create "*tracker-update*")
        (erase-buffer)
        (insert (format "%s %d of %d repo(s)\n\n"
                        (if check "Would update" "Updated")
                        (length rows) (length repos)))
        (pcase-dolist (`(,root . ,files) rows)
          (insert (abbreviate-file-name root) "\n")
          (pcase-dolist (`(,name . ,status) files)
            (insert (format "  %-11s %s\n" status name))))
        (display-buffer (current-buffer))))
    rows))

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

;;;###autoload
(defun my/tracker-validate (&optional root)
  "Report unresolvable BLOCKER edges and dependency cycles under ROOT."
  (interactive (list (funcall project-prompter)))
  ;; Truename, because `tickets' is a symlink into the tracker repo: without it
  ;; `find-file-noselect' opens every tracker file under two names.
  (let* ((dir (file-truename
               (expand-file-name my/session-tickets-subdir root)))
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
