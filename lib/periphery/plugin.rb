# frozen_string_literal: true

module Danger
  # Checks a Periphery report to match files with unused code.
  #
  # @example See if your active files contain unused code
  #
  #          periphery.report("report.json")
  #
  # @see  RestlessThinker/danger-periphery
  # @tags periphery
  #
  class DangerPeriphery < Plugin
    def report(report_file, src_root: nil)
      files = periphery(report_file)
      return if files.empty?

      markdown offenses_message(files, src_root)
    end

    private

    def periphery(report_file)
      require 'json'

      periphery_report_file = File.read(report_file)
      periphery_report_json = JSON.parse(periphery_report_file)
      active_files = (git.modified_files + git.added_files)

      periphery_files = Hash.new { |h, k| h[k] = [] }

      periphery_report_json.each do |entry|
        filename = File.basename(entry["location"].gsub(/:.*/, ""))
        periphery_files[filename] << entry
      end

      final_warnings = Hash.new 

      active_files.any? do |filename|
        basename = File.basename(filename)
        if periphery_files.key?(basename)
          final_warnings[basename] = periphery_files[basename]
        end
      end

      return final_warnings
    end

    # Builds the message
    def offenses_message(offending_files, src_root)
      require 'terminal-table'

      output = offending_files.map { |k,v| v }.flatten

      message = "### Periphery Unused Code\n\n"
      table = Terminal::Table.new(
        headings: %w(Hints File Name Kind Accessibility Modifiers Module),
        style: { border_i: '|' },
        rows: output.map do |file|
          location = file['location']
          if !src_root.empty?
            paths = file['location'].split(src_root.to_s, 2)
            location = paths[1] if paths.size > 1
          end
          [file['hints'], location, file['name'], file['kind'], file['accessibility'], file['modifiers'], file['modules']]
        end
      ).to_s
      message + table.split("\n")[1..-2].join("\n")
    end
  end
end
