---
- hosts: sdkperf_nodes
  remote_user: centos

  ##################################################
  # SDKPerf Config Section
  #
  # INSTRUCTIONS:
  #  (1) Fill out the following variables
  #  (2) Run `ansible-playbook -i ../../ansible/inventory/az-sdkperf-nodes.inventory --private-key ../../keys/azure_key start-sdkperf-c-pub.yml`
  #  (3) If you do not have a monitoring solution in place for your broker, you'll need to check the nohup.out file on each of the sdkperf nodes.
  #  (4) Rename this file "start-sdkperf.yml"
  ##################################################
  vars:
    # solace broker connection details
    broker_ips: [
%{ for ip in solacebroker-node-ips ~}
    ${ip},
%{ endfor ~}
    ]
    broker_port: 55555
    broker_msg_vpn: sdkperf # you don't have to edit this unless you've created your own message vpn
    client_username: testUsr
    client_password: default
    msg_queue_prefix: TestQueue

    # sdkperf settings
    client_connection_count: 5 # 1 || 10 || 100 || 1000 || etc...

  ##################################################

  tasks:
    - name: Consume Test Queue 
      shell: nohup ./sdkperf-c-x64/sdkperf_c -cip="{{ item }}":"{{ broker_port }}" -cu="{{ client_username }}"@"{{ broker_msg_vpn }}" -cp="{{ client_password }}" -cc="{{ client_connection_count }}" -sql="{{ msg_queue_prefix }}""{{groups['sdkperf_nodes'].index(inventory_hostname)}}" </dev/null >/dev/null 2>&1 &
      loop: "{{ broker_ips }}"

