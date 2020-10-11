#!/bin/sh
printenv
aws ecs update-service \
  --force-new-deployment \
  --cluster minecraft-box-cluster \
  --service minecraft-box-service \
  --region us-east-2
