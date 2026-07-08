# TASK-260708-2gcguc: create-sample-github-remote

## Description
Create a dedicated GitHub repository for the ReluxAnalytics sample app under relux-works and configure the local sample/ directory with that repository as its git remote without touching the root SDK repository remote.

## Scope
Create a public relux-works/relux-analytics-sample GitHub repository and configure sample/ as a nested local git repository with origin pointing to that repository. Do not stage, commit, or push files automatically.

## Acceptance Criteria
- GitHub repository relux-works/relux-analytics-sample exists and is public.
- sample/ is its own local git repository.
- sample/ origin is git@github.com:relux-works/relux-analytics-sample.git.
- Root relux-analytics origin remains git@github.com:relux-works/relux-analytics.git.
- No files are staged or committed automatically.
