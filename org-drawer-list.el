;;; org-drawer-list.el --- tame your lists in a drawer

;; Copyright (c) 2018 Boris Buliga

;; Author: Boris Buliga <boris@d12frosted.io>
;; Maintainer: Boris Buliga <boris@d12frosted.io>
;; Created: 18 Oct 2018

;; Keywords: org-mode
;; Homepage: https://github.com/d12frosted/org-drawer-list

;; Package-Version: 0.0.1
;; Package-Requires: ((org "9.1.0") (emacs "25.1"))

;; This file is not part of GNU Emacs.
;;; License: GPLv3

;;; Commentary:
;;

;;; Code:
;;

(require 'org)

(defun org-drawer-list-block (name &optional create-when-absent inside)
  "Return the (beg . end) range of the NAME drawer.

NAME is case insensitive.

If CREATE-WHEN-ABSENT is non-nil, create the drawer when it
doesn't exist.

If INSIDE is non-nil, return the (beg . end) range of the drawers
body.

Example result with INSIDE being nil:

|:NAME:
- val1
- val2
:END:
|

Example result with INSIDE being non-nil:

:NAME:
|- val1
- val2
|:END:"
  (setq name (downcase name))
  (org-drawer-list--with-entry
   (unless (org-before-first-heading-p)
     (org-back-to-heading t)
     (end-of-line)
     (let* ((drawer-beg-regexp (concat "^[ \t]*:" name ":[ \t]*$"))
            (drawer-end-regexp "^[ \t]*:end:[ \t]*$")
            (bound (save-excursion
                     (if (search-forward-regexp org-heading-regexp nil t)
                         (line-beginning-position)
                       (buffer-end 1))))
            (beg)
            (end))
       (when (search-forward-regexp drawer-beg-regexp bound t)
         (when inside
           (forward-line))
         (setq beg (line-beginning-position))
         (goto-char beg)
         (when (search-forward-regexp drawer-end-regexp bound t)
           (unless inside
             (forward-line))
           (setq end (line-beginning-position))))
       (if (and (not (null beg))
                (not (null end)))
           (cons beg end)
         (when create-when-absent
           (goto-char (cdr (org-get-property-block)))
           (forward-line 1)
           (open-line 1)
           (indent-for-tab-command)
           (insert ":" name ":\n")
           (indent-for-tab-command)
           (insert ":END:")
           (org-drawer-list--block name nil inside)))))))

(defmacro org-drawer-list--with-entry (&rest body)
  "Move to buffer and point of current entry for the duration of BODY."
  `(cond ((eq major-mode 'org-mode)
          (org-with-point-at (point) ,@body))
         ((eq major-mode 'org-agenda-mode)
          (org-agenda-with-point-at-orig-entry nil ,@body))))

(provide 'org-drawer-list)

;;; org-drawer-list.el ends here
