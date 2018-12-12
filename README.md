MDU Custom Macros for Redmine
=============================

## Installation

**NB**: The preferred method of installation is via Git

### By Git

1. Clone git repo to Redmine plugins directory, e.g.
   ```bash
   cd /opt/redmine/plugins/
   git clone git@github.com:pskillen/mdu-redmine-macros.git
   ```
2. Restart Redmine
3. Plugin should be available in Redmine -> Administration -> Plugins

### By file copy

1. Copy `init.rb` and `lib/` to redmine plugins directory on server
   e.g. `/opt/redmine/plugins/mdu-redmine-macros/`
2. Restart Redmine
3. Plugin should be available in Redmine -> Administration -> Plugins