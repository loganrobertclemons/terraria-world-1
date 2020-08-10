TAG=v1
IMAGE=gcr.io/exam-prep-285301/startup-script

.PHONY: build push

build:
	docker build --pull -t : ./gke-startup-script

push: build
	gcloud docker -- push :
TAG=v1
IMAGE=gcr.io/exam-prep-285301/startup-script

.PHONY: build push

build:
	docker build --pull -t gcr.io/exam-prep-285301/startup-script:v1 ./gke-startup-script

push: build
	gcloud docker -- push gcr.io/exam-prep-285301/startup-script:v1 
