module MDU
  module RedmineMacros
    module ProjectMembersMacro
      def do_format(users, format)
        if format == 'ul'
          out = "<ul>\n"
          users.each { |u| out << "<li>#{link_to_user(u)}</li>\n" }
          out << '</ul>'
          return out
        end

        if format == 'ol'
          out = "<ol>\n"
          users.each { |u| out << "<li>#{link_to_user(u)}</li>\n" }
          out << '</ol>'
          return out
        end

        return users.map { |u| link_to_user (u) }.join(' ') if format == 'ssv'

        # default is csv
        users.map { |u| link_to_user (u) }.join(', ')
      end
    end

    Redmine::WikiFormatting::Macros.register do
      desc 'Include a list of project members. Example:
  {{project_members(Tech lead)}}
or for a specific project:
  {{project_members(projectname:Tech lead)}}

To specify formatting:
  {{project_members(projectname:Tech lead|format)}}
Format may be one of: csv, ssv, ol, ul'
      macro :project_members do |obj, args|
        out = ''

        begin
          raise '- no parameters' if args.count.zero?
          raise '- too many parameters' if args.count > 1

          arg = args.shift
          arg.strip!

          regex = /^((?<project>[A-Z][A-Z\d]+)(:))?(?<role>[A-Z][A-Z\d ]+)((\|)(?<format>[A-Z]+))?$/i
          match = arg.match(regex)

          if match[:project]
            prj = Project.find_by_identifier(match[:project])
            prj ||= Project.find_by_name(match[:project])
            raise "- project:#{match[:project]} is not found." unless prj
          else
            prj = obj.project
          end

          role_name = match[:role]
          format = match[:format] || 'csv'

          user_roles = prj.users_by_role
          raise "- role: #{role_name} is not found in project #{prj.name}" unless user_roles.keys.any? { |r| r.name == role_name }

          extend ProjectMembersMacro
          user_roles.each do |key, users|
            next unless key.name == role_name

            out << do_format(users, format)
          end
        rescue => err_msg
          raise <<-TEXT.html_safe
  Parameter error: #{err_msg}<br>
  Usage: {{project_members([project_name:]role name)}}
          TEXT
        end

        out.html_safe # return value
      end
    end
  end
end
