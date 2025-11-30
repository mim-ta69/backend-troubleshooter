;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Back-End Troubleshooter Expert System (single diagnosis)
; Rebuilt to return ONE root cause + ONE recommendation only.
; Strategy:
;  - Diagnostic rules include (not (diagnosed)) so only the first matching
;    (highest-priority) rule fires.
;  - Each diagnostic rule asserts (diagnosed TRUE) after printing to block others.
;  - Salience values set priorities (higher = evaluated/fired earlier).
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Helper functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(deffunction ask-question (?question $?allowed)
   (printout t ?question)
   (bind ?answer (read))
   (while (not (member$ ?answer ?allowed)) do
      (printout t "Please answer one of: " ?allowed crlf)
      (printout t ?question)
      (bind ?answer (read)))
   (return ?answer))

(deffunction ask-number (?question)
   (printout t ?question)
   (bind ?num (read))
   (while (not (numberp ?num)) do
      (printout t "Please enter a number." crlf)
      (printout t ?question)
      (bind ?num (read)))
   (return ?num))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Category selection & question collection (no change in behavior)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defrule start
   =>
   (printout t crlf "=== Back-End Troubleshooter Expert System ===" crlf)
   (printout t "Select a category:" crlf)
   (printout t "1. Service Availability" crlf)
   (printout t "2. API Performance" crlf)
   (printout t "3. Database Issues" crlf)
   (printout t "4. Configuration & Environment" crlf)
   (printout t "5. Infrastructure & Resources" crlf)
   (printout t "6. Security & Network" crlf crlf)

   (bind ?choice (ask-question "Enter choice (1-6): " (create$ 1 2 3 4 5 6)))

   (if (eq ?choice 1) then (assert (category service)))
   (if (eq ?choice 2) then (assert (category api)))
   (if (eq ?choice 3) then (assert (category db)))
   (if (eq ?choice 4) then (assert (category config)))
   (if (eq ?choice 5) then (assert (category infra)))
   (if (eq ?choice 6) then (assert (category security)))
)

(defrule service-questions
   (category service)
   =>
   (bind ?ping (ask-question "Did ping to the service fail? (yes/no): " (create$ yes no)))
   (if (eq ?ping yes) then (assert (ping fail)))

   (bind ?proc (ask-question "Is the service process not running? (yes/no): " (create$ yes no)))
   (if (eq ?proc yes) then (assert (service_process_not_running TRUE)))

   (bind ?port (ask-question "Is the service port closed? (yes/no): " (create$ yes no)))
   (if (eq ?port yes) then (assert (port_closed TRUE)))

   (bind ?uptime (ask-number "Enter uptime (minutes): "))
   (assert (uptime ?uptime))

   (bind ?ssl (ask-question "Is the SSL certificate expired? (yes/no): " (create$ yes no)))
   (if (eq ?ssl yes) then (assert (ssl_cert_expired TRUE)))

   (bind ?lb (ask-question "Is load balancer reporting unhealthy? (yes/no): " (create$ yes no)))
   (if (eq ?lb yes) then (assert (load_balancer_health fail)))

   (bind ?dns (ask-question "Is DNS resolution failing? (yes/no): " (create$ yes no)))
   (if (eq ?dns yes) then (assert (dns_resolution_fail TRUE)))

   (bind ?err (ask-number "Enter error rate percentage (0-100): "))
   (assert (high_error_rate ?err))

   (printout t crlf "Service diagnostics collected." crlf)
)

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

   (bind ?dep (ask-question "Is a dependent API failing? (yes/no): " (create$ yes no)))
   (if (eq ?dep yes) then (assert (api_dependency_fail TRUE)))

   (bind ?cache (ask-number "Cache miss rate (%): "))
   (assert (cache_miss_rate ?cache))

   (bind ?slow (ask-question "Is any endpoint noticeably slow? (yes/no): " (create$ yes no)))
   (if (eq ?slow yes) then (assert (slow_endpoint_detected TRUE)))

   (printout t crlf "API diagnostics collected." crlf)
)

