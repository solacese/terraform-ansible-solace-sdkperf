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

    # sdkperf settings
    client_connection_count: 4 # 1 || 10 || 100 || 1000 || etc...
    msg_payload_size_bytes: 1024 # 100 || 1000 || 10000 || etc...
    persistent: true # true || false

    # probably don't touch these
    msg_number: 10000000000 # how many total messages to send, but we don't want our test to stop until we tell it to
    msg_rate_per_second: 500 # 0 === full blast, which is the behavior we want if we're testing for msg/sec rates.  If you want to run controlled tests you can edit this

  ##################################################

  tasks:
    - name: run QoS0 test
      shell: nohup ./sdkperf-c-x64/sdkperf_c -cip="{{ item }}":"{{ broker_port }}" -cu="{{ client_username }}"@"{{ broker_msg_vpn }}" -cp="{{ client_password }}" -cc="{{ client_connection_count }}" -ptl=topic1,topic2,topic3,topic4,topic5,topic6,topic7,topic8,topic9,topic10 -mn="{{ msg_number }}" -msa="{{ msg_payload_size_bytes }}" -mr="{{ msg_rate_per_second }}" -mt=direct </dev/null >/dev/null 2>&1 &
      loop: "{{ broker_ips }}"
      when: persistent == false

    - name: run QoS1 test
      shell: nohup ./sdkperf-c-x64/sdkperf_c -cip="{{ item }}":"{{ broker_port }}" -cu="{{ client_username }}"@"{{ broker_msg_vpn }}" -cp="{{ client_password }}" -cc="{{ client_connection_count }}" -ptl=topic1,topic2,topic3,topic4,topic5,topic6,topic7,topic8,topic9,topic10 -mn="{{ msg_number }}" -msa="{{ msg_payload_size_bytes }}" -mr="{{ msg_rate_per_second }}" -mt=persistent </dev/null >/dev/null 2>&1 &
      loop: "{{ broker_ips }}"
      when: persistent == true
