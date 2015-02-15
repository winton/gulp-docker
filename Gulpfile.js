var gulp       = require("gulp");
var GulpDocker = require("./lib/gulp-docker");

new GulpDocker(gulp, {
	"gulp-docker-test": {
		command: [ "/bin/sh", "-c", "while true; do echo $MSG; sleep 10; done" ],
		env:     { MSG: "hello world" },
		git:     "git@github.com:winton/gulp-docker-test.git",
		ports:   [ "8080:8080" ],
		repo:    "quay.io/fullstackmedia/gulp-docker-test",
		volumes: [ ".:/app" ]
	}
});