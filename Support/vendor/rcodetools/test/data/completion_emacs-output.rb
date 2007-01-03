(progn
(setq rct-method-completion-table '(("uniq") ("uniq!") ))
(setq pattern "uni")
(try-completion pattern rct-method-completion-table nil)
)
