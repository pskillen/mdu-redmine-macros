module MDU
  module RedmineMacros
    Redmine::WikiFormatting::Macros.register do
      desc 'Include a project custom field. Example:\n\n
  !{{project_field(Status)}}\n\n
or to include a field of a specific project:\n\n
  !{{project_field(projectname:Status)}}'
      macro :project_field do |obj, args|
        out = ''

        begin
          raise '- no parameters' if args.count.zero?
          raise '- too many parameters' if args.count > 1

          arg = args.shift
          arg.strip!

          if arg =~ /^([A-Za-z][A-Za-z0-9]+)(:)([A-Za-z][A-Za-z0-9 ]+)$/
            prj = Project.find_by_identifier($1)
            prj ||= Project.find_by_name($1)
            raise "- project:#{$1} is not found." unless prj

            name = $3
          else
            prj = obj.project
            name = arg
          end

          field = CustomField.where(type: 'ProjectCustomField', name: name).first
          raise "- custom field: #{name} is not found" unless field

          value = prj.custom_field_value(field.id)
          raise "- custom field:#{name} is not found in prj:#{prj.to_s}" unless value

          out << value
        rescue => err_msg
          raise <<-TEXT.html_safe
Parameter error: #{err_msg}<br>
Usage: {{project_field([project_name:]field name)}}
          TEXT
        end

        out.html_safe
      end
    end
  end
end
