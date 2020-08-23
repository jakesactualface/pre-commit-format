# Overview

This repository exists as a way of integrating the google-java-format jar as a git hook during the pre-commit phase. This would assist developers in ensuring that their code is always properly formatted before being committed to their branch.

## Usage
After installation, the hook can be enabled for any repository by setting the `hooks.googleformatflag` git config variable to one of the following values:
- `1`: If any formatting errors exist, the commit will be aborted and the names of the offending files will be output as an error message.
- `2`: The formatter will be executed for all staged Java files, and any changes made by the formatter will be added to the content of the commit.
- Unset/Any other value: The formatter will not be executed.

### Example:
> git config hooks.googleformatflag 1

This variable can also be set at levels higher than a single repository. See the [git config description](https://git-scm.com/docs/git-config#_description) for more information on variable scoping.

## Installation Steps

### Download google-java-format
The following steps are necessary to use this script correctly:
- Navigate to the [google-java-format repository](https://github.com/google/google-java-format) and download the latest release .jar file
- Save the file in a safe location on your machine
- Create a wrapper script named `google-java-format` in some permanent location for executing the jar. An example is shown below:
  ```bash
  #!/bin/sh
  java -jar "C:/path/to/google-java-format/google-java-format-1.8-all-deps.jar" "$@"
  ```
  - Note: The `google-java-format` file we are creating should not have a file extension. This is an assumption made by the `pre-commit-format.sh` script, but you can also replace usages of `google-java-format` with your own executable name.

### Add Directory to Path
The "permanent location" containing the `google-java-format` wrapper script above needs to be added to the PATH variable:
- Open your machine's System Properties
- Click `Environment Variables`
- Add the full path of the directory to your preferred `PATH` variable

### Create a Pre-Commit Hook File
Since this hook's internal logic is configurable based on a `git config` parameter, the recommended approach is to establish this hook as a template to ensure any new repositories will be governed under its behavior:
- Navigate to the `git-core/templates/hooks` directory of your git installation
  - For `Git For Windows` users, this is probably at `C:\Program Files\mingw64\share\git-core\templates\hooks`
- Create a file in this directory named `pre-commit` with executable permissions
  - The [pre-commit-format.sh](pre-commit-format.sh) file can be renamed and used as the new `pre-commit` file
  - If you do not wish to store all of your pre-commit hooks within the same file, you can also use this new `pre-commit` file as a wrapper to execute various scripts. The [pre-commit.example](pre-commit.example) file was created as an example of this.

### Enable Hooks Globally
Assuming the pre-commit file was added as a template in the previous step, we can enable that template globally for our git installation:
- Using the same `git-core/templates/hooks` directory as above, execute the following command in your git terminal: `git config --global core.hooksPath 'c/Program Files/Git/mingw64/share/git-core/templates/hooks'`
  - This will enable the formatter hook on all Java files within any git repository on your system. If this seems too intrusive for you, see [the git template documentation](http://schacon.github.io/git/git-init.html#_template_directory) for additional levels of granularity on enabling this hook.

## Uninstallation Steps
- Execute the following command in your git terminal to remove the global template setting: `git config --global --unset core.hooksPath`
- Delete the `pre-commit` file in your `git-core/templates/hooks` directory
- Remove the PATH entry for the `google-java-format` wrapper script