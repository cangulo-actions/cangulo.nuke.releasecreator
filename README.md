- [What this GH action does ?](#what-this-gh-action-does-)
- [Examples](#examples)
  - [Create a Release - branch without required checks](#create-a-release---branch-without-required-checks)
  - [Create a Release - branch with required checks](#create-a-release---branch-with-required-checks)
  - [Calculate Next Release Number](#calculate-next-release-number)
- [Requirements](#requirements)
  - [Definitions](#definitions)
    - [Releases types:](#releases-types)
    - [Changelog:](#changelog)
- [Notes](#notes)
- [Solution repo](#solution-repo)


# What this GH action does ?

* Update your changelog with the commit messages from the merged PR
* Update the current version in the versionTracker.json file
* Optionally, update the version in your .csproj files
* Optionally, calculate the next release version

# Examples

## Create a Release - branch without required checks

if your branch doesn't have protection or required checks you can use the next example:

```yml
name: Release New Version

on:
  pull_request:
    types:
      - closed
    branches:
      - main

jobs:
  release-new-version:
    name: Releasing new version
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Creating Release
        uses: cangulo-actions/cangulo.nuke.releasecreator@main
        with:
          releaseSettingsPath: ./cicd/releaseSettings.json
          token: ${{ secrets.GITHUB_TOKEN }}
```

## Create a Release - branch with required checks

However, if your branch **does have protection or required checks** you should check it out using a PAT (personal access token) as the next example:

```yml
name: Release New Version

on:
  pull_request:
    types:
      - closed
    branches:
      - main

jobs:
  release-new-version:
    name: Releasing new version
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
        with:
          token: ${{ secrets.PERSONAL_PAT }}        # <-- WORKAROUND
      - name: Creaing Release
        uses: cangulo-actions/cangulo.nuke.releasecreator@main
        with:
          releaseSettingsPath: ./cicd/releaseSettings.json
          token: ${{ secrets.GITHUB_TOKEN }}
```

## Calculate Next Release Number

```yml
name: Release New Version

on:
  pull_request:
    types:
      - closed
    branches:
      - main

jobs:
  release-new-version:
    name: Releasing new version
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Calculating Next Release Version
        uses: cangulo-actions/cangulo.nuke.releasecreator@release/v0.0.1
        with:
          releaseSettingsPath: ./cicd/releaseSettings.json
          token: ${{ secrets.GITHUB_TOKEN }}
          onlyCalculateReleaseNumber: true
```

Please note the last parameter `onlyCalculateReleaseNumber`.

# Requirements

* This GH Actions aims to create a new GH Release when a PR is merged. Please add the next triggers in your GH schema:

```yml
on:
  pull_request:
    types:
      - closed
    branches:
      - main
```

* Define the current version in a json file following the next model:

```json
{
  "currentVersion": "0.0.0"
}
```

* Define the settings for the release in a json file following the next model:

```json
{
    "VersionTrackerFilePath": "./cicd/versionTracker.json",
    "conventionalCommitsAllowed": [
        {
            "commitType": "fix",
            "releaseType": "patch"
        },
        {
            "commitType": "patch",
            "releaseType": "patch"
        },
        {
            "commitType": "refactor",
            "releaseType": "patch"
        },
        {
            "commitType": "feat",
            "releaseType": "patch"
        },
        {
            "commitType": "major",
            "releaseType": "major"
        },
        {
            "commitType": "break",
            "releaseType": "major"
        },
        {
            "commitType": "docs"
        },
        {
            "commitType": "ci"
        }
    ],
    "changelogSettings": {
        "changelogPath": "./CHANGELOG.md",
        "commitsMode": "conventionalCommits",
        "conventionalCommitsSettings": {
            "types": [
                "fix",
                "patch",
                "refactor",
                "feat",
                "major",
                "break",
                "docs"
            ]
        }
    },
    "gitPushReleaseFilesSettings": {
        "email": "cangulomas@outlook.com",
        "name": "cangulo.nuke.releasecreator"
    }
}
```

| Property                      | Description                                                                                          |
| ----------------------------- | ---------------------------------------------------------------------------------------------------- |
| `VersionTrackerFilePath     ` | json file where the current version is                                                               |
| `conventionalCommitsAllowed ` | List of conventional commits and the release type associated are defined                             |
| `changelogSettings          ` | Settings for the changelog. Please note the commit types here the ones to be listed in the changelog |
| `gitPushReleaseFilesSettings` | git settings for the the commits done from the pipeline                                              |

## Definitions

### Releases types:

| Types   | Version Increase format | Description                                                  |
| ------- | ----------------------- | ------------------------------------------------------------ |
| `patch` | x.y.(`z+1`              | A fix or minor change that does not add features is included |
| `minor` | x.(`y+1`).0             | A new feature is added                                       |
| `major` | (`x+1`).0.0             | A breaking change is included.                               |

### Changelog:

Markdown file where all the changes per version are listed. Next is an example for the version v0.0.1

```markdown
# v0.0.1                        <- `title`
2021-10-24                      <- `date`

fix:                            <- `commit type`
* created initial version       <- `commit message`

```

Please note that only the **commits which follows the types** defined in `changelogSettings.conventionalCommitsSettings.types` will be listed in the changes.

# Notes

* Only use this GH action with a PR event. This is because solution depends on the PR number provided in the `${{ github.event.number }}` parameter. 

# Solution repo
The source code is in the next repo:

https://github.com/cangulo/cangulo.nuke.prcommitsvalidations