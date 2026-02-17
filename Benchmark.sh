#!/bin/bash 

# enumeration.sh v 1.0 built by pk feb 16,2026  

# Enterprise-grade evidence drift detection & performance measurement script 

# 

# ROLE: Evidence-only system enumeration. 

# This script records observable system state in phases. 

# Later phases may induce load, but no interpretation or judgment is performed. 

# Consumers must treat output as raw evidence only. 

# 

# INTENT: This script enumerates observable system state across multiple phases. 

# All outputs are raw measurements and listings. No inference is made. 

# Any interpretation is the responsibility of an external consumer. 

# 

# DESIGN PHILOSOPHY: 

# 1. Evidence-Only: Captures raw data without making inferences or labels. 

# 2. Maximum Signal: Probes every observable OS surface (/proc, /sys, MSR, DMI). 

# 3. evidence Integrity: Log timestamps and RCs to ensure chain of custody. 

# 4. Non-Destructive: All benchmarks and tests are read-heavy or limited file-io. 

# 

# ENUMERATION LOG LOCATION: 

# Reports are generated in the directory where the script is executed. 

# Filename: ENUMERATION__<host>__<UTC_timestamp>.txt 

 

set -euo pipefail 

 

# ERROR TRACKING 

# This counter monitors the 'Measurement' of the execution—tracking non-zero exit  

# codes from system tools to ensure the enumeration trail is transparent about missing data. 

TOTAL_ERRORS=0 

 

# INITIALIZATION & PRIVILEGE CHECK 

# Root is required to access hardware registers (MSRs), DMI tables, and restricted /proc paths. 

if [[ "${EUID:-$(id -u)}" -ne 0 ]]; then 

  echo "ERROR: enumeration.sh requires root privileges (sudo) for evidence-grade enumeration." >&2 

  exit 1 

fi 

 

# ENVIRONMENT SETTINGS 

# Defaulting to local directory to ensure reports are immediately accessible. 

OUTDIR="${OUTDIR:-$(pwd)}" 

mkdir -p "$OUTDIR" 

 

NET_PING_TARGET="${NET_PING_TARGET:-1.1.1.1}" 

IPERF_SERVER="${IPERF_SERVER:-}" 

IPERF_PORT="${IPERF_PORT:-5201}" 

IPERF_TIME="${IPERF_TIME:-20}" 

 

STRESS_LEVEL="${STRESS_LEVEL:-safe}" 

CPU_STRESS_SEC="${CPU_STRESS_SEC:-300}" 

MEM_STRESS_SEC="${MEM_STRESS_SEC:-300}" 

IO_STRESS_SEC="${IO_STRESS_SEC:-180}" 

 

FIO_DIR="${FIO_DIR:-/var/tmp}" 

FIO_SIZE="${FIO_SIZE:-6G}" 

FIO_JOBS="${FIO_JOBS:-4}" 

 

NMAP_LOCAL="${NMAP_LOCAL:-1}" 

NMAP_SELFIP="${NMAP_SELFIP:-0}" 

 

# evidence NAMING CONVENTION 

ts_utc="$(date -u +%Y-%m-%dT%H:%M:%SZ)" 

host="$(hostname -f 2>/dev/null || hostname)" 

REPORT="$OUTDIR/ENUMERATION__${host}__${ts_utc}.txt" 

 

# TELEMETRY REDIRECTION 

# Mirroring output to terminal and the evidence log file simultaneously. 

exec > >(tee "$REPORT") 2>&1 

 

# FORMATTING HELPERS 

SECTION() { 

  echo 

  echo "====================================================================" 

  echo "[$1]" 

  echo "====================================================================" 

} 

 

# EXECUTION WRAPPERS 

# Every system call is wrapped to prevent script termination on failure,  

# instead logging the Failure correlation (Exit Code) for the auditor to interpret. 

RUN() { 

  local name="$1"; shift 

  echo "---- $name ----" 

  echo "CMD: $*" 

  set +e 

  "$@" 

  local rc=$? 

  set -e 

  [[ $rc -ne 0 ]] && TOTAL_ERRORS=$((TOTAL_ERRORS + 1)) 

  echo "RC: $rc" 

  echo 

} 

 

RUN_SH() { 

  local name="$1"; shift 

  echo "---- $name ----" 

  echo "CMD: bash -lc $*" 

  set +e 

  bash -lc "$*" 

  local rc=$? 

  set -e 

  [[ $rc -ne 0 ]] && TOTAL_ERRORS=$((TOTAL_ERRORS + 1)) 

  echo "RC: $rc" 

  echo 

} 

 

DUMP_FILE() { 

  local title="$1" 

  local path="$2" 

  SECTION "$title" 

  echo "PATH: $path" 

  if [[ -r "$path" ]]; then 

    cat "$path" 

    echo 

  else 

    echo "UNREADABLE/MISSING" 

    TOTAL_ERRORS=$((TOTAL_ERRORS + 1)) 

    echo 

  fi 

} 

 

PRIMARY_IF() { ip route 2>/dev/null | awk '/default/ {print $5; exit}'; } 

PRIMARY_IP() { 

  local ifc; ifc="$(PRIMARY_IF 2>/dev/null || true)" 

  [[ -n "${ifc:-}" ]] && ip -4 addr show dev "$ifc" 2>/dev/null | awk '/inet /{print $2}' | cut -d/ -f1 | head -n1 || true 

} 

 

echo "PRODUCTION RELEASE: enumeration.sh PERFORMANCE MEASUREMENT SCRIPT" 

echo "UTC:     $ts_utc" 

echo "HOST:    $host" 

echo "REPORT:  $REPORT" 

echo "MACHINE_STATE_FILE: /var/lib/system-lock/LOCKED" 

echo "STATUS:  Enumeration logs are being written to $OUTDIR" 

echo "====================================================================" 

 

### PHASE 0 — PASSIVE ENUMERATION (NO LOAD) 

 

######################################## 

# 0. TOOLING INSTALL 

######################################## 

SECTION "0. TOOLING INSTALL" 

export DEBIAN_FRONTEND=noninteractive 

RUN "apt-get update" apt-get update -qq 

