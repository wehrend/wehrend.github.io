
# ~/development/hugo/blog#
version="klakegg/hugo:0.107.0-ext-asciidoctor"
pwd_ = "/home/sven/development/hugo/blog"

pull:
	docker login
	docker pull $(version)

up:
	docker run  -it -v $(pwd_):/src -p 1313:1313 $(version) server  --disableFastRender --renderToDisk --verbose

deploymnent:
	rsync -rav public/ wehrend@giclas.uberspace.de:/var/www/virtual/wehrend/html --delete
