#!/usr/bin/env bash
set -o errexit

echo "Logging in to AWS Docker Repository"
$(aws ecr get-login --no-include-email --region $AWS_DEFAULT_REGION)

function build_DOCKER {
	# Build
  echo "Building ${DOCKER_FILE} with tag ${DOCKER_TAG}"
	docker build --no-cache -f $DOCKER_FILE -t $DOCKER_TAG .

	# Tag
  echo "Tagging ${DOCKER_TAG} with tag ${DOCKER_TAG}"
	docker tag $DOCKER_TAG $DOCKER_REPO/$DOCKER_TAG

	# Push
  echo "Pushing: $DOCKER_REPO/$DOCKER_TAG"
  docker push $DOCKER_REPO/$DOCKER_TAG

  echo "Done"
}

#
# Restarts all tasks (containers) in ECS, this will cause them to relaunch
# with the latest version of the code and/or latest version of the database.
#
function restart_all_tasks {
  echo "Updating ECS Cluster"
  aws ecs update-service --force-new-deployment --cluster $DOCKER_CLUSTER --service $DOCKER_SERVICE

  echo "Stopping any old remaining containers (autoscaling should spawn new tasks)"
  for DOCKER_TASK_ID in $(aws ecs list-tasks --cluster $DOCKER_CLUSTER | jq -r ".taskArns[] | split(\"/\") | .[1]");
  do
		echo "Stopping task id: ${DOCKER_TASK_ID}";
		aws ecs stop-task --cluster $DOCKER_CLUSTER --task $DOCKER_TASK_ID;
  done
}