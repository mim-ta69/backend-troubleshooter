; Ask a yes/no or multiple-choice question
(deffunction ask-question (?question $?allowed)
   (printout t ?question)
   (bind ?answer (read))
   (while (not (member$ ?answer ?allowed)) do
      (printout t "Please answer one of: " ?allowed crlf)
      (printout t ?question)
      (bind ?answer (read)))
   (return ?answer))

; Ask a numeric question
(deffunction ask-number (?question)
   (printout t ?question)
   (bind ?num (read))
   (while (not (numberp ?num)) do
      (printout t "Please enter a number." crlf)
      (printout t ?question)
      (bind ?num (read)))
   (return ?num))

; CATEGORY SELECTION
(defrule start
   =>
   (printout t crlf)
   (printout t "<< Back-End troubleshooter Expert System >>" crlf)
   (printout t "Select a category:" crlf)
   (printout t "1. Service Availability" crlf)
   (printout t "2. API Performance" crlf)
   (printout t "3. Database Issues" crlf)
   (printout t "4. Configuration & Environment" crlf)
   (printout t "5. Infrastructure" crlf)
   (printout t "6. Security & Networking" crlf crlf)

   (bind ?choice (ask-question "Enter choice (1-6): "
                               (create$ 1 2 3 4 5 6)))

   (switch ?choice
      (case 1 then (assert (category service)))
      (case 2 then (assert (category api)))
      (case 3 then (assert (category db)))
      (case 4 then (assert (category config)))
      (case 5 then (assert (category infra)))
      (case 6 then (assert (category security))))
)

; CATEGORY 1: SERVICE AVAILABILITY
(defrule service-questions
   (category service)
   =>
   (bind ?ping (ask-question "Did ping to the service fail? (yes/no): "
                             (create$ yes no)))
   (if (eq ?ping yes) then (assert (ping fail)))

   (bind ?proc (ask-question "Is the service process not running? (yes/no): "
                             (create$ yes no)))
   (if (eq ?proc yes) then (assert (service_process_not_running TRUE)))

   (bind ?port (ask-question "Is the service port closed? (yes/no): "
                             (create$ yes no)))
   (if (eq ?port yes) then (assert (port_closed TRUE)))

   (bind ?uptime (ask-number "Enter uptime (minutes): "))
   (assert (uptime ?uptime))

   (bind ?ssl (ask-question "Is the SSL certificate expired? (yes/no): "
                            (create$ yes no)))
   (if (eq ?ssl yes) then (assert (ssl_cert_expired TRUE)))

   (printout t crlf "Running Service Diagnostics..." crlf)
)

; CATEGORY 2: API PERFORMANCE
(defrule api-questions
   (category api)
   =>
   (bind ?resp (ask-number "Average response time (ms): "))
   (assert (avg_response_time ?resp))

   (bind ?e500 (ask-number "500 error rate (%): "))
   (assert (status_code_500_rate ?e500))

   (bind ?e429 (ask-number "429 rate limit errors (%): "))
   (assert (status_code_429_rate ?e429))

   (bind ?size (ask-number "Average response size (MB): "))
   (assert (response_size ?size))

   (bind ?to (ask-number "Timeout error rate (%): "))
   (assert (timeout_error_rate ?to))

   (printout t crlf "Running API Diagnostics..." crlf)
)

; CATEGORY 3: DATABASE
(defrule db-questions
   (category db)
   =>
   (bind ?conn (ask-question "Is the DB connection failing? (yes/no): "
                             (create$ yes no)))
   (if (eq ?conn yes) then (assert (db_connection_fail TRUE)))

   (bind ?timeout (ask-number "DB query timeout rate (%): "))
   (assert (db_query_timeout ?timeout))

   (bind ?lag (ask-number "Replication lag (seconds): "))
   (assert (replica_lag ?lag))

   (bind ?dead (ask-question "Are deadlocks detected? (yes/no): "
                             (create$ yes no)))
   (if (eq ?dead yes) then (assert (deadlock_detected TRUE)))

   (bind ?disk (ask-question "Is DB disk full? (yes/no): "
                             (create$ yes no)))
   (if (eq ?disk yes) then (assert (db_disk_full TRUE)))

   (printout t crlf "Running Database Diagnostics..." crlf)
)

; CATEGORY 4: CONFIGURATION
(defrule config-questions
   (category config)
   =>
   (bind ?cfg (ask-question "Is configuration invalid? (yes/no): "
                            (create$ yes no)))
   (if (eq ?cfg yes) then (assert (config_invalid TRUE)))

   (bind ?env (ask-question "Is there environment mismatch? (yes/no): "
                            (create$ yes no)))
   (if (eq ?env yes) then (assert (environment_mismatch TRUE)))

   (printout t crlf "Running Configuration Diagnostics..." crlf)
)

; CATEGORY 5: INFRASTRUCTURE
(defrule infra-questions
   (category infra)
   =>
   (bind ?cpu (ask-number "CPU usage (%): "))
   (assert (cpu_usage ?cpu))

   (bind ?ram (ask-number "Memory usage (%): "))
   (assert (memory_usage ?ram))

   (printout t crlf "Running Infrastructure Diagnostics..." crlf)
)

