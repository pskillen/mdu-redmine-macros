module MDU
  module RedmineMacros
    module ProjectSummaryMacro
      def do_format(project)
        out = ''
        # TODO: Table
        # Code, Name, Tech lead, PM, Project Team, Status Wiki, Charter/PAR, Med Dev/Class
        out << "<tr>\n"
        out << "<td>#{project.name}</td>\n"
        out << '</tr>'

        out
      end
    end

    Redmine::WikiFormatting::Macros.register do
      desc 'Include a summary list of projects with a given status. Example:
  {{projects_summary(Active)}}'
      macro :projects_summary do |obj, args|
        out = ''

        begin
          raise '- no parameters' if args.count.zero?
          raise '- too many parameters' if args.count > 1

          arg = args.shift
          arg.strip!
          filter_status_name = arg

          status_field = CustomField.where(type: 'ProjectCustomField', name: 'Status').first
          raise '- custom field \'Status\' not found' unless status_field

          mdu_prj = Project.find_by_identifier('projects')
          raise '- Project identifier \'projects\' not found' unless mdu_prj


          extend ProjectSummaryMacro
          mdu_prj.hierarchy.each do |prj|
            status = prj.custom_field_value(status_field.id)
            next unless status == filter_status_name

            out << do_format(prj)
          end
        rescue => err_msg
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
