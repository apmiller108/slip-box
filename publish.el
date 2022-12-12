;; Usage:
;; emacs -Q --batch -l ./publish.el --funcall my/update-org-id-locations-file
;; emacs -Q --batch -l ./publish.el --funcall my/publish

(setq org-confirm-babel-evaluate nil
      org-id-track-globally nil
      my/org-id-locations nil)

;; Compile the packages. Do this after copying the locked packages.
(defun my/byte-compile-packages-locked()
  (byte-recompile-directory "./.packages" 0))

;; Run this to build the .org-id-locations file
(defun my/update-org-id-locations-file()
  (require 'org-id)
  (setq org-id-locations-file-relative t
        org-id-locations-file "./.org-id-locations"
        org-id-track-globally t)
  (org-id-update-id-locations (seq-filter 'file-regular-p (directory-files "./")) t)
  (print (my/org-id-alist-to-hash (read (find-file-noselect "./.org-id-locations")))))

(defun my/publish()
  (setq my/org-id-locations (my/org-id-alist-to-hash (read (find-file-noselect "./.org-id-locations"))))
  (get-buffer (find-file "./publish.org"))
  (org-babel-execute-buffer)
  (org-publish "site" t))

;; Shamelessly copied from org-id.el https://github.com/tkf/org-mode/blob/master/lisp/org-id.el#L573-L584
(defun my/org-id-alist-to-hash (list)
  "Turn an org-id location list into a hash table."
  (let ((res (make-hash-table
	            :test 'equal
	            :size (apply '+ (mapcar 'length list))))
	      f)
    (mapc
     (lambda (x)
       (setq f (car x))
       (mapc (lambda (i) (puthash i f res)) (cdr x)))
     list)
    res))