RUN "apt-get install" apt-get install -y -qq coreutils util-linux procps psmisc pciutils usbutils dmidecode lshw hwinfo iproute2 iputils-ping net-tools ethtool nmap nftables iptables sysstat stress-ng sysbench fio jq lmbench smartmontools nvme-cli hdparm curl ca-certificates gnupg linux-cpupower linux-tools-common lm-sensors lsof mesa-utils vulkan-tools clinfo numactl apparmor-utils strace bc binutils kmod netstat-nat msr-tools cpuid bpftool iucode-tool fping hping3 dnsutils zfsutils-linux xfsprogs e2fsprogs lvm2 acct auditd || true 

RUN "sensors-detect" sensors-detect --auto >/dev/null 2>&1 || true 

 

######################################## 

# 1. IDENTITY / OS / KERNEL / TIME 

######################################## 

SECTION "1. IDENTITY / OS / KERNEL / TIME" 

RUN "date -u" date -u 

RUN "hostnamectl" hostnamectl 

RUN_SH "os-release" 'cat /etc/os-release 2>/dev/null || true' 

RUN "uname -a" uname -a 

RUN_SH "cmdline" 'cat /proc/cmdline 2>/dev/null || true' 

RUN_SH "boot_id" 'cat /proc/sys/kernel/random/boot_id 2>/dev/null || true' 

DUMP_FILE "CLOCKSOURCE current" "/sys/devices/system/clocksource/clocksource0/current_clocksource" 

 

######################################## 

# 1A. MACHINE STATE (AUTHORITATIVE) 

######################################## 

SECTION "1A. MACHINE STATE (AUTHORITATIVE)" 

 

STATE_FILE="/var/lib/system-lock/LOCKED" 

 

if [[ -f "$STATE_FILE" ]]; then 

  echo "SYSTEM_STATE: LOCKED" 

  echo "STATE_FILE: $STATE_FILE" 

  ls -l "$STATE_FILE" 2>/dev/null || true 

  lsattr "$STATE_FILE" 2>/dev/null || true 

  cat "$STATE_FILE" 2>/dev/null || true 

else 

  echo "SYSTEM_STATE: UNLOCKED" 

  echo "STATE_FILE: ABSENT" 

fi 

 

RUN_SH "auditd status" 'auditctl -s 2>/dev/null || true' 

RUN_SH "audit rules snapshot" 'auditctl -l 2>/dev/null || true' 

RUN_SH "recent auth logs (lock correlation)" ' 

journalctl -n 200 -t audit -t sudo -t sshd --no-pager 2>/dev/null || true 

' 

 

######################################## 

# 2. CPU / SCHEDULER / MITIGATION STATE 

######################################## 

SECTION "2. CPU / SCHEDULER / MITIGATION STATE" 

RUN "lscpu" lscpu 

RUN_SH "cpupower frequency-info" 'cpupower frequency-info 2>/dev/null || true' 

RUN_SH "mpstat (10s)" 'mpstat -P ALL 1 10 2>/dev/null || true' 

DUMP_FILE "SCHEDSTAT" "/proc/schedstat" 

RUN_SH "numactl --hardware" 'numactl --hardware 2>/dev/null || true' 

 

######################################## 

# 3. CPU VULNERABILITY FILES 

######################################## 

SECTION "3. CPU VULNERABILITY FILES" 

RUN_SH "cat vulnerabilities/*" 'if [[ -d /sys/devices/system/cpu/vulnerabilities ]]; then for v in /sys/devices/system/cpu/vulnerabilities/*; do echo "--- $(basename "$v") ---"; cat "$v" 2>/dev/null || true; done; fi' 

 

######################################## 

# 4. POWER / THERMAL / SENSORS 

######################################## 

SECTION "4. POWER / THERMAL / SENSORS" 

RUN_SH "turbostat" 'command -v turbostat >/dev/null && turbostat --quiet --Summary --interval 1 --num_iterations 5 2>/dev/null || true' 

RUN_SH "thermal zones" 'for z in /sys/class/thermal/thermal_zone*; do echo "== $z =="; cat "$z/type" "$z/temp" 2>/dev/null || true; done' 

RUN_SH "dmesg throttle" 'dmesg | grep -i throttle || true' 

 

######################################## 

# 5. MEMORY / NUMA / THP / PRESSURE 

######################################## 

SECTION "5. MEMORY / NUMA / THP / PRESSURE" 

RUN "free -h" free -h 

RUN_SH "numactl --show" 'numactl --show 2>/dev/null || true' 

DUMP_FILE "THP enabled" "/sys/kernel/mm/transparent_hugepage/enabled" 

RUN_SH "vmstat sample 10s" 'vmstat 1 10 2>/dev/null || true' 

 

######################################## 

# 6. PSI FILES (PRESSURE STALL INFO) 

######################################## 

SECTION "6. PSI FILES" 

DUMP_FILE "PSI cpu" "/proc/pressure/cpu" 

DUMP_FILE "PSI memory" "/proc/pressure/memory" 

DUMP_FILE "PSI io" "/proc/pressure/io" 

 

######################################## 

# 7. PCI / USB INVENTORY 

######################################## 

SECTION "7. PCI / USB INVENTORY" 

RUN "lspci -tv" lspci -tv 

RUN "lspci -nnvv" lspci -nnvv 

RUN "lsusb -t" 'lsusb -t 2>/dev/null || true' 

 

######################################## 

# 8. HARDWARE INVENTORY TOOLS 

######################################## 

SECTION "8. HARDWARE INVENTORY TOOLS" 

RUN_SH "lshw -short" 'lshw -short 2>/dev/null || true' 

RUN_SH "hwinfo --all" 'hwinfo --all 2>/dev/null || true' 

 

######################################## 

# 9. DMI / BIOS / SYSFS SERIAL CORRELATION 

######################################## 

SECTION "9. DMI / BIOS / SYSFS SERIAL CORRELATION" 

RUN_SH "sysfs dmi id" 'for f in /sys/class/dmi/id/*; do [[ -f "$f" ]] && echo "$(basename "$f"): $(cat "$f" 2>/dev/null)"; done' 

RUN_SH "dmidecode serials" 'dmidecode -t system -t baseboard -t bios 2>/dev/null | grep -Ei "Serial|UUID|Manufacturer" || true' 

 

