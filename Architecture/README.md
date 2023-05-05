# Architecture Contents
This repo supports an article on the Azure Architecture Center (AAC) - [Trusted Internet Connection (TIC) 3.0 compliance - Azure Example Scenarios | Microsoft Docs](https://docs.microsoft.com/en-us/azure/architecture/example-scenario/security/trusted-internet-connections), it contains lots of great information on using the content of this repo. Please visit the article in the AAC before proceeding.

**Azure Active Directory**

- Deploy an automated service to deliver Azure Active Directory logs to CISA CLAW. This supports the TIC 3.0 compliance for authentication and sign-in logs.

**Azure Application Gateway**
- Deploy a suite of services that leverage Azure Application Gateway, regional load balancer with a Web Application Firewall, to provide direct access to an Azure-based application. 
- Meet TIC 3.0 telemetry compliance with the automated service to deliver application connection logs and layer 7 firewall logs to CISA CLAW. 

**Azure Firewall**
- Deploy a suite of services that leverage Azure Firewall, scalable layer 4 firewall, to provide direct access to an Azure-based application. 
- Meet TIC 3.0 telemetry compliance with the automated service to deliver connection logs and layer 4 firewall logs to CISA CLAW.

**Azure Front Door**
- Deploy a suite of services that leverage Azure Front Door, global load balancer with a Web Application Firewall, to provide direct access to an Azure-based application. 
- Meet TIC 3.0 telemetry compliance with the automated service to deliver application connection logs and layer 7 firewall logs to CISA CLAW. 

**Images**
- Contains images used throughout the articles in this repo.

**NetFlow Logs**
- Deploy an automated service to deliver NetFlow logs to CISA CLAW. This supports the TIC 3.0 compliance for NetFlow logs.

**Post Deployment Tasks**
- Article that defines list of tasks following deployment of scenarios.

**Prerequisite Tasks**
- Article that defines list of tasks that need to happen before deployment of scenarios.

**Third-party Firewall**
- Deploy an automated service to deliver third-party firewalls, layer 4 firewall, to provide direct access to an Azure-based application. 
- Meet TIC 3.0 telemetry compliance with the automated service to deliver connection logs and layer 4 firewall logs to CISA CLAW.

**Visio**
- Architecture for all scenarios and solutions in Visio document.