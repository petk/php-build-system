# Contributing guide

Contributions are most welcome. Below is described procedure for contributing to
this repository.

* Fork this repository over GitHub.
* Create a separate branch, for instance `patch-1` so you will not need to
  rebase your fork if your main branch is merged.

  ```sh
  git clone git@github.com:your_username/php-build-system
  cd php-build-system
  git checkout -b patch-1
  ```
* Make changes, commit them and push to your fork

  ```sh
  git add .
  git commit -m "Fix bug"
  git push origin patch-1
  ```
* Open a pull request

## Style guide

* This repository uses [Markdown](https://daringfireball.net/projects/markdown/)
  syntax and follows
  [cirosantilli/markdown-style-guide](http://www.cirosantilli.com/markdown-style-guide/)
  style guide.

## GitHub issues labels

Labels are used to organize issues and pull requests into manageable categories.
The following labels are used:

* **bug** - Attached when bug is reported.
* **duplicate** - Attached when the same issue or pull request already exists.
* **enhancement** - Attached when creating a new feature.
* **invalid** - Attached when the issue or pull request does not correspond with
  scope of the repository or because of some inconsistency.
* **question** - Attached for questions or discussions.
* **wontfix** - Attached when decided that issue will not be fixed.

## Repository directory structure

This is a monolithic repository consisting of the following files:

```sh
📂 <php-build-system>
└─📂 .github        # GitHub directory
  └─📂 workflows    # Workflows for GitHub actions
    └─📂 ...
└─📂 bin            # Helper development scripts, not part of the build system
  └─📂 ...
└─📂 cmake          # CMake-based PHP build system
  └─📂 ...
└─📂 docs           # Repository documentation
  └─📂 ...
└─📂 patches        # Patches needed for using CMake with PHP
  └─📂 ...
└─📂 php-*          # Downloaded PHP sources
  └─📂 ...
├─📄 .editorconfig  # EditorConfig https://editorconfig.org
└─ ...
```
