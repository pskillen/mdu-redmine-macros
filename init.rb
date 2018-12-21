plugin_name = :mdu_redmine_macros

Rails.configuration.to_prepare do
  require_dependency "mdu_redmine_macros/project_field_macro"
  require_dependency "mdu_redmine_macros/project_members_macro"
  require_dependency "mdu_redmine_macros/project_summary_box_macro"
  require_dependency "mdu_redmine_macros/projects_summary_macro"
end

Redmine::Plugin.register plugin_name do
  requires_redmine :version_or_higher => '3.4'
  name 'MDU Redmine Custom Macros'
  author 'Patrick Skillen'
  description 'Wiki macros to support MDU QMS via Redmine.'
  version '0.0.2'
  url 'https://github.com/pskillen/mdu-redmine-macros'
  author_url 'https://github.com/pskillen/mdu-redmine-macros'
end