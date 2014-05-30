
(defun wu-lign-region (start end arg)
  (interactive (list (region-beginning) (region-end) current-prefix-arg))
  (shell-command-on-region start end "~/bin/wu-lign" t t))
