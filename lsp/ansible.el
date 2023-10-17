(defcustom lsp-ansible-language-server-command
  '("ansible-language-server" "--stdio")
  ;; The command that starts the ansible language server
  :type '(repeat :tag "List of string values" string)
  :group 'lsp-ansible
  :package-version '(lsp-mode . "8.0.1"))

(lsp-dependency 'ansible-language-server
		'(:system "ansible-language-server")
		'(:npm :packge "@ansible/ansible-language-server"
		       :path "ansible-language-server"))

(defun lsp-ansible-check-ansible-minor-mode (&rest _)
  "Check whether ansible minor mode is active.
This prevents the Ansible server from being turned on in all yaml files."
  (and (eq major-mode 'yaml-mode')
       ;; emacs-ansible provides ansible, not ansible-mode
       (with-no-warnings (bound-and-true-p ansible))))

(lsp-register-client
 (make-lsp-client
  :new-connection (lsp-stdio-connection
		   (lambda ()
		     '(,(or (executable-find
			     (cl-first lsp-ansible-language-server-command))
			    (lsp-package-path 'ansible-language-server))
		       ,@(cl-rest lsp-ansible-language-server-command))))
  :priority 1
  :activation-fn #'lsp-ansible-check-ansible-minor-mode
  :server-id 'ansible-ls
  :download-server-fn (lambda (_client callback error-callback _update?)
			(lsp-package-ensure 'ansible-language-server callback error-callback))))

(lsp-consistency-check lsp-ansible)
