;;; org-drawer-list.el --- tame your lists in a drawer

;; Copyright (c) 2018 Boris Buliga

;; Author: Boris Buliga <boris@d12frosted.io>
;; Maintainer: Boris Buliga <boris@d12frosted.io>
;; Created: 18 Oct 2018

;; Keywords: org-mode
;; Homepage: https://github.com/d12frosted/org-drawer-list

;; Package-Version: 0.0.1
;; Package-Requires: ((org "9.1.0") (emacs "26.1"))

;; This file is not part of GNU Emacs.
;;; License: GPLv3

;;; Commentary:
;;
;; Small utility library for dealing with lists in an `org-mode' drawer. This
;; library provides the following functions:
;;
;; - `org-drawer-list' - returns the content of the named drawer as a list.
;; - `org-drawer-list-add' - adds the value to the list under the named drawer.
;; - `org-drawer-list-remove' - removes the value from the list under the named
;;   drawer.
;; - `org-drawer-list-contains' - returns first element of the named drawer that
;;   is equal to a given element.
;; - `org-drawer-list-block' - returns the region of the named drawer; when
;;   asked creates a missing drawer
;;
;; Every function works also in the agenda buffer.
;;
;; Please refer to each function's documentation for more information.

;;; Code:
;;

(require 'org)
(require 'org-agenda)
(require 'seq)
(require 'subr-x)

(defvar org-drawer-list-prefix "- "
  "Prefix for list elements.")

;;;###autoload
(defun org-drawer-list (name)
  "Return the content of the NAME drawer as list.

List prefix must be supported by `org-mode'."
  (org-drawer-list-block
   name nil t
   (lambda (range)
     (goto-char (car range))
     (seq-map
      (lambda (struct)
        (let ((beg (car struct))
              (end (- (car (last struct)) 1))
              (prefix (nth 2 struct)))
          (replace-regexp-in-string
           "\n" ""
           (replace-regexp-in-string
            "^ +" " "
            (string-remove-prefix
             prefix
             (buffer-substring-no-properties beg end))))))
      (org-element-property :structure (org-element-at-point))))))

;;;###autoload
(defun org-drawer-list-add (name value)
  "Add a VALUE to the list under the drawer with NAME.

When the list is empty, value will be added with
`org-drawer-list-prefix'. Otherwise, current prefix will be
used."
  (org-drawer-list-block
   name t t
   (lambda (range)
     (goto-char (cdr range))
     (backward-char)
     (if (equal (car range) (cdr range))
         (insert "\n" org-drawer-list-prefix)
       (org-insert-item))
     (insert value)
     value)))

;;;###autoload
(defun org-drawer-list-remove (name value &optional testfn)
  "Remove elements of NAME that are equal to VALUE.

Equality is defined by TESTFN if non-nil or by `equal' if nil."
  (org-drawer-list-block
   name t t
   (lambda (range)
     (goto-char (car range))
     (seq-length
      (seq-map
       (lambda (struct)
         (let ((beg (car struct))
               (end (car (last struct))))
           (delete-region beg end)
           (beginning-of-line)
           (ignore-errors
             (org-ctrl-c-ctrl-c))))
       (seq-reverse
        (seq-filter
         (lambda (struct)
           (let ((beg (car struct))
                 (end (- (car (last struct)) 1))
                 (prefix (nth 2 struct)))
             (funcall (or testfn #'equal)
                      value
                      (replace-regexp-in-string
                       "\n" ""
                       (replace-regexp-in-string
                        "^ +" " "
                        (string-remove-prefix
                         prefix
                         (buffer-substring-no-properties beg end)))))))
         (org-element-property :structure (org-element-at-point)))))))))

;;;###autoload
(defun org-drawer-list-contains (name elt &optional testfn)
  "Return the first element in NAME that is equal to ELT.

Equality is defined by TESTFN if non-nil or by `equal' if nil."
  (seq-contains (org-drawer-list name) elt (or testfn #'equal)))

(defmacro org-drawer-list--with-entry (&rest body)
  "Move to buffer and point of current entry for the duration of BODY."
  `(cond ((eq major-mode 'org-mode)
          (org-with-point-at (point) ,@body))
         ((eq major-mode 'org-agenda-mode)
          (org-agenda-with-point-at-orig-entry nil ,@body))))

;;;###autoload
(defun org-drawer-list-block (name &optional create inside fn)
  "Return the (beg . end) range of the NAME drawer.

NAME is case insensitive.

If CREATE is non-nil, create the drawer when it doesn't exist.

If INSIDE is non-nil, return the (beg . end) range of the drawers
body.

Example result with INSIDE being nil:

|:NAME:
- val1
- val2
:END:|

Example result with INSIDE being non-nil:

:NAME:
|- val1
- val2
|:END:

If FN is non-nil, `org-drawer-list-block' returns the result of
applying FN to the (beg . end) range. Note that the FN is called
only when the (beg. end) exists."
  (org-drawer-list--with-entry
   (unless (org-before-first-heading-p)
     (org-back-to-heading t)
     (end-of-line)
     (let* ((drawer-beg-regexp (concat "^[ \t]*:" (downcase name) ":[ \t]*$"))
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
           (setq end (if inside
                         (line-beginning-position)
                       (line-end-position)))))
       (if (and (not (null beg))
                (not (null end)))
           (if fn
               (funcall fn (cons beg end))
             (cons beg end))
         (when create
           (if-let ((property-block (org-get-property-block)))
               (goto-char (cdr property-block))
             (org-back-to-heading t))
           (end-of-line)
           (open-line 1)
           (forward-line 1)
           (insert ":" (upcase name) ":\n:END:")
           (when (eobp) (insert "\n"))
           (org-drawer-list-block name nil inside fn)))))))

(provide 'org-drawer-list)

;;; org-drawer-list.el ends here
