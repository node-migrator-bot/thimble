
test:
	@./node_modules/.bin/mocha \
		--require should \
	  --reporter list \
		--growl

.PHONY: test