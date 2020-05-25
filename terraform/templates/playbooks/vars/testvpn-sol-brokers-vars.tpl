#####################################################
# Config variables SEMP calls
#####################################################
semp_admin_user: admin
semp_admin_password: admin

#####################################################
# Broker Max Spool
#####################################################
max_spool_usage: 100000

#####################################################
# config variables for creating the VPN
#####################################################
#Message VPN params
vpn:
  vpn_name: "sdkperf"
  maxMsgSpoolUsage: 100000
  authenticationBasicType: "none"

#####################################################
# config variables for creating the ClientProfile
#####################################################
client_profiles:
- clientProfileName: "testCP"
  allowGuaranteedMsgSendEnabled: "true"
  allowGuaranteedMsgReceiveEnabled: "true"
  allowTransactedSessionsEnabled: "false"
  maxConnectionCountPerClientUsername: 1000
  serviceSmfMaxConnectionCountPerClientUsername: 1000
  serviceWebMaxConnectionCountPerClientUsername: 100
  allowBridgeConnectionsEnabled: "false"
  allowGuaranteedEndpointCreateEnabled: "false"
  maxEndpointCountPerClientUsername: 10000
  maxEgressFlowCount: 10000
  maxIngressFlowCount: 10000
  apiQueueManagementCopyFromOnCreateName: ""
  apiTopicEndpointManagementCopyFromOnCreateName: ""
  maxSubscriptionCount: 10000
  maxTransactedSessionCount: 10
  maxTransactionCount: 10

#####################################################
# config variables for creating the Client-Usernames
#####################################################

client_usernames:
- username: "testUsr"
  aclProfileName: "default"
  clientProfileName: "testCP"
  enabled: true
  password: solace123

#####################################################
# config variables for creating queues
#####################################################
# List of Queues generated from Terraform based on the number of SDKPerf Nodes 

queues:
- queueName: "default"
  accessType: "non-exclusive"
  consumerAckPropagationEnabled: "true" 
  egressEnabled: false
  ingressEnabled: false
  maxBindCount: 1000
  maxMsgSize: 10000000
  maxMsgSpoolUsage: 50000
  permission: "delete"
  rejectMsgToSenderOnDiscardBehavior: "never"  
  subscription_topics:
  - ">"

%{ for ip in sdkperf_node_ips ~}
- queueName: "TestQueue${index(sdkperf_node_ips, ip)}"
  accessType: "non-exclusive"
  consumerAckPropagationEnabled: "true" 
  egressEnabled: true
  ingressEnabled: true
  maxBindCount: 1000
  maxMsgSize: 10000000
  maxMsgSpoolUsage: 50000
  permission: "delete"
  rejectMsgToSenderOnDiscardBehavior: "never"  
  subscription_topics:
  - ">"
  
%{ endfor ~}
