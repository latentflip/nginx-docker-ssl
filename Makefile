IP := $(shell ipconfig getifaddr en0)

# Util to kill as I develop
kill:
	docker kill $(shell docker ps -q)

sites-enabled/default.tmpl: templates/default.erb
	HOST_IP=$(IP) erb $< > $@

start.sh: templates/start.sh.erb
	HOST_IP=$(IP) erb $< > $@

start: kill start.sh
	bash start.sh

build: Dockerfile sites-enabled/default.tmpl boot.sh
	docker build -t latentflip/nginx .

.IGNORE: kill
