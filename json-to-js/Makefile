all:
	node parsejs.js ../programs/break.js > jsonprograms/break.json
	node parsejs.js ../programs/continue.js > jsonprograms/continue.json
	node parsejs.js ../programs/dowhile.js > jsonprograms/dowhile.json
	node parsejs.js ../programs/for.js > jsonprograms/for.json
	node parsejs.js ../programs/forin.js > jsonprograms/forin.json
	node parsejs.js ../programs/func2.js > jsonprograms/func2.json
	node parsejs.js ../programs/func3.js > jsonprograms/func3.json
	node parsejs.js ../programs/switch.js > jsonprograms/switch.json
	node parsejs.js ../programs/trycatch.js > jsonprograms/trycatch.json

run:
	krun jsonprograms/bool.json
	krun jsonprograms/multipvar.json
	krun jsonprograms/var.json
	krun jsonprograms/if.json
	krun jsonprograms/null.json
	krun jsonprograms/post.json
	krun jsonprograms/pre.json
	krun jsonprograms/while.json
	krun jsonprograms/asgn.json
	krun jsonprograms/arr.json
	krun jsonprograms/float.json
	krun jsonprograms/str.json
#	krun jsonprograms/break.json
#	krun jsonprograms/continue.json
#	krun jsonprograms/dowhile.json
#	krun jsonprograms/for.json
#	krun jsonprograms/forin.json
#	krun jsonprograms/func2.json
#	krun jsonprograms/func3.json
#	krun jsonprograms/switch.json
#	krun jsonprograms/trycatch.json
