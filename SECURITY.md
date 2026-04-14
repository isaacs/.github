# Security Policy

This document covers the policy and procedures for reporting
security vulnerabilities in all of my repositories.

If your report does not comply with the guidance here, then it
may be summarily closed. Doing this is a waste of your time as a
security researcher, and mine as a maintainer, and thus makes the
entire ecosystem slightly less secure, as that effort could be
better spent.

## Read the README.md FIRST

Many libraries are designed in a way that is fundamentally
impossible to harden against malicious input, and it is called
out as the user's responsibility to only provide trusted input to
these.

For example, libraries that generate regular expressions will
generally _always_ be subject to ReDOS attacks. The
[rimraf](https://github.com/isaacs/rimraf) library is a module
for use in deleting files, and so can be used to delete files.

If you are using my libraries in a way that is known to be
insecure, then you are exposing yourself and your users to risks
that I cannot help prevent.

**Please do not waste your time and mine reporting
vulnerabilities at are already explicitly called out as known
risks in the README.md.**

## Supported Versions

While reports for any version are allowed and may be accepted if
valid, typically only the most recent version of a library is
supported for fixing security vulnerabilities.

In rare cases, especially when the most recent major version is
very new and has not diverged much from the prior major version
branch, security fixes _may_ be backported. But this is not the
norm.

**It is not my responsibility to backport fixes. It is _your_
responsibility to stay up to date.**

If you are using unsupported versions of libraries in a
security-sensitive application, then you are exposing yourself
and your users to risks that I cannot help prevent.

**Please do not waste your time and mine reporting security
vulnerabilities that apply to old versions, when they were
already reported and fixed in the latest version. If a backport
was not provided, that's because it will not be provided.**

## Report Vulnerabilities via GitHub Security Advisories

Please report all security vulnerabilities through 
[GitHub Security Advisories](https://github.com/advisories). 
This allows us to collaborate on investigation, remediation, and
correction, while maintaining confidentiality until it is safe to
disclose responsibly and accurately.

Reports via email are likely to be missed, ignored, or flagged as
spam.

Reports via normal GitHub issues are public, and this is not
responsible disclosure. These issues will be deleted.

To report a vulnerability
([docs](https://docs.github.com/en/code-security/security-advisories/guidance-on-reporting-and-writing-information-about-vulnerabilities/privately-reporting-a-security-vulnerability)):  

1. Visit the **Security** tab of the affected repository on
   GitHub.
2. Click **Report a vulnerability** and follow the provided
   steps.
