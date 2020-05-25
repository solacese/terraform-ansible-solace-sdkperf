[sdkperf_nodes]
%{ for ip in sdkperf_node_ips ~}
${ip}
%{ endfor ~}