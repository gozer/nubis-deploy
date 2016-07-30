# Change Log

## [v1.2.1](https://github.com/nubisproject/nubis-deploy/tree/v1.2.1) (2016-07-30)
[Full Changelog](https://github.com/nubisproject/nubis-deploy/compare/v1.2.0...v1.2.1)

**Closed issues:**

- \[datadog\] Update IAM permissions granted to DataDog [\#95](https://github.com/nubisproject/nubis-deploy/issues/95)

**Merged pull requests:**

- Update pinned release version for v1.2.1 release [\#99](https://github.com/nubisproject/nubis-deploy/pull/99) ([tinnightcap](https://github.com/tinnightcap))
- Update DataDog permissions as per their docs [\#96](https://github.com/nubisproject/nubis-deploy/pull/96) ([gozer](https://github.com/gozer))

## [v1.2.0](https://github.com/nubisproject/nubis-deploy/tree/v1.2.0) (2016-07-11)
[Full Changelog](https://github.com/nubisproject/nubis-deploy/compare/bugzilla...v1.2.0)

**Implemented enhancements:**

- \[nat\] Bump up instance type [\#67](https://github.com/nubisproject/nubis-deploy/issues/67)

**Closed issues:**

- Turn Atlas token into a variable [\#20](https://github.com/nubisproject/nubis-deploy/issues/20)
- Use tf\_module \(https://github.com/mengesb/tf\_filemodule\) for generating files [\#12](https://github.com/nubisproject/nubis-deploy/issues/12)
- ipsec\_targets is now ipsec\_target \(singular\) [\#91](https://github.com/nubisproject/nubis-deploy/issues/91)
- Update external module references to v1.2.0 [\#90](https://github.com/nubisproject/nubis-deploy/issues/90)
- Tag v1.2.0 release [\#87](https://github.com/nubisproject/nubis-deploy/issues/87)
- For global resources, pick the first region instead of hard-coding us-east-1 [\#82](https://github.com/nubisproject/nubis-deploy/issues/82)
- Create a resource with NubisVersion [\#77](https://github.com/nubisproject/nubis-deploy/issues/77)
- Document the usage of aws-vault [\#73](https://github.com/nubisproject/nubis-deploy/issues/73)
- Make NAT a disableable tunable [\#69](https://github.com/nubisproject/nubis-deploy/issues/69)
- Deploy a single, global opsec security audit stack [\#64](https://github.com/nubisproject/nubis-deploy/issues/64)
- Add new credstash\_key paramater to nubis-ci [\#62](https://github.com/nubisproject/nubis-deploy/issues/62)
- Ensure we don't require an Atlas Token [\#60](https://github.com/nubisproject/nubis-deploy/issues/60)
- \[dummy\] PrivateAvailabilityZone\[1-3\] [\#57](https://github.com/nubisproject/nubis-deploy/issues/57)
- create read-only guest accounts too [\#52](https://github.com/nubisproject/nubis-deploy/issues/52)
- Output IAM roles for admins [\#50](https://github.com/nubisproject/nubis-deploy/issues/50)
- remove references to aws\_profile and just rely on AWS\* keys to be in the environment [\#49](https://github.com/nubisproject/nubis-deploy/issues/49)
- Create a read-only policy and allow all admin users to assume it for convenience [\#46](https://github.com/nubisproject/nubis-deploy/issues/46)
- Enable and enforce MFA for all admin accounts [\#44](https://github.com/nubisproject/nubis-deploy/issues/44)
- get rid of my\_ip, it's really just for debugging [\#43](https://github.com/nubisproject/nubis-deploy/issues/43)
- \[opsec\] Remove useless variables [\#39](https://github.com/nubisproject/nubis-deploy/issues/39)
- \[ci\] Attach to the correct credstash policy to make it part of the platorm ACL [\#38](https://github.com/nubisproject/nubis-deploy/issues/38)
- \[ci\] Github OAuth client id is incorrectly passed in [\#36](https://github.com/nubisproject/nubis-deploy/issues/36)
- \[opsec\] enable cloudtrail logs everywhere [\#34](https://github.com/nubisproject/nubis-deploy/issues/34)
- Output the actual top-level public route53 zones to facilitate hooking up in inventory [\#32](https://github.com/nubisproject/nubis-deploy/issues/32)
- \[proxy\] Front internal proxies with an ELB so the fallback proxy DNS entry always works [\#31](https://github.com/nubisproject/nubis-deploy/issues/31)

**Merged pull requests:**

- Add config for nubis-market Upgrade to v1.2.0 \( and rotate datadog api key \) [\#94](https://github.com/nubisproject/nubis-deploy/pull/94) ([gozer](https://github.com/gozer))
- Upgrade external TF module references to v1.2.0 [\#93](https://github.com/nubisproject/nubis-deploy/pull/93) ([gozer](https://github.com/gozer))
- ipsec\_targets was renamed ipsec\_target [\#92](https://github.com/nubisproject/nubis-deploy/pull/92) ([gozer](https://github.com/gozer))
- Update CHANGELOG for v1.2.0 release [\#88](https://github.com/nubisproject/nubis-deploy/pull/88) ([tinnightcap](https://github.com/tinnightcap))
- We only need one IPSec target on the DC side [\#86](https://github.com/nubisproject/nubis-deploy/pull/86) ([gozer](https://github.com/gozer))
- Fix default ipsec\_targets target [\#85](https://github.com/nubisproject/nubis-deploy/pull/85) ([gozer](https://github.com/gozer))
- Use the first region for global resources instead of hard-coding an arbitrairy one [\#84](https://github.com/nubisproject/nubis-deploy/pull/84) ([gozer](https://github.com/gozer))
- Provisions for HA NAT [\#70](https://github.com/nubisproject/nubis-deploy/pull/70) ([limed](https://github.com/limed))
- Enforce MFA policies on all admin users [\#45](https://github.com/nubisproject/nubis-deploy/pull/45) ([gozer](https://github.com/gozer))

## [bugzilla](https://github.com/nubisproject/nubis-deploy/tree/bugzilla) (2016-05-27)
[Full Changelog](https://github.com/nubisproject/nubis-deploy/compare/v1.1.0...bugzilla)

**Implemented enhancements:**

- Use t2.small for nat instance [\#72](https://github.com/nubisproject/nubis-deploy/pull/72) ([limed](https://github.com/limed))

**Merged pull requests:**

- Just remove documentation references to aws\_profile. [\#80](https://github.com/nubisproject/nubis-deploy/pull/80) ([gozer](https://github.com/gozer))
- Add dummy SG for version tracking [\#79](https://github.com/nubisproject/nubis-deploy/pull/79) ([gozer](https://github.com/gozer))
- Add 'nat' as en enable flag [\#78](https://github.com/nubisproject/nubis-deploy/pull/78) ([gozer](https://github.com/gozer))
- Tyops [\#75](https://github.com/nubisproject/nubis-deploy/pull/75) ([tinnightcap](https://github.com/tinnightcap))
- Initial drop of aws-vault documentation [\#74](https://github.com/nubisproject/nubis-deploy/pull/74) ([gozer](https://github.com/gozer))
- Revert "Use a bigger instance" [\#71](https://github.com/nubisproject/nubis-deploy/pull/71) ([tinnightcap](https://github.com/tinnightcap))
- Use a bigger instance [\#68](https://github.com/nubisproject/nubis-deploy/pull/68) ([limed](https://github.com/limed))
- Deploy a single, global opsec security audit stack [\#65](https://github.com/nubisproject/nubis-deploy/pull/65) ([gozer](https://github.com/gozer))
- Add new required credstash\_key to nubis-ci [\#63](https://github.com/nubisproject/nubis-deploy/pull/63) ([gozer](https://github.com/gozer))
- Create an atlas\_token variable, defaults to 'anonymous'  [\#61](https://github.com/nubisproject/nubis-deploy/pull/61) ([gozer](https://github.com/gozer))
- update bugzilla GitHub settings [\#59](https://github.com/nubisproject/nubis-deploy/pull/59) ([gozer](https://github.com/gozer))
- Provide PrivateAvailabilityZone\[1-3\] inputs [\#58](https://github.com/nubisproject/nubis-deploy/pull/58) ([gozer](https://github.com/gozer))
- Name the NAT instances like other platform instances   Name \(v0.0.0\) for account in environment [\#56](https://github.com/nubisproject/nubis-deploy/pull/56) ([gozer](https://github.com/gozer))
- terraform fmt [\#55](https://github.com/nubisproject/nubis-deploy/pull/55) ([gozer](https://github.com/gozer))
- Add support for read-only guest accounts [\#53](https://github.com/nubisproject/nubis-deploy/pull/53) ([gozer](https://github.com/gozer))
- Add admin roles as outputs [\#51](https://github.com/nubisproject/nubis-deploy/pull/51) ([gozer](https://github.com/gozer))
- Move readonly role to the /nubis/ path, to avoid calshes with usernames [\#48](https://github.com/nubisproject/nubis-deploy/pull/48) ([gozer](https://github.com/gozer))
- Add a readonly IAM role intended for Nubis Admins [\#47](https://github.com/nubisproject/nubis-deploy/pull/47) ([gozer](https://github.com/gozer))

## [v1.1.0](https://github.com/nubisproject/nubis-deploy/tree/v1.1.0) (2016-04-26)
**Closed issues:**

- Figure out what to do with each account's config file in the long run [\#29](https://github.com/nubisproject/nubis-deploy/issues/29)
- Create a README [\#26](https://github.com/nubisproject/nubis-deploy/issues/26)
- NATs don't need EIPs [\#25](https://github.com/nubisproject/nubis-deploy/issues/25)
- Add cloudhealth module [\#23](https://github.com/nubisproject/nubis-deploy/issues/23)
- \[state\] Create the state user and credentials [\#22](https://github.com/nubisproject/nubis-deploy/issues/22)
- Use Route53 delegation sets for all our zones [\#19](https://github.com/nubisproject/nubis-deploy/issues/19)
- Add technical\_contact input variable [\#18](https://github.com/nubisproject/nubis-deploy/issues/18)
- Handle VPN connections [\#17](https://github.com/nubisproject/nubis-deploy/issues/17)
- create fake stacks for stage and prod [\#16](https://github.com/nubisproject/nubis-deploy/issues/16)
- Enable support for nubis-ci [\#15](https://github.com/nubisproject/nubis-deploy/issues/15)
- Fix Consul TechnicalOwner =\> TechnicalContact [\#14](https://github.com/nubisproject/nubis-deploy/issues/14)
- Assign a public EIP to NAT instances so we can do IP whitelists for the admin [\#13](https://github.com/nubisproject/nubis-deploy/issues/13)
- s/TechnicalOwner/TechnicalContact/ [\#11](https://github.com/nubisproject/nubis-deploy/issues/11)
- Datadog [\#7](https://github.com/nubisproject/nubis-deploy/issues/7)
- datadog [\#6](https://github.com/nubisproject/nubis-deploy/issues/6)
- Create the state holding bucket [\#5](https://github.com/nubisproject/nubis-deploy/issues/5)
- Add all missing account buckets [\#4](https://github.com/nubisproject/nubis-deploy/issues/4)
- Need separate Credstash IAM policies per environments [\#3](https://github.com/nubisproject/nubis-deploy/issues/3)
- Credstash Policy missing from NAT instance IAM role [\#2](https://github.com/nubisproject/nubis-deploy/issues/2)
- Publish fluentd outputs into Consul [\#1](https://github.com/nubisproject/nubis-deploy/issues/1)

**Merged pull requests:**

- Rollbak local change that shouldn't have been pushed [\#42](https://github.com/nubisproject/nubis-deploy/pull/42) ([gozer](https://github.com/gozer))
- Create an ELB-based proxy endpoint for initial bootstrap [\#41](https://github.com/nubisproject/nubis-deploy/pull/41) ([gozer](https://github.com/gozer))
- Cleanup useless stuff [\#40](https://github.com/nubisproject/nubis-deploy/pull/40) ([gozer](https://github.com/gozer))
- Correctly pass in ci\_github\_oauth\_client\_id where needed [\#37](https://github.com/nubisproject/nubis-deploy/pull/37) ([gozer](https://github.com/gozer))
- Enable global cloudtrail as per opsec's request [\#35](https://github.com/nubisproject/nubis-deploy/pull/35) ([gozer](https://github.com/gozer))
- Large PR with leftover bits. [\#33](https://github.com/nubisproject/nubis-deploy/pull/33) ([gozer](https://github.com/gozer))
- Update CHANGELOG for v1.1.0 release [\#30](https://github.com/nubisproject/nubis-deploy/pull/30) ([tinnightcap](https://github.com/tinnightcap))
- Issue/26/readme [\#28](https://github.com/nubisproject/nubis-deploy/pull/28) ([gozer](https://github.com/gozer))
- EIPs are not needed for the NATs, and once released, we are done. [\#27](https://github.com/nubisproject/nubis-deploy/pull/27) ([gozer](https://github.com/gozer))
- Issue/23/cloudhealth [\#24](https://github.com/nubisproject/nubis-deploy/pull/24) ([gozer](https://github.com/gozer))



\* *This Change Log was automatically generated by [github_changelog_generator](https://github.com/skywinder/Github-Changelog-Generator)*