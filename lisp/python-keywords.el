;;; python-keywords.el --- Highlight python keywords

;;; Commentary:
;;

;;; Code:

(defun get-python-keywords ()
  "Return data structure of python keywords from glossary."
  (let ((buf (find-file-noselect
	      (expand-file-name
               "python-glossary.org"
	       tq-course-directory))))
    (with-current-buffer buf
      (org-map-entries
       (lambda ()
	 (cons
	  (nth 4 (org-heading-components))
	  (list
	   :python (org-entry-get (point) "python")
	   :content (save-restriction
		      (org-narrow-to-subtree)
		      (buffer-string)))))))))

(defun pydoc-click ()
  "For the python glossary, this is the click action."
  (interactive)
  (mouse-set-point last-input-event)
  (let* ((result (button-lock-find-extent (point) 'glossary))
	 (beg (car result))
	 (end (cdr result))
	 (keyword (buffer-substring beg end))
	 (python (plist-get
		  (cdr
		   (assoc
		    keyword
		    (get-python-keywords)))
		  :python)))
    (when python
      (pydoc python))))

(defvar python-keyword-buttons nil
  "For storing buttons in.")

(defun highlight-python-keywords ()
  "Put highlight on each python keyword."
  (interactive)
  (setq python-keyword-buttons
	(button-lock-set-button
	 (regexp-opt (mapcar 'car (get-python-keywords)))
	 nil ;; no click action
	 :additional-property 'glossary
	 :face '((:background "gray90") (:underline t))
	 :help-echo (lambda (window object position)
		      (save-excursion
			(goto-char position)
			(let* ((result (button-lock-find-extent (point) 'glossary))
			       (beg (car result))
			       (end (cdr result))
			       (keyword (buffer-substring beg end)))
			  (org-remove-flyspell-overlays-in beg end)
			  (plist-get
			   (cdr
			    (assoc
			     keyword
			     (get-python-keywords)))
			   :content))))
	 :mouse-3 'pydoc-click
	 :S-mouse-1 'pydoc-click  ; shift-mouse-1
	 )))

(defun unhighlight-python-keywords ()
  "Remove the python keyword highlights."
  (interactive)
  (button-lock-unset-button python-keyword-buttons)
  (setq python-keyword-buttons nil))

(provide 'python-keywords)

;;; python-keywords.el ends here