; CATEGORY 6: SECURITY
(defrule security-questions
   (category security)
   =>
   (bind ?fw (ask-question "Firewall blocking traffic? (yes/no): "
                           (create$ yes no)))
   (if (eq ?fw yes) then (assert (firewall_block TRUE)))

   (bind ?susp (ask-question "Suspicious logins detected? (yes/no): "
                             (create$ yes no)))
   (if (eq ?susp yes) then (assert (suspicious_login TRUE)))

   (printout t crlf "Running Security Diagnostics..." crlf)
)

; DIAGNOSTIC RULES
(defrule service-down
   (ping fail)
   =>
   (printout t "Root Cause: Service Down" crlf)
   (printout t "Recommendation: Check connection or restart service." crlf))

(defrule process-not-running
   (service_process_not_running TRUE)
   =>
   (printout t "Root Cause: Process Not Running" crlf)
   (printout t "Recommendation: Start the service process." crlf))

(defrule port-closed
   (port_closed TRUE)
   =>
   (printout t "Root Cause: Port Closed" crlf)
   (printout t "Recommendation: Adjust firewall rules." crlf))

(defrule recent-crash
   (uptime ?u&:(< ?u 5))
   =>
   (printout t "Root Cause: Recent Service Crash" crlf)
   (printout t "Recommendation: Check service logs." crlf))

(defrule ssl-expired
   (ssl_cert_expired TRUE)
   =>
   (printout t "Root Cause: SSL Certificate Expired" crlf)
   (printout t "Recommendation: Renew SSL certificate." crlf))

(defrule high-latency
   (avg_response_time ?t&:(> ?t 2000))
   =>
   (printout t "Root Cause: High API Latency" crlf)
   (printout t "Recommendation: Inspect DB or CPU load." crlf))

(defrule internal-error
   (status_code_500_rate ?r&:(> ?r 5))
   =>
   (printout t "Root Cause: Excessive 500 Errors" crlf)
   (printout t "Recommendation: Investigate server exceptions." crlf))

(defrule rate-limit
   (status_code_429_rate ?r&:(> ?r 1))
   =>
   (printout t "Root Cause: Rate Limit Triggered" crlf)
   (printout t "Recommendation: Adjust API throttling." crlf))

(defrule large-payload
   (response_size ?s&:(> ?s 1))
   =>
   (printout t "Root Cause: Large API Payload" crlf)
   (printout t "Recommendation: Reduce response size." crlf))

(defrule timeouts
   (timeout_error_rate ?r&:(> ?r 2))
   =>
   (printout t "Root Cause: Timeout Errors" crlf)
   (printout t "Recommendation: Optimize performance." crlf))

(defrule db-unreachable
   (db_connection_fail TRUE)
   =>
   (printout t "Root Cause: Database Unreachable" crlf)
   (printout t "Recommendation: Check DB host and credentials." crlf))

(defrule slow-queries
   (db_query_timeout ?r&:(> ?r 5))
   =>
   (printout t "Root Cause: Slow DB Queries" crlf)
   (printout t "Recommendation: Add indexes, optimize queries." crlf))

(defrule replication-lag
   (replica_lag ?r&:(> ?r 30))
   =>
   (printout t "Root Cause: DB Replication Lag" crlf)
   (printout t "Recommendation: Review replication configuration." crlf))

(defrule deadlock
   (deadlock_detected TRUE)
   =>
   (printout t "Root Cause: Deadlock Detected" crlf)
   (printout t "Recommendation: Optimize transactions." crlf))

(defrule db-disk-full
   (db_disk_full TRUE)
   =>
   (printout t "Root Cause: Database Disk Full" crlf)
   (printout t "Recommendation: Free space or extend storage." crlf))

(defrule config-invalid
   (config_invalid TRUE)
   =>
   (printout t "Root Cause: Invalid Configuration" crlf)
   (printout t "Recommendation: Fix environment variables or config files." crlf))

(defrule env-mismatch
   (environment_mismatch TRUE)
   =>
   (printout t "Root Cause: Environment Mismatch" crlf)
   (printout t "Recommendation: Align dev/stage/prod settings." crlf))

(defrule high-cpu
   (cpu_usage ?u&:(> ?u 90))
   =>
   (printout t "Root Cause: High CPU Usage" crlf)
   (printout t "Recommendation: Scale or optimize." crlf))

(defrule high-memory
   (memory_usage ?u&:(> ?u 90))
   =>
   (printout t "Root Cause: High Memory Usage" crlf)
   (printout t "Recommendation: Restart or increase RAM." crlf))

(defrule firewall-block
   (firewall_block TRUE)
   =>
   (printout t "Root Cause: Firewall Blocking Traffic" crlf)
   (printout t "Recommendation: Update firewall rules." crlf))

(defrule suspicious-login
   (suspicious_login TRUE)
   =>
   (printout t "Root Cause: Suspicious Login Activity" crlf)
   (printout t "Recommendation: Reset credentials, review logs." crlf))
