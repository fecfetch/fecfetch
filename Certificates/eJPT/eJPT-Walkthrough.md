# Hands-On Offensive Security Practice & eJPT Practical Exam Walkthrough

## Practical Preparation in Home Lab Environment
To practice core penetration testing skills prior to taking the eJPT (eLearnSecurity Junior Penetration Tester) practical exam, I built a local virtualized lab using **VirtualBox** to simulate a vulnerable network.

### Lab Topology
* **Attacker Machine:** Kali Linux
* **Target 1:** Windows 7 SP1
* **Target 2:** Linux running Damn Vulnerable Web Application

```text
[ Kali Linux (Attacker) ]
         │
         ├────────── (NAT Network)─────────┐
         │                                 │
[ Windows 7 Target ]                   [ DVWA ]
(EternalBlue)               (Intentionally vulnerable Web App)
```

### Key Attack Vectors & Tooling Practiced
* **Network & Service Reconnaissance:** Conducted active and passive enumeration using Nmap service detection (-sV), OS fingerprinting (-O), and NSE scripts (--script vuln) to map open ports and attack surfaces.
* **Exploitation via Metasploit Framework:** Leveraged msfconsole to execute MS17-010 (EternalBlue) against the unpatched Windows 7 host and configured handlers to practice SMB exploitation mechanics.
* **Legacy & Forgotten Services:** Performed target enumeration and credential brute-force attacks against legacy services like Telnet, FTP or SSH using Hydra and custom SecLists wordlists to simulate real-world service exposure misconfigurations.
* **Web Application Security:** Utilized Burp Suite for HTTP request interception and parameter manipulation, Gobuster and DirBuster for hidden directory and file discovery, and SQLmap alongside manual testing on DVWA to practice SQL Injection, Cross-Site Scripting, and other web application vulnerabilities.

---

## 2. Practical Exam Execution & Methodology
The eJPT exam is a practical assessment where I performed a real-time penetration test against a multi-subnet network consisting of 7 target machines.

### Engagement Methodology & Ops Log
During the exam, I maintained a structured, real-time operations log to track every asset and finding:
* **Asset & Route Tracking:** Documented active IP addresses and hostnames to establish pivots across internal subnets using Metasploit's autoroute.
* **Service Matrix:** Cataloged open ports, service versions, banner grabs, and potential attack vectors for every host.
* **Credential Vault:** Tracked all discovered username, plain-text passwords, hashes, SSH keys, and potentially vulnerable default configurations found across compromised hosts.
* **Evidence & Artifacts:** Recorded step-by-step actions, commands used, and flags captured to maintain clear traceability throughout the engagement.

### Post-Exploitation & Pivoting Operations
Once initial access was achieved across various targets, I executed systematic post-exploitation procedures:
* **Local Enumeration:** Leveraged Meterpreter built-ins (sysinfo, getuid, netstat, ps) and local enumeration scripts like WinPEAS to identify misconfigurations and privilege escalation vectors.
* **Credential Harvesting:** Extracted local SAM database hashes using Metasploit's hashdump and mimikatz. Then cracked weak password hashes using John the Ripper and Hashcat. 
* **File Transfers & Persistence:** Set up staging servers using Python HTTP modules (python3 -m http.server), certutil, and curl/wget to transfer enumeration scripts and binaries onto target environments.
* **Subnet Pivoting:** Configured internal network routes through compromised session hosts, enabling scanning and exploitation of secondary isolated subnets that were not directly exposed to the internet.

### Exam Completion
By applying structured recon, systematic vulnerability mapping, manual exploitation, and careful pivoting across subnets, I successfully compromised the target environment and completed the practical exam in **8 hours** (including rest breaks).

---
### [Certificate Link](https://github.com/fecfetch/fecfetch/blob/main/Certificates/eJPT%20INE.pdf) 
