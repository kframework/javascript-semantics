.PHONY: build
build: prerequisite jsaf test262
	@echo "Bootstrapping build..."
	rm -f js-config.k
	touch js-config.k
	$(kbuild)
	@echo "Self-hosted standard built-in objects..."
	cat $(wildcard stdlib/*.js) >stdlib.js
	@echo "Hard-wiring standard built-in objects..."
	krun stdlib.js >stdlib.out 2>&1
	{ echo "<objs> ( _ =>"; \
      cat stdlib.out | awk '/<objs>/ {p=1; next} /<\/objs>/ {p=0} p' | sed 's/@o/@oo/g'; \
      echo ") </objs>"; \
      echo "syntax Oid ::= \"@oo\" \"(\" Int \")\""; \
    } >js-config.k
	@echo "Final build..."
	$(kbuild)

define kbuild
rm -rf js-kompiled
echo "rule #@PWD => \"`pwd`\"" >js-pwd.k
./kpp.py js-main.k >js.k
kompile --no-prelude --backend java js.k
endef

.PHONY: prerequisite
prerequisite:
ifeq ($(shell which kompile),)
	$(error Install K (http://kframework.org) and set PATH accordingly)
endif
ifeq ($(shell which node),)
	$(error Install Node.js (e.g., sudo apt-get install nodejs))
endif

jsaf:
	git clone https://github.com/daejunpark/jsaf.git
	( cd jsaf && \
      wget http://cs.nyu.edu/rgrimm/xtc/xtc.jar && mv xtc.jar bin/ )

test262:
	git clone https://github.com/tc39/test262.git
	( cd test262 && \
      git reset --hard 9b669da66c78bd583bc130a7ca3151258e4681a1 )

include Makefile.test262
