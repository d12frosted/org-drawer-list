(require 'cl)
(require 'el-mock)
(require 'undercover)
(require 'subr-x)

(setq user-home-directory (concat (getenv "HOME") "/"))

(undercover "*.el")

(add-to-list 'load-path ".")
(load "org-drawer-list.el")

(defmacro make-test (name input drawer-name drawer-name-case point-location)
  `(ert-deftest ,(make-test-name name drawer-name-case point-location) ()
     (with-temp-buffer
       (org-mode)
       (insert (string-join ',input "\n"))
       (pcase ',point-location
         ('beginning (place-cursor-beginning))
         ('end (place-cursor-end))
         ('random (place-cursor-random)))
       (setq drawer-name
             (pcase ',drawer-name-case
               ('lower (downcase ,drawer-name))
               ('upper (upcase ,drawer-name))
               ('random (randomcase ,drawer-name))))
       (should (equal (get-block-range)
                      (org-drawer-list-block ,drawer-name nil nil))))))

(defun make-test-name (name drawer-name-case point-location)
  (intern (format "org-drawer-list|%s|%s-case|point-at-%s|test"
                  (symbol-name name)
                  (symbol-name drawer-name-case)
                  (symbol-name point-location))))

(defun place-cursor-beginning ()
  (let ((p0 (get-position-of "{"))
        (p1 (get-position-of "}")))
    (goto-char p0)))

(defun place-cursor-end ()
  (let ((p0 (get-position-of "{"))
        (p1 (get-position-of "}")))
    (goto-char p1)))

(defun place-cursor-random ()
  (let ((p0 (get-position-of "{"))
        (p1 (get-position-of "}")))
    (goto-char (+ p0 (random (- p1 p0))))))

(defun get-block-range ()
  (let ((bchar "<")
        (echar ">"))
    (cons (get-position-of bchar)
          (get-position-of echar))))

(defun get-position-of (str)
  (save-excursion
    (beginning-of-buffer)
    (search-forward str)
    (delete-backward-char (length str))
    (point)))

(defun randomcase (str)
  (concat
   (mapcar (lambda (x)
             (if (> 0 (random))
                 (upcase x)
               (downcase x)))
           str)))

(defun cartesian-product (a b)
  (mapcan
   (lambda (item-from-a)
     (mapcar
      (lambda (item-from-b)
        (if (listp item-from-a)
            (append item-from-a (list item-from-b))
          (list item-from-a item-from-b)))
      b))
   a))
