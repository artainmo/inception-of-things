#Starts the whole app
all:
	./scripts/setup.sh

#Reloads the whole app
re:
	./scripts/fclean.sh
	./scripts/setup.sh

#Remove the whole app
clean:
	./scripts/fclean.sh

#Create the argo-cd app (if kubernetes cluster with argo-cd controller already exists)
launch:
	./scripts/launch.sh

#Reload the argo-cd app
re_launch:
	./scripts/clean.sh
	./scripts/launch.sh

#Remove the argo-cd app
clean_launch:
	./scripts/clean.sh

#Verify created app
verify:
	./scripts/verify.sh
