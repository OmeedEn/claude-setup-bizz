# SaaS Integration Notes

## GitHub
- Personal access token or GitHub App
- Scopes: repo, issues, pull requests
- Webhook for PR notifications (optional)

## Jira / Linear
- API token required
- Project keys and board IDs
- Custom fields for triage classification

## Slack
- Bot token with appropriate channel permissions
- Channels: #dev, #bugs, #deployments (customize per client)
- Can send notifications and respond to mentions

## Database
- Read-only connection recommended for safety
- Use for debugging data issues
- Never run write queries without explicit approval

## Common Customizations
- CI/CD pipeline integration (GitHub Actions, CircleCI)
- Monitoring alerts (Datadog, Sentry)
- On-call rotation integration (PagerDuty)
- Custom code analysis rules

## Knowledge Base Documents to Collect
- Architecture documentation
- API documentation
- Coding standards / style guide
- Deployment procedures / runbooks
- Team structure and responsibilities
- Sprint/project management processes
- Incident response procedures
