(require 'cl)
(require 'el-mock)
(require 'undercover)
(require 'subr-x)

(setq user-home-directory (concat (getenv "HOME") "/"))

(undercover "*.el")

(add-to-list 'load-path ".")
(load "org-drawer-list.el")

(defmacro make-list-test (name
                          input
                          drawer-name
                          result
                          drawer-name-case
                          point-location
                          create
                          inside)
  `(ert-deftest
       ,(make-list-test-name name
                             drawer-name-case
                             point-location
                             create
                             inside)
       ()
     (with-temp-buffer
       (org-mode)
       (insert (string-join ',input "\n"))
       (pcase ',point-location
         ('beginning (place-cursor-beginning))
         ('end (place-cursor-end))
         ('random (place-cursor-random)))
       (let ((drawer-name (pcase ',drawer-name-case
                            ('lower (downcase ,drawer-name))
                            ('upper (upcase ,drawer-name))
                            ('random (randomcase ,drawer-name)))))
         (should (equal (if ,inside
                            (progn
                              (get-block-range "<" ">")
                              (get-block-range "≤" "≥"))
                          (progn
                            (get-block-range "≤" "≥")
                            (get-block-range "<" ">")))
                        (org-drawer-list-block
                         drawer-name
                         ,create
                         ,inside)))
         (should (equal ,result
                        (org-drawer-list ,drawer-name)))))))

(defun make-list-test-name (name
                            drawer-name-case
                            point-location
                            create
                            inside)
  (intern (format "org-drawer-list|%s|%s-case|point-at-%s|%s|%s|test"
                  (symbol-name name)
                  (symbol-name drawer-name-case)
                  (symbol-name point-location)
                  (if create
                      "create"
                    "ignore")
                  (if inside
                      "inside"
                    "outside"))))

(defmacro make-add-test (name
                         input
                         drawer-name
                         elements-to-add
                         result
                         output)
  `(ert-deftest
       ,(intern (format "org-drawer-list-add|%s|test" name))
       ()
     (with-temp-buffer
       (org-mode)
       (insert (string-join ',input "\n"))
       (seq-map (lambda (value) (org-drawer-list-add ,drawer-name value))
                ,elements-to-add)
       (should (equal ,result
                      (org-drawer-list ,drawer-name)))
       (should (equal (string-join ',output "\n")
                      (org-drawer-list-block
                       ,drawer-name nil nil
                       (lambda (range)
                         (buffer-substring-no-properties
                          (car range)
                          (cdr range)))))))))

(defmacro make-remove-test (name
                            input
                            drawer-name
                            elt
                            testfn
                            count
                            result
                            output)
  `(ert-deftest
       ,(intern (format "org-drawer-list-remove|%s|test" name))
       ()
     (with-temp-buffer
       (org-mode)
       (insert (string-join ',input "\n"))
       (should (equal ,count
                      (org-drawer-list-remove ,drawer-name ,elt ,testfn)))
       (should (equal ,result
                      (org-drawer-list ,drawer-name)))
       (should (equal (string-join ',output "\n")
                      (org-drawer-list-block
                       ,drawer-name nil nil
                       (lambda (range)
                         (buffer-substring-no-properties
                          (car range)
                          (cdr range)))))))))

(defmacro make-contains-test (name
                              input
                              drawer-name
                              elt
                              testfn
                              result)
  `(ert-deftest
       ,(intern (format "org-drawer-list-contains|%s|test" name))
       ()
     (with-temp-buffer
       (org-mode)
       (insert (string-join ',input "\n"))
       (should (equal ,result
                      (org-drawer-list-contains ,drawer-name ,elt ,testfn))))))

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

(defun get-block-range (bchar echar)
  (condition-case nil
      (cons (get-position-of bchar)
            (get-position-of echar))
    (error nil)))

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

;; Compatibility
;; https://github.com/rejeep/ert-runner.el/issues/49
(defun ert--print-backtrace (backtrace do-xrefs)
  "Format the backtrace BACKTRACE to the current buffer."
  (let ((print-escape-newlines t)
        (print-level 8)
        (print-length 50))
    (debugger-insert-backtrace backtrace do-xrefs)))

;; Compatibility
;; https://github.com/rejeep/ert-runner.el/issues/49
(defun debugger-insert-backtrace (frames do-xrefs)
   "Format and insert the backtrace FRAMES at point.
 Make functions into cross-reference buttons if DO-XREFS is non-nil."
   (let ((standard-output (current-buffer))
         (eval-buffers eval-buffer-list))
     (require 'help-mode)     ; Define `help-function-def' button type.
     (pcase-dolist (`(,evald ,fun ,args ,flags) frames)
       (insert (if (plist-get flags :debug-on-exit)
                   "* " "  "))
       (let ((fun-file (and do-xrefs (symbol-file fun 'defun)))
             (fun-pt (point)))
         (cond
          ((and evald (not debugger-stack-frame-as-list))
           (debugger--print fun)
           (if args (debugger--print args) (princ "()")))
          (t
           (debugger--print (cons fun args))
           (cl-incf fun-pt)))
         (when fun-file
           (make-text-button fun-pt (+ fun-pt (length (symbol-name fun)))
                             :type 'help-function-def
                             'help-args (list fun fun-file))))
       ;; After any frame that uses eval-buffer, insert a line that
       ;; states the buffer position it's reading at.
       (when (and eval-buffers (memq fun '(eval-buffer eval-region)))
         (insert (format "  ; Reading at buffer position %d"
                         ;; This will get the wrong result if there are
                         ;; two nested eval-region calls for the same
                         ;; buffer.  That's not a very useful case.
                         (with-current-buffer (pop eval-buffers)
                           (point)))))
       (insert "\n"))))