######################################## 

# 10. BLOCK DEVICES / FILESYSTEMS 

######################################## 

SECTION "10. BLOCK DEVICES / FILESYSTEMS / QUEUES / UDEV" 

RUN_SH "lsblk -a -O" 'lsblk -a -O 2>/dev/null || true' 

RUN_SH "mount" 'mount 2>/dev/null || true' 

RUN_SH "df -hT" 'df -hT 2>/dev/null || true' 

RUN_SH "LVM summary" 'pvs 2>/dev/null || true; vgs 2>/dev/null || true; lvs -a 2>/dev/null || true' 

 

######################################## 

# 11. BLOCK QUEUE PARAMETERS 

######################################## 

SECTION "11. BLOCK QUEUE PARAMETERS" 

RUN_SH "block scheduler" 'for b in /sys/block/*; do echo "==== $(basename "$b") ===="; for f in scheduler nr_requests max_sectors_kb; do [[ -e "$b/queue/$f" ]] && echo "$f: $(cat "$b/queue/$f")"; done; done' 

 

######################################## 

# 12. UDEV PER DISK 

######################################## 

SECTION "12. UDEV PER DISK" 

RUN_SH "udevadm info" 'for d in /dev/sd? /dev/nvme?n?; do [[ -e "$d" ]] || continue; echo "==== $d ===="; udevadm info --query=all --name="$d" 2>/dev/null || true; done' 

 

######################################## 

# 13. DISK HEALTH (BEST-EFFORT) 

######################################## 

SECTION "13. DISK HEALTH (BEST-EFFORT)" 

RUN_SH "Health Logs" 'for d in /dev/sd? /dev/nvme?n?; do [[ -e "$d" ]] || continue; echo "==== $d ===="; if [[ "$d" == /dev/nvme* ]]; then nvme smart-log "$d" 2>/dev/null || true; else smartctl -a "$d" 2>/dev/null || true; fi; done' 

 

######################################## 

# 14. DEVICE ↔ SERIAL ↔ PATH correlation MAP 

######################################## 

SECTION "14. DEVICE ↔ SERIAL ↔ PATH correlation MAP" 

RUN_SH "CPU correlation" 'for c in /sys/devices/system/cpu/cpu*; do [[ -d "$c" ]] || continue; echo "CPU: $(basename "$c")"; grep . "$c"/topology/* 2>/dev/null || true; done' 

RUN_SH "NIC correlation" 'for i in /sys/class/net/*; do [[ -e "$i/address" ]] || continue; echo "IFACE: $(basename "$i") MAC: $(cat "$i/address")"; ethtool -i "$(basename "$i")" 2>/dev/null || true; done' 

RUN_SH "DISK correlation" 'for d in /sys/class/block/*; do [[ -e "$d/device" ]] || continue; echo "DISK: $(basename "$d")"; udevadm info --query=property --path="$(readlink -f "$d")" 2>/dev/null | grep -E "ID_SERIAL|ID_WWN|ID_MODEL|ID_PATH"; done' 

 

######################################## 

# 15. NETWORK / PORTS / FIREWALL 

######################################## 

SECTION "15. NETWORK / PORTS / FIREWALL / STACK" 

RUN_SH "ip addr" 'ip -details addr show 2>/dev/null || true' 

RUN_SH "ip neighbor" 'ip neighbor show 2>/dev/null || true' 

RUN_SH "tc qdisc" 'tc qdisc show 2>/dev/null || true' 

RUN_SH "Initial Interface Error Counters" 'for i in $(ls /sys/class/net); do echo "=== $i ==="; ethtool -S "$i" 2>/dev/null || true; ip -s link show "$i" 2>/dev/null || true; done' 

 

######################################## 

# 16. SOCKETS / LISTENERS 

######################################## 

SECTION "16. SOCKETS / LISTENERS" 

RUN_SH "ss -tulpn" 'ss -tulpn 2>/dev/null || true' 

RUN_SH "ss -m" 'ss -m 2>/dev/null || true' 

 

######################################## 

# 17. PORT ↔ PROCESS ↔ BINARY ↔ HASH correlation 

######################################## 

SECTION "17. PORT ↔ PROCESS ↔ BINARY ↔ HASH correlation" 

RUN_SH "socket correlation" 'ss -tunap 2>/dev/null | awk "NR>1 {print \$0}" | while read -r line; do pid=$(echo "$line" | grep -o "pid=[0-9]*" | cut -d= -f2); [[ -z "$pid" ]] && continue; exe=$(readlink -f /proc/$pid/exe 2>/dev/null || true); echo "$line EXE: $exe"; [[ -f "$exe" ]] && sha256sum "$exe" 2>/dev/null || true; done' 

 

######################################## 

# 18. FIREWALL (READ-ONLY) 

######################################## 

SECTION "18. FIREWALL (READ-ONLY)" 

RUN_SH "nft ruleset" 'nft list ruleset 2>/dev/null || true' 

RUN_SH "iptables summary" 'iptables -L -n -v 2>/dev/null || true' 

 

######################################## 

# 19. INTERRUPTS / SOFTIRQS 

######################################## 

SECTION "19. INTERRUPTS / SOFTIRQS" 

DUMP_FILE "interrupts" "/proc/interrupts" 

RUN_SH "tcp sysctl" 'sysctl -a 2>/dev/null | grep -E "^net.ipv4.tcp_|^net.core.(rmem|wmem)" || true' 

 

######################################## 

# 20. KERNEL / SECURITY SURFACE 

######################################## 

SECTION "20. KERNEL / SECURITY SURFACE" 

RUN_SH "lsmod" 'lsmod 2>/dev/null || true' 

RUN_SH "caps/self" 'grep -E "^Cap(Prm|Eff|Bnd|Amb)|^NoNewPrivs" /proc/self/status' 

DUMP_FILE "entropy" "/proc/sys/kernel/random/entropy_avail" 

 

######################################## 

# 21. GPU EVIDENCE 

######################################## 

SECTION "21. GPU EVIDENCE" 

RUN_SH "PCI display" 'lspci -nn | grep -Ei "vga|3d|display" || true' 

