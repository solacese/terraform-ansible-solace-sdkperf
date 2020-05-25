[sa_sol_broker_nodes]
%{ for ip in solacebroker-nodes-ips ~}
${ip}
%{ endfor ~}