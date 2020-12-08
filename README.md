## Preventing Server-Side Request Forgery Attacks

This repository is for sharing the implementation materials of our paper titled "Preventing Server-Side Request Forgery Attacks".

### Abstract
In today’s web, it is not uncommon for web applications to take a complete URL as input from users. Usually, once the web application receives a URL, the server opens a connection to it. However, if the URL points to an internal service and the server still makes the connection, the server becomes vulnerable to Server-Side Request Forgery (SSRF) attacks. These attacks can be highly destructive when they exploit internal services. They are equally destructive and need much less effort to succeed if the server is hosted in a cloud environment. Therefore, with the growing use of cloud computing, the threat of SSRF attacks is becoming more serious.

In this paper, we present a novel defense approach to protect internal services from SSRF attacks. Our analysis of more than 60 SSRF vulnerability reports shows that developers’ awareness about this vulnerability is generally limited. Therefore, coders usually have flaws in their defenses. Even when these defenses have no
flaws, they are usually still affected by important security and functionality limitations. In this work, we develop a prototype based on the proposed approach by extending the functionality of a popular reverse proxy application and deploy a set of vulnerable web applications with that prototype. We demonstrate how SSRF attacks on these applications, with almost no loss of performance, are prevented.

### Description of the files
[prevent-ssrf.lua](https://github.com/bahruzjabiyev/prevent-ssrf/blob/master/prevent-ssrf.lua) - NGINX extension code

[dockerize](https://github.com/bahruzjabiyev/prevent-ssrf/tree/master/dockerize) - Files needed for the "helper server" image
