# Healthcare Integration Notes

## Scheduling System
- Options: Google Calendar, Calendly, practice-specific EHR scheduling
- Need provider availability calendars
- Appointment types with different durations
- Buffer time between appointments

## EHR Integration (if applicable)
- Common systems: Epic, Cerner, Athenahealth, DrChrono
- FHIR API for standardized data access
- HIPAA-compliant connection required
- Read-only access recommended for AI

## Patient Portal
- Limited to non-PHI information unless HIPAA-compliant setup
- Insurance verification, billing inquiries
- Appointment history (with patient authentication)

## HIPAA Compliance Checklist
- [ ] BAA (Business Associate Agreement) in place
- [ ] Data encrypted at rest and in transit
- [ ] Access logging enabled
- [ ] No PHI in system prompts or knowledge base
- [ ] Patient identity verification before sharing info
- [ ] Data retention policy defined

## Knowledge Base Documents to Collect
- Services offered and descriptions
- Provider bios and specialties
- Insurance accepted list
- Office hours and locations
- Pre-visit preparation instructions
- Post-procedure care instructions
- Billing and payment FAQ
- Patient rights information