(defrule db-questions
   (category db)
   =>
   (bind ?conn (ask-question "Is the DB connection failing? (yes/no): " (create$ yes no)))
   (if (eq ?conn yes) then (assert (db_connection_fail TRUE)))

   (bind ?qt (ask-number "DB query timeout rate (%): "))
   (assert (db_query_timeout ?qt))

   (bind ?pool (ask-question "Is connection pool exhausted? (yes/no): " (create$ yes no)))
   (if (eq ?pool yes) then (assert (db_connection_pool_exhausted TRUE)))

   (bind ?lag (ask-number "Replica lag (seconds): "))
   (assert (replica_lag ?lag))

   (bind ?dead (ask-question "Deadlock detected recently? (yes/no): " (create$ yes no)))
   (if (eq ?dead yes) then (assert (deadlock_detected TRUE)))

   (bind ?disk (ask-question "Is DB disk full? (yes/no): " (create$ yes no)))
   (if (eq ?disk yes) then (assert (db_disk_full TRUE)))

   (bind ?index (ask-question "Are important indexes missing? (yes/no): " (create$ yes no)))
   (if (eq ?index yes) then (assert (index_missing TRUE)))

   (bind ?backup (ask-question "Did recent DB backup fail? (yes/no): " (create$ yes no)))
   (if (eq ?backup yes) then (assert (db_backup_failed TRUE)))

   (printout t crlf "Database diagnostics collected." crlf)
)

(defrule config-questions
   (category config)
   =>
   (bind ?cfg (ask-question "Is the configuration file missing or invalid? (yes/no): " (create$ yes no)))
   (if (eq ?cfg yes) then (assert (config_invalid TRUE)))

   (bind ?env (ask-question "Is there an environment mismatch? (yes/no): " (create$ yes no)))
   (if (eq ?env yes) then (assert (environment_mismatch TRUE)))

   (bind ?secret (ask-question "Are secrets missing or incorrect? (yes/no): " (create$ yes no)))
   (if (eq ?secret yes) then (assert (missing_secret TRUE)))

   (bind ?perm (ask-question "Are file/dir permissions incorrect? (yes/no): " (create$ yes no)))
   (if (eq ?perm yes) then (assert (bad_permissions TRUE)))

   (bind ?ver (ask-question "Is software version incompatible? (yes/no): " (create$ yes no)))
   (if (eq ?ver yes) then (assert (wrong_version TRUE)))

   (printout t crlf "Configuration diagnostics collected." crlf)
)

(defrule infra-questions
   (category infra)
   =>
   (bind ?cpu (ask-number "CPU usage (%): "))
   (assert (cpu_usage ?cpu))

   (bind ?mem (ask-number "Memory usage (%): "))
   (assert (memory_usage ?mem))

   (bind ?diskio (ask-number "Disk I/O (ops/sec): "))
   (assert (disk_io ?diskio))

   (bind ?diskfree (ask-number "Disk free percentage (%): "))
   (assert (disk_free ?diskfree))

   (bind ?net (ask-number "Network saturation (%): "))
   (assert (network_saturation ?net))

   (bind ?oom (ask-question "Is the system experiencing OOM kills? (yes/no): " (create$ yes no)))
   (if (eq ?oom yes) then (assert (oom_kill TRUE)))

   (printout t crlf "Infrastructure diagnostics collected." crlf)
)

