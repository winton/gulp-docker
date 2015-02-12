var gulp       = require("gulp");
var GulpDocker = require("./lib/gulp-docker");

new GulpDocker(gulp, {
	"gulp-docker-test": {
		command: "/bin/sh -c 'while true; do echo $MSG; sleep 1; done'",
		env:     { MSG: "hello world" },
		git:     "git@github.com:winton/gulp-docker-test.git",
		ports:   [ "3000:4000" ],
		repo:    "quay.io/fullstackmedia/gulp-docker-test",
		volumes: [ ".:/app" ]
	}
});