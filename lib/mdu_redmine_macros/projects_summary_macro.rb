module MDU
  module RedmineMacros
    module ProjectSummaryMacro

      def summary_table_header_row
        out = ''
        # Code, Name, Tech lead/PM, Project Team, Status Wiki, Charter/PAR, Med Dev/Class
        out << "<tr>\n"
        out << "<th>Code</th>\n"
        out << "<th>Name</th>\n"
        out << "<th>Tech Lead / PM</th>\n"
        out << "<th>Team</th>\n"
        out << "<th>Resource Priority</th>\n"
        out << "<th>Status Wiki</th>\n"
        out << "<th>Charter/PAR</th>\n"
        out << "<th>Med Dev/Class</th>\n"
        out << '</tr>'
        out
      end

      def format_project_summary(project, custom_fields, _fmt = 'tr')
        roles = project.users_by_role

        _pm_role, pm_users = roles.select { |r| r.name == 'Project Lead' }.first
        _tl_role, tl_users = roles.select { |r| r.name == 'Tech Lead' }.first
        _team_role, team_users = roles.select { |r| r.name == 'Project Team' }.first
        status_wiki = Wiki.find_page('Project_status', project: project)
        status_wiki ||= Wiki.find_page('Project_Status', project: project)

        code = custom_fields[:code] ? project.custom_field_value(custom_fields[:code].id) : nil
        resource_priority = custom_fields[:resource_priority] ? project.custom_field_value(custom_fields[:resource_priority].id) : nil

        med_dev = custom_fields[:med_dev] ? project.custom_field_value(custom_fields[:med_dev].id) : nil
        med_dev = 'No' if med_dev == '0'
        med_dev = 'Yes' if med_dev == '1'

        mdr_class = custom_fields[:mdr_class] ? project.custom_field_value(custom_fields[:mdr_class].id) : nil
        mdd_class = custom_fields[:mdd_class] ? project.custom_field_value(custom_fields[:mdd_class].id) : nil

        charter_ticket = custom_fields[:charter_ticket] ? project.custom_field_value(custom_fields[:charter_ticket].id) : nil
        charter_ticket = Issue.find_by_id(charter_ticket) if charter_ticket
        charter_ticket = charter_ticket ? "<a href=\"/issues/#{charter_ticket.id}\">##{charter_ticket.id}</a>" : '(not found)'

        par_ticket = custom_fields[:par_ticket] ? project.custom_field_value(custom_fields[:par_ticket].id) : nil
        par_ticket = Issue.find_by_id(par_ticket) if par_ticket
        par_ticket = par_ticket ? "<a href=\"/issues/#{par_ticket.id}\">##{par_ticket.id}</a>" : '(not found)'

        out = ''
        # Code, Name, Tech lead/PM, Project Team, Status Wiki, Charter/PAR, Med Dev/Class
        out << "<tr>\n"

        # Code
        out << "<td>#{code}</td>\n"

        # Name
        out << "<td>#{link_to_project(project)}</td>\n"

        # TL/PM
        out << '<td><strong>TL:</strong> '
        out << tl_users.map { |u| link_to_user(u) }.join(', ') if tl_users
        out << "<br>\n"
        out << '<strong>PM:</strong> '
        out << pm_users.map { |u| link_to_user(u) }.join(', ') if pm_users
        out << "</td>\n"

        # Team
        out << '<td>'
        if team_users
          extend ProjectMembersMacro
          out << format_users(team_users, 'br')
        end
        out << "</td>\n"

        # Resource priority
        out << "<td>#{resource_priority}</td>\n"

        # Status Wiki
        #
        out << '<td>'
        out << "<a href=\"/projects/#{project.identifier}/wiki/#{status_wiki.title}\">Status</a>" if status_wiki
        out << '(not found)' unless status_wiki
        out << "</td>\n"

        # Charter/PAR
        out << "<td><strong>Charter:</strong> #{charter_ticket}<br>\n"
        out << "<strong>PAR:</strong> #{par_ticket}</td>\n"

        # Med Dev / MDR Class
        out << "<td><strong>Med device:</strong> #{med_dev}\n"
        if med_dev == 'Yes'
          out << "<br><strong>Class (MDR):</strong> #{mdr_class}\n"
          out << "<br><strong>Class (MDD):</strong> #{mdd_class}\n"
        end
        out << "</td>\n"

        out << '</tr>'

        out
      end
    end

    Redmine::WikiFormatting::Macros.register do
      desc 'Include a summary list of projects with a given status. Example:
  {{projects_summary(Active)}}'
      macro :projects_summary do |_obj, args|
        out = ''

        begin
          raise '- no parameters' if args.count.zero?
          raise '- too many parameters' if args.count > 1

          arg = args.shift
          arg.strip!
          filter_status_name = arg
          fmt = 'table'

          fields = {
              status: CustomField.where(type: 'ProjectCustomField', name: 'Status').first,
              code: CustomField.where(type: 'ProjectCustomField', name: 'Code').first,
              charter_ticket: CustomField.where(type: 'ProjectCustomField', name: 'Charter').first,
              par_ticket: CustomField.where(type: 'ProjectCustomField', name: 'PAR').first,
              med_dev: CustomField.where(type: 'ProjectCustomField', name: 'Medical device').first,
              mdr_class: CustomField.where(type: 'ProjectCustomField', name: 'MDR Class').first,
              mdd_class: CustomField.where(type: 'ProjectCustomField', name: 'MDD Class').first,
              resource_priority: CustomField.where(type: 'ProjectCustomField', name: 'Resource priority').first
          }
          raise '- custom field \'Status\' not found' unless fields[:status]

          mdu_prj = Project.find_by_identifier('projects')
          raise '- Project identifier \'projects\' not found' unless mdu_prj

          extend ProjectSummaryMacro

          if fmt == 'table'
            out << "<table>\n"
            out << "<thead>\n"
            out << summary_table_header_row
            out << "</thead>\n"
            out << "</tbody>\n"
          end

          mdu_prj.descendants.each do |prj|
            if filter_status_name
              status = prj.custom_field_value(fields[:status].id)
              next unless status == filter_status_name
            end

            out << format_project_summary(prj, fields, 'tr')
          end

          if fmt == 'table'
            out << '</tbody>'
            out << '</table>'
          end

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
