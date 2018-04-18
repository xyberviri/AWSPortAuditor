@ECHO OFF
IF %1 == "" EXIT /B 1
SET targetProfile=%1
shift
SET targetGroupIDs=%1
aws elb --profile "%targetProfile%" describe-load-balancers --output json|jq -r "{ID:.LoadBalancerDescriptions[].Instances[].InstanceId,NAME: .LoadBalancerDescriptions[].LoadBalancerName}"
