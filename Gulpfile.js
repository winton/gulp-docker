var gulp       = require("gulp");
var GulpDocker = require("./lib/gulp-docker");

new GulpDocker(gulp, {
	"gulp-docker-test": {
		run:     [ "/bin/sh", "-c", "while true; do echo $MSG; sleep 10; done" ],
		env:     { MSG: "hello world" },
		git:     "git@github.com:winton/gulp-docker-test.git",
		ports:   [ "8080:8080" ],
		repo:    "quay.io/fullstackmedia/gulp-docker-test",
		volumes: [ ".:/app" ]
	},
	"gulp-runner": {
		build:   [ "/bin/sh", "-c", "cp -r /app_volume /app; cd /app; rm -rf node_modules; npm install" ],
		git:     "git@github.com:winton/docker-nodebox.git",
		repo:    "quay.io/fullstackmedia/gulp-runner",
		volumes: [ ".:/app_volume" ]
	}
});