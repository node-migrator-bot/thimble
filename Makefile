
test:
	@./node_modules/.bin/mocha \
		--reporter list \
		--growl

subl:
	@subl lib/ test/ examples/ bin/ package.json index.js

.PHONY: subl test