RUN_SH "vulkan/clinfo" 'vulkaninfo --summary 2>/dev/null || true; clinfo 2>/dev/null || true' 

 

### PHASE 1 — ACTIVE ENUMERATION (CONTROLLED LOAD, MEASUREMENT ONLY) 

 

######################################## 

# 22. BENCHMARKS + STRESS (TELEMETRY SAMPLING) 

######################################## 

SECTION "22. BENCHMARKS + STRESS (TELEMETRY SAMPLING)" 

FIOFILE="$FIO_DIR/blind_fio_testfile__${host}__${ts_utc}" 

 

sampler() { 

  local secs="$1" 

  local end=$(( $(date +%s) + secs )) 

  while [[ "$(date +%s)" -lt "$end" ]]; do 

    echo "----- SAMPLE UTC $(date -u +%Y-%m-%dT%H:%M:%SZ) -----" 

    mpstat 1 1 2>/dev/null || true 

    cat /proc/pressure/cpu 2>/dev/null || true 

    echo; sleep 5 

  done 

} 

 

######################################## 

# 23. CPU STRESS 

######################################## 

SECTION "23. CPU STRESS" 

sampler "$CPU_STRESS_SEC" & 

samp_pid=$! 

RUN_SH "stress-ng" "stress-ng --cpu \"\$(nproc)\" --timeout ${CPU_STRESS_SEC}s --metrics-brief" 

kill "$samp_pid" 2>/dev/null || wait "$samp_pid" 2>/dev/null || true 

 

######################################## 

# 24. MEMORY BENCHMARKS 

######################################## 

SECTION "24. MEMORY BENCHMARKS" 

RUN_SH "sysbench memory" 'sysbench memory --memory-block-size=1M --memory-total-size=40G run' 

 

######################################## 

# 25. STORAGE BENCHMARK (RANDRW) 

######################################## 

SECTION "25. STORAGE BENCHMARK (RANDRW)" 

RUN_SH "fio randrw" "fio --name=randrw --filename='${FIOFILE}' --rw=randrw --ioengine=libaio --direct=1 --bs=4k --size='${FIO_SIZE}' --numjobs='${FIO_JOBS}' --runtime='${IO_STRESS_SEC}' --time_based --group_reporting --output-format=json --output='${OUTDIR}/fio_randrw.json'" 

RUN_SH "fio summary" "jq -r '.jobs[0] | \"Read IOPS: \(.read.iops) Write IOPS: \(.write.iops)\"' '${OUTDIR}/fio_randrw.json' 2>/dev/null || true" 

 

######################################## 

# 26. STORAGE BENCHMARK (FIO SEQ) 

######################################## 

SECTION "26. STORAGE BENCHMARK (SEQ)" 

RUN_SH "fio seq" "fio --name=seq --filename='${FIOFILE}' --rw=readwrite --ioengine=libaio --direct=1 --bs=1m --size='${FIO_SIZE}' --numjobs=1 --runtime='${IO_STRESS_SEC}' --time_based --group_reporting --output-format=json --output='${OUTDIR}/fio_seq.json'" 

rm -f '${FIOFILE}' 

 

######################################## 

# 27. NETWORK THROUGHPUT (IPERF3) 

######################################## 

SECTION "27. NETWORK THROUGHPUT (iperf3 if configured)" 

if [[ -n "$IPERF_SERVER" ]]; then 

  RUN_SH "iperf3 uplink" "iperf3 -c '$IPERF_SERVER' -p '$IPERF_PORT' -t '$IPERF_TIME'" 

  RUN_SH "iperf3 reverse" "iperf3 -c '$IPERF_SERVER' -p '$IPERF_PORT' -t '$IPERF_TIME' -R" 

  RUN_SH "iperf3 UDP" "iperf3 -u -b 100M -c '$IPERF_SERVER' -p '$IPERF_PORT' -t '$IPERF_TIME'" 

fi 

 

######################################## 

# 28. MIXED STRESS 

######################################## 

SECTION "28. MIXED STRESS" 

RUN_SH "stress-ng mixed" "stress-ng --cpu \"\$(nproc)\" --vm 2 --vm-bytes 60% --timeout ${MEM_STRESS_SEC}s --metrics-brief" 

 

######################################## 

# 29. GEEKBENCH 6 

######################################## 

SECTION "29. GEEKBENCH 6" 

echo "NOTE: User responsible for license compliance. Free version used (may upload results)." 

URL="https://cdn.geekbench.com/Geekbench-6.2.1-Linux.tar.gz" 

RUN_SH "Geekbench" "curl -fsSL '$URL' -o /tmp/gb6.tgz && tar -xf /tmp/gb6.tgz -C /tmp && /tmp/Geekbench-6.2.1-Linux/geekbench6" 

 

######################################## 

# 30. SERVICES / PACKAGES / LOGS 

######################################## 

SECTION "30. SERVICES / PACKAGES / LOGS" 

RUN_SH "running services" 'systemctl list-units --type=service --state=running --no-pager' 

RUN_SH "dmesg tail" 'dmesg | tail -n 300' 

 

######################################## 

# 31. TELEMETRY / AGENT SURFACE 

######################################## 

SECTION "31. TELEMETRY / AGENT SURFACE" 

RUN_SH "agents" 'ps aux | grep -Ei "prometheus|otel|datadog|agent" | grep -v grep || true' 

RUN_SH "exporters" 'ss -tulpn 2>/dev/null | grep -Ei "9100|4317|9090" || true' 

 

######################################## 

# 32. PROCESSES / THREADS / IPC 

######################################## 

SECTION "32. PROCESSES / THREADS / IPC" 

RUN_SH "ps auxwf" 'ps auxwf 2>/dev/null' 

RUN_SH "ipcs summary" 'ipcs -a 2>/dev/null' 

 

######################################## 

# 33. CRON / TIMERS 

######################################## 

SECTION "33. CRON / TIMERS / SCHEDULED EXECUTION" 

RUN_SH "crontab -l all" 'cut -d: -f1 /etc/passwd | while read -r u; do echo "USER: $u"; crontab -l -u "$u" 2>/dev/null || echo "NONE"; done' 

RUN_SH "systemd timers" 'systemctl list-timers --all --no-pager' 

 

######################################## 

# 34. /proc DEEP KERNEL STATE 

