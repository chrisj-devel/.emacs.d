(use-package systemd
  :vc (:url "https://github.com/mavit/systemd-mode.git" :branch "podman")
  :hook (systemd-mode . (lambda () (setq-local require-final-newline t))))
