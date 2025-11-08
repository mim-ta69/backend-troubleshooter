;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; IT INFRASTRUCTURE EXPERT SYSTEM
;; Version: Fact-based (no user prompts)
;; Usage:
;;   (load "diagnostic_system.clp")
;;   (reset)
;;   (assert (ping fail) (service_process_not_running TRUE))
;;   (run)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(clear)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; TEMPLATE DEFINITIONS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(deftemplate system-state
   (slot component)
   (slot metric)
   (slot value))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; CATEGORY 1: SERVICE AVAILABILITY
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defrule service-down
   (ping fail)
   =>
   (printout t "Root Cause: Service Down" crlf)
   (printout t "Recommendation: Check the server connection or restart service or check server." crlf))

(defrule process-not-running
   (service_process_not_running TRUE)
   =>
   (printout t "Root Cause: Process Not Running" crlf)
   (printout t "Recommendation: Start process." crlf))

(defrule port-closed
   (port_closed TRUE)
   =>
   (printout t "Root Cause: Port Closed" crlf)
   (printout t "Recommendation: Open port in firewall." crlf))

(defrule recent-crash
   (uptime ?u&:(< ?u 5))
   =>
   (printout t "Root Cause: Recent Crash" crlf)
   (printout t "Recommendation: Check logs for crash reason." crlf))

(defrule ssl-expired
   (ssl_cert_expired TRUE)
   =>
   (printout t "Root Cause: SSL Certificate Expired" crlf)
   (printout t "Recommendation: Renew SSL certificate." crlf))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; CATEGORY 2: API PERFORMANCE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defrule high-latency
   (avg_response_time ?t&:(> ?t 2000))
   =>
   (printout t "Root Cause: High Latency" crlf)
   (printout t "Recommendation: Check DB queries and CPU load." crlf))

(defrule internal-error
   (status_code_500_rate ?r&:(> ?r 5))
   =>
   (printout t "Root Cause: Internal Server Error" crlf)
   (printout t "Recommendation: Check logs for exceptions." crlf))

(defrule rate-limit
   (status_code_429_rate ?r&:(> ?r 1))
   =>
   (printout t "Root Cause: Rate Limit Exceeded" crlf)
   (printout t "Recommendation: Review API throttling configuration." crlf))

(defrule large-payload
   (response_size ?s&:(> ?s 1))
   =>
   (printout t "Root Cause: Large Payload" crlf)
   (printout t "Recommendation: Optimize API response payload." crlf))

(defrule timeouts
   (timeout_error_rate ?r&:(> ?r 2))
   =>
   (printout t "Root Cause: Timeout Errors" crlf)
   (printout t "Recommendation: Check network latency and DB." crlf))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; CATEGORY 3: DATABASE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defrule db-unreachable
   (db_connection_fail TRUE)
   =>
   (printout t "Root Cause: Database Unreachable" crlf)
   (printout t "Recommendation: Check host, credentials, or firewall." crlf))

(defrule slow-queries
   (db_query_timeout ?r&:(> ?r 5))
   =>
   (printout t "Root Cause: Slow Queries" crlf)
   (printout t "Recommendation: Optimize queries and add indexes." crlf))

(defrule replication-lag
   (replica_lag ?r&:(> ?r 30))
   =>
   (printout t "Root Cause: Replication Lag" crlf)
   (printout t "Recommendation: Check replication configuration." crlf))

(defrule deadlock
   (deadlock_detected TRUE)
   =>
   (printout t "Root Cause: Deadlock Detected" crlf)
   (printout t "Recommendation: Optimize transaction flow." crlf))

(defrule db-disk-full
   (db_disk_full TRUE)
   =>
   (printout t "Root Cause: Database Disk Full" crlf)
   (printout t "Recommendation: Free up disk space or extend storage." crlf))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; CATEGORY 4: CONFIGURATION & ENVIRONMENT
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defrule config-invalid
   (config_invalid TRUE)
   =>
   (printout t "Root Cause: Invalid Configuration" crlf)
   (printout t "Recommendation: Review environment variables or YAML/JSON files." crlf))

(defrule env-mismatch
   (environment_mismatch TRUE)
   =>
   (printout t "Root Cause: Environment Mismatch" crlf)
   (printout t "Recommendation: Align configuration between environments." crlf))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; CATEGORY 5: INFRASTRUCTURE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defrule high-cpu
   (cpu_usage ?u&:(> ?u 90))
   =>
   (printout t "Root Cause: High CPU Usage" crlf)
   (printout t "Recommendation: Optimize or scale the system." crlf))

(defrule high-memory
   (memory_usage ?u&:(> ?u 90))
   =>
   (printout t "Root Cause: High Memory Usage" crlf)
   (printout t "Recommendation: Restart services or add memory." crlf))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; CATEGORY 6: SECURITY & NETWORK
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defrule firewall-block
   (firewall_block TRUE)
   =>
   (printout t "Root Cause: Firewall Blocking Traffic" crlf)
   (printout t "Recommendation: Update firewall or allowlist rules." crlf))

(defrule suspicious-login
   (suspicious_login TRUE)
   =>
   (printout t "Root Cause: Suspicious Login Activity" crlf)
   (printout t "Recommendation: Reset credentials and review logs." crlf))