######################################## 

SECTION "34. /proc DEEP KERNEL STATE" 

DUMP_FILE "locks" "/proc/locks" 

DUMP_FILE "vmallocinfo" "/proc/vmallocinfo" 

 

######################################## 

# 35. /sys SELECTIVE TREE SNAPSHOTS 

######################################## 

SECTION "35. /sys SELECTIVE TREE SNAPSHOTS" 

RUN_SH "cpu tree" 'find /sys/devices/system/cpu -maxdepth 3 -type f -readable -exec sh -c "echo PATH: {}; cat {}" \; 2>/dev/null' 

 

######################################## 

# 36. HARDWARE PERFORMANCE COUNTERS 

######################################## 

SECTION "36. HARDWARE PERFORMANCE COUNTERS (perf)" 

RUN_SH "perf stat" 'perf stat -a sleep 5 2>&1 || true' 

 

######################################## 

# 37. SCHEDULER LATENCY 

######################################## 

SECTION "37. SCHEDULER LATENCY" 

DUMP_FILE "sched_debug" "/proc/sched_debug" 

 

######################################## 

# 38. IRQ / INTERRUPT AFFINITY MAPS 

######################################## 

SECTION "38. IRQ / INTERRUPT AFFINITY MAPS" 

RUN_SH "irq affinity" 'for d in /proc/irq/*; do [[ -d "$d" ]] && echo "DIR: $d smp_affinity: $(cat "$d/smp_affinity" 2>/dev/null)"; done' 

 

######################################## 

# 39. NETWORK INTERNAL TABLES 

######################################## 

SECTION "39. NETWORK INTERNAL TABLES" 

DUMP_FILE "tcp" "/proc/net/tcp" 

DUMP_FILE "nf_conntrack" "/proc/net/nf_conntrack" 

 

######################################## 

# 40. CGROUP CONTROLLER INTERNALS 

######################################## 

SECTION "40. CGROUP CONTROLLER INTERNALS" 

RUN_SH "cgroup controllers" 'cat /sys/fs/cgroup/cgroup.controllers 2>/dev/null || true' 

 

######################################## 

# 41. PER-PROCESS IO + SMAPS 

######################################## 

SECTION "41. PER-PROCESS IO + SMAPS" 

RUN_SH "top rss" 'ps -e -o pid=,rss=,comm= --sort=-rss | head -n 10' 

 

######################################## 

# 42. CLOCK / TIME STABILITY 

######################################## 

SECTION "42. CLOCK / TIME STABILITY" 

RUN_SH "clock current" 'cat /sys/devices/system/clocksource/clocksource0/current_clocksource' 

 

######################################## 

# 43. ENERGY / POWER COUNTERS 

######################################## 

SECTION "43. ENERGY / POWER COUNTERS" 

RUN_SH "rapl" 'find /sys/class/powercap/intel-rapl* -name "energy_uj" -exec grep . {} +' 

 

######################################## 

# 44. FILESYSTEM MICROTESTS 

######################################## 

SECTION "44. FILESYSTEM MICROTESTS" 

RUN_SH "fsync latency" 'dd if=/dev/zero of=/tmp/fsync_test bs=4M count=16 conv=fsync oflag=direct 2>&1 && rm /tmp/fsync_test' 

 

######################################## 

# 45. BENCHMARK VARIANCE 

######################################## 

SECTION "45. BENCHMARK VARIANCE" 

RUN_SH "repeat stress" 'for i in 1 2 3; do echo "RUN $i"; stress-ng --cpu 1 --timeout 10s --metrics-brief; done' 

 

######################################## 

# 46. FULL BOOT + KERNEL LOGS 

######################################## 

SECTION "46. FULL BOOT + KERNEL LOGS" 

RUN_SH "journalctl full" 'journalctl -b --no-pager 2>/dev/null || true' 

 

######################################## 

# 47. SYSCALL PROFILE (STRACE -C) 

######################################## 

SECTION "47. SYSCALL PROFILE (strace -c)" 

RUN_SH "strace stress" 'strace -c -f stress-ng --cpu 1 --timeout 10s 2>/dev/null || true' 

 

######################################## 

# 48. ELF / ABI / LOADER 

######################################## 

SECTION "48. ELF / ABI / LOADER" 

RUN_SH "ldd version" 'ldd --version' 

 

######################################## 

# 49. CPU MICROCODE / FIRMWARE INTERACTION 

######################################## 

SECTION "49. CPU MICROCODE / FIRMWARE INTERACTION" 

RUN_SH "ucode" 'grep . /sys/devices/system/cpu/cpu*/microcode/version' 

 

######################################## 

# 50. RAW CPUID LEAF DUMPS 

######################################## 

SECTION "50. RAW CPUID LEAF DUMPS" 

RUN_SH "cpuid -1" 'cpuid -1 2>/dev/null || true' 

 

######################################## 

# 51. MSR SNAPSHOTS 

######################################## 

SECTION "51. MSR SNAPSHOTS" 

RUN_SH "rdmsr" 'rdmsr 0x1a0 2>/dev/null || echo "MSR BLOCKED"' 

 

######################################## 

# 52. KERNEL CONFIG EVIDENCE 

######################################## 

SECTION "52. KERNEL CONFIG EVIDENCE" 

RUN_SH "config" 'ls -la /boot/config-$(uname -r)' 

 

######################################## 

# 53. SCHEDULER CLASS & POLICY 

######################################## 

SECTION "53. SCHEDULER CLASS & POLICY INVENTORY" 

RUN_SH "chrt policies" 'ps -e -o pid= | head -n 10 | xargs -I {} chrt -p {} 2>/dev/null' 

 

######################################## 

# 54. RCU STATE & STALL OBSERVABILITY 

######################################## 

SECTION "54. RCU STATE & STALL OBSERVABILITY" 

RUN_SH "rcu" 'find /sys/kernel/debug/rcu -type f -exec grep . {} + 2>/dev/null' 

 

######################################## 

# 55. MEMORY CONTROLLER & PAGE FAULT 

######################################## 

SECTION "55. MEMORY CONTROLLER & PAGE FAULT DETAIL" 

DUMP_FILE "vmstat" "/proc/vmstat" 

 

