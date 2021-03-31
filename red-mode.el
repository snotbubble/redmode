;;; red-mode.el -*- coding: utf-8; lexical-binding: t; -*-

;; modified from sample in this article:
;; How to Write a Emacs Major Mode for Syntax Coloring By Xah Lee. 2008-11-30
;; http://www.ergoemacs.org/emacs/elisp_syntax_coloring.html

;; faces for this mode - cpb 2103
;; colors cycle down the list, from red to red, except for uservars
;;
;; #FF4D4D -control......... red
;; #E65C73 - specialstring
;; #CC5C81 - series
;; #CC5C95 - logic
;; #BF609F - modifiers
;; #A6624B - uservars....... brown (disabled for now; regex issues)
;; #9966CC - constants...... purple
;; #7F6CD9 - datatypes
;; #6C7ED9 - viewobj........ blue
;; #527BCC - viewcmd
;; #3992BF
;; #3EB2B3 - viewprop....... cyan
;; #3EB38C - context
;; #3EB365 - comment........ forest-green
;; #3FB33E
;; #599C36 - help........... green
;; #89B336 - datetime....... olive
;; #B3B22D - system
;; #BF8C26 - io............. yellow
;; #CC7B29 - events
;; #D9662B - comparison
;; #E64D2E - math

(defvar red-system-word 'red-system-word)
(defface red-system-word '((t (:foreground "#B3B22D" :weight bold)))
	"system"
	:group 'red-mode)

(defvar red-io-word 'red-io-word)
(defface red-io-word '((t (:foreground "#BF8C26" :weight bold)))
	"io"
	:group 'red-mode)

(defvar red-events-word 'red-events-word)
(defface red-events-word '((t (:foreground "#CC7B29" :weight bold)))
	"events"
	:group 'red-mode)

(defvar red-comparison-word 'red-comparison-word)
(defface red-comparison-word '((t (:foreground "#D9662B" :weight bold)))
	"comparison"
	:group 'red-mode)

(defvar red-math-word 'red-math-word)
(defface red-math-word '((t (:foreground "#E64D2E" :weight bold)))
	"math"
	:group 'red-mode)

(defvar red-control-word 'red-control-word)
(defface red-control-word '((t (:foreground "#FF4D4D" :weight bold)))
	"control"
	:group 'red-mode)

(defvar red-specialstring-word 'red-specialstring-word)
(defface red-specialstring-word '((t (:foreground "#E65C73" :weight bold)))
	"specialstring"
	:group 'red-mode)

(defvar red-series-word 'red-series-word)
(defface red-series-word '((t (:foreground "#CC5C81" :weight bold)))
	"series"
	:group 'red-mode)

(defvar red-logic-word 'red-logic-word)
(defface red-logic-word '((t (:foreground "#CC5C95" :weight bold)))
	"logic"
	:group 'red-mode)

(defvar red-modifiers-word 'red-modifiers-word)
(defface red-modifiers-word '((t (:foreground "#BF609F" :weight bold)))
	"modifiers"
	:group 'red-mode)

(defvar red-var-word 'red-var-word)
(defface red-var-word '((t (:foreground "#B35147" :weight bold)))
	"user variables"
	:group 'red-mode)

(defvar red-constants-word 'red-constants-word)
(defface red-constants-word '((t (:foreground "#9966CC" :weight bold)))
	"constants"
	:group 'red-mode)

(defvar red-datatypes-word 'red-datatypes-word)
(defface red-datatypes-word '((t (:foreground "#7F6CD9" :weight bold)))
	"datatypes"
	:group 'red-mode)

(defvar red-viewobj-word 'red-viewobj-word)
(defface red-viewobj-word '((t (:foreground "#6C7ED9" :weight bold)))
	"viewobj"
	:group 'red-mode)

(defvar red-drawobj-word 'red-drawobj-word)
(defface red-drawobj-word '((t (:foreground "#6C7ED9" :weight bold)))
	"drawobj"
	:group 'red-mode)

(defvar red-viewcmd-word 'red-viewcmd-word)
(defface red-viewcmd-word '((t (:foreground "#527BCC" :weight bold)))
	"viewcmd"
	:group 'red-mode)

(defvar red-drawcmd-word 'red-drawcmd-word)
(defface red-drawcmd-word '((t (:foreground "#527BCC" :weight bold)))
	"drawcmd"
	:group 'red-mode)

(defvar red-viewprp-word 'red-viewprp-word)
(defface red-viewprp-word '((t (:foreground "#3EB2B3" :weight bold)))
	"viewprp"
	:group 'red-mode)

(defvar red-drawprp-word 'red-drawprp-word)
(defface red-drawprp-word '((t (:foreground "#3EB2B3" :weight bold)))
	"drawprp"
	:group 'red-mode)

(defvar red-context-word 'red-context-word)
(defface red-context-word '((t (:foreground "#3EB38C" :weight bold)))
	"context"
	:group 'red-mode)

(defvar red-comment-word 'red-comment-word)
(defface red-comment-word '((t (:foreground "#3EB365" :weight bold)))
	"modifiers"
	:group 'red-mode)

(defvar red-help-word 'red-help-word)
(defface red-help-word '((t (:foreground "#599C36" :weight bold)))
	"help"
	:group 'red-mode)

(defvar red-datetime-word 'red-datetime-word)
(defface red-datetime-word '((t (:foreground "#89B336" :weight bold)))
	"datetime"
	:group 'red-mode)


;; override fonts, this is applies to all buffers, envestigate a local option
(set-face-foreground 'font-lock-string-face "#3EB365")
(set-face-foreground 'font-lock-comment-face "#4E736D")
(set-face-foreground 'default "#86B5BF")

;; create the list for font-lock.
;; each category of keyword is given a particular face 
(
	setq red-font-lock-keywords (
		let* (
			;; define several category of keywords
			;;
			;; red/rebol words sourced from http://www.rebol.org/view-script.r?script=code-colorizer.r
			;; by David Oliva 2009
			(x-comparison '("all" "and" "and~" "any" "equal?" "even?" "greater-or-equal?" "greater?" "lesser-or-equal?" "lesser?" "negative?" "not" "not-equal?" "odd?" "or" "or~" "positive?" "same?" "sign?" "strict-equal?" "xor" "xor?" "zero?" ))
			(x-context '("alias" "bind" "context" "get" "in" "set" "unset" "use" "value?" "needs"))
			(x-control '("Red" "opt" "attempt" "break" "catch" "compose" "disarm" "dispatch" "does" "either" "else" "exit" "forall" "foreach" "for" "forever" "forskip" "func" "function" "halt" "has" "if" "launch" "loop" "next" "quit" "reduce" "remove-each" "repeat" "return" "switch" "throw" "try" "unless" "until" "while" "do" ))
			(x-help '("prin" "print" "about" "comment" "dump-face" "dump-obj" "help" "license" "probe" "source" "trace" "usage" "what"))
			(x-logic '("complement" "found?" "true" "false" "none" "any-block?" "any-function?" "any-string?" "any-type?" "any-word?" "as-pair" "binary?" "bitset?" "block?" "char?" "construct" "datatype?" "date?" "decimal?" "dir?" "dump-obj" "email?" "empty?" "error?" "event?" "file?" "function?" "get-word?" "head?" "hash?" "image?" "integer?" "issue?" "library?" "list?" "lit-path?" "lit-word?" "logic?" "make" "money?" "native?" "none?" "number?" "object?" "op?" "pair?" "paren?" "path?" "port?" "refinement?" "routine?" "series?" "set-path?" "set-word?" "string?" "struct?" "suffix?" "tag?" "tail?" "time?" "tuple?" "type?" "unset?" "url?" "word?"))
			(x-datatypes '("to-binary" "to-bitset" "to-block" "to-char" "to-date" "to-decimal" "to-email" "to-file" "to-get-word" "to-hash" "to-hex" "to-idate" "to-image" "to-integer" "to-issue" "to-list" "to-lit-path" "to-lit-word" "to-logic" "to-money" "to-pair" "to-paren" "to-path" "to-refinement" "to-set-path" "to-set-word" "to-string" "to-tag" "to-time" "to-tuple" "to-url" "to-word" ))
			(x-math '("abs" "absolute" "add" "arccosine" "acos" "arcsine" "arctangent" "complement" "cosine" "divide" "exp" "log-10" "log-2" "log-e" "maximum-of" "maximum" "max"  "min" "minimum" "multiply" "negate" "power" "random" "remainder" "round" "sine" "square-root" "subtract" "tangent"))
			(x-io '("ask" "change-dir" "close" "confirm" "connected?" "delete" "dispatch" "echo" "exists\\s\\?" "get-modes" "info?" "input" "input?" "list-dir" "make-dir" "modified?" "open"  "query" "read" "read-io" "rename" "resend" "save" "script?" "secure" "send" "set-modes" "set-net" "size?" "to-local-file" "to-rebol-file" "update" "wait" "what-dir" "write-io" "write" ))
			(x-series '("alter" "append" "array" "at" "back" "change" "clear" "copy" "difference" "exclude" "extract" "find" "first" "found?" "free" "head" "index?" "insert" "intersect" "join" "last" "length?" "load" "maximum-of" "minimum-of" "offset?" "parse" "pick" "poke" "remove" "remove-each" "repend" "replace" "reverse" "select" "skip" "sort" "switch" "tail" "union" "unique"))
			(x-specialstring '("build-tag" "checksum" "clean-path" "compress" "debase" "decode-cgi" "decompress" "dehex" "detab" "dirize" "enbase" "entab" "form" "import-email" "lowercase" "mold" "parse-xml" "pad" "quote" "reform" "rejoin" "remold" "split-path" "suffix" "trim" "uppercase" "to" "thru"))
			(x-system '("browse" "call" "component?" "link?" "protect" "protect-system" "recycle" "unprotect" "upgrade"))
			(x-datetime '("now" "date" "time" "precise" "weekday" "month" "year" "second"))
			(x-viewcmd '("across" "alert" "as-pair" "below" "brightness?" "caret-to-offset" "center-face" "choose" "clear-fields" "do-events" "flash" "focus" "hide-popup" "hide" "in-window?" "inform" "link?" "load-image" "make-face" "offset-to-caret" "request-color" "request" "request-date" "request-download" "request-file" "request-list" "request-pass" "request-text" "return" "show-popup" "show" "size-text" "span?" "stylize" "unfocus" "unview" "viewed?" "within?"))
			(x-viewobj '("panel" "font" "area" "check" "face" "tab-panel" "button" "image" "field" "drop-list" "drop-down" "text-list" "text" "slider" "layout" "view"))
			(x-viewprp '("all-over" "anti-alias" "text" "offset" "size" "x" "y" "data" "extra" "options" "flags" "color" "font-size" "font-weight" "font-name" "font-style" "selected" "pane" "tight" "loose" "bold" "picked" "parent"))
			(x-constants '("black" "red" "white" "green" "papaya" "blue"))
			(x-events '("event" "on-change" "on-enter" "on-menu" "on-down" "on-up" "on-resizing" "react" "on-drag" "on-mid-down" "on-mid-up" "on-wheel" "on-over"))
			(x-drawcmd '("draw"))
			(x-drawobj '("box" "line" "circle" "arc" "pen" "fill-pen"))
			(x-modifiers '("with" "left" "right" "only" "deep" "output" "filter"))
			;; generate regex string for each category of keywords
			;; suffixed words 1st, as they contain many duplicates
			(x-logic-regexp (regexp-opt x-logic 'words))
			;; hyphenated words, may contain duplicates
			(x-datatypes-regexp (regexp-opt x-datatypes 'words))
			(x-viewprp-regexp (regexp-opt x-viewprp 'words))
			(x-events-regexp (regexp-opt x-events 'words))
			;; special exception
			(x-comparison-regexp (regexp-opt x-comparison 'words))
			;; may contain the odd hyphen or suffix, but mostly pure
			(x-context-regexp (regexp-opt x-context 'words))
			(x-io-regexp (regexp-opt x-io 'words))
			(x-system-regexp (regexp-opt x-system 'words))
			(x-help-regexp (regexp-opt x-help 'words))
			(x-math-regexp (regexp-opt x-math 'words))
			(x-specialstring-regexp (regexp-opt x-specialstring 'words))
			(x-viewobj-regexp (regexp-opt x-viewobj 'words))
			(x-control-regexp (regexp-opt x-control 'words))
			;; 'pure' words; no hyphens, suffixes etc.
			(x-viewcmd-regexp (regexp-opt x-viewcmd 'words))
			(x-datetime-regexp (regexp-opt x-datetime 'words))
			(x-series-regexp (regexp-opt x-series 'words))
			(x-constants-regexp (regexp-opt x-constants 'words))
			(x-drawcmd-regexp (regexp-opt x-drawcmd 'words))
			(x-drawobj-regexp (regexp-opt x-drawobj 'words))
			(x-modifiers-regexp (regexp-opt x-modifiers 'words))
		)
		`(
			;; suffixed
			(,"[A-Za-z]+\\?+" . red-logic-word)
			(,x-logic-regexp . red-logic-word) 
			;; hyphenated
			(,x-datatypes-regexp . red-datatypes-word) 
			(,x-viewprp-regexp . red-viewprp-word) 
			(,x-events-regexp . red-events-word)
			;; special exception
			(,x-comparison-regexp . red-comparison-word)
			;; some suffixes or hyphens
			(,x-context-regexp . red-context-word) 
			(,x-io-regexp . red-io-word) 
			(,x-system-regexp . red-system-word) 
			(,x-help-regexp . red-help-word)
			(,x-math-regexp . red-math-word) 
			(,x-specialstring-regexp . red-specialstring-word) 
			(,x-viewobj-regexp . red-viewobj-word) 
			(,x-control-regexp . red-control-word)
			;; pure
			(,x-viewcmd-regexp . red-viewcmd-word) 
			(,x-datetime-regexp . red-datetime-word) 
			(,x-series-regexp . red-series-word) 
			(,x-constants-regexp . red-constants-word) 
			(,x-drawcmd-regexp . red-drawcmd-word) 
			(,x-drawobj-regexp . red-drawobj-word) 
			(,x-modifiers-regexp . red-modifiers-word)
			;; note: order above matters, because once colored, that part won't change.
			;; in general, put longer words first
		)
	)
)

;;;###autoload
(
	define-derived-mode red-mode lisp-mode "red mode"
	"Major mode for editing RED…"
	;; code for syntax highlighting
	(
		setq font-lock-defaults '(
			(
				red-font-lock-keywords
			)
		)
	)
)

;; add the mode to the `features' list
(provide 'red-mode)

;;; red-mode.el ends here
