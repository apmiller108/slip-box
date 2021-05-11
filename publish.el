;; Usage:
;; emacs -Q --batch -l ./publish.el --funcall my/publish

(setq org-confirm-babel-evaluate nil)

(defun my/publish()
  (get-buffer (find-file "./publish.org"))
  (org-babel-execute-buffer)
  (org-publish "site"))
