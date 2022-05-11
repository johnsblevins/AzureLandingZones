# AKS Private endpoint requirements

## Route To Mcr.Microsoft.Com
A Route to mcr.microsoft.com public ip is required for AKS cluster to deploy successfully.
```
{
    name: 'McrMicrosoftCom'
    properties: {
        nextHopType: 'Internet'
        addressPrefix: '204.79.197.219/32'          
    }        
}    
```

## Managed Identity Considerations

### System Managed

### User Managed
User Managed Identity specified with the following az cli argmuments:
```
     --enable-managed-identity --assign-identity "$identity_id"
```
If these arguments are skipped a System Managed identity is Created and used.
User MI must be prestaged and given read/write to UDR otherwise you get this error:

```
(CustomRouteTableMissingPermission) Managed identity or service principle must be given permission to read and write to custom route table /subscriptions/f86eed1f-a251-4b29-a8b3-98089b46ce6c/resourceGroups/aks-dns-vnet/providers/Microsoft.Network/routeTables/spokert. Please see https://aka.ms/aks/customrt for more information
Code: CustomRouteTableMissingPermission
Message: Managed identity or service principle must be given permission to read and write to custom route table /subscriptions/f86eed1f-a251-4b29-a8b3-98089b46ce6c/resourceGroups/aks-dns-vnet/providers/Microsoft.Network/routeTables/spokert. Please see https://aka.ms/aks/customrt for more information
```

# Troubleshooting

##
VM has reported a failure when processing extension 'vmssCSE'. 
Error message: "Enable failed: failed to execute command: command terminated with exit status=52 [stdout] 
{   "ExitCode": "52", 
    "Output": "
    Mon Feb 7 12:39:05 UTC 2022,aks-test-36831656-vmss000000\n
    % Total % Received % Xferd Average Speed Time Time Time Current\n 
    Dload Upload Total Spent Left Speed\n\r 
    0 0 0 0 0 0 0 0 --:--:-- --:--:-- --:--:-- 0* Trying 204.79.197.219...\n
    * TCP_NODELAY set\n
    * Connected to mcr.microsoft.com (204.79.197.219) port 443 (#0)\n
    * ALPN, offering h2\n
    * ALPN, offering http/1.1\n
    * successfully set certificate verify locations:\n
    * CAfile: /etc/ssl/certs/ca-certificates.crt\n
     CApath: /etc/ssl/certs\n
     } [5 bytes data]\n
     * TLSv1.3 (OUT), TLS handshake, Client hello (1):\n
     } [512 bytes data]\n
     * TLSv1.3 (IN), TLS handshake, Server hello (2):\n
     { [98 bytes data]\n
     * TLSv1.2 (IN), TLS handshake, Certificate (11):\n
     { [3786 bytes data]\n
     * TLSv1.2 (IN), TLS handshake, Server key exchange (12):\n{ [365 bytes data]\n* TLSv1.2 (IN), TLS handshake, Server finished (14):\n
     { [4 bytes data]\n
     * TLSv1.2 (OUT), TLS handshake, Client key exchange (16):\n} [102 bytes data]\n* TLSv1.2 (OUT), TLS change cipher, Client hello (1):\n} [1 bytes data]\n* TLSv1.2 (OUT), TLS handshake, Finished (20):\n} [16 bytes data]\n* TLSv1.2 (IN), TLS handshake, Finished (20):\n{ [16 bytes data]\n* SSL connection using TLSv1.2 / ECDHE-RSA-AES256-GCM-SHA384\n* ALPN, server accepted to use h2\n* Server certificate:\n
     * subject: C=US; ST=WA; L=Redmond; O=Microsoft Corporation; CN=mcr.microsoft.com\n
     * start date: Jan 13 05:46:51 2022 GMT\n
     * expire date: Jan 8 05:46:51 2023 GMT\n
     * issuer: C=US; O=Microsoft Corporation; CN=Microsoft Azure TLS Issuing CA 06\n* SSL certificate verify ok.\n
     * Using HTTP2, server supports multi-use\n
     * Connection state changed (HTTP/2 confirmed)\n
     * Copying HTTP/2 data in stream buffer to connection buffer after upgrade: len=0\n} [5 bytes data]\n
     * Using Stream ID: 1 (easy handle 0x55dbb129b620)\n} [5 bytes data]\n> GET /v2/ HTTP/2\r\n> Host: mcr.microsoft.com\r\n> User-Agent: curl/7.58.0\r\n> Accept: */*\r\n> \r\n{ [5 bytes data]\n
     * Connection state changed (MAX_CONCURRENT_STREAMS updated)!\n} [5 bytes data]\n< HTTP/2 200 \r\n< content-length: 2\r\n< content-type: application/json; charset=utf-8\r\n< access-control-expose-headers: Docker-Content-Digest\r\n< access-control-expose-headers: WWW-Authenticate\r\n< access-control-expose-headers: Link\r\n< access-control-expose-headers: X-Ms-Correlation-Request-Id\r\n< docker-distribution-api-version: registry/2.0\r\n< strict-transport-security: max-age=31536000; includeSubDomains\r\n< x-content-type-options: nosniff\r\n< x-ms-correlation-request-id: fffa8399-f703-42c7-a82b-9d0a8e3ada5f\r\n< strict-transport-security: max-age=31536000; includeSubDomains\r\n< x-cache: CONFIG_NOCACHE\r\n< x-mcr-env: preview\r\n< x-msedge-ref: Ref A: 60CA219290BC48B8A1187CF94EB2866C Ref B: BN3EDGE0307 Ref C: 2022-02-07T12:39:05Z\r\n< date: Mon, 07 Feb 2022 12:39:04 GMT\r\n< \r\n{ [2 bytes data]\n\r100 2 100 2 0 0 31 0 --:--:-- --:--:-- --:--:-- 31\n
     * Connection #0 to host mcr.microsoft.com left intact\n{}● kubelet.service - Kubele", 
    "Error": "", "ExecDuration": "225", "KernelStartTime": "Mon 2022-02-07 12:36:59 UTC", "CSEStartTime": "Mon Feb 7 12:39:05 UTC 2022", "GuestAgentStartTime": "Mon 2022-02-07 12:37:17 UTC", "SystemdSummary": "Startup finished in 1.536s (firmware) + 9.858s (loader) + 5.471s (kernel) + 4min 44.549s (userspace) = 5min 1.414s\ngraphical.target reached after 1min 42.537s in userspace", "BootDatapoints": { "KernelStartTime": "Mon 2022-02-07 12:36:59 UTC", "CSEStartTime": "Mon Feb 7 12:39:05 UTC 2022", "GuestAgentStartTime": "Mon 2022-02-07 12:37:17 UTC", "KubeletStartTime": "Mon 2022-02-07 12:39:27 UTC" } } [stderr] " More information on troubleshooting is available at https://aka.ms/VMExtensionCSELinuxTroubleshoot