######################################## 

# 56. FILESYSTEM INTERNAL STATE 

######################################## 

SECTION "56. FILESYSTEM INTERNAL STATE" 

RUN_SH "ext4" 'find /sys/fs/ext4 -type f -exec grep . {} + 2>/dev/null' 

 

######################################## 

# 57. VFS / DENTRY / INODE PRESSURE 

######################################## 

SECTION "57. VFS / DENTRY / INODE PRESSURE" 

DUMP_FILE "dentry" "/proc/sys/fs/dentry-state" 

 

######################################## 

# 58. NETWORK QUEUE DISCIPLINE 

######################################## 

SECTION "58. NETWORK QUEUE DISCIPLINE INTERNALS" 

RUN_SH "tc -s" 'tc -s qdisc show' 

 

######################################## 

# 59. TCP CONGESTION INTERNAL VARIABLES 

######################################## 

SECTION "59. TCP CONGESTION INTERNAL VARIABLES" 

RUN_SH "ss -ti" 'ss -ti state established' 

 

######################################## 

# 60. BPF / eBPF CAPABILITY SURFACE 

######################################## 

SECTION "60. BPF / eBPF CAPABILITY SURFACE" 

RUN_SH "bpftool" 'bpftool feature probe' 

 

######################################## 

# 61. KERNEL LOCK CONTENTION 

######################################## 

SECTION "61. KERNEL LOCK CONTENTION" 

DUMP_FILE "lock_stat" "/proc/lock_stat" 

 

######################################## 

# 62. STORAGE CACHE & WRITEBACK STATE 

######################################## 

SECTION "62. STORAGE CACHE & WRITEBACK STATE" 

RUN_SH "vm.dirty" 'sysctl -a | grep vm.dirty' 

 

######################################## 

# 63. INTERRUPT RATE UNDER LOAD 

######################################## 

SECTION "63. INTERRUPT RATE UNDER LOAD (DIFF SNAPSHOTS)" 

RUN_SH "irq diff" 'cat /proc/interrupts > /tmp/irq1; sleep 5; cat /proc/interrupts > /tmp/irq2; diff /tmp/irq1 /tmp/irq2 || true' 

 

######################################## 

# 64. USERLAND ABI SURFACE 

######################################## 

SECTION "64. USERLAND ABI SURFACE" 

RUN_SH "vdso" 'grep vdso /proc/self/maps' 

 

######################################## 

# 65. RANDOMNESS / ENTROPY BEHAVIOR 

######################################## 

SECTION "65. RANDOMNESS / ENTROPY BEHAVIOR UNDER LOAD" 

RUN_SH "entropy loop" 'for i in {1..6}; do cat /proc/sys/kernel/random/entropy_avail; sleep 5; done' 

 

######################################## 

# 66. FAILURE MODES / ERROR SURFACE 

######################################## 

SECTION "66. FAILURE MODES / ERROR SURFACE" 

RUN_SH "errors" 'dmesg | grep -Ei "mce|aer|ecc|edac" || true' 

 

######################################## 

# 66A. MACHINE STATE INVARIANT 

######################################## 

SECTION "66A. MACHINE STATE INVARIANT" 

 

if [[ -f "$STATE_FILE" ]]; then 

  echo "INVARIANT: LOCKED_STATE_ENFORCED" 

else 

  echo "INVARIANT: UNLOCKED_STATE (BASELINE ONLY)" 

fi 

 

######################################## 

# 67. END / CHECKSUM 

######################################## 

SECTION "67. END / CHECKSUM" 

echo "PRIMARY_IF: $(PRIMARY_IF 2>/dev/null || true)" 

echo "PRIMARY_IP: $(PRIMARY_IP 2>/dev/null || true)" 

RUN_SH "sha256sum report" "sha256sum '$REPORT' 2>/dev/null || true" 

echo "END OF REPORT" 

 

######################################## 

# 68. ICMP LATENCY + JITTER 

######################################## 

SECTION "68. ICMP LATENCY + JITTER" 

RUN_SH "sustained ping" "ping -c 100 -i 0.2 -D '$NET_PING_TARGET' 2>/dev/null || true" 

 

######################################## 

# 69. PACKET LOSS / JITTER (FPING) 

######################################## 

SECTION "69. PACKET LOSS / JITTER (FPING)" 

RUN_SH "fping sustained" "fping -c 1000 -p 20 '$NET_PING_TARGET' 2>&1 || true" 

 

######################################## 

# 70. TCP HANDSHAKE LATENCY (HPING3) 

######################################## 

SECTION "70. TCP HANDSHAKE LATENCY (HPING3)" 

RUN_SH "hping3 SYN latency" "hping3 -S -p 443 -c 100 '$NET_PING_TARGET' 2>&1 || true" 

 

######################################## 

# 71. DNS RESOLUTION MEASUREMENT 

######################################## 

SECTION "71. DNS RESOLUTION MEASUREMENT" 

RUN_SH "dns latency" "dig google.com | grep 'Query time' || true" 

 

######################################## 

# 72. MTU / FRAGMENTATION MEASUREMENT 

######################################## 

SECTION "72. MTU / FRAGMENTATION MEASUREMENT" 

RUN_SH "MTU sweep" "ping -M do -s 1472 -c 10 '$NET_PING_TARGET' 2>/dev/null || echo 'Fragmentation required at 1472 bytes'" 

 

######################################## 

# 73. CLIENT-ONLY TCP THROUGHPUT (CURL) 

######################################## 

SECTION "73. CLIENT-ONLY TCP THROUGHPUT (CURL)" 

cat << 'EOF' > /tmp/curl-format.txt 

     time_namelookup:  %{time_namelookup}s\n 

        time_connect:  %{time_connect}s\n 

     time_appconnect:  %{time_appconnect}s\n 

    time_pretransfer:  %{time_pretransfer}s\n 

       time_redirect:  %{time_redirect}s\n 

  time_starttransfer:  %{time_starttransfer}s\n 

                     ----------\n 

          time_total:  %{time_total}s\n 

       speed_download: %{speed_download} bytes/s\n 

EOF 

RUN_SH "HTTPS download measurement" "curl -w '@/tmp/curl-format.txt' -o /dev/null -s https://speed.hetzner.de/100MB.bin || true" 

 

