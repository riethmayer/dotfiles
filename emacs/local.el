;; this file is intended to have changes for current machine only.
(setq dotfiles-dir (file-name-directory (or (buffer-file-name) load-file-name)))
(add-to-list 'load-path dotfiles-dir)

(load "defunkt")
(server-start)

(setq initial-frame-alist
      '((top . 3) (left . 3) (width . 120) (height . 60)))