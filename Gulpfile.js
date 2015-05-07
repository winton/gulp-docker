var gulp       = require("gulp");
var GulpDocker = require("./lib/gulp-docker");

var env = process.env.ENV || "development";

new GulpDocker(gulp, {
	"gulp-docker-test": {
		run:        [ "/bin/sh", "-c", "while true; do echo $MSG; sleep 10; done" ],
		dockerfile: ".",
		env:        { ENV: env },
		git:        "git@github.com:winton/gulp-docker-test.git",
		ports:      [ "8080:8080" ],
		repo:       "quay.io/fullstackmedia/gulp-docker-test",
		tags:       [ env ],
		volumes:    [ ".:/app" ]
	}
});
