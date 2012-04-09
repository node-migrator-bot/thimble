
test:
		@./node_modules/.bin/mocha \
		--compilers coffee:coffee-script \
		--reporter dot \
		--growl

subl:
	@subl lib/ test/ examples/ bin/ package.json Makefile index.js

.PHONY: subl test
