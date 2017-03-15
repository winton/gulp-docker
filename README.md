# GulpDocker

Gulp tasks for managing Docker images and containers.

## Gulpfile

Within your `Gulpfile`, initialize `GulpDocker` with an instance of gulp and container options:

	var gulp       = require("gulp");
	var GulpDocker = require("gulp-docker");

	new GulpDocker(gulp, {
		sidekick: {
			build: "bin/build"
			run:   "bin/sidekick",
			env:   { ENV: "production" },
			git:   "git@github.com:winton/sidekick.git#release",
			repo:  "quay.io/winton/sidekick"
		}
	});

## Container Options

Each key of the object is the container name.

Each value of the object is another object with the following possible keys:

* `build` - The command to run within the Docker container after building the image, before pushing (optional).
* `dockerfile` - The directory to discover the Dockerfile (optional).
* `env` - Object containing environmental variables (optional).
* `git` - A git repository URL string (optional).
* `name` - The name of the container (required).
* `ports` - An array of port strings in "[host-port]:[container-port]" format (optional).
* `repo` - The Docker repository to push to on build (optional).
* `run` - The command to run within the Docker container (optional).
* `tags` - An array of tags to use when pushing the image (required).
* `volumes` - An array of volume strings in "[host-dir]:[container-dir]:[rw|ro]" format (optional).

## Tasks

* `docker:image` - Build and optionally push one or more Docker images.
* `docker:restart` - Restart one or more Docker containers.
* `docker:run` - Run one or more Docker containers.
* `docker:stop` - Stop one or more Docker containers.

## What happens on build?

* Ask user which containers to build and (optionally) push.
* Clone a pristine copy of the app.
* Run `docker build` within app directory (`Dockerfile` should be present).
* Push the Docker image if specified.

## What happens on run?

* Build happens if image is not found (see above).
* Generate run arguments from container options.
* Call `docker run` with arguments.

## How to avoid user prompts

Simply set the following two environment variables:
* IMAGE - string, the name of the image to build
* PUSH - int, enter '1' for auto push

## Dev setup

	npm install

## Docs

	node_modules/.bin/codo lib
	open doc/index.html
