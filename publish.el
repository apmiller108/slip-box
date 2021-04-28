;; Based on David Wilson's publish.el
;; Author: David Wilson <david@daviwil.com>
;; Maintainer: David Wilson <david@daviwil.com>
;; URL: https://sr.ht/~daviwil/dotfiles

;; Usage:
;; emacs -Q --batch -l ./publish.el --funcall my/publish

;; Initialize package sources
(require 'package)

;; Set the package installation directory so that packages aren't stored in the
;; ~/.emacs.d/elpa path.
(setq package-user-dir (expand-file-name "./.packages"))

(setq package-archives '(("melpa" . "https://melpa.org/packages/")
                         ("elpa" . "https://elpa.gnu.org/packages/")))

;; Initialize the package system
(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))

;; Install use-package
(unless (package-installed-p 'use-package)
  (package-install 'use-package))
(require 'use-package)

;; Install other dependencies
(use-package esxml ;; provides writing markup in lisp
  :ensure t)

(use-package ox-slimhtml ;; more sane html markup
  :ensure t)

(use-package htmlize ;; syntax highlighting
  :ensure t)

(use-package webfeeder ;; generate rss/atom feed
  :ensure t)

(require 'ox-publish) ;; publishing system for org-mode

;; Set site variables
(setq my/site-title   "Alex's Org-mode Dump"
      my/site-tagline "These are my org-mode notes"
      my/sitemap-title "Notes Index")

;; NOTE some of these may be overridden by the publishing backend and may not be needed here.
(setq org-publish-use-timestamps-flag t
      org-publish-timestamp-directory "./.org-cache/"
      org-export-with-section-numbers nil
      org-export-use-babel nil ;; set this to nil to prevent execution of code blocks
      org-export-with-smart-quotes t ;; improves the look of quotations
      org-export-with-sub-superscripts nil
      org-export-with-tags 'not-in-toc
      org-export-with-toc t) ;; toc = table of contents

(setq make-backup-files nil)

;; The backquote quotes a list but allows use of the `,' to evalulate expressions selectively.
;; See for more on this https://www.gnu.org/software/emacs/manual/html_node/elisp/Backquote.html
(defun my/site-header (info)
  (let* ((file (plist-get info :output-file)))
    (concat
     (sxml-to-xml
      `(div (div (@ (class "heading uk-container")) ;; `@' is the attribute function
                 (div (@ (class "site-title uk-heading-medium")) ,my/site-title)
                 (div (@ (class "site-tagline uk-text-lead")) ,my/site-tagline))
            (div (@ (class "uk-container"))
                 (nav (@ (class "uk-nav-primary"))
                      (a (@ (class "nav-link") (href "/")) "Notes Index") " "
                      (a (@ (class "nav-link") (href "https://blog.alex-miller.co")) "Blog") " "
                      (a (@ (class "nav-link") (href "https://github.com/apmiller108")) "Github") " "
                      (a (@ (class "nav-link") (href "https://alex-miller.co")) "alex-miller.co"))))))))

(defun my/site-footer (info) ;; info is a plist passed in from org-mode
  (concat
   ;; "</div></div>"
   (sxml-to-xml
    `(footer (@ (class "blog-footer"))
      (div (@ (class "uk-container"))
           (div (@ (class "made-with"))
                (p "Made with " ,(plist-get info :creator)))))) ;; this gets the :creator key's value from the info plist
   (sxml-to-xml
    `(script (@ (src "/js/site.js"))))))

(defun get-article-output-path (org-file pub-dir)
  (let ((article-dir (concat pub-dir
                             (downcase
                              (file-name-as-directory
                               (file-name-sans-extension
                                (file-name-nondirectory org-file)))))))

    (if (string-match "\\/sitemap.org$" org-file) ;; Makes the sitemap the root index.html file
        pub-dir
        (progn
          (unless (file-directory-p article-dir)
            (make-directory article-dir t))
          article-dir))
    ))

(defun my/org-html-template (contents info)
  (concat
   "<!DOCTYPE html>"
   (sxml-to-xml
    `(html (@ (lang "en"))
           (head
            "<!-- " ,(org-export-data (org-export-get-date info "%Y-%m-%d") info) " -->"
            (meta (@ (charset "utf-8")))
            (meta (@ (author "Alex P. Miller")))
            (meta (@ (name "viewport")
                     (content "width=device-width, initial-scale=1, shrink-to-fit=no")))
            (link (@ (rel "stylesheet")
                     (href "/css/uikit.min.css")))
            (link (@ (rel "stylesheet")
                     (href "/css/code.css")))
            (link (@ (rel "stylesheet")
                     (href "/css/site.css")))
            (script (@ (src "/js/uikit.min.js")) nil)
            (script (@ (src "/js/uikit-icons.min.js")) nil)
            (title ,(concat (org-export-data (plist-get info :title) info) " - notes.alex-miller.com")))
           (body
             ,(my/site-header info)
             (div (@ (class "uk-container"))
                  (div (@ (class "row"))
                       (div (@ (class "col-sm-12 blog-main"))
                            (div (@ (class "blog-post"))
                                 (h1 (@ (class "blog-post-title"))
                                     ,(org-export-data (plist-get info :title) info))
                                 (p (@ (class "blog-post-meta"))
                                    ,(org-export-data (org-export-get-date info "%B %e, %Y") info)) ;; Comes from the `#date:' export option
                                 (p (@ (class "test-container"))
                                    ,(org-export-data (plist-get info :page-type) info))
                                 ,contents
                                 ,(let ((tags (org-export-data (plist-get info :roam_tags) info)))
                                    (when (and tags (> (length tags) 0))
                                      `(p (@ (class "blog-post-tags"))
                                          "Tags: "
                                          ,(mapconcat (lambda (tag) tag)
                                                        ;; TODO: We don't have tag pages yet
                                                        ;; (format "<a href=\"/tags/%s/\">%s</a>" tag tag))
                                                      (plist-get info :roam_tags)
                                                      ", "))))
                                 ,(when (not (string-equal my/sitemap-title (org-export-data (plist-get info :title) info)))
                                    "<script src=\"https://utteranc.es/client.js\"
                                             repo=\"apmiller108/slip-box\"
                                             issue-term=\"title\"
                                             label=\"comments\"
                                             theme=\"boxy-light\"
                                             crossorigin=\"anonymous\"
                                             async>
                                     </script>")))))

             ,(my/site-footer info))))))

(defun my/org-html-link (link contents info)
  "Removes file extension and changes the path into lowercase org file:// links."
  (when (and (string= 'file (org-element-property :type link))
             (string= "org" (file-name-extension (org-element-property :path link))))
    (org-element-put-property link :path
                              (downcase
                               (file-name-sans-extension
                                (org-element-property :path link)))))

  (if (and (string= 'file (org-element-property :type link))
           (file-name-extension (org-element-property :path link))
           (string-match "png\\|jpg\\|svg"
                         (file-name-extension
                          (org-element-property :path link)))
           (equal contents nil))
      (format "<img src=%s >" (org-element-property :path link))
    (if (and (equal contents nil)
             (or (not (file-name-extension (org-element-property :path link)))
                 (and (file-name-extension (org-element-property :path link))
                      (not (string-match "png\\|jpg\\|svg"
                                         (file-name-extension
                                          (org-element-property :path link)))))))
        (format "<a href=\"%s\">%s</a>"
                (org-element-property :raw-link link)
                (org-element-property :raw-link link))
      (org-export-with-backend 'slimhtml link contents info))))

;; Make sure we have thread-last
(require 'subr-x)

(defun my/make-heading-anchor-name (headline-text)
  (thread-last headline-text
    (downcase)
    (replace-regexp-in-string " " "-")
    (replace-regexp-in-string "[^[:alnum:]_-]" "")))

(defun my/org-html-headline (headline contents info)
  (let* ((text (org-export-data (org-element-property :title headline) info))
         (level (org-export-get-relative-level headline info))
         (level (min 7 (when level (1+ level))))
         (anchor-name (my/make-heading-anchor-name text))
         (attributes (org-element-property :ATTR_HTML headline))
         (container (org-element-property :HTML_CONTAINER headline))
         (container-class (and container (org-element-property :HTML_CONTAINER_CLASS headline))))
    (when attributes
      (setq attributes
            (format " %s" (org-html--make-attribute-string
                           (org-export-read-attribute 'attr_html `(nil
                                                                   (attr_html ,(split-string attributes))))))))
    (concat
     (when (and container (not (string= "" container)))
       (format "<%s%s>" container (if container-class (format " class=\"%s\"" container-class) "")))
     (if (not (org-export-low-level-p headline info))
         (format "<h%d%s><a id=\"%s\" class=\"anchor\" href=\"#%s\">¶</a>%s</h%d>%s"
                 level
                 (or attributes "")
                 anchor-name
                 anchor-name
                 text
                 level
                 (or contents ""))
       (concat
        (when (org-export-first-sibling-p headline info) "<ul>")
        (format "<li>%s%s</li>" text (or contents ""))
        (when (org-export-last-sibling-p headline info) "</ul>")))
     (when (and container (not (string= "" container)))
       (format "</%s>" (cl-subseq container 0 (cl-search " " container)))))))

(org-export-define-derived-backend 'site-html ;; Create a new back-end as a variant of an existing one.
    'slimhtml
  :translate-alist ;; These are override functions for various org elements.
  '((template . my/org-html-template)
    (link . my/org-html-link)
    (code . ox-slimhtml-verbatim)
    (headline . my/org-html-headline))
  :options-alist ;; Define custom options. See docs for org-export-options-alist
  '((:page-type "PAGE-TYPE" nil nil t)
    (:html-use-infojs nil nil nil)
    (:roam_tags "ROAM_TAGS" nil nil split)))

(defun my/org-html-publish-to-html (plist filename pub-dir)
  "Publish an org file to HTML, using the FILENAME as the output directory."
  (let ((article-path (get-article-output-path filename pub-dir)))
    (cl-letf (((symbol-function 'org-export-output-file-name)
               (lambda (extension &optional subtreep pub-dir)
                 (concat article-path "index" extension))))
      (org-publish-org-to 'site-html ;; Use the derrived backend defined above.
                          filename
                          (concat "." (or (plist-get plist :html-extension)
                                          "html"))
                          plist
                          article-path))))

(defun my/sitemap-format-entry (entry style project)
  ;; entry is the filename
  ;; style (eg `tree')
  ;; project is the a-list
  (concat (format "[[file:%s][%s]]"
                  entry
                  (org-publish-find-title entry project))
          ;; If we have roam_tags, place them after the link formatted like: `(tag1, tag2)'
          (if (org-publish-find-property entry :roam_tags project 'site-html)
              (concat " ("
                      (mapconcat (lambda (tag) tag)
                                 (org-publish-find-property entry :roam_tags project 'site-html)
                                 ", ")
                      ")"))))


(defun my/generate-sitemap (title list)
  (concat
    "#+TITLE: " title "\n\n"
    "#+BEGIN_EXPORT html\n"
    (mapconcat (lambda (item)
                 (car item))
               (cdr list)
               "\n")
    "\n#+END_EXPORT\n"))

(setq org-html-preamble  #'my/site-header
      org-html-postamble #'my/site-footer
      org-html-metadata-timestamp-format "%Y-%m-%d"
      org-html-checkbox-type 'site-html
      org-html-html5-fancy nil
      org-html-htmlize-output-type 'css ;; syntax highlighting with stylesheet not inline css. Use
      org-html-self-link-headlines t    ;; org-html-htmlize-generate-css to generate a stylesheet
      org-html-validation-link nil
      org-html-inline-images t
      org-html-doctype "html5")

(setq org-publish-project-alist
      (list
       (list "notes.alex-miller.co"
             :base-extension "org"
             :base-directory "./"
             :publishing-function '(my/org-html-publish-to-html)
             :publishing-directory "./public"
             :auto-sitemap t
             :sitemap-title my/sitemap-title
             :sitemap-format-entry 'my/sitemap-format-entry
             :with-title nil)
       (list "images"
             :base-extension "png\\|jpg\\|svg"
             :base-directory "./images"
             :publishing-directory "./public/images"
             :publishing-function 'org-publish-attachment)
       (list "site" :components '("notes.alex-miller.co" "images"))))

(defun my/publish ()
  (interactive)
  (org-publish-all t))