### PHASE 2 — POST-ENUMERATION STATE CAPTURE 

 

######################################## 

# 74. INTERFACE ERROR COUNTERS (POST-LOAD) 

######################################## 

SECTION "74. INTERFACE ERROR COUNTERS (POST-LOAD)" 

RUN_SH "Final Interface Stats" 'for i in $(ls /sys/class/net); do echo "=== $i ==="; ethtool -S "$i" 2>/dev/null || true; ip -s link show "$i" 2>/dev/null || true; done' 

 

######################################## 

# 76. FILESYSTEM HEALTH & ERROR STATE 

######################################## 

SECTION "76. FILESYSTEM HEALTH & ERROR STATE" 

RUN_SH "findmnt detail" 'findmnt -o TARGET,FSTYPE,OPTIONS 2>/dev/null || true' 

RUN "df -i" df -i 

RUN_SH "tune2fs state" 'for d in $(lsblk -n -o NAME,TYPE | awk "\$2==\"part\" {print \"/dev/\"\$1}"); do echo "== $d =="; tune2fs -l "$d" 2>/dev/null | grep -Ei "Filesystem state|Errors behavior|Journal" || true; done' 

RUN_SH "xfs_repair dry-run" 'for d in $(lsblk -n -o NAME,TYPE | awk "\$2==\"part\" {print \"/dev/\"\$1}"); do echo "== $d =="; xfs_repair -n "$d" 2>/dev/null || true; done' 

 

######################################## 

# 77. FILESYSTEM SNAPSHOTS (GENERIC) 

######################################## 

SECTION "77. FILESYSTEM SNAPSHOTS (GENERIC)" 

RUN "ls /.snapshots" ls /.snapshots 2>/dev/null || true 

RUN "find snapshots" find / -maxdepth 3 -type d -name "*snapshot*" 2>/dev/null || true 

 

######################################## 

# 78. ZFS — POOL INVENTORY 

######################################## 

SECTION "78. ZFS — POOL INVENTORY" 

RUN_SH "zpool list" 'command -v zpool >/dev/null && zpool list || true' 

RUN_SH "zpool status" 'command -v zpool >/dev/null && zpool status -v || true' 

RUN_SH "zpool get all" 'command -v zpool >/dev/null && zpool get all || true' 

 

######################################## 

# 79. ZFS — DATASET PROPERTIES 

######################################## 

SECTION "79. ZFS — DATASET PROPERTIES" 

RUN_SH "zfs list detail" 'command -v zfs >/dev/null && zfs list -o name,used,avail,refer,recordsize,compression,sync,checksum || true' 

RUN_SH "zfs get all" 'command -v zfs >/dev/null && zfs get all || true' 

 

######################################## 

# 80. ZFS — SNAPSHOTS 

######################################## 

SECTION "80. ZFS — SNAPSHOTS" 

RUN_SH "zfs snapshots" 'command -v zfs >/dev/null && zfs list -t snapshot || true' 

 

######################################## 

# 81. ZFS — ARC / MEMORY 

######################################## 

SECTION "81. ZFS — ARC / MEMORY" 

DUMP_FILE "zfs arcstats" "/proc/spl/kstat/zfs/arcstats" 

 

######################################## 

# 82. ZFS — SCRUB / ERROR HISTORY 

######################################## 

SECTION "82. ZFS — SCRUB / ERROR HISTORY" 

RUN_SH "zpool scrub status" 'command -v zpool >/dev/null && zpool status -s || true' 

 

######################################## 

# 83. ZFS — PERFORMANCE & LATENCY 

######################################## 

SECTION "83. ZFS — PERFORMANCE & LATENCY" 

RUN_SH "zpool iostat" 'command -v zpool >/dev/null && zpool iostat -v 1 5 || true' 

 

######################################## 

# 84. LVM / DM / RAID HEALTH 

######################################## 

SECTION "84. LVM / DM / RAID HEALTH" 

RUN_SH "lvs health" 'lvs -a -o +devices,segtype,lv_health_status 2>/dev/null || true' 

RUN_SH "vgs metadata" 'vgs -o +vg_mda_count,vg_mda_used_count 2>/dev/null || true' 

RUN_SH "pvs used" 'pvs -o +pv_used 2>/dev/null || true' 

DUMP_FILE "mdstat" "/proc/mdstat" 

RUN_SH "dmsetup status" 'dmsetup status 2>/dev/null || true' 

 

######################################## 

# 85. STORAGE ERROR SURFACE (KERNEL) 

######################################## 

SECTION "85. STORAGE ERROR SURFACE (KERNEL)" 

RUN_SH "dmesg storage errors" 'dmesg | grep -Ei "blk|I/O error|buffer error|zfs|nvme|ext4|xfs" || true' 

 

######################################## 

# 86. STORAGE CACHE & FLUSH BEHAVIOR 

######################################## 

SECTION "86. STORAGE CACHE & FLUSH BEHAVIOR" 

RUN_SH "dirty/writeback sysctl" 'sysctl -a | grep -E "vm.dirty|vm.writeback" || true' 

RUN_SH "write_cache state" 'cat /sys/block/*/queue/write_cache 2>/dev/null || true' 

 

######################################## 

# 87. SHELL HISTORY (ALL USERS) 

######################################## 

SECTION "87. SHELL HISTORY (ALL USERS)" 

RUN_SH "user shell history" 'for u in /home/* /root; do [[ -d "$u" ]] || continue; echo "USER_HOME: $u"; for h in .bash_history .zsh_history .ash_history; do [[ -f "$u/$h" ]] && echo "--- $u/$h ---" && cat "$u/$h" 2>/dev/null; done; done' 

 

######################################## 

# 88. SYSTEM COMMAND EXECUTION LOGS 

######################################## 

SECTION "88. SYSTEM COMMAND EXECUTION LOGS" 

RUN_SH "process accounting logs" 'lastcomm 2>/dev/null || echo "acct not installed"; journalctl _COMM=bash --no-pager 2>/dev/null || true; journalctl _COMM=ssh --no-pager 2>/dev/null || true' 

 

######################################## 

# 89. SSH ACCESS & AUTHENTICATION HISTORY 

