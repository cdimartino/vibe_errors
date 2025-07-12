# CI/CD Pipeline Documentation

This document describes the CI/CD pipeline for the VibeErrors Rails engine.

## Overview

The VibeErrors project uses GitHub Actions for continuous integration and deployment. The pipeline includes:

- **Multi-version testing** across Ruby 3.1-3.3 and Rails 6.1-7.1
- **Code quality checks** with StandardRB, RuboCop, Reek, and Brakeman
- **Security scanning** with bundle-audit and CodeQL
- **Automated dependency updates** with Dependabot
- **Automated releases** with gem publishing and Docker images

## Workflows

### Main CI Workflow (`.github/workflows/ci.yml`)

Runs on every push and pull request to `main` and `develop` branches.

**Jobs:**
- `test`: Matrix testing across Ruby/Rails versions
- `quality`: Code quality checks (StandardRB, RuboCop, Reek, Brakeman)
- `security`: Security scanning (bundle-audit, Brakeman SARIF)
- `compatibility`: Rails compatibility testing (4.2-7.1)
- `integration`: Full integration testing with sample app
- `publish`: Gem building and publishing (on main branch)

### Release Workflow (`.github/workflows/release.yml`)

Triggers on git tags (`v*`).

**Features:**
- Automatic changelog generation
- Gem building and publishing to RubyGems
- GitHub Release creation
- Docker image building and publishing
- Version validation

### Security Workflows

**CodeQL** (`.github/workflows/codeql.yml`):
- Weekly security scanning
- Ruby and JavaScript analysis
- SARIF results uploaded to GitHub Security tab

**Dependency Review** (`.github/workflows/dependency-review.yml`):
- Runs on pull requests
- Checks for vulnerable dependencies
- License compliance checking

### Maintenance Workflows

**Stale Issues** (`.github/workflows/stale.yml`):
- Daily cleanup of stale issues and PRs
- Configurable timeouts and labels

**Dependabot** (`.github/dependabot.yml`):
- Weekly dependency updates
- Separate configs for engine and sample app
- Automated PR creation

## Local Development

### Running CI Locally

Use the included CI script:

```bash
# Run all checks
./bin/ci

# Run specific checks
./bin/ci test
./bin/ci quality
./bin/ci security

# Fix common issues
./bin/ci fix

# Clean up
./bin/ci clean
```

### Docker Development

```bash
# Start development environment
docker-compose up vibe_errors

# Run tests
docker-compose run test

# Run quality checks
docker-compose run quality
```

## Code Quality Standards

### StandardRB
- Primary code style enforcement
- Configuration: `.standard.yml`
- Auto-fix: `bundle exec standardrb --fix`

### RuboCop
- Additional style rules
- Configuration: `.rubocop.yml`
- Auto-fix: `bundle exec rubocop -A`

### Reek
- Code smell detection
- Configuration: `.reek.yml`
- Report: `bundle exec reek --format json`

### Brakeman
- Security vulnerability scanning
- Configuration: `.brakeman.yml`
- SARIF output for GitHub Security integration

## Test Coverage

- **Minimum coverage**: 95% overall, 80% per file
- **Tools**: SimpleCov with multiple formatters
- **Integration**: CodeClimate for coverage reporting
- **Branch coverage**: Enabled for detailed analysis

## Security

### Bundle Audit
- Dependency vulnerability scanning
- Daily updates in CI
- Fails build on moderate+ vulnerabilities

### Brakeman
- Static application security testing
- SARIF integration with GitHub Security
- Custom configuration for Rails engines

### CodeQL
- Weekly deep security analysis
- Multi-language scanning (Ruby, JavaScript)
- GitHub Security integration

## Secrets Required

For full CI/CD functionality, configure these secrets in GitHub:

- `RUBYGEMS_API_KEY`: For gem publishing
- `DOCKER_HUB_USERNAME`: For Docker image publishing
- `DOCKER_HUB_TOKEN`: For Docker image publishing
- `CC_TEST_REPORTER_ID`: For CodeClimate integration

## Compatibility Matrix

| Ruby Version | Rails 4.2 | Rails 5.0 | Rails 5.1 | Rails 5.2 | Rails 6.0 | Rails 6.1 | Rails 7.0 | Rails 7.1 |
|--------------|-----------|-----------|-----------|-----------|-----------|-----------|-----------|-----------|
| 3.1          | ✅        | ✅        | ✅        | ✅        | ✅        | ✅        | ✅        | ✅        |
| 3.2          | ✅        | ✅        | ✅        | ✅        | ✅        | ✅        | ✅        | ✅        |
| 3.3          | ❌        | ❌        | ❌        | ❌        | ❌        | ❌        | ✅        | ✅        |

## Performance

- **Parallel testing**: Matrix jobs run in parallel
- **Caching**: Bundle cache, Ruby setup cache
- **Optimizations**: Job dependencies, conditional steps
- **Resource limits**: Appropriate timeouts and retries

## Monitoring

- **Build status**: GitHub Actions status badges
- **Coverage**: CodeClimate integration
- **Security**: GitHub Security tab
- **Dependencies**: Dependabot alerts

## Troubleshooting

### Common Issues

1. **Ruby version conflicts**: Check matrix configuration
2. **Bundle install failures**: Update gemspec dependencies
3. **Test failures**: Check database setup and migrations
4. **Security alerts**: Review Brakeman and bundle-audit reports

### Debug Steps

1. Check GitHub Actions logs
2. Run `./bin/ci` locally
3. Review specific tool outputs
4. Check Docker container health

### Getting Help

- Check existing issues and PRs
- Review CI logs and artifacts
- Use issue templates for bug reports
- Contact maintainers for urgent issues

## Contributing

- All PRs must pass CI checks
- Follow code quality standards
- Add tests for new features
- Update documentation as needed
- Use conventional commit messages

## Future Improvements

- [ ] Performance benchmarking
- [ ] Multi-database testing
- [ ] Cross-platform testing (Windows, macOS)
- [ ] Automated security updates
- [ ] Enhanced monitoring and alerting