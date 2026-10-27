# Weather Sensing Server

## Prerequisites

Weather Sensing Server is a [Spring Boot](https://spring.io/projects/spring-boot) server written in Java, built with
[Gradle](https://gradle.org/), and backed by [PostgreSQL 18](https://www.postgresql.org/). Containerization with
[Podman](https://podman.io/) is used for deployment and is optional for local development.

| Dependency  | Version |
|-------------|---------|
| JDK         | 25 |
| Spring Boot | 4.1.x |
| Gradle      | 9.8.x (pinned by the Gradle wrapper) |
| PostgreSQL  | 18 |

### Local Development

The Java toolchain uses **Homebrew on macOS** and **[SDKMAN!](https://sdkman.io) on Linux**.

#### macOS (Homebrew)

```bash
# `spring-boot` lives in Spring's tap, not in homebrew-core
brew tap spring-io/tap
brew install spring-boot gradle openjdk@25 postgresql@18
brew services start postgresql@18
```

`openjdk@25` is keg-only — to expose it to the system Java wrappers run:

```bash
sudo ln -sfn /opt/homebrew/opt/openjdk@25/libexec/openjdk.jdk \
  /Library/Java/JavaVirtualMachines/openjdk-25.jdk
```

#### Linux (SDKMAN! for the toolchain)

Install SDKMAN!, then Java 25, the Spring Boot CLI, and (optionally) Gradle:

```bash
curl -s "https://get.sdkman.io" | bash
source "$HOME/.sdkman/bin/sdkman-init.sh"
sdk install java 25.0.5-tem   # or check `sdk list java` for the newest 25.x build
sdk install springboot
sdk install gradle            # optional — the Gradle wrapper pins 9.8.x
```

PostgreSQL 18: **Ubuntu / Debian** (official PGDG repository):

```bash
sudo apt install -y postgresql-common
sudo /usr/share/postgresql-common/pgdg/apt.postgresql.org.sh
sudo apt install postgresql-18
```

**Fedora 43+** (PostgreSQL 18 is the default version):

```bash
sudo dnf install postgresql-server postgresql-contrib
sudo postgresql-setup --initdb && sudo systemctl enable --now postgresql
```

On Fedora ≤ 42, RHEL, or CentOS Stream, use the
[PGDG yum repository](https://www.postgresql.org/download/linux/redhat/) instead.

Verify on either platform:

```bash
java -version   # should print a 25.x build
./gradlew build
```

## Deployment

Containers are managed with Podman.

- **macOS**:
  ```bash
  brew install podman
  podman machine init
  podman machine start
  ```
  Or install the GUI: `brew install --cask podman-desktop`.
- **Ubuntu / Debian**: `sudo apt install podman` (Ubuntu 24.04 ships an older 4.9.x).
- **Fedora 43+**: `sudo dnf install podman` — no `podman machine` setup is needed on Linux.