######################################## 

SECTION "89. SSH ACCESS & AUTHENTICATION HISTORY" 

RUN_SH "auth history" 'last -ai; lastlog; who -a; journalctl -u ssh -u sshd --no-pager 2>/dev/null || true' 

 

######################################## 

# 90. SSH KEYS & TRUST SURFACE 

######################################## 

SECTION "90. SSH KEYS & TRUST SURFACE" 

RUN_SH "ssh trust map" 'for u in /home/* /root; do [[ -d "$u/.ssh" ]] || continue; echo "==== SSH DIR: $u/.ssh ===="; ls -la "$u/.ssh"; for f in authorized_keys known_hosts config; do [[ -f "$u/.ssh/$f" ]] && echo "--- $f ---" && cat "$u/.ssh/$f" 2>/dev/null; done; done' 

 

######################################## 

# 91. SUDO USAGE & PRIVILEGE ESCALATION 

######################################## 

SECTION "91. SUDO USAGE & PRIVILEGE ESCALATION" 

RUN_SH "sudo execution logs" 'journalctl _COMM=sudo --no-pager 2>/dev/null || true; grep -R "sudo" /var/log 2>/dev/null || true' 

 

######################################## 

# 92. SYSTEMD UNIT EXECUTION HISTORY 

######################################## 

SECTION "92. SYSTEMD UNIT EXECUTION HISTORY" 

RUN_SH "systemd execution logs" 'journalctl _SYSTEMD_UNIT=* --no-pager 2>/dev/null || true; systemctl list-unit-files --no-pager' 

 

######################################## 

# 93. PACKAGE INSTALL / REMOVAL HISTORY 

######################################## 

SECTION "93. PACKAGE INSTALL / REMOVAL HISTORY" 

RUN_SH "package drift logs" 'grep -E " install | upgrade | remove " /var/log/dpkg.log* 2>/dev/null || true; apt history list 2>/dev/null || true' 

 

######################################## 

# 94. AUTO-UPDATES / UNATTENDED-UPGRADES 

######################################## 

SECTION "94. AUTO-UPDATES / UNATTENDED-UPGRADES" 

RUN_SH "unattended-upgrades state" 'cat /etc/apt/apt.conf.d/20auto-upgrades 2>/dev/null || true; cat /etc/apt/apt.conf.d/50unattended-upgrades 2>/dev/null || true; systemctl status unattended-upgrades --no-pager 2>/dev/null || true' 

 

######################################## 

# 95. KERNEL UPDATE & BOOT DRIFT 

######################################## 

SECTION "95. KERNEL UPDATE & BOOT DRIFT" 

RUN_SH "boot and kernel timeline" 'ls -lt /boot; dpkg -l | grep linux-image; journalctl -b -1 -k --no-pager 2>/dev/null || true' 

 

######################################## 

# 96. FILE MODIFICATION TIMELINE (HIGH-RISK PATHS) 

######################################## 

SECTION "96. FILE MODIFICATION TIMELINE (HIGH-RISK PATHS)" 

RUN_SH "recent binary/config changes" 'find /etc /usr/bin /usr/sbin /bin /sbin -type f -mtime -30 -exec ls -l --time-style=full-iso {} \; 2>/dev/null || true' 

 

######################################## 

# 97. SYSTEM SNAPSHOT / BACKUP ARTIFACTS 

######################################## 

SECTION "97. SYSTEM SNAPSHOT / BACKUP ARTIFACTS" 

RUN_SH "backup/snapshot detection" 'find / -maxdepth 3 -type d \( -name "*snapshot*" -o -name "*backup*" \) 2>/dev/null || true' 

 

######################################## 

# 98. ZFS SNAPSHOT LIFECYCLE (DELETION SIGNALS) 

######################################## 

SECTION "98. ZFS SNAPSHOT LIFECYCLE (DELETION SIGNALS)" 

RUN_SH "ZFS creation/deletion logs" 'command -v zfs >/dev/null && zfs list -t snapshot -o name,creation || true; grep -R "destroy" /var/log 2>/dev/null | grep zfs || true' 

 

######################################## 

# 99. FILE DELETION evidence (AUDITD IF PRESENT) 

######################################## 

SECTION "99. FILE DELETION evidence (AUDITD IF PRESENT)" 

RUN_SH "auditd forensics" 'command -v aureport >/dev/null && aureport -f --summary 2>/dev/null || true; command -v ausearch >/dev/null && ausearch -x rm 2>/dev/null || true' 

 

######################################## 

# 100. ENVIRONMENT VARIABLE INJECTION 

######################################## 

SECTION "100. ENVIRONMENT VARIABLE INJECTION" 

RUN_SH "active env and profiles" 'printenv; grep -R "export " /etc/profile* /etc/bash* 2>/dev/null || true' 

 

######################################## 

# 101. PERSISTENCE VECTORS 

######################################## 

SECTION "101. PERSISTENCE VECTORS" 

RUN_SH "init and auto-start logic" 'ls -la /etc/rc*.d /etc/init.d; systemctl list-unit-files --state=enabled --no-pager' 

 

######################################## 

# 102. END / CHECKSUM 

######################################## 

SECTION "102. END / CHECKSUM" 

echo "PRIMARY_IF: $(PRIMARY_IF 2>/dev/null || true)" 

echo "PRIMARY_IP: $(PRIMARY_IP 2>/dev/null || true)" 

RUN_SH "sha256sum report" "sha256sum '$REPORT' 2>/dev/null || true" 

 

# FINAL SUMMARY LOGIC 

echo 

echo "====================================================================" 

if [[ $TOTAL_ERRORS -gt 0 ]]; then 

  echo "ENUMERATION COMPLETE WITH $TOTAL_ERRORS NON-FATAL ERRORS/WARNINGS." 

else 

  echo "ENUMERATION COMPLETE: TOTAL SUCCESS (ZERO ERRORS DETECTED)." 

fi 

echo "evidence ENUMERATION FILE GENERATED AT: $REPORT" 

echo "ENUMERATION_ROLE: OBSERVATION_ONLY" 

echo "INTERPRETATION_ROLE: EXTERNAL_CONSUMER" 

echo "====================================================================" 

echo "END OF REPORT" 