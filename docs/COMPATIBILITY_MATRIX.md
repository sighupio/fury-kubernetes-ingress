# Compatibility Matrix

| Module Version / Kubernetes Version |       1.14.X       |       1.15.X       |       1.16.X       |       1.17.X       |       1.18.X       |       1.19.X       |       1.20.X       |       1.21.X       |       1.22.X       | 1.23.X            | 1.24.X            |
| ----------------------------------- | :----------------: | :----------------: | :----------------: | :----------------: | :----------------: | :----------------: | :----------------: | :----------------: | :----------------: | ----------------- | ----------------- |
| v1.1.0                              |                    |                    |                    |                    |                    |                    |                    |                    |                    |                   |                   |
| v1.2.0                              | :white_check_mark: | :white_check_mark: | :white_check_mark: |                    |                    |                    |                    |                    |                    |                   |                   |
| v1.3.0                              | :white_check_mark: | :white_check_mark: | :white_check_mark: |                    |                    |                    |                    |                    |                    |                   |                   |
| v1.4.0                              | :white_check_mark: | :white_check_mark: | :white_check_mark: |                    |                    |                    |                    |                    |                    |                   |                   |
| v1.5.0                              | :white_check_mark: | :white_check_mark: | :white_check_mark: |                    |                    |                    |                    |                    |                    |                   |                   |
| v1.6.0                              | :white_check_mark: | :white_check_mark: | :white_check_mark: |                    |                    |                    |                    |                    |                    |                   |                   |
| v1.6.1                              | :white_check_mark: | :white_check_mark: | :white_check_mark: |                    |                    |                    |                    |                    |                    |                   |                   |
| v1.7.0                              |                    |                    | :white_check_mark: | :white_check_mark: | :white_check_mark: |                    |                    |                    |                    |                   |                   |
| v1.8.0                              |                    |                    | :white_check_mark: | :white_check_mark: | :white_check_mark: |     :warning:      |                    |                    |                    |                   |                   |
| v1.8.1                              |                    |                    | :white_check_mark: | :white_check_mark: | :white_check_mark: |     :warning:      |                    |                    |                    |                   |                   |
| v1.8.2                              |                    |                    | :white_check_mark: | :white_check_mark: | :white_check_mark: |     :warning:      |                    |                    |                    |                   |                   |
| v1.9.0                              |                    |                    |                    |     :warning:      |     :warning:      |     :warning:      |     :warning:      |     :warning:      |                    |                   |                   |
| v1.9.1                              |                    |                    |                    | :white_check_mark: | :white_check_mark: | :white_check_mark: |     :warning:      |     :warning:      |                    |                   |                   |
| v1.10.0                             |                    |                    |                    |                    | :white_check_mark: | :white_check_mark: | :white_check_mark: |     :warning:      |                    |                   |                   |
| v1.11.0                             |                    |                    |                    |                    |                    | :white_check_mark: | :white_check_mark: | :white_check_mark: |     :warning:      |                   |                   |
| v1.11.1                             |                    |                    |                    |                    |                    | :white_check_mark: | :white_check_mark: | :white_check_mark: |     :warning:      |                   |                   |
| v1.11.2                             |                    |                    |                    |                    |                    | :white_check_mark: | :white_check_mark: | :white_check_mark: |     :warning:      |                   |                   |
| v1.12.0                             |                    |                    |                    |                    |                    |                    |        :x:         |        :x:         |        :x:         | :x:               |                   |
| v1.12.1                             |                    |                    |                    |                    |                    |                    |        :x:         |        :x:         |        :x:         | :x:               |                   |
| v1.12.2                             |                    |                    |                    |                    |                    |                    | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark |                   |
| v1.13.0                             |                    |                    |                    |                    |                    |                    | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark | :white_check_mark |

:white_check_mark: Compatible

:warning: Has issues

:x: Incompatible

## Warning

- :warning: : module version: `v1.9.0` and Kubernetes Version: `1.20.x`. It works as expected. Marked as a warning
because it is not officially supported by [SIGHUP](https://sighup.io).
- :warning: : module version: `v1.9.0`. Has some problems exposing metrics and with the log recollection.
Move to v1.9.1 instead. [Follow the migration path.](docs/releases/v1.9.1.md)
- :warning: : module version: `v1.10.0` and Kubernetes Version: `1.21.x`. It works as expected. Marked as a warning
because it is not officially supported by [SIGHUP](https://sighup.io).
- :warning: : module version: `v1.11.X` and Kubernetes Version: `1.22.x`. It works as expected. Marked as a warning because it is not officially supported by [SIGHUP](https://sighup.io).
- :warning: : module version: `v1.12.X` and Kubernetes Version: `1.23.x`. It works as expected. Marked as a warning because it is not officially supported by [SIGHUP](https://sighup.io).
- :x:: module version: `v1.12.0` has a known bug breaking upgrades. Please do not use.
- :x:: module version: `v1.12.1` has a known bug breaking upgrades. Please do not use.
