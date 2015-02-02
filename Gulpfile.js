var gulp       = require("gulp");
var GulpDocker = require("./lib/gulp-docker");

new GulpDocker(gulp, {
	"gulp-docker-test": {
		app:     "git@github.com:winton/gulp-docker-test.git",
		command: "/bin/sh -c 'while true; do echo $MSG; sleep 1; done'",
		env:     { MSG: "hello world" },
		ports:   [ "3000:4000" ],
		repo:    "quay.io/gulp-docker-test",
		volumes: [ ".:/app" ]
	}
});