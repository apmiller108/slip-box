;; This is based on David Wilson's publish.el
;; Author: David Wilson <david@daviwil.com>
;; Maintainer: David Wilson <david@daviwil.com>
;; URL: https://sr.ht/~daviwil/dotfiles

;; Usage:
;; emacs -Q --batch -l ./publish.el --funcall my/publish

(require 'package)

;; Set the package installation directory so that packages aren't stored in the
;; ~/.emacs.d/elpa path.
(setq package-user-dir (expand-file-name "./.packages"))

(setq package-archives '(("melpa" . "https://melpa.org/packages/")
                         ("elpa" . "https://elpa.gnu.org/packages/")))

(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))

(unless (package-installed-p 'use-package)
  (package-install 'use-package))
(require 'use-package)

;; Provides writing markup in lisp
(use-package esxml :ensure t)

;; A publishing backend
(use-package ox-slimhtml :ensure t)

;; Syntax highlighting
(use-package htmlize :ensure t)

;; rss/atom feed
(use-package webfeeder :ensure t)

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
      org-export-date-timestamp-format "Y-%m-%d %H:%M %p"
      org-export-with-toc t) ;; toc = table of contents

(setq make-backup-files nil)

;; The backquote quotes a list but allows use of the `,' to evalulate expressions selectively.
;; See for more on this https://www.gnu.org/software/emacs/manual/html_node/elisp/Backquote.html
(defun my/site-header (info)
  (let* ((file (plist-get info :output-file)))
    (concat
     (sxml-to-xml
      `(div (div (@ (class "heading uk-container")) ;; `@' is the attribute function
                 (div (@ (class "site-title-container uk-flex uk-flex-middle"))
                      (span (@ (uk-icon "icon: user; ratio: 2.5")) nil)
                      (h1 (@ (class "site-title uk-h1 uk-heading-medium")) ,my/site-title))
                 (div (@ (class "site-tagline uk-text-lead")) ,my/site-tagline))
            (div (@ (class "uk-container"))
                 (nav (@ (class "uk-navbar-container uk-navbar-transparent")
                         (uk-navbar))
                      (div (@ (class "uk-navbar-left"))
                              (ul (@ (class "uk-navbar-nav"))
                                  (li (a (@ (class "nav-link") (href "/")) "Notes"))
                                  (li (a (@ (class "nav-link") (href "https://blog.alex-miller.co")) "Blog"))
                                  (li (a (@ (class "nav-link") (href "https://github.com/apmiller108")) "Github"))
                                  (li (a (@ (class "nav-link") (href "https://alex-miller.co")) "alex-miller.co")))))))))))

(defun my/site-footer (info) ;; info is a plist passed in from org-mode
  (sxml-to-xml
   `(footer (@ (class "blog-footer"))
            (div (@ (class "uk-container"))
                 (div (@ (class "made-with"))
                      (p "Made with " ,(plist-get info :creator))))))) ;; creator is "Emacs version# (Org mode version#)"

(defun get-article-output-path (org-file pub-dir)
  (let ((article-dir (concat pub-dir
                             (downcase
                              (file-name-as-directory
                               (file-name-sans-extension
                                (file-name-nondirectory org-file)))))))
    ;; Makes the sitemap the root index.html file
    (if (string-match "\\/sitemap.org$" org-file)
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
            (script (@ (src "/js/site.js")) nil)
            (script (@ (src "https://www.googletagmanager.com/gtag/js?id=G-YM3EHHB2YQ")) nil)
            (script
             "window.dataLayer = window.dataLayer || [];
              function gtag(){dataLayer.push(arguments);}
              gtag('js', new Date());

              gtag('config', 'G-YM3EHHB2YQ');"
             )
            (title ,(concat (org-export-data (plist-get info :title) info) " - notes.alex-miller.com")))
           (body
             ,(my/site-header info)
             (div (@ (class "uk-container"))
                  (div (@ (class "note"))
                       (div (@ (class "blog-post"))
                            (h1 (@ (class "blog-post-title uk-h1"))
                                ,(org-export-data (plist-get info :title) info))
                            (p (@ (class "blog-post-meta"))
                              ,(org-export-data (org-export-get-date info "%B %e, %Y") info)) ;; Comes from the `#date:' export option
                            ,(let ((tags (org-export-data (plist-get info :roam_tags) info)))
                               (when (and tags (> (length tags) 0))
                                 `(p (@ (class "blog-post-tags"))
                                     "Tags: "
                                     ,(mapconcat (lambda (tag) (format "<a href=\"/?tag=%s\">%s</a>" tag tag))
                                                 (plist-get info :roam_tags)
                                                 ", "))))
                            ,contents)
                       ,(when (not (string-equal my/sitemap-title (org-export-data (plist-get info :title) info)))
                          '(script (@ (src "https://utteranc.es/client.js")
                                      (repo "apmiller108/slip-box")
                                      (issue-term "title")
                                      (label "comments")
                                      (theme "boxy-light")
                                      (crossorigin "anonymous")
                                      (async))
                                   nil))))
                  ,(my/site-footer info))))))

(defun my/org-html-link (link contents info)
  "Removes file extension and changes the path into lowercase org file:// links.
   Handles creating inline images with `<img>' tags for png, jpg, and svg files
   when the link doesn't have a label, otherwise just creates a link."
  ;; TODO: refactor this mess
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
  "Formats sitemap entry <date> <title> (<tags>). Returns a list containing the
   sitemap entry string and roam tags"
  (let* ((roam-tags (org-publish-find-property entry :roam_tags project 'site-html))
         (created-at (format-time-string "%Y-%m-%d"
                                         (date-to-time
                                          (format "%s" (nth 0 (org-publish-find-property entry :date project))))))
         (entry
          (concat
           (format "<div data-date=\"%s\" data-tags=\"[%s]\">" created-at (mapconcat (lambda (tag) tag) roam-tags ", "))
           (format "<span class=\"sitemap-entry-date\">%s</span>" created-at)
           (format " <a href=/%s>%s</a>"
                   (file-name-sans-extension entry)
                   (org-publish-find-title entry project))
           (if roam-tags
               (concat " <span class=\"sitemap-entry-tags\">("
                       (mapconcat (lambda (tag) tag) roam-tags ", ")
                       ")</span>"))
           "</div>")))
    (list entry roam-tags)))

(defun my/sitemap (title list)
  (let* ((unique-tags
          (sort
           (delete-dups
            (flatten-tree
              (mapcar (lambda (item) (cdr (car item)))
                      (cdr list))))
           (lambda (a b) (string< a b)))))
    (concat
     "#+TITLE: " title "\n\n"
     "#+BEGIN_EXPORT html\n"
     (concat
      "<div class=\"tags\">"
      (mapconcat (lambda (item) (format "<span><a href=/?=%s>%s</a></span>" item item))
                 unique-tags
                 "\n")
      "</div>"
      "<ul class=\"sitemap-entries uk-list uk-list-disc uk-list-emphasis\">"
      (mapconcat (lambda (item) (format "<li>%s</li>" (car (car item))))
                 (cdr list)
                 "\n")
      "</ul>")
     "\n#+END_EXPORT\n")))

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
             :sitemap-function 'my/sitemap
             :sitemap-title my/sitemap-title
             :sitemap-format-entry 'my/sitemap-format-entry
             :sitemap-sort-files 'alphabetically
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
