
test:
	@./node_modules/.bin/mocha \
		--require should \
	  --reporter list \
		--growl

mate:
	mate src/ test/

.PHONY: test