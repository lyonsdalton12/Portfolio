**Project:** IT-Governance-Standards  
**Domain:** IT Operations, Data Security Compliance, Asset Management, Process Engineering  
**Languages:** T-SQL, Technical Writing  

**Overview**
This project establishes a comprehensive internal IT governance framework designed to eliminate "knowledge silos," streamline incident response, and enforces a more strict data security compliance. By creating a standard for documentation, technical runbooks, and code assets, this initiative drastically reduces manual overhead and improves cross-departmental operations.

**The Problem**
The internal IT department and indirectly adjacent offices were facing significant operational bottlenecks:
* **Inconsistent Documentation:** A lack of standardized formats led to confusion, making teams overly reliant on the original authors of scripts or processes to understand how they worked.
* **Cumbersome Troubleshooting:** Without clear dependency mapping or context, manual oversight and troubleshooting took much longer than necessary.
* **Unclear Security & Duty Delegation:** There was a lack of defined boundaries regarding data security limitations, making it difficult to safely delegate duties involving proprietary or client custodial assets.

**The Solution**
To resolve these issues, I engineered a suite of standardized templates, security guidelines, and documentation policies. The goal of this structured approach was to transition the department from a reactive, decentralized state to a proactive, highly organized environment.

Core Components & Deliverables

1. **Unified Documentation Standards** (Documentation Standards.txt)
* **Purpose:** Serves as the foundational policy for all institutional IT documentation.
* **Highlights:** Enforces stricter naming conventions (e.g., [Dept]_[Category]_[Short Name]), mandates baseline metadata (up-to-date timestamps, authors, revision history), and provides quick-start templates to ensure uniformity & quicker prototyping across all operational documentation.

2. **Strategic Playbook & Runbook Architecture** (Play_Runbook Template.txt)
* **Purpose:** Bridges the gap between high-level strategic intent and granular technical execution.
* **Highlights:** Combines Playbooks (the "why" and "what") with Runbooks (the "how") into a single, cohesive workflow for simplicity. Crucially, it mandates the documentation of **Dependencies** and **Systems in Use**, giving engineers a rapid snapshot of upstream and downstream impacts during incident response and troubleshooting.

3. **Data Security Classification Framework** (Security Levels.txt)
* **Purpose:** Defines clear boundaries for duty delegation and data access.
* **Highlights:** Establishes a rigid 4-Tier Security Level system (Level 1: Public to Level 4: Highly Restricted). This acts as a continuous operational guideline to secure both internal proprietary assets and sensitive custodial data entrusted to us by clientele, ensuring regulatory compliance.

4. **Standardized T-SQL Development Template** (SQLTemplate.txt)
* **Purpose:** Accelerates database asset creation while enforcing coding best practices.
* **Highlights:** Provides a boilerplate SQL template that mandates clarity of purpose, requires structured pre-construct areas for variable declarations, and enforces revision tracking. Includes a "quick copy-paste" section to expedite the creation of secure, legible, and easily maintainable T-SQL scripts.

---

**Key Skills Demonstrated**
* **Process Optimization:** Reducing manual overhead and incident response times through structured dependency mapping.
* **Technical Writing & Communication:** Translating complex IT workflows into digestible, standard operating procedures (SOPs).
* **Security & Compliance:** Designing tiered access control policies to protect sensitive institutional data.

*Note: All logic in this repository has been carefully sanitized of personalized and proprietary assets for demonstration purposes. AI assistance was utilized periodically for code documentation, formatting standardization, and exception logic refinement.*