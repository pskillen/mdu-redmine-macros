module MDU
  module RedmineMacros
    Redmine::WikiFormatting::Macros.register do
      desc 'Include a summary box for the specified project. Example:
  {{project_summary_box(P123)}}'
      macro :project_summary_box do |_obj, args|
        out = ''

        begin
          raise '- no parameters' if args.count.zero?
          raise '- too many parameters' if args.count > 1

          arg = args.shift
          arg.strip!
          project_name = arg

          custom_fields = {
              status: CustomField.where(type: 'ProjectCustomField', name: 'Status').first,
              charter_ticket: CustomField.where(type: 'ProjectCustomField', name: 'Charter').first,
              par_ticket: CustomField.where(type: 'ProjectCustomField', name: 'PAR').first,
              med_dev: CustomField.where(type: 'ProjectCustomField', name: 'Medical device').first,
              mdr_class: CustomField.where(type: 'ProjectCustomField', name: 'MDR Class').first,
              mdd_class: CustomField.where(type: 'ProjectCustomField', name: 'MDD Class').first,
              resource_priority: CustomField.where(type: 'ProjectCustomField', name: 'Resource priority').first,
              clinical_sponsor: CustomField.where(type: 'ProjectCustomField', name: 'Clinical sponsor').first,
              external_partners: CustomField.where(type: 'ProjectCustomField', name: 'External partners').first,
          }

          project = Project.find_by_identifier(project_name)
          project ||= Project.find_by_name(project_name)
          raise "- Project '#{project_name}' not found" unless project

          roles = project.users_by_role

          _pm_role, pm_users = roles.select { |r| r.name == 'Project Lead' }.first
          _tl_role, tl_users = roles.select { |r| r.name == 'Tech Lead' }.first
          _team_role, team_users = roles.select { |r| r.name == 'Project Team' }.first

          status = custom_fields[:status] ? project.custom_field_value(custom_fields[:status].id) : '(not found)'
          resource_priority = custom_fields[:resource_priority] ? project.custom_field_value(custom_fields[:resource_priority].id) : '(not found)'
          clinical_sponsor = custom_fields[:clinical_sponsor] ? project.custom_field_value(custom_fields[:clinical_sponsor].id) : nil
          external_partners = custom_fields[:external_partners] ? project.custom_field_value(custom_fields[:external_partners].id) : nil

          status_wiki = Wiki.find_page('Project_status', project: project)
          status_wiki ||= Wiki.find_page('Project_Status', project: project)

          med_dev = custom_fields[:med_dev] ? project.custom_field_value(custom_fields[:med_dev].id) : '(not found)'
          med_dev = (med_dev == '1')

          mdr_class = custom_fields[:mdr_class] ? project.custom_field_value(custom_fields[:mdr_class].id) : '(not found)'
          mdd_class = custom_fields[:mdd_class] ? project.custom_field_value(custom_fields[:mdd_class].id) : '(not found)'

          charter_ticket = custom_fields[:charter_ticket] ? project.custom_field_value(custom_fields[:charter_ticket].id) : nil
          charter_ticket = Issue.find_by_id(charter_ticket) if charter_ticket
          charter_ticket = charter_ticket ? "<a href=\"/issues/#{charter_ticket.id}\">##{charter_ticket.id}</a>" : '(not found)'

          par_ticket = custom_fields[:par_ticket] ? project.custom_field_value(custom_fields[:par_ticket].id) : nil
          par_ticket = Issue.find_by_id(par_ticket) if par_ticket
          par_ticket = par_ticket ? "<a href=\"/issues/#{par_ticket.id}\">##{par_ticket.id}</a>" : '(not found)'

          extend ProjectMembersMacro

          out << "<table>\n"

          out << "<tr>\n"
          out << "<th>Status</th>\n"
          out << "<td>#{status}</td>\n"
          out << "<th>Resource Priority</th>\n"
          out << "<td>#{resource_priority}</td>\n"
          out << "<th>Updates</th>\n"
          out << "<a href=\"/projects/#{project.identifier}/wiki/#{status_wiki.title}\">Status</a>" if status_wiki
          out << '(not found)' unless status_wiki
          out << '</tr>'

          out << "<tr>\n"
          out << "<th>Members</th>\n"
          out << '<td colspan="3">'
          out << 'TL: ' << format_users(tl_users, 'csv') if tl_users
          out << 'PM: ' << format_users(pm_users, 'csv') if pm_users
          out << 'Team: ' << format_users(team_users, 'csv') if team_users
          out << '</td>'
          out << '</tr>'

          if clinical_sponsor
            out << "<tr>\n"
            out << "<th>Clinical sponsor</th>\n"
            out << '<td colspan="3">' << clinical_sponsor << '</td>'
            out << '</tr>'
          end

          if external_partners
            out << "<tr>\n"
            out << "<th>External partners</th>\n"
            out << '<td colspan="3">' << external_partners << '</td>'
            out << '</tr>'
          end

          out << "<tr>\n"
          out << "<th>PAR</th>\n"
          out << "<td>#{par_ticket}</td>\n"
          out << "<th>Charter</th>\n"
          out << "<td>#{charter_ticket}</td>\n"
          out << "<th>Medical Device</th>\n"
          out << if med_dev
                   "<td>MDD #{mdd_class} / MDR #{mdr_class}</td>\n"
                 else
                   "<td>No</td>\n"
                 end
          out << '</tr>'

          out << "</tbody>\n"

          out << '</table>'

        rescue StandardError => err_msg
          raise <<-TEXT.html_safe
  Parameter error: #{err_msg}<br>
  Usage: {{projects_summary(status)}}
          TEXT
        end

        out.html_safe # return value
      end
    end
  end
end