(defrule security-questions
   (category security)
   =>
   (bind ?fw (ask-question "Is firewall blocking traffic? (yes/no): " (create$ yes no)))
   (if (eq ?fw yes) then (assert (firewall_block TRUE)))

   (bind ?sus (ask-question "Suspicious login activity observed? (yes/no): " (create$ yes no)))
   (if (eq ?sus yes) then (assert (suspicious_login TRUE)))

   (bind ?bf (ask-question "Are there many failed logins (possible brute force)? (yes/no): " (create$ yes no)))
   (if (eq ?bf yes) then (assert (brute_force_detected TRUE)))

   (bind ?openp (ask-question "Are unexpected open ports detected? (yes/no): " (create$ yes no)))
   (if (eq ?openp yes) then (assert (open_ports_detected TRUE)))

   (bind ?deps (ask-question "Are dependencies outdated or vulnerable? (yes/no): " (create$ yes no)))
   (if (eq ?deps yes) then (assert (outdated_dependencies TRUE)))

   (bind ?sql (ask-question "Is there evidence of SQL injection attempts? (yes/no): " (create$ yes no)))
   (if (eq ?sql yes) then (assert (sql_injection_detected TRUE)))

   (printout t crlf "Security diagnostics collected." crlf)
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Diagnostic rules — ONLY ONE will fire (use diagnosed lock + salience)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Highest priority: critical network/DNS/load-balancer that blocks everything
(defrule dns-issue
   (declare (salience 200))
   (not (diagnosed))
   (dns_resolution_fail TRUE)
   =>
   (printout t crlf "Root Cause: DNS Resolution Failure" crlf)
   (printout t "Recommendation: Check DNS records and resolvers." crlf)
   (assert (diagnosed TRUE))
)

(defrule load-balancer-issue
   (declare (salience 190))
   (not (diagnosed))
   (load_balancer_health fail)
   =>
   (printout t crlf "Root Cause: Load Balancer Issue" crlf)
   (printout t "Recommendation: Check load balancer configuration and health checks." crlf)
   (assert (diagnosed TRUE))
)

(defrule service-down
   (declare (salience 180))
   (not (diagnosed))
   (ping fail)
   =>
   (printout t crlf "Root Cause: Service Down (no network response)" crlf)
   (printout t "Recommendation: Restart service or check server connectivity." crlf)
   (assert (diagnosed TRUE))
)

(defrule ssl-expired
   (declare (salience 175))
   (not (diagnosed))
   (ssl_cert_expired TRUE)
   =>
   (printout t crlf "Root Cause: SSL Certificate Expired" crlf)
   (printout t "Recommendation: Renew SSL certificate." crlf)
   (assert (diagnosed TRUE))
)

(defrule process-not-running
   (declare (salience 170))
   (not (diagnosed))
   (service_process_not_running TRUE)
   =>
   (printout t crlf "Root Cause: Process Not Running" crlf)
   (printout t "Recommendation: Start the service process." crlf)
   (assert (diagnosed TRUE))
)

(defrule service-high-error-rate
   (declare (salience 165))
   (not (diagnosed))
   (high_error_rate ?r&:(>= ?r 50))
   =>
   (printout t crlf "Root Cause: High Service Error Rate" crlf)
   (printout t "Recommendation: Investigate recent error logs and dependent services." crlf)
   (assert (diagnosed TRUE))
)

; API priority rules
(defrule api-internal-errors
   (declare (salience 160))
   (not (diagnosed))
   (status_code_500_rate ?r&:(> ?r 5))
   =>
   (printout t crlf "Root Cause: Excessive 500 Errors" crlf)
   (printout t "Recommendation: Check application logs and exception traces." crlf)
   (assert (diagnosed TRUE))
)

(defrule api-high-latency
   (declare (salience 150))
   (not (diagnosed))
   (avg_response_time ?t&:(> ?t 2000))
   =>
   (printout t crlf "Root Cause: High API Latency" crlf)
   (printout t "Recommendation: Profile endpoints and check DB/CPU." crlf)
   (assert (diagnosed TRUE))
)

(defrule api-rate-limit
   (declare (salience 145))
   (not (diagnosed))
   (status_code_429_rate ?r&:(> ?r 1))
   =>
   (printout t crlf "Root Cause: Rate Limiting" crlf)
   (printout t "Recommendation: Review throttling and client usage." crlf)
   (assert (diagnosed TRUE))
)

(defrule api-large-payload
   (declare (salience 140))
   (not (diagnosed))
   (response_size ?s&:(> ?s 1))
   =>
   (printout t crlf "Root Cause: Large Response Payload" crlf)
   (printout t "Recommendation: Reduce fields or paginate results." crlf)
   (assert (diagnosed TRUE))
)

(defrule api-dependency-fail
   (declare (salience 135))
   (not (diagnosed))
   (api_dependency_fail TRUE)
   =>
   (printout t crlf "Root Cause: Dependent Service Failure" crlf)
   (printout t "Recommendation: Check upstream services and fallbacks." crlf)
   (assert (diagnosed TRUE))
)

; Database priority rules
(defrule db-unreachable
   (declare (salience 130))
   (not (diagnosed))
   (db_connection_fail TRUE)
   =>
   (printout t crlf "Root Cause: Database Unreachable" crlf)
   (printout t "Recommendation: Verify host, credentials and firewall." crlf)
   (assert (diagnosed TRUE))
)

(defrule db-slow-queries
   (declare (salience 125))
   (not (diagnosed))
   (db_query_timeout ?r&:(> ?r 5))
   =>
   (printout t crlf "Root Cause: Slow Database Queries" crlf)
   (printout t "Recommendation: Optimize queries and add indexes." crlf)
   (assert (diagnosed TRUE))
)

(defrule db-pool-exhausted
   (declare (salience 120))
   (not (diagnosed))
   (db_connection_pool_exhausted TRUE)
   =>
   (printout t crlf "Root Cause: Connection Pool Exhausted" crlf)
   (printout t "Recommendation: Increase pool size or fix leaks." crlf)
   (assert (diagnosed TRUE))
)

(defrule db-replica-lag
   (declare (salience 115))
   (not (diagnosed))
   (replica_lag ?r&:(> ?r 30))
   =>
   (printout t crlf "Root Cause: Replication Lag" crlf)
   (printout t "Recommendation: Check replication and network." crlf)
   (assert (diagnosed TRUE))
)

(defrule db-deadlock
   (declare (salience 110))
   (not (diagnosed))
   (deadlock_detected TRUE)
   =>
   (printout t crlf "Root Cause: Deadlock Detected" crlf)
   (printout t "Recommendation: Review transaction logic and locking." crlf)
   (assert (diagnosed TRUE))
)

(defrule db-disk-full
   (declare (salience 105))
   (not (diagnosed))
   (db_disk_full TRUE)
   =>
   (printout t crlf "Root Cause: Database Disk Full" crlf)
   (printout t "Recommendation: Free space or increase storage." crlf)
   (assert (diagnosed TRUE))
)

; Configuration rules
(defrule config-invalid
   (declare (salience 100))
   (not (diagnosed))
   (config_invalid TRUE)
   =>
   (printout t crlf "Root Cause: Invalid Configuration" crlf)
   (printout t "Recommendation: Fix configuration files and env vars." crlf)
   (assert (diagnosed TRUE))
)

(defrule env-mismatch
   (declare (salience 95))
   (not (diagnosed))
   (environment_mismatch TRUE)
   =>
   (printout t crlf "Root Cause: Environment Mismatch" crlf)
   (printout t "Recommendation: Align configurations across environments." crlf)
   (assert (diagnosed TRUE))
)

(defrule missing-secret
   (declare (salience 90))
   (not (diagnosed))
   (missing_secret TRUE)
   =>
   (printout t crlf "Root Cause: Missing or Incorrect Secrets" crlf)
   (printout t "Recommendation: Verify secret store and deployment configs." crlf)
   (assert (diagnosed TRUE))
)

(defrule bad-permissions
   (declare (salience 85))
   (not (diagnosed))
   (bad_permissions TRUE)
   =>
   (printout t crlf "Root Cause: Bad File/Directory Permissions" crlf)
   (printout t "Recommendation: Correct permissions for service accounts." crlf)
   (assert (diagnosed TRUE))
)

(defrule wrong-version
   (declare (salience 80))
   (not (diagnosed))
   (wrong_version TRUE)
   =>
   (printout t crlf "Root Cause: Incompatible Software Version" crlf)
   (printout t "Recommendation: Use supported versions or update compatibility." crlf)
   (assert (diagnosed TRUE))
)

; Infrastructure rules
(defrule infra-high-cpu
   (declare (salience 75))
   (not (diagnosed))
   (cpu_usage ?u&:(> ?u 90))
   =>
   (printout t crlf "Root Cause: High CPU Usage" crlf)
   (printout t "Recommendation: Scale or optimize processes." crlf)
   (assert (diagnosed TRUE))
)

(defrule infra-high-memory
   (declare (salience 70))
   (not (diagnosed))
   (memory_usage ?u&:(> ?u 90))
   =>
   (printout t crlf "Root Cause: High Memory Usage" crlf)
   (printout t "Recommendation: Restart services or add memory." crlf)
   (assert (diagnosed TRUE))
)

(defrule infra-low-disk
   (declare (salience 65))
   (not (diagnosed))
   (disk_free ?p&:(< ?p 10))
   =>
   (printout t crlf "Root Cause: Low Disk Space" crlf)
   (printout t "Recommendation: Clean files or add storage." crlf)
   (assert (diagnosed TRUE))
)

(defrule infra-disk-io
   (declare (salience 60))
   (not (diagnosed))
   (disk_io ?d&:(> ?d 1000))
   =>
   (printout t crlf "Root Cause: High Disk I/O" crlf)
   (printout t "Recommendation: Investigate heavy I/O jobs." crlf)
   (assert (diagnosed TRUE))
)

(defrule infra-network-sat
   (declare (salience 55))
   (not (diagnosed))
   (network_saturation ?n&:(> ?n 80))
   =>
   (printout t crlf "Root Cause: Network Saturation" crlf)
   (printout t "Recommendation: Check bandwidth and limits." crlf)
   (assert (diagnosed TRUE))
)

(defrule infra-oom
   (declare (salience 50))
   (not (diagnosed))
   (oom_kill TRUE)
   =>
   (printout t crlf "Root Cause: OOM (Out of Memory) Kills" crlf)
   (printout t "Recommendation: Reduce memory usage or increase RAM." crlf)
   (assert (diagnosed TRUE))
)

; Security rules
(defrule sec-brute-force
   (declare (salience 45))
   (not (diagnosed))
   (brute_force_detected TRUE)
   =>
   (printout t crlf "Root Cause: Brute Force Attack Suspected" crlf)
   (printout t "Recommendation: Block offending IPs and enable rate limiting." crlf)
   (assert (diagnosed TRUE))
)

(defrule sec-sql-injection
   (declare (salience 40))
   (not (diagnosed))
   (sql_injection_detected TRUE)
   =>
   (printout t crlf "Root Cause: SQL Injection Attempts Detected" crlf)
   (printout t "Recommendation: Sanitize inputs and review logs." crlf)
   (assert (diagnosed TRUE))
)

(defrule sec-open-ports
   (declare (salience 35))
   (not (diagnosed))
   (open_ports_detected TRUE)
   =>
   (printout t crlf "Root Cause: Unexpected Open Ports Detected" crlf)
   (printout t "Recommendation: Close unused ports and review exposure." crlf)
   (assert (diagnosed TRUE))
)

(defrule sec-outdated-deps
   (declare (salience 30))
   (not (diagnosed))
   (outdated_dependencies TRUE)
   =>
   (printout t crlf "Root Cause: Outdated or Vulnerable Dependencies" crlf)
   (printout t "Recommendation: Update dependencies and apply patches." crlf)
   (assert (diagnosed TRUE))
)

(defrule sec-suspicious-login
   (declare (salience 25))
   (not (diagnosed))
   (suspicious_login TRUE)
   =>
   (printout t crlf "Root Cause: Suspicious Login Activity" crlf)
   (printout t "Recommendation: Rotate credentials and audit logs." crlf)
   (assert (diagnosed TRUE))
)

(defrule sec-firewall-block
   (declare (salience 20))
   (not (diagnosed))
   (firewall_block TRUE)
   =>
   (printout t crlf "Root Cause: Firewall Blocking Traffic" crlf)
   (printout t "Recommendation: Review and relax rules if appropriate." crlf)
   (assert (diagnosed TRUE))
)

; Fallback rule - lowest priority, prints if nothing else matched
(defrule general-unknown-issue
   (declare (salience 0))
   (not (diagnosed))
   =>
   (printout t crlf "Root Cause: No single dominant issue detected." crlf)
   (printout t "Recommendation: Collect more logs and metrics; run deeper diagnostics." crlf)
   (assert (diagnosed TRUE))
)
