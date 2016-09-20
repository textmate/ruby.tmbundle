# rubocop: disable AsciiComments
# rubocop: disable Style/HashSyntax

# -- Imports -------------------------------------------------------------------

require ENV['TM_BUNDLE_SUPPORT'] + '/lib/executable'

require ENV['TM_SUPPORT_PATH'] + '/lib/exit_codes'
require ENV['TM_SUPPORT_PATH'] + '/lib/progress'
require ENV['TM_SUPPORT_PATH'] + '/lib/tm/detach'
require ENV['TM_SUPPORT_PATH'] + '/lib/tm/save_current_document'

# -- Module --------------------------------------------------------------------

# This module allows you to reformat files via RuboCop.
module RuboCop
  class << self
    # This function reformats the current TextMate document using RuboCop.
    #
    # It works both on saved and unsaved files:
    #
    # 1. In the case of an unsaved files this method will stall until RuboCop
    #    fixed the file. While this process takes place the method displays a
    #    progress bar.
    #
    # 2. If the current document is a file saved somewhere on your disk, then
    #    the method will not wait until RuboCop is finished. Instead it will run
    #    RuboCop in the background. This has the advantage, that you can still
    #    work inside TextMate, while RuboCop works on the document.
    #
    # After RuboCop finished reformatting the file, the method will inform you
    # – via a tooltip – about the problems RuboCop found in the *previous*
    # version of the document.
    def reformat
      unsaved_file = true unless ENV['TM_FILEPATH']
      TextMate.save_if_untitled('rb')
      format_file(locate_rubocop, unsaved_file)
    end

    private

    def locate_rubocop
      Dir.chdir(ENV['TM_PROJECT_DIRECTORY'] ||
                File.dirname(ENV['TM_FILEPATH'].to_s))
      begin
        Executable.find('rubocop').join ' '
      rescue Executable::NotFound => error
        return 'rubocop' if File.executable?(`which rubocop`.rstrip)
        TextMate.exit_show_tool_tip(error.message)
      end
    end

    def format_file(rubocop, unsaved_file)
      aha = `which aha`.rstrip
      output_format = aha ? :html : :text
      command = "#{rubocop} -a#{'n' if aha} \"$TM_FILEPATH\"" \
                "#{' | aha' if aha} 2>&1"
      if unsaved_file
        format_unsaved(command, output_format)
      else
        format_saved(command, output_format)
      end
    end

    def format_unsaved(rubocop_command, output_format)
      output, success = TextMate.call_with_progress(
        :title => '🤖 RuboCop', :summary => 'Reformatting File'
      ) do
        [`#{rubocop_command}`, $CHILD_STATUS.success?]
      end
      TextMate.exit_show_tool_tip(output) unless success
      TextMate::UI.tool_tip(output, :format => output_format)
      TextMate.exit_replace_document(File.read(ENV['TM_FILEPATH']))
    end

    def format_saved(rubocop_command, output_format)
      TextMate.detach do
        output = `#{rubocop_command}`
        TextMate::UI.tool_tip(output, :format => output_format)
      end
    end
  end
